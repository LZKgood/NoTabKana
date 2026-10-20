# NoTabKana
> ⚠️ **BETA VERSION：v1.3.5‑Beta（测试版）**
> This release is still in public beta. Unexpected edge‑case bugs may exist.
> Please evaluate risks before daily production‑grade usage. Feedback via Issues is welcome.

## Overview｜概要｜简介
**🇬🇧 English**
NoTabKana is an AutoHotkey‑v2‑powered enhancement script for the native Microsoft Japanese IME on Windows.
It is designed to mimic the smooth selecting experience of macOS Japanese input: you no longer need to repeatedly tap the `Tab` key to unfold candidate lists and pick kanji.
Instead, after you finish typing your romaji word, simply hit a number key to select the corresponding kanji entry directly.
The `=` key opens the next page of conversion candidates, and the `-` key acts dual‑purpose: it outputs the long‑vowel mark「ー」during normal typing, and jumps to the previous candidate page only when page‑switching mode is active.
This script does NOT hook into any internal IME APIs. It works purely by tracking your romaji keystroke sequence and sending lightweight auxiliary keystrokes.

**🇨🇳 中文**
NoTabKana 是基于 AutoHotkey v2 打造的 Windows 原生微软日语输入法增强脚本。
目标是复刻 macOS 日语输入法顺滑的选词体验：你不再需要反复敲击 `Tab` 展开候选列表、翻页选汉字。
当你打完罗马音之后，直接按下数字键就可以选中对应的汉字条目。
`=` 按键用于切换至下一页候选；`-` 具备双重行为：普通输入状态输出长音符号「ー」，仅在翻页模式激活时跳转至上一页候选。
本脚本**不会劫持任何输入法底层私有接口**，仅靠追踪你的罗马音输入序列、发送轻量化辅助按键来实现全部功能。

**🇯🇵 日本語**
NoTabKana は AutoHotkey v2 で作られた、Windows標準のMicrosoft日本語IME向けの補助スクリプトです。
macOSの日本語入力の滑らかな選択体験を再現することを目的としています。
変換候補一覧を出すために何度も`Tab`キーを叩く必要はもうありません。
ローマ字入力が終わったら数字キーを押すだけで、対応する漢字を直接選択可能になります。
`=`キーは変換候補の次ページへ移動、`-`キーは二つの動作を持ちます：通常入力時は長音記号「ー」を出力し、ページ切り替えモードが有効な時のみ前の候補ページへジャンプします。
このスクリプトはIMEの内部APIに一切フックせず、ローマ字のキー入力シーケンスを追跡し、軽量な補助キーイベントを送信するだけで動作します。

---

## Example｜使用示例｜例
> Example 1：基础汉字选词｜基礎漢字選択｜基本的な漢字選択

**🇬🇧 English**
Switch your input method to Microsoft Japanese IME. Type `kawa`, then press number key `1` to select「川」directly.

**🇨🇳 中文**
将输入法切换为微软日语IME，输入`kawa`，按下数字`1`，直接选中「川」。

**🇯🇵 日本語**
Microsoft日本語IMEに切り替え、`kawa`と入力し、数字キー`1`を押すと「川」を直接選択できます。

> Example 2：长音符与翻页｜長音符とページ送り｜Long vowel mark & page navigation

**🇬🇧 English**
Type `bi`, press `-` to output long‑vowel mark「ー」to get「ビー」, continue typing `ru`.
If your target word is not on the current candidate page, press `=` to jump to the next page.
When page‑mode is active, press `-` to go back one page. Once you find your desired term, press the corresponding number key (e.g. `1`) to select it.

**🇨🇳 中文**
输入`bi`，按下`‑`输出长音符号「ー」得到「ビー」，接着继续输入`ru`。
如果目标词汇不在当前候选页面，按下`=`切换到下一页候选。
在翻页模式激活状态下，按下`‑`返回上一页。找到目标词后，按下对应数字（例如`1`）选中词条。

**🇯🇵 日本語**
`bi`と入力し、`-`キーで長音記号「ー」を出力し「ビー」にしたあと、続けて`ru`を入力します。
目的の単語が現在の候補ページに無い場合は`=`キーで次のページへ移動します。
ページモードが有効な状態で`-`を押すと前のページに戻ります。探している単語を見つけたら、数字キー（例：`1`）で選択します。

