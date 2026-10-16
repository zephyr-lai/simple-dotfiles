#!/usr/bin/env python3
"""把终端画面渲染成 PNG,供 README 展示配置效果。

纯 PIL,不依赖 termshot / asciinema / 浏览器之类的截图工具。手动运行:

    python3 tools/gen-screenshots.py

产物写到 docs/images/,由 README.md 用相对路径引用。

画面内容是从真实的 .bashrc / .vimrc / .tmux.conf 跑出来的,不是手写的假字,
所以改了配置重跑一次就能同步,不会变成没人敢动的死图。

依赖:Pillow、DejaVu Sans Mono(正文)、NotoColorEmoji(⚡)、tmux(取 vim/tmux 画面)。

配置和插件都随仓库分发,要用到时一律软链仓库自带的那份进假 HOME,所以不依赖
本机的部署状态 —— 刚 clone 下来、还没跑 install.sh 也能拍出一模一样的图。
"""

import os
import re
import shutil
import subprocess
import tempfile
import time
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

REPO = Path(__file__).resolve().parent.parent
OUT_DIR = REPO / "docs" / "images"

# 等宽字体:渲染靠「字符数 × 步进宽度」定位,所以必须是等宽的
FONT_REGULAR = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
FONT_BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf"

FONT_SIZE = 17
LINE_HEIGHT = 26
PAD_X = 22
PAD_Y = 18
TITLE_H = 34          # 顶部标题栏高度,给三个窗口圆点留位置
RADIUS = 10           # 窗口圆角

# --- Catppuccin Mocha:和 tmux 状态栏用的是同一套色,整份 README 观感统一 ---
BG = "#1e1e2e"        # 终端底色
FG = "#cdd6f4"        # 默认前景
TITLE_BG = "#181825"  # 标题栏底色
# ANSI 0-15。下标即 SGR 色号
ANSI = [
    "#45475a", "#f38ba8", "#a6e3a1", "#f9e2af",
    "#89b4fa", "#f5c2e7", "#94e2d5", "#bac2de",
    "#585b70", "#f38ba8", "#a6e3a1", "#f9e2af",
    "#89b4fa", "#f5c2e7", "#94e2d5", "#a6adc8",
]

SGR = re.compile(r"\033\[([0-9;]*)m")

# 彩色 emoji:终端里的 ⚡ 是 NotoColorEmoji 画的金色图标,不吃 ANSI 颜色。
# 只认 ⚡ 和整个现代 emoji 区块,别写成 ☀-➿ 那种大范围 ——
# 里头夹着 ✓ → 之类终端按一格算的符号,误判会让整行向右错位。
EMOJI_FONT = "/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf"
EMOJI_SIZE = 20       # emoji 占两格,这个尺寸约等于两格宽
EMOJI_RE = re.compile("[⚡\U0001f300-\U0001faff]")


