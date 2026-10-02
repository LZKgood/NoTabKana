# KanaTap
Microsoft Japanese IME enhancement script
Microsoft日本語IME補助スクリプト
Windows微软日语输入法增强脚本

## 概要 / Abstract / はじめに
English:
This script is built with AutoHotkey v2, an enhancement tool for Microsoft native Japanese IME on Windows. It optimizes candidate word page turning and candidate selection with number keys, simulating Mac Japanese input experience to reduce frequent Tab pressing.

日本語：
このスクリプトは AutoHotkey v2 で作成された、Windows 上の Microsoft純正日本語IME向け入力補助ツールです。変換候補のページ送りと数字キーによる候補確定を最適化し、Mac風の日本語入力体験を実現、Tabキーを連打する手間を省きます。

中文：
本脚本基于 AutoHotkey v2 开发，是 Windows 微软自带日语输入法增强工具。优化候选词翻页与数字选候选功能，模拟 Mac 日语输入体验，不用频繁按 Tab。

### Main Features / 主な機能 / 主要功能
English:
- After typing romaji, pressing number key automatically sends Tab to confirm conversion candidate
- `=` key: Page down for candidates, send Tab only on first page turn
- `-` key: Page up for candidates when in page mode; outputs long vowel symbol 「ー」 normally outside page mode
- ESC key: Reset all internal state of script to avoid logic error
- Support Ctrl/Alt/Shift modifier keys, prevent misfire when copy & paste
- Disable mouse hook, only listen keyboard, low resource consumption

日本語：
- ローマ字入力後、数字キーを押すと自動でTabを送信し変換候補を確定
- `=` キー：変換候補を次ページへ送り、初回のみTabを送信
- `-` キー：ページモード時は候補を前ページへ戻す、通常時は長音記号「ー」を出力
- ESCキー：スクリプトの内部状態を全リセットし、論理異常を防止
- Ctrl/Alt/Shift修飾キーに対応、コピー貼り付け時の誤動作を抑制
- マウスフックを無効化、キーボードのみ監視でリソース消費が少ない

中文：
- 输入罗马音假名后，按下数字键自动发送Tab确认候选汉字
- `=` 号：候选词向下翻页，仅第一次翻页发送Tab
- `-` 号：翻页模式下向上翻页；普通输入状态输出长音符号「ー」
- ESC键：清空脚本全部内部状态，防止逻辑错乱
- 兼容Ctrl/Alt/Shift修饰快捷键，复制粘贴不会误触发假名模式
- 禁用鼠标钩子，仅监听键盘，资源占用极低

## Operating Environment / 動作環境 / 运行环境
English:
- OS: Windows 10 / Windows 11
- AutoHotkey v2 (Required)
- Input Method: Microsoft native Japanese IME
> Not compatible with third-party IME such as Sogou IME, Google Japanese IME

日本語：
- OS：Windows 10 / Windows 11
- AutoHotkey v2（必須）
- 入力方式：Microsoft 純正日本語IME
> ※搜狗日本語、Google日本語IMEなどサードパーティ製IMEは非対応

中文：
- 操作系统：Windows10 / Windows11
- AutoHotkey v2（必须安装）
- 输入法：微软自带日语IME
> 不支持搜狗日语、Google日语输入法等第三方输入法

## Installation / インストール手順 / 安装步骤
English:
1. Install AutoHotkey v2 from official website
2. Save `KanaTap.ahk` locally
3. Double-click the ahk file to run the script
4. If the AHK icon appears in tray, startup is complete

日本語：
1. AutoHotkey v2 を公式サイトからインストール
2. `KanaTap.ahk` をローカルに保存
3. ファイルをダブルクリックで実行
4. タスクトレイにAHKアイコンが表示されたら起動完了

中文：
1. 前往官网安装 AutoHotkey v2
2. 将仓库内 `KanaTap.ahk` 保存到本地
3. 双击ahk文件启动脚本
4. 托盘出现AHK图标即运行成功

## Configuration / 設定 / 自定义配置
English:
You can adjust key send interval by modifying `KEY_DELAY` at the top of script (Unit: ms).
If timing problem occurs, try changing value to 2~5.

日本語：
スクリプト上部の `KEY_DELAY` でキー送信間隔を調整可能（単位：ms）。
不具合が発生する場合は `2～5` に変更して試してください。

中文：
修改脚本头部 `KEY_DELAY` 调整按键间隔（单位：毫秒）。
如果出现按键时序异常，可以改成2~5测试。

## License / ライセンス / 许可证
English:
This script is released under the MIT License.
See the `LICENSE` file for the full legal text.
Short summary: You are free to use, modify and redistribute this software. The author provides no warranty.

日本語：
本スクリプトは MIT License で公開されています。
正式な法的文面は `LICENSE` ファイルを参照してください。
簡単な説明：本ソフトウェアを自由に使用、改変、再配布できます。作者はいかなる保証も行いません。

中文：
本脚本采用 MIT 许可证开源。
完整法律文本请查看仓库内 `LICENSE` 文件。
简要说明：你可以自由使用、修改、分发本软件，作者不提供任何担保。

- AutoHotkey v2: GNU GPLv2 (User needs to install it separately)
- AutoHotkey v2：GNU GPLv2（利用者が別途インストールする必要があります）
- AutoHotkey v2：GNU GPLv2协议（由用户自行独立安装）

## Disclaimer / 免責事項 / 免责说明
English:
1. This tool depends on system environment, operation on all PCs is not guaranteed.
2. It will not modify system files, only monitor keyboard input events.
3. The author shall not be liable for any damage caused by using this script.

日本語：
1. 本ツールは環境依存のため、全てのPCで動作を保証するものではありません。
2. システムファイルを改変せず、キーボード入力イベントのみ監視します。
3. 本スクリプトの使用によって生じた損害について作者は責任を負いません。

## Known Issues / 既知の問題 / 已知问题
English:
Windows has no API to get the total number of candidate pages of IME, so page loop function cannot be implemented.

日本語：
IMEの候補ページ総数を取得するWindows APIが存在しないため、ページを循環させる機能は実装できません。

中文：
Windows没有可以读取IME候选总页数的API，无法实现翻页循环功能。

## Contribute / 貢献 / 贡献
English:
Issues and Pull Requests are welcome.

日本語：
IssueやPull Requestを歓迎します。

中文：
欢迎提交Issue与Pull Request。