> Example3：状态自动重置｜自動リセット｜Auto‑state reset

**🇬🇧 English**
If you stop typing for 15 seconds, click elsewhere on screen, switch windows or change input language, all working states will reset automatically to prevent stuck hot‑key behaviour.

**🇨🇳 中文**
如果停止输入15秒、点击别处、切换窗口、切换输入法语言，全部运行状态会自动重置，避免热键状态卡死。

**🇯🇵 日本語**
15秒入力を止めたり、別の場所をクリック、ウィンドウ切り替え、言語切り替えをすると、全ての動作状態が自動的にリセットされ、ホットキーの状態固着を防ぎます。

---

## Main Features / 主な機能 / 主要功能
**🇬🇧 English**
- Romaji‑buffer‑based state‑tracking engine: parse combinations, contracted sounds (拗音), geminate consonants(促音), syllabic nasal「ん」precisely, instead of simple keypress counting.
- Pressing number keys after romaji input triggers `{Down}` to pop‑up the candidate panel and then selects the numbered entry.
- `=` key: Activate page‑switch mode, trigger candidate panel, move to next candidate page. Page mode expires automatically after 1800ms.
- `-` key: Dual‑mode behaviour. Output long‑vowel「ー」under normal state; jump to previous page only when page‑switch mode is alive.
- Backspace debounce: instead of deleting one raw character, it removes one Japanese phonetic unit each time, with a short debounce window for rapid backspace hits.
- Built‑in watchdog timer: reset automatically on window‑switch, IME‑language change, idle timeout, page‑mode timeout.
- Safe bypass: Ctrl / Alt / Win modifier keys disable script logic, preserving native shortcuts such as copy‑paste.
- Self‑test command: run `NoTabKana.ahk test` from command‑line to execute full‑automated unit tests without sending real keystrokes to your system.
- Emergency manual reset shortcut: press `F12` while on Japanese IME to clear all states instantly.

**🇨🇳 中文**
- 基于罗马音缓冲区的状态追踪引擎：精准解析拗音、促音、拨音「ん」，而不是简单地统计敲击次数。
- 罗马音输入后按下数字键：发送`{Down}`唤起候选面板，随后发送对应数字完成选词。
- `=`按键：激活翻页模式，唤起候选面板，跳转至下一页候选；翻页模式1800毫秒后自动过期失效。
- `-`按键：双模式行为。普通状态输出长音符号「ー」；只有翻页模式尚未超时时，才执行上翻页动作。
- 退格防抖单元删除：不是删除原始英文字符，而是以一个日文发音单元作为删除对象；高速连打退格带有防抖合并窗口。
- 内置看门狗定时器：切换窗口、切换输入法语言、空闲超时、翻页超时都会自动重置脚本状态。
- 修饰键安全旁路：检测Ctrl / Alt / Win，一旦按下则绕过脚本逻辑，保留复制粘贴等原生快捷键不受干扰。
- 内置自检命令：在命令行执行`NoTabKana.ahk test`即可全自动运行全套单元测试，不会向系统发送真实按键。
- 紧急手动重置快捷键：日语输入法状态下按下`F12`，立刻清空全部状态。

**🇯🇵 日本語**
- ローマ字バッファを用いた状態追跡エンジン：単純なキーカウントではなく、拗音・促音・撥音「ん」を正確に分解します。
- ローマ字入力後に数字キーを押す：`{Down}`を送信し候補ウィンドウを呼び出し、続けて数字キーを送信し選択を実行します。
- `=`キー：ページ切り替えモードを起動、候補ウィンドウを表示し、次の候補ページへ移動。ページモードは1800ms後に自動失効します。
- `-`キー：二つの動作。通常状態では長音記号「ー」を出力、ページモードが有効かつ期限内の場合のみ前のページへ移動します。
- バックスペースデバウンス：生の英文字単位ではなく、日本語の発音単位ごとに削除します。高速連打に対して、短い待ち時間で操作をまとめます。
- ウォッチドッグタイマー内蔵：ウィンドウ切り替え、IME言語変更、アイドルタイムアウト、ページモードの時間切れで自動リセットします。
- 修飾キー安全バイパス：Ctrl/Alt/Winが押されているときはスクリプトのロジックをスキップし、コピー・ペーストなどのショートカットを保護します。
- セルフテスト機能：コマンドラインから`NoTabKana.ahk test`を実行すると、実際のキーを送信せずに全自動単体テストを実行可能。
- 緊急リセットショートカット：日本語IME使用中に`F12`を押すと、すべての状態を瞬時にクリアします。

