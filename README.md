# NoTabKana




**NoTabKana — Windows Microsoft Japanese IME enhancement script built with AutoHotkey v2.**
NoTabKana 是基于 AutoHotkey v2 开发的 Windows 微软日语输入法增强脚本，模拟 Mac 日语输入体验，解决微软日语IME选词时必须反复按Tab的痛点，自定义候选词翻页快捷键。
NoTabKana は AutoHotkey v2 で作成されたWindows Microsoft日本語IME補助スクリプトです。Macライクな日本語入力環境を実現し、変換候補選択のためTabキーを何度も押す手間をなくします。

## Demo / 動作例 / 演示
- ローマ字でかな入力後、数字キーを押すと自動でTab送信し候補を選択
- `=` キー：候補ページ送り（初回のみTab送信）
- `-` キー：候補ページ戻し、通常時は長音「ー」を出力
- Ctrl/Alt/Shift修飾キーに対応。コピー・貼り付け時誤動作しない

输入罗马音假名 → 调出候选列表 → `=` 向下翻页、`-`向上翻页，按下数字键直接选中候选。Windows 上实现接近 Mac 的日语输入体验，告别重复敲击 Tab。

## Main Features / 主な機能 / 主要功能
English:
- After typing romaji, pressing number key automatically sends Tab to confirm conversion candidate
- `=` key: Page down for candidates, send Tab only on first page turn
- `-` key: Page up for candidates when in page mode; outputs long vowel symbol 「ー」 normally outside page mode
- Support Ctrl/Alt/Shift modifier keys, prevent misfire when copy & paste

日本語：
- ローマ字入力後、数字キーを押すと自動でTabを送信し変換候補を確定
- `=` キー：変換候補を次ページへ送り、初回のみTabを送信
- `-` キー：ページモード時は候補を前ページへ戻す、通常時は長音記号「ー」を出力
- Ctrl/Alt/Shift修飾キーに対応、コピー貼り付け時の誤動作を抑制

中文：
- 输入罗马音假名后，按下数字键自动发送Tab确认候选汉字
- `=` 号：候选词向下翻页，仅第一次翻页发送Tab
- `-` 号：翻页模式下向上翻页；普通输入状态输出长音符号「ー」
- 兼容Ctrl/Alt/Shift修饰快捷键，复制粘贴不会误触发假名模式

## Operating Environment / 動作環境 / 运行环境
English:
- OS: Windows 10 / Windows 11
- AutoHotkey v2 (Required)
- Input Method: Microsoft native Japanese IME
> Not compatible with third‑party IME such as Sogou IME, Google Japanese IME

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

## Quick Install / 簡単インストール / 快速安装
English:
1. Download and install AutoHotkey v2 from the [official website](https://www.autohotkey.com/).
2. Download `NoTabKana.ahk` from this repository to your local computer.
3. Double‑click `NoTabKana.ahk` to launch the script.
4. You will see the AutoHotkey icon in the system tray when running successfully.

> Important notice: This script only works with Microsoft native Japanese IME on Windows. It will NOT work with Sogou, Google Japanese Input or other third-party input methods.

日本語：
1. [AutoHotkey公式サイト](https://www.autohotkey.com/) からAutoHotkey v2をダウンロードしインストールします。
2. このリポジトリから `NoTabKana.ahk` をダウンロードしてローカルPCに保存します。
3. `NoTabKana.ahk` をダブルクリックしてスクリプトを起動します。
4. タスクトレイにAutoHotkeyのアイコンが表示されたら起動成功です。

> 重要：本スクリプトはWindows標準のMicrosoft日本語IME専用です。搜狗やGoogle日本語入力などサードパーティ製IMEには対応していません。

中文：
1. 前往 [AutoHotkey官网](https://www.autohotkey.com/) 下载并安装 AutoHotkey v2。
2. 在本仓库下载 `NoTabKana.ahk` 保存到电脑本地。
3. 双击 `NoTabKana.ahk` 启动脚本。
4. 托盘出现AutoHotkey图标，代表脚本运行成功。

> ⚠️重要声明：该脚本**仅支持Windows系统自带微软日语输入法**，搜狗、谷歌日语输入法等第三方输入法无法使用。

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

## Disclaimer / 免責事項 / 免责说明
【中文免责声明】
本开源工具 NoTabKana 仅供个人学习、研究、非商业体验使用。
本软件依赖 Windows 系统输入法环境，作者不保证程序在所有设备、系统版本、输入法环境下完全兼容、稳定、无差错。
本程序仅监听与转发键盘输入事件，不会篡改、覆盖、损坏任何系统文件与用户数据。
使用者明确知悉：使用本脚本产生的一切后果、系统异常、配置变动、操作失误风险，均由使用者本人全权承担。
作者不对因使用本工具导致的直接或间接损失、数据异常、设备故障、兼容性问题承担任何法律责任。
本项目为开源免费项目，无任何担保、无售后、无义务更新，使用者需自行承担使用风险。

【English Disclaimer】
NoTabKana is an open-source tool for personal learning, research and non-commercial use only.
This software depends on the Windows system input environment. The author does not guarantee full compatibility, stability or error-free operation on all devices, system versions or IME environments.
This program only monitors and forwards keyboard input events. It will not modify, overwrite or damage any system files or user data.
The user explicitly acknowledges that all consequences, system abnormalities, configuration changes and operational risks arising from the use of this script shall be borne solely by the user.
The author shall not be liable for any direct or indirect loss, data abnormality, device failure or compatibility issues caused by using this tool.
This project is free and open-source with no warranty, no after-sales service and no mandatory update obligation. All usage risks are undertaken by the user.

【日本語 免責事項】
本オープンソースツール NoTabKana は、個人の学習・研究・非営利目的での利用に限ります。
本ソフトウェアはWindowsの入力環境に依存するため、すべての機器・システムバージョン・IME環境で完全な互換性・安定性・無不具合を保証するものではありません。
本プログラムはキーボード入力イベントの監視・転送のみを行い、システムファイルやユーザーデータを改変・破損することはありません。
本ツールの使用によって生じるすべての結果、システム異常、設定変更、操作リスクは、利用者自身が全責任を負うものとします。
作者は、本ツールの使用により発生した直接的・間接的な損失、データ異常、機器障害、互換性問題について、一切の責任を負いません。
本プロジェクトは無料オープンソースであり、保証・サポート・強制アップデート義務はありません。すべての利用リスクは利用者が負担します。

## Contribute / 貢献 / 贡献
English:
Issues and Pull Requests are welcome.
日本語：
IssueやPull Requestを歓迎します。
中文：
欢迎提交Issue与Pull Request。