def xterm256(n):
    """xterm 256 色号 -> #rrggbb(vim 的 retrobox 配色大量用 38;5;N)。"""
    if n < 16:
        return ANSI[n]
    if n < 232:
        n -= 16
        step = (0, 95, 135, 175, 215, 255)
        return "#%02x%02x%02x" % (step[n // 36], step[n // 6 % 6], step[n % 6])
    v = 8 + 10 * (n - 232)
    return "#%02x%02x%02x" % (v, v, v)


def ext_color(ps, i):
    """解析 38/48 后面的扩展颜色,返回 (颜色, 消耗掉的参数个数)。"""
    if ps[i + 1:i + 2] == [5]:
        return xterm256(ps[i + 2]), 3
    if ps[i + 1:i + 2] == [2]:
        return "#%02x%02x%02x" % tuple(ps[i + 2:i + 5]), 5
    return None, 1


def parse_ansi(line):
    """把一行带 ANSI 转义的文字拆成 [(文本, 前景, 背景, 粗体), ...]。

    只认 SGR(颜色和粗体),光标移动/清屏之类的序列直接丢弃 —— 本脚本处理的
    已经是排版好的成品文本,不需要模拟终端行为。背景色必须支持,否则
    lightline 状态栏和 tmux 状态栏会渲染成一片透明。
    """
    runs, fg, bg, bold, pos = [], None, None, False, 0
    for m in SGR.finditer(line):
        if m.start() > pos:
            runs.append((line[pos:m.start()], fg, bg, bold))
        ps = [int(p or 0) for p in (m.group(1) or "0").split(";")]
        i = 0
        while i < len(ps):
            n = ps[i]
            if n == 0:
                fg, bg, bold = None, None, False
            elif n == 1:
                bold = True
            elif n == 22:
                bold = False
            elif 30 <= n <= 37:
                fg = ANSI[n - 30]
            elif 40 <= n <= 47:
                bg = ANSI[n - 40]
            elif 90 <= n <= 97:
                fg = ANSI[n - 90 + 8]
            elif 100 <= n <= 107:
                bg = ANSI[n - 100 + 8]
            elif n == 39:
                fg = None
            elif n == 49:
                bg = None
            elif n in (38, 48):
                col, used = ext_color(ps, i)
                if n == 38:
                    fg = col
                else:
                    bg = col
                i += used - 1
            i += 1
        pos = m.end()
    if pos < len(line):
        runs.append((line[pos:], fg, bg, bold))
    # \001 \002 是 bash 用来标记「非打印字符」的,本身不该出现在画面上
    out = []
    for t, f, b, bo in runs:
        t = t.replace("\001", "").replace("\002", "")
        if t:
            out.append((t, f, b, bo))
    return out


def cell_width(ch):
    """字符在终端里占几格宽:emoji 两格,其余一格。"""
    return 2 if EMOJI_RE.match(ch) else 1


def text_cells(text):
    return sum(cell_width(c) for c in text)


def split_emoji(text):
    """把一段文字按「emoji / 非 emoji」切开,返回 [(片段, 是不是 emoji), ...]。"""
    out = []
    for ch in text:
        is_emoji = bool(EMOJI_RE.match(ch))
        if out and out[-1][1] == is_emoji:
            out[-1][0] += ch
        else:
            out.append([ch, is_emoji])
    return out


_EMOJI_CACHE = {}


def emoji_glyph(ch):
    """把彩色 emoji 画成一张小图,结果缓存起来。

    要还原真机上的 ⚡ 就得请同一个字体来画 —— DejaVu 里的 U+26A1 是个单色轮廓,
    画出来跟终端里那颗金色闪电完全不是一回事。
    """
    if ch not in _EMOJI_CACHE:
        # 这个字体只提供 109px 一档位图,先按原尺寸画好再等比缩到正文大小
        big = Image.new("RGBA", (200, 200), (0, 0, 0, 0))
        ImageDraw.Draw(big).text((0, 0), ch,
                                 font=ImageFont.truetype(EMOJI_FONT, 109),
                                 embedded_color=True)
        g = big.crop(big.getbbox() or (0, 0, 136, 128))
        s = EMOJI_SIZE / max(g.size)
        _EMOJI_CACHE[ch] = g.resize(
            (max(1, round(g.width * s)), max(1, round(g.height * s))), Image.LANCZOS)
    return _EMOJI_CACHE[ch]


def render(lines, out_path, title=""):
    """把若干行文本画成一张带窗口边框的 PNG。"""
    font = ImageFont.truetype(FONT_REGULAR, FONT_SIZE)
    font_b = ImageFont.truetype(FONT_BOLD, FONT_SIZE)
    char_w = font.getlength("M")          # 等宽字体,量一个字符就够

    # 宽度取「整行格数」的最大值 —— 按单个片段算会把长行截断。格数不是字符数:
    # emoji 占两格
    cols = max((sum(text_cells(t) for t, _, _, _ in parse_ansi(line))
                for line in lines), default=0)
    cols = max(cols, len(title) + 6)
    w = int(PAD_X * 2 + cols * char_w)
    h = int(PAD_Y * 2 + TITLE_H + len(lines) * LINE_HEIGHT)

    img = Image.new("RGB", (w, h), BG)
    d = ImageDraw.Draw(img)

    # 标题栏 + 三个窗口圆点
    d.rounded_rectangle([0, 0, w - 1, h - 1], RADIUS, fill=BG)
    d.rectangle([0, 0, w, TITLE_H], fill=TITLE_BG)
    for i, c in enumerate(("#f38ba8", "#f9e2af", "#a6e3a1")):
        cx = PAD_X + i * 18
        d.ellipse([cx, TITLE_H / 2 - 5, cx + 10, TITLE_H / 2 + 5], fill=c)
    if title:
        d.text((PAD_X + 66, TITLE_H / 2 - FONT_SIZE * 0.62), title,
               font=font, fill="#7f849c")

    y = TITLE_H + PAD_Y
    for line in lines:
        runs = parse_ansi(line)
        # 分两趟:先铺背景色块再画字,否则后一个色块会盖住前一段的文字。
        # 状态栏那种「纯空格 + 背景色」的整条色带就靠这一步出来。
        x = PAD_X
        for text, _, bg, _ in runs:
            if bg:
                d.rectangle([x, y - 4, x + char_w * text_cells(text),
                             y + LINE_HEIGHT - 4], fill=bg)
            x += char_w * text_cells(text)
        x = PAD_X
        for text, fg, _, bold in runs:
            for seg, is_emoji in split_emoji(text):
                if is_emoji:
                    # emoji 单独贴图(彩色字体没法用 fill 上色),两格宽居中
                    for k, ch in enumerate(seg):
                        g = emoji_glyph(ch)
                        img.paste(g, (int(x + k * 2 * char_w + (2 * char_w - g.width) / 2),
                                      int(y + (FONT_SIZE - g.height) / 2 + 1)), g)
                else:
                    d.text((x, y), seg, font=font_b if bold else font, fill=fg or FG)
                x += char_w * text_cells(seg)   # 按格数推进,保证列对齐
        y += LINE_HEIGHT

    out_path.parent.mkdir(parents=True, exist_ok=True)
    img.save(out_path)
    print(f"  写出 {out_path.relative_to(REPO)}  ({w}x{h})")


# ------------------------------------------------------------------ 演示仓库

SRC_OLD = """\
#include <stdio.h>

/* demo program */
int main(void) {
    printf("hello\\n");
    return 0;
}
"""

SRC_NEW = """\
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    printf("hello, world\\n");
    return EXIT_SUCCESS;
}
"""


def seed_home(home):
    """给假 HOME 放一份 bash 配置。

    提示符要显示成 ~/demo,而 \\w 只缩写 $HOME 之下的路径,所以演示仓库必须
    落在 HOME 里,跑它的 shell 也得用这个 HOME —— 那就得有 .bashrc 可读。
    .bash_profile 也要给:tmux 起的是登录 shell,只读它,不给就退回发行版
    自带的提示符。
    """
    for name in (".bashrc", ".bash_profile", ".bash_aliases"):
        src = REPO / "bash" / name
        if src.exists():
            shutil.copy(src, home / name)


def make_fixture(parent):
    """造一个三种状态齐全的 git 仓库,让 * + ? 三个标记都能出现。

    仓库放在假 HOME 里面,这样 PS1 的 \\w 会缩写成 ~/demo,比 /tmp/xxx 干净。
    src/main.c 特意留了新增/修改/删除三种改动,给 vim 的 gitgutter 出标记。
    """
    repo = Path(parent) / "demo"
    (repo / "src").mkdir(parents=True)
    env = dict(os.environ, GIT_CONFIG_GLOBAL=os.devnull,
               GIT_AUTHOR_NAME="demo", GIT_AUTHOR_EMAIL="demo@example.com",
               GIT_COMMITTER_NAME="demo", GIT_COMMITTER_EMAIL="demo@example.com")

    def git(*a):
        subprocess.run(["git", "-c", "init.defaultBranch=master", *a],
                       cwd=repo, env=env, capture_output=True, check=True)

    git("init", "-q")
    (repo / "README.md").write_text("demo\n")
    (repo / "src" / "main.c").write_text(SRC_OLD)
    git("add", ".")
    git("commit", "-qm", "init")

    (repo / "README.md").write_text("demo\nmodified\n")   # -> 未暂存 *
    (repo / "src" / "main.c").write_text(SRC_NEW)         # gitgutter 的 +/~/- 来源
    (repo / "notes.txt").write_text("todo\n")             # -> 未跟踪 ?
    (repo / "src" / "util.c").write_text("/* util */\n")  # -> 已暂存 +
    git("add", "src/util.c")
    return repo


# ---------------------------------------------------------------- bash 截图

def _run(rc, cwd, home, expr):
    """在一个干净环境里跑交互式 bash,取回原始输出(含 ANSI 转义)。"""
    env = dict(os.environ, HOME=home, TERM="xterm-256color")
    env.pop("BLE_VERSION", None)         # 截图里不要 ble.sh 的额外输出
    p = subprocess.run(["bash", "--noprofile", "--rcfile", rc, "-i", "-c", expr],
                       cwd=cwd, env=env, capture_output=True, timeout=30)
    out = p.stdout.decode("utf-8", "replace")
    # Ubuntu 首次 sudo 会打印一段横幅,把画面撑歪,滤掉
    return "\n".join(l for l in out.split("\n")
                     if "administrator" not in l and "sudo_root" not in l)


def bash_shot(tmp, home, repo):
    """四种组合各渲一次提示符,拼成对比图。"""
    lines = ["", "  PROMPT_STYLE x GIT_STYLE - all four combinations", ""]
    src = (REPO / "bash" / ".bashrc").read_text()
    git_line = re.search(r"^GIT_STYLE=.*$", src, re.M).group(0)
    for label, ps, gs in (("green + detail", "green", "detail"),
                          ("green + dirty", "green", "dirty"),
                          ("pygmalion + detail", "pygmalion", "detail"),
                          ("pygmalion + dirty", "pygmalion", "dirty")):
        rc = Path(tmp) / f"rc.{ps}.{gs}"
        rc.write_text(
            re.sub(r"^PROMPT_STYLE=.*$", f"PROMPT_STYLE={ps}", src, flags=re.M)
              .replace(git_line, f"GIT_STYLE={gs}"))
        prompt = _run(str(rc), str(repo), str(home), 'printf "%s" "${PS1@P}"')
        lines += [f"  # {label}", "  " + prompt, ""]
    render(lines, OUT_DIR / "bash-prompt.png", "bash - prompt styles")


# ------------------------------------------------------------ vim / tmux 截图

SOCKETS = ("shotgen", "shotinner")   # 自己用的两个 socket,收尾时一并清掉


def tmux_capture(cmd, cols, rows, settle=2.5, sock="shotgen"):
    """在隔离的 tmux 服务器里跑一条命令,取回带颜色的整屏。

    不去自己解析 vim/tmux 的转义序列 —— 那需要完整实现一个终端模拟器
    (光标定位、清屏、备用屏幕)。交给 tmux:capture-pane 直接吐出已经
    排版好的屏幕内容,省掉整个模拟器。

    必须走 -L 独立 socket:用默认 socket 会在使用者自己的 tmux 服务器里
    建会话,那是别人的工作区,不能碰。
    """
    for s in SOCKETS:
        subprocess.run(["tmux", "-L", s, "kill-server"], capture_output=True)
    subprocess.run(["tmux", "-L", sock, "new-session", "-d",
                    "-x", str(cols), "-y", str(rows), "-s", "shot", cmd],
                   capture_output=True, check=True)
    time.sleep(settle)
    p = subprocess.run(["tmux", "-L", sock, "capture-pane",
                        "-t", "shot", "-p", "-e"], capture_output=True)
    for s in SOCKETS:
        subprocess.run(["tmux", "-L", s, "kill-server"], capture_output=True)
    return p.stdout.decode("utf-8", "replace").rstrip("\n").split("\n")


def vim_shot(home, repo):
    """vim:行号 + 语法高亮 + lightline 状态栏 + gitgutter 改动标记。"""
    # 配置和插件都取仓库里的那份(插件是随仓库分发的,见 README 目录结构),
    # 而不是真 HOME 里 stow 出来的软链 —— 那样没部署过的机器上会拍成裸 vim。
    # .vimrc 里写的是 plug#begin('~/.vim/plugged'),~ 按 $HOME 展开,顺着软链
    # 正好落到仓库的 vim/.vim/plugged。
    (home / ".vimrc").symlink_to(REPO / "vim" / ".vimrc")
    (home / ".vim").symlink_to(REPO / "vim" / ".vim")
    lines = tmux_capture(f"cd {repo} && HOME={home} vim src/main.c", 84, 18, settle=3.0)
    render(lines, OUT_DIR / "vim.png", "vim - lightline + gitgutter")


def tmux_shot(home, repo):
    """tmux:Catppuccin 状态栏 + 左右分屏。"""
    conf = REPO / "tmux" / ".tmux.conf"

    # 配置要软链成 ~/.tmux.conf,不能图省事用 -f 指过去:tpm 是靠 grep
    # ~/.tmux.conf 里的 @plugin 行来认插件的,配置不在那个位置它就当没有插件,
    # catppuccin 静默不加载,状态栏回落成 tmux 默认的绿条。软链也正是 stow
    # 部署完的真实形态。
    (home / ".tmux.conf").symlink_to(conf)

    # 插件目录同理,也得在假 HOME 里找得到。
    # 指向仓库自带的这份,而不是 ~/.tmux/plugins —— 后者是 stow 软链出来的部署
    # 产物,没部署过的机器上就不存在(插件是随仓库分发的,见 README 目录结构)。
    # 只链 plugins,不链整个 ~/.tmux:那样 continuum 会把真机的会话存档认成自己的,
    # 恢复出一堆窗口来,还会往真机的 resurrect 目录里写。
    plugins = REPO / "tmux" / ".tmux" / "plugins"
    if plugins.is_dir():
        (home / ".tmux").mkdir(exist_ok=True)
        (home / ".tmux" / "plugins").symlink_to(plugins)

    # $TMUX 必须先清掉,否则内层 tmux 拒绝启动
    # ("sessions should be nested with care, unset $TMUX to force")
    # -L shotinner:内层也要自己的 socket,否则会跑进使用者本人的 tmux 服务器
    inner = (f"unset TMUX; HOME={home} tmux -L shotinner "
             f"new-session -s demo -c {repo} \\; split-window -h -c {repo}")
    lines = tmux_capture(inner, 96, 20, settle=3.5)
    render(lines, OUT_DIR / "tmux.png", "tmux - catppuccin status bar")


if __name__ == "__main__":
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        home = Path(tmp) / "home"
        home.mkdir()
        (home / ".sudo_as_admin_successful").touch()
        (home / ".hushlogin").touch()    # 压掉登录横幅,否则 tmux 整屏都是 MOTD
        seed_home(home)
        repo = make_fixture(home)
        print("生成截图:")
        bash_shot(tmp, home, repo)
        vim_shot(home, repo)
        tmux_shot(home, repo)
    print("完成。")