---

## Operating Environment / 動作環境 / 运行环境
**🇬🇧 English**
- OS: Windows 10 / Windows 11
- Runtime: AutoHotkey v2 (MANDATORY)
- Input Method: Microsoft‑built‑in Japanese IME only
> Not compatible with third‑party IME: Sogou Japanese, Google Japanese Input, ATOK, etc.

**🇨🇳 中文**
- 操作系统：Windows10 / Windows11
- 运行依赖：AutoHotkey v2（必须安装）
- 输入法：**仅支持Windows自带微软日语IME**
> 不兼容第三方输入法：搜狗日语、谷歌日语、ATOK等。

**🇯🇵 日本語**
- OS：Windows10 / Windows11
- 実行環境：AutoHotkey v2（必須）
- 入力方式：Windows標準Microsoft日本語IME専用
> ※サードパーティ製IME（搜狗日本語、Google日本語入力、ATOKなど）には対応していません。

## Quick Install / 簡単インストール / 快速安装
**🇬🇧 English**
1. Go to the official AutoHotkey website and download & install AutoHotkey v2.
2. Download `NoTabKana.ahk` from this repository and save it locally.
3. Double‑click `NoTabKana.ahk` to launch the background script service.
4. If you see the AutoHotkey tray icon in the system notification bar, startup is successful.
> Optional: Run `NoTabKana.ahk test` in terminal to trigger built‑in self‑diagnostic tests.
> ⚠️Notice: This is a BETA release. Unexpected behaviours could still occur.

**🇨🇳 中文**
1. 前往 AutoHotkey 官网下载并且安装 AutoHotkey v2。
2. 从本仓库下载 `NoTabKana.ahk` 保存到本地电脑。
3. 双击 `NoTabKana.ahk`，启动后台脚本服务。
4. 任务栏托盘出现AutoHotkey图标，代表启动成功。
> 可选操作：终端运行 `NoTabKana.ahk test`，启动内置的自我诊断测试。
> ⚠️注意：本版本为BETA测试版，仍有可能出现意料之外的异常行为。

**🇯🇵 日本語**
1. AutoHotkey公式サイトへアクセスし、AutoHotkey v2をダウンロード・インストールします。
2. このリポジトリから`NoTabKana.ahk`をダウンロードしPCに保存します。
3. `NoTabKana.ahk`をダブルクリックするとバックグラウンドサービスが起動します。
4. システムトレイにAutoHotkeyアイコンが表示されたら起動成功です。
> オプション：ターミナルから`NoTabKana.ahk test`を実行すると内蔵自己診断テストが起動します。
> ⚠️注意：これはベータ版です。予期せぬ動作が発生する可能性があります。

---

## License / ライセンス / 许可证
**🇬🇧 English**
Released under MIT License.
You are free to use, modify, fork and redistribute this software. There is NO warranty of any kind.

**🇨🇳 中文**
采用 MIT 开源许可证。
你可以自由地使用、修改、分叉、再分发本软件。本软件不附带任何形式担保。

**🇯🇵 日本語**
MITライセンスで公開されています。
自由に使用、改変、フォーク、再配布が可能です。一切の保証はありません。

## Disclaimer / 免責事項 / 免责说明
**🇬🇧 English**
NoTabKana‑v1.3.5‑Beta is for personal study, research and non‑commercial testing purposes only.
This script relies fully on Windows system input‑event behaviour. The author cannot guarantee zero‑fault performance under every hardware, Windows build, or input scenario.
The program only listens and sends keyboard events; it will NOT modify, delete or overwrite any system files or personal data.
All risks arising out of running this beta script shall be borne entirely by the end‑user. The author shall not be liable for any direct or indirect damages.
This project is free‑of‑charge open‑source: there is no mandatory support, maintenance or update obligation.

**🇨🇳 中文**
NoTabKana v1.3.5‑Beta 仅供个人学习、研究、非商业测试用途。
本脚本高度依赖 Windows 的按键事件行为，作者无法保证在每一种硬件、系统版本、输入场景下零故障运行。
程序仅监听与发送键盘事件，**不会修改、删除或者覆盖任何系统文件和私人数据**。
运行此Beta测试版本产生的一切风险，全部由终端使用者自行承担。作者不对任何直接或间接损害承担责任。
本项目是免费开源项目，不存在强制的技术支持、维护以及更新义务。

**🇯🇵 日本語**
NoTabKana v1.3.5‑Beta は個人の学習・研究・非営利テスト目的のみでご利用ください。
本スクリプトはWindowsのキーイベントの挙動に依存しており、全ての環境、Windowsバージョン、入力シチュエーションで不具合ゼロを保証することはできません。
プログラムはキーボードイベントの監視と送信のみを行い、システムファイルや個人データを変更・削除・上書きすることは一切ありません。
このベータ版スクリプトの実行によって生じたすべてのリスクは利用者自身が負うものとします。作者はいかなる直接的・間接的損害についても責任を負いません。
本プロジェクトは無料のオープンソースであり、サポート・保守・アップデートを義務付けるものではありません。

## Contribute / 貢献 / 贡献
**🇬🇧 English**
Issues, feedback and Pull Requests are warmly welcomed! Please report any weird or broken behaviours you meet.

**🇨🇳 中文**
欢迎提交Issue、反馈以及Pull Request！如果你遇到异常或者奇怪的行为，请积极反馈。

**🇯🇵 日本語**
Issue、フィードバック、Pull Requestを歓迎します！不具合や奇妙な動作を見つけたらぜひご報告ください。

---

# 📜 Changelog｜変更履歴｜版本更新日志
## Upgrade scope: From v1.3.0 → v1.3.5‑Beta
### 📌 Major breaking architectural change: Trigger key migrated from `Tab` to `{Down}` (↓)
#### Why we replaced Tab with Down key｜なぜTabキーから↓(Down)に変更したのか？｜为什么把Tab换成向下方向键？
**🇬🇧 English**
Original v1.3.0 used simulated `{Tab}` keystrokes to pop‑up the candidate panel, matching Microsoft IME’s native shortcut.
But three fundamental, unfixable defects were discovered:
1. Inside Microsoft Japanese IME, `Tab` has dual‑binded behaviour: it opens candidates **AND** shifts word segmentation boundaries. It will often unexpectedly split your input phrase, destroying your intended conversion range. This logic is hard‑coded deep inside Microsoft’s IME and cannot be overridden by AHK scripts.
2. `Tab` is heavily used across browsers, code editors, terminals and forms for UI focus navigation. Emitting synthetic Tab events risks unwanted focus jumps.
3. Once `Tab` triggers candidates, the IME locks itself into persistent segment‑edit mode until you press Enter or Esc, even if you cancel selection. This creates many hard‑to‑handle stuck‑state edge‑cases for our state machine.

In contrast, within the pre‑composition zone of Microsoft Japanese IME, the down arrow `{Down}` key has **only one single job: open the candidate dropdown**.
It will never alter word segmentation, will not cause stray UI focus jumps, and does NOT trigger that stubborn persistent lock‑in state.
This single‑purpose behaviour drastically cuts side‑effects and reduces freeze risks. That is the core reason for this breaking change.

**🇨🇳 中文**
原始 v1.3.0 版本是模拟发送 `{Tab}` 唤起候选面板，这个思路本来贴合微软IME原生快捷键。
但是我们发现了三条根本性、无法靠小补丁修复的硬缺陷：
1. 在微软日语IME底层，`Tab`是双重绑定：它除了打开候选列表，**同时还会移动文节切分边界**！经常擅自拆分正在输入的词汇，破坏转换范围。这个逻辑是微软硬编码在输入法内部的，AHK脚本无法屏蔽。
2. `Tab` 在浏览器、编辑器、终端、表单大量用来跳转UI焦点。模拟发送Tab可能引发意料之外的焦点乱跑。
3. 一旦用Tab唤起候选，就算放弃选词，IME也会持续锁定在顽固的「文节编辑模式」，直到回车或ESC。这制造了大量状态卡死的边界问题，给状态机带来巨大压力。

反观向下方向键 `{Down}`：在微软日语IME的预编辑区域，**它只有一个单一功能：唤起候选下拉菜单**。
它不会修改文节切分，不会乱跳UI焦点，不会触发那种顽固的锁定状态。
这种单一用途的特性大幅降低副作用，减少卡死风险。这就是做出这次破坏性架构变更的核心理由。

**🇯🇵 日本語**
初期のv1.3.0では`{Tab}`のキー送信で候補ウィンドウを開いていました。これはMicrosoft IMEの標準ショートカットに沿った設計でした。
しかし根本的でパッチでは直せない3つの問題が発見されました：
1. Microsoft日本語IMEの内部では`Tab`は2つの動作を持っています。候補を開くだけでなく、**文節の区切り位置を移動させてしまう**のです。意図しない箇所で単語が分割され、変換範囲が崩れます。この動作はIME内部にハードコードされており、AHKから上書きできません。
2. `Tab`はブラウザ・エディタ・ターミナル・フォームでフォーカス移動に多用されています。偽のTabイベント送信は予期せぬフォーカスジャンプを引き起こす可能性があります。
3. Tabで候補を開くと、選択をキャンセルしても、EnterまたはEscを押すまでIMEが「文節編集モード」にロックされます。これにより、状態管理が非常に困難になる多くの境界ケースが生まれます。

一方、下矢印`{Down}`は、Microsoft日本語IMEのプリ編集領域において、**候補リストを開くという一つの役割だけを持っています**。
文節を分割せず、UIのフォーカスを飛ばさず、厄介なロック状態も引き起こしません。
副作用を大きく抑え、ハングのリスクを減らせる。これが今回の破壊的変更を行った根本的な理由です。

### ✨ Other Major Improvements from v1.3.0 → v1.3.5‑Beta
**🇬🇧 English**
- Replaced the simple keypress‑counter state‑machine with a full romaji‑token parsing engine backed by a character buffer, correctly handling contracted sounds, geminate consonants and syllabic‑nasal sequences.
- Implemented phonetic‑unit‑aware backspace erase logic plus backspace debounce protection.
- Added watchdog auto‑reset system: idle timeout, window switch detection, IME language change detection.
- Built‑in safety bypass for Ctrl/Alt/Win modifier shortcuts.
- Added emergency reset hotkey (`F12`) and a zero‑keystroke automated unit‑test framework runnable from command‑line.
- Fixed many edge‑case parsing bugs and fine‑tuned default timing values to balance responsiveness and stability.

**🇨🇳 中文**
- 抛弃了 v1.3.0 简陋的敲击计数器状态机，改用基于字符缓冲区的完整罗马音分词解析引擎，可以正确处理拗音、促音、拨音序列。
- 实现了「按发音单元」删除的退格逻辑，并加入退格防抖保护。
- 增加看门狗自动重置系统：空闲超时、窗口切换检测、输入法语种切换检测。
- 增加 Ctrl/Alt/Win 修饰键安全旁路，保护原生系统快捷键。
- 新增紧急重置热键（`F12`）和一套不需要发送真实按键、可从命令行启动的自动化单元测试框架。
- 修复大量边界解析BUG，精细调校各项默认延时参数，平衡响应速度与稳定性。

**🇯🇵 日本語**
- v1.3.0の単純なキーカウンター式ステートマシンを廃止し、文字バッファに基づいた完全なローマ字トークン解析エンジンに置き換え、拗音・促音・撥音のシーケンスを正しく処理できるようになりました。
- 発音単位で削除するバックスペースロジックと、バックスペースのデバウンス保護を実装。
- ウォッチドッグ自動リセットシステムを追加：アイドルタイムアウト、ウィンドウ切り替え検知、IME言語切り替え検知。
- Ctrl/Alt/Win修飾キーの安全バイパスを実装し、OS本来のショートカットを保護。
- 緊急リセットホットキー（`F12`）、および実キーを送信せずコマンドラインから起動可能な自動単体テストフレームワークを追加。
- 多くの境界パース不具合を修正、応答性と安定性のバランスのためデフォルトの待ち時間を微調整。
