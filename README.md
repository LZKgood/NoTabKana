<div align="center">

# NoTabKana

### A smoother Japanese typing experience on Windows.

**Windows で、より快適な日本語入力を。**<br>**让 Windows 日语输入更加顺手。**

[![AutoHotkey v2](https://img.shields.io/badge/AutoHotkey-v2-blue?logo=autohotkey&logoColor=white)](https://www.autohotkey.com/)
[![Windows 10/11](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![License: MIT](https://img.shields.io/badge/License-MIT-2ea44f.svg)](LICENSE)
[![Status: Stable](https://img.shields.io/badge/Status-Stable-brightgreen)](https://github.com/LZKgood/NoTabKana/releases)

[**Features**](#features) · [**Installation**](#installation) · [**Key Bindings**](#key-bindings) · [**Limitations**](#known-limitations) · [**Changelog**](#changelog)

</div>

> [!NOTE]
> **NoTabKana** is a lightweight AutoHotkey v2 helper for the built-in Microsoft Japanese IME on Windows. It streamlines candidate selection and aims to make Japanese typing feel more fluid, with a workflow inspired by macOS.
>
> **日本語：** AutoHotkey v2 で開発された、Windows 標準の Microsoft 日本語 IME 向け入力支援スクリプトです。変換候補の選択操作を効率化し、よりスムーズな日本語入力を目指します。
>
> **简体中文：** NoTabKana 是一款基于 AutoHotkey v2 开发的 Windows 微软日语输入法增强脚本，旨在简化候选词选择操作，让日语输入更加流畅，并借鉴 macOS 的输入体验。

| **Platform** | **Input method** | **Implementation** | **License** |
|:---:|:---:|:---:|:---:|
| Windows 10 / 11 | Microsoft Japanese IME | AutoHotkey v2 | MIT |

> [!WARNING]
> **Stable release / 安定版 / 正式版 — v1.3.6**
>
> v1.3.6 is the current stable release. Stable means this version has been formally released; it does not imply perfect compatibility with every IME state, Windows configuration, or application. Please review the known limitations.
>
> v1.3.6 は現在の正式リリースです。安定版は正式にリリースされたバージョンを意味し、すべての IME 状態、Windows 環境、アプリケーションでの完全な互換性を保証するものではありません。既知の制限事項をご確認ください。
>
> v1.3.6 是当前正式发布的稳定版本。“正式版”表示该版本已正式发布，并不意味着它能与所有输入法状态、Windows 配置和应用程序完美兼容。请先阅读已知限制。

---

## 🧭 Navigate the README / 目次 / 文档导航

| Getting started | Design & reliability | Project information |
|---|---|---|
| ✨ [Features / 機能 / 功能](#features)<br>⌨️ [Key bindings / キー操作 / 按键说明](#key-bindings)<br>🚀 [Requirements / 動作環境 / 运行环境](#requirements)<br>📥 [Installation / インストール / 安装](#installation)<br>💡 [Usage examples / 使用例 / 使用示例](#usage-examples) | ⚙️ [How it works / 仕組み / 工作原理](#how-it-works)<br>🧠 [Why not IMM32? / IMM32 API を使わない理由](#design-tradeoff)<br>🔄 [Why Down instead of Tab?](#why-down-instead-of-tab)<br>🧪 [Self-test / 自检](#self-test)<br>⚠️ [Known limitations / 已知限制](#known-limitations) | 🔄 [Changelog / 更新日志](#changelog)<br>🛠️ [Troubleshooting / 故障排查](#troubleshooting)<br>🤝 [Contributing / 参与贡献](#contributing)<br>📄 [License / 许可证](#license)<br>⚠️ [Disclaimer / 免责声明](#disclaimer) |

---

<a id="features"></a>

## ✨ Features / 機能 / 功能

### 🇬🇧 English

- **Number-key candidate selection:** Use a number key to select a conversion candidate after tracked Japanese input.
- **Simplified candidate navigation:** Use `=` and `-` for candidate navigation and long-vowel-mark input.
- **Romaji buffer parsing:** Track romaji sequences and recognize common Japanese kana combinations.
- **Kana-unit tracking:** Maintain an internal representation of the input units to help handle Backspace operations.
- **Backspace handling:** Use a short debounce interval to reduce state errors caused by rapid deletion.
- **Automatic state recovery:** Monitor active-window changes, input-language changes, inactivity, and candidate-page timeouts.
- **Letter-key passthrough:** Allow letter keystrokes to continue to the underlying input system while the script tracks input.
- **Built-in self-tests:** Run automated logic checks without performing the normal candidate-selection actions during the test handlers.

### 🇯🇵 日本語

- **数字キーによる候補選択：** 日本語入力を追跡している状態で数字キーを押すと、変換候補の選択を補助します。
- **候補操作の簡略化：** `=` と `-` を使って候補の移動や長音記号の入力を行います。
- **ローマ字バッファ解析：** ローマ字の入力列を追跡し、一般的な日本語のかな入力パターンを認識します。
- **かな単位の追跡：** 内部で入力単位を管理し、Backspace による削除への対応を補助します。
- **Backspace 対策：** 短いデバウンス処理により、連続削除時の状態ずれを抑えます。
- **状態の自動リセット：** アクティブウィンドウ、入力言語、無操作時間、候補ページのタイムアウトを監視します。
- **英字キーの透過：** スクリプトが入力を追跡している間も、英字キーの入力を下位の入力システムへ通します。
- **セルフテスト機能：** 通常の候補選択操作を行わずに、スクリプトのロジックを自動テストできます。

### 🇨🇳 简体中文

- **数字键选择候选词：** 在脚本追踪到日语输入后，按数字键辅助选择转换候选词。
- **简化候选词翻页：** 使用 `=` 和 `-` 进行候选词导航或输入长音符号。
- **罗马字缓冲区解析：** 追踪罗马字输入序列，识别常见的日语假名组合。
- **假名单位追踪：** 在脚本内部维护输入单位信息，以辅助处理 Backspace 删除操作。
- **Backspace 处理：** 通过短暂的防抖机制，减少连续删除时的状态错误。
- **自动状态恢复：** 监测活动窗口变化、输入语言变化、长时间无操作及候选页超时。
- **字母按键透传：** 在追踪输入状态的同时，让字母按键继续传递给底层输入系统。
- **内置自检：** 运行自动化逻辑测试；测试处理程序不会执行正常的候选词选择操作。

---

<a id="key-bindings"></a>

## ⌨️ Key Bindings / キー操作 / 按键说明

| Key | English | 日本語 | 简体中文 |
|---|---|---|---|
| `A–Z` | Type romaji normally while the script tracks input. | ローマ字を通常どおり入力し、スクリプトが入力を追跡します。 | 正常输入罗马字，同时由脚本追踪输入状态。 |
| `0–9` | Attempt candidate selection when tracked kana input exists; otherwise pass the digit through. | 追跡中のかな入力がある場合は候補選択を試み、それ以外では数字をそのまま通します。 | 存在被追踪的假名输入时尝试选择候选词，否则直接透传数字。 |
| `=` | Send candidate-navigation keys to move forward. | 候補を進めるためのキー操作を送信します。 | 发送候选导航按键以向后移动。 |
| `-` | Enter the long-vowel mark during normal input; move backward when page mode is active. | 通常入力時は長音記号を入力し、ページモード中は前の候補ページへ移動します。 | 普通输入时输入长音符号；翻页模式下向前翻页。 |
| `Backspace` | Delete normally while updating the tracked state. | 通常どおり削除しながら、追跡状態を更新します。 | 正常执行删除，同时更新脚本追踪状态。 |
| `Enter` | Confirm input and reset the tracked state. | 入力を確定し、追跡状態をリセットします。 | 确认输入并重置追踪状态。 |
| `Esc` | Cancel the current input and reset the tracked state. | 現在の入力を取り消し、追跡状態をリセットします。 | 取消当前输入并重置追踪状态。 |
| Mouse click | Reset tracked state to reduce stale-state errors. | 古い状態が残るのを防ぐため、追跡状態をリセットします。 | 重置追踪状态，以减少残留状态造成的问题。 |

**Important / 注意 / 注意：** These are the script's intended key behaviors. Actual candidate selection and navigation depend on the current Microsoft IME state and candidate layout.

これらはスクリプトが想定するキー操作です。実際の候補選択や移動動作は、Microsoft IME の状態や候補表示によって異なる場合があります。

以上为脚本设计的按键行为。实际候选词选择和导航效果取决于微软日语输入法当前的状态及候选列表布局。

---

<a id="requirements"></a>

## 🚀 Requirements / 動作環境 / 运行环境

### 🇬🇧 English

- **Operating system:** Windows 10 or Windows 11
- **Runtime:** AutoHotkey v2
- **Input method:** Built-in Microsoft Japanese IME
- **Permissions:** Run with the permissions required by your target application. Administrator privileges should not be assumed to be necessary for every environment.

Third-party IMEs such as Google Japanese Input and ATOK are not officially supported.

### 🇯🇵 日本語

- **OS：** Windows 10 または Windows 11
- **実行環境：** AutoHotkey v2
- **入力方式：** Windows 標準の Microsoft 日本語 IME
- **権限：** 対象アプリケーションの権限に応じて実行してください。すべての環境で管理者権限が必要というわけではありません。

Google 日本語入力や ATOK などのサードパーティ製 IME は、公式サポートの対象外です。

### 🇨🇳 简体中文

- **操作系统：** Windows 10 或 Windows 11
- **运行环境：** AutoHotkey v2
- **输入法：** Windows 内置微软日语输入法
- **运行权限：** 根据目标应用程序的权限要求运行，不应默认认为所有环境都必须使用管理员权限。

Google 日语输入法、ATOK 等第三方输入法暂不属于官方支持范围。

---

<a id="installation"></a>

## 📥 Installation / インストール / 安装

### 🇬🇧 English

1. Install [AutoHotkey v2](https://www.autohotkey.com/).
2. Open the [NoTabKana GitHub repository](https://github.com/LZKgood/NoTabKana/tree/main).
3. Download the main `.ahk` script from the repository.
4. Double-click the script to launch it.
5. Confirm that the AutoHotkey icon appears in the system tray.
6. Switch to Microsoft Japanese IME and try the usage examples below.

To stop the script, right-click its system-tray icon and select the exit option.

### 🇯🇵 日本語

1. [AutoHotkey v2](https://www.autohotkey.com/) をインストールします。
2. [NoTabKana の GitHub リポジトリ](https://github.com/LZKgood/NoTabKana/tree/main) を開きます。
3. リポジトリからメインの `.ahk` スクリプトをダウンロードします。
4. スクリプトをダブルクリックして起動します。
5. タスクトレイに AutoHotkey のアイコンが表示されていることを確認します。
6. Microsoft 日本語 IME に切り替え、下記の使用例を試します。

終了するには、タスクトレイのアイコンを右クリックし、終了メニューを選択してください。

### 🇨🇳 简体中文

1. 安装 [AutoHotkey v2](https://www.autohotkey.com/)。
2. 打开 [NoTabKana 的 GitHub 仓库](https://github.com/LZKgood/NoTabKana/tree/main)。
3. 下载仓库中的主 `.ahk` 脚本文件。
4. 双击脚本启动程序。
5. 确认系统托盘中出现 AutoHotkey 图标。
6. 切换到微软日语输入法，尝试下方的使用示例。

如需退出脚本，右键单击系统托盘中的图标，然后选择退出。

---

<a id="usage-examples"></a>

## 💡 Usage Examples / 使用例 / 使用示例

### Example 1 — Candidate selection / 候補選択 / 选择候选词

**English**

1. Switch to Microsoft Japanese IME.
2. Type `kawa`.
3. Press `1` while the composition is being tracked.
4. NoTabKana attempts to open candidate navigation and select the first candidate.

For example, the desired result may be `川`, depending on the IME's conversion results and candidate order.

**日本語**

1. Microsoft 日本語 IME に切り替えます。
2. `kawa` と入力します。
3. 入力が追跡されている状態で `1` を押します。
4. NoTabKana が候補操作を開始し、最初の候補の選択を試みます。

変換結果や候補の順序によっては、`川` などが候補として表示されます。

**简体中文**

1. 切换到微软日语输入法。
2. 输入 `kawa`。
3. 在脚本仍追踪这段输入时按 `1`。
4. NoTabKana 会尝试打开候选导航并选择第一个候选词。

根据输入法的转换结果和候选词顺序，目标结果可能是 `川`。

### Example 2 — Long-vowel mark / 長音記号 / 长音符号

**English**

1. Type `bi`.
2. Press `-` during normal input.
3. Continue typing `ru`.

The intended result is `ビール`. The exact output depends on how the active IME handles the forwarded key.

**日本語**

1. `bi` と入力します。
2. 通常の入力状態で `-` を押します。
3. 続けて `ru` と入力します。

想定される入力結果は `ビール` です。実際の出力は、使用中の IME によるキー処理に依存します。

**简体中文**

1. 输入 `bi`。
2. 在普通输入状态下按 `-`。
3. 继续输入 `ru`。

预期输入结果为 `ビール`。实际输出取决于当前输入法如何处理传递过去的按键。

### Example 3 — Candidate navigation / 候補移動 / 候选词导航

**English**

- Press `=` to trigger the configured forward-navigation sequence.
- While page mode is active, press `-` to trigger backward navigation.
- Press a number key to attempt to select a candidate.

**日本語**

- `=` を押すと、設定された次候補への移動操作を実行します。
- ページモード中に `-` を押すと、前の候補への移動を試みます。
- 数字キーを押すと、候補の選択を試みます。

**简体中文**

- 按 `=` 执行脚本配置的向后导航操作。
- 翻页模式激活时，按 `-` 尝试向前翻页。
- 按数字键尝试选择候选词。

> **Note / 注意 / 注意**
> Candidate navigation is state-dependent. If the IME is not showing the expected candidate interface, the same key sequence may produce a different result.

> 候補操作は IME の状態に依存します。想定した候補画面が表示されていない場合、同じキー操作でも結果が異なることがあります。

> 候选词导航取决于输入法状态。如果输入法没有处于预期的候选界面，同一组按键也可能产生不同结果。

---

<a id="how-it-works"></a>

## ⚙️ How It Works / 仕組み / 工作原理

### 🇬🇧 English

NoTabKana uses keyboard-event tracking and an internal romaji buffer rather than reading the Microsoft IME's private composition buffer.

Its workflow is:

1. **Capture and pass through:** Letter keys continue to the underlying input system while the script observes them.
2. **Buffer:** Romaji sequences are recorded in an internal buffer.
3. **Parse:** The parser recognizes supported romaji patterns and updates the tracked kana units.
4. **Handle special keys:** Number keys and navigation keys trigger actions according to the script's tracked state.
5. **Recover:** Window changes, input-language changes, inactivity, and other reset events help clear stale state.

The internal buffer is only an estimate of the IME's actual composition. It cannot perfectly detect every edit or state change made by the IME itself.

### 🇯🇵 日本語

NoTabKana は、Microsoft IME の非公開の変換バッファを直接読み取るのではなく、キーボードイベントと内部のローマ字バッファを使って入力状態を追跡します。

処理の流れは次のとおりです。

1. **入力の透過と監視：** 英字キーを入力システムへ通しながら、その入力をスクリプトが監視します。
2. **バッファリング：** ローマ字の入力列を内部バッファに記録します。
3. **解析：** 対応するローマ字パターンを認識し、追跡対象のかな単位を更新します。
4. **特殊キーの処理：** 数字キーや候補操作キーを、追跡状態に応じて処理します。
5. **状態の復旧：** ウィンドウや入力言語の変更、無操作時間などを利用して、古い状態の解消を試みます。

内部バッファは IME の実際の変換状態を推定したものです。IME 側で発生するすべての編集や状態変化を完全に検出できるわけではありません。

### 🇨🇳 简体中文

NoTabKana 不会直接读取微软输入法的私有组合缓冲区，而是通过键盘事件和内部罗马字缓冲区追踪输入状态。

工作流程如下：

1. **透传与监测：** 字母按键继续传递给底层输入系统，同时由脚本观察这些按键。
2. **缓冲：** 将罗马字输入序列记录到内部缓冲区。
3. **解析：** 识别脚本支持的罗马字组合，并更新内部追踪的假名单位。
4. **特殊按键处理：** 根据当前追踪状态处理数字键和候选导航按键。
5. **状态恢复：** 利用窗口变化、输入语言变化、无操作超时等机制，尝试清理过期状态。

内部缓冲区只是对输入法实际组合状态的估算，无法完美识别输入法内部发生的所有编辑和状态变化。

---

<a id="design-tradeoff"></a>

## 🧠 Design Tradeoff: Why Not Use IMM32 IME API Directly / 設計上のトレードオフ：IMM32 IME APIを直接使わない理由 / 设计取舍：为何不直接调用 IMM32 IME API

### 🇬🇧 English

Many Japanese input helper tools use IMM32 API such as `ImmGetCompositionStringW` to read IME composition text. However, **NoTabKana does NOT rely on native IME APIs**. Instead, it uses a self-managed local romaji buffer parser. The reasons:

1. IMM32 API can only read **converted kana text**, not the raw romaji keys you typed.
   Microsoft Japanese IME converts romaji to kana internally. IMM API returns only kana characters like `か` or `きゃ`. It cannot get the original input sequence like `ka` / `kya`.
   This project relies on raw romaji string to split kana units, detect sokuon(っ), youon(拗音) and implement unit-wise backspace (erase whole kana unit in one backspace press). Without raw romaji, these core features cannot be implemented.

2. Poor compatibility across popular applications.
   IMM32 only works on native Win32 windows (e.g. Notepad). It fails on:
   - Chromium / Electron apps: Chrome, VSCode, Obsidian, Discord
   - UWP apps and most games (UIPI security isolation blocks IME context access)
   When API read fails, candidate selection / page flipping features break entirely.

3. IME message event timing is uncontrollable and introduces latency.
   `WM_IME_COMPOSITION` fires **after IME updates its composition buffer**. There is inherent delay between keypress and message arrival, which breaks the real-time romaji parsing required for this script.

4. Candidate list parsing is fragile across Windows versions.
   Although `GCS_CANDIDATES` exists for reading candidates, the memory layout varies on different Windows builds. Parsing code is easy to break on different user environments. And it still cannot retrieve raw romaji.

5. Bound exclusively to Microsoft Japanese IME.
   IMM32 API only works for Microsoft IME. It stops working completely if users switch to Google Japanese Input, ATOK or other third-party Japanese IME.
   The current keystroke-based implementation has no hard dependency on a specific IME backend.

> Optional branch note:
> An optional IMM API branch can be implemented for cross-checking kana state, but it **cannot replace the local romaji parser**. Removing local buffer entirely will lose unit backspace and romaji parsing features.

### 🇯🇵 日本語

多くの日本語入力補助ツールは`ImmGetCompositionStringW`などIMM32 APIを利用し、IMEの変換中テキストを読み取ります。しかし本プロジェクト NoTabKana では**IMEのネイティブAPIに依存せず、ローカルでローマ字バッファを管理・解析する方式を採用しています**。理由は以下の通りです。

1. IMM32 APIは**変換後の仮名しか取得できず、入力した元のローマ字文字列を取得できない**
Microsoft日本語IMEは内部でローマ字を仮名に変換します。IMM APIから取得できるのは「か」「きゃ」のような仮名だけで、打ち込んだ`ka`や`kya`といった元のローマ字シーケンスは取得不可能です。
本ツールのコア機能はローマ字文字列をもとに仮名単位へ分割、促音・拗音・「ん」の判別、**単位単位のバックスペース（拗音を一括削除）**を実現しています。元のローマ字が取得できない場合、これらの機能を実装できません。

2. 対応アプリケーションの互換性が極端に低い
IMM32 APIはメモ帳など**標準Win32ウィンドウでのみ正常動作**します。
Electron/Chromium製アプリ(Chrome、VSCode、Obsidian、Discord)、UWPアプリ、多くのゲームではUIPIのセキュリティ制限によりIMEコンテキストを取得できず読み取りが失敗します。APIが失敗すると候補選択・ページ送り機能が完全に動作しなくなります。

3. IMEイベントの発火タイミング制御が難しく、遅延や状態のズレが発生する
`WM_IME_COMPOSITION`メッセージはIME内部の変換完了後に送られるため、キー入力からイベントまでに遅延が発生します。リアルタイムでローマ字解析を行う本スクリプトには不向きです。

4. 候補一覧取得APIはWindowsバージョン間で挙動が不安定
`GCS_CANDIDATES`で候補リストを読み出すことは可能ですが、Windowsのバージョンごとにメモリレイアウトに差異があり、環境によって動作しない可能性が高いです。また、元のローマ字が取得できない根本的な問題は解決しません。

5. Microsoft日本語IME専用になってしまう
IMM32はWindows標準Microsoft IME向けのAPIです。Google日本語入力、ATOKなど他の日本語IMEに切り替えると、API機能が完全に動作しなくなります。
現在のキー入力を監視する実装は特定IMEに依存しないため、拡張性が高いです。

> 補足：
> IMM APIをオプション機能として追加し、仮名の状態を検証する分岐は作成可能です。ただし**ローカルローマ字パーサーの代替にはなりません**。ローカルバッファを完全に削除しIME API依存にすると、単位バックスペースやローマ字解析機能が失われます。

### 🇨🇳 简体中文

很多同类日语输入辅助工具会使用 `ImmGetCompositionStringW` 等 IMM32 API 读取输入法预编辑文本。本项目 **NoTabKana** 最终选择**不依赖 IME 原生API**，采用**本地罗马音缓冲区自主解析**方案，原因如下：

1. **IMM32 API 只能读取「已经转换完成的假名」，无法获取用户输入的原始罗马音**
微软日语IME内部流程：用户输入罗马音 → IME内部转换为假名。IMM API 拿到的输出只有假名文本（`か`、`きゃ`、`っ`），**拿不到用户敲的原始字母序列 `ka` / `kya` / `tta`**。
本项目核心逻辑依赖罗马音串进行假名单元拆分、促音/拗音/ん识别、单元级退格（一键删除整个拗音，而不是单个字符）。缺少原始罗马音，精细的单元退格、罗马音语法解析功能无法实现。

2. **API 兼容性严重受限，大量常用软件直接读取失败**
IMM32 仅对**标准Win32原生窗口（记事本等）**有效。
- 基于 Electron / Chromium 的软件：Chrome、VSCode、Obsidian、Discord 等网页壳程序，IME上下文隔离，`ImmGetContext` 返回空，读取失败。
- UWP应用、大部分游戏输入框：UIPI权限隔离，无法获取IME合成文本。
一旦API读取失败，脚本候选选词、翻页全部失效，体验不稳定。

3. **事件触发时机不可控，容易产生状态不同步**
IME的 `WM_IME_COMPOSITION` 消息是**IME内部状态变更后才推送**。按键按下 → 系统处理IME → 触发消息，存在延迟。
本脚本需要**按键按下瞬间立刻处理罗马音缓存**，依赖API事件会造成按键处理滞后、候选选词时序错乱。

4. **候选词读取接口复杂，跨Windows版本行为不一致**
虽然 IMM32 支持读取候选列表（`GCS_CANDIDATES`），但不同Windows版本、补丁下，候选数据内存排布有差异，解析代码极易在部分用户环境报错。
并且读取候选词依然**不能解决上面「无原始罗马音」的核心缺陷**。

5. **绑定微软日语IME，换输入法直接失效**
IMM这套API是Windows微软自带日文IME专属。如果用户切换到 Google日本入力、ATOK等第三方日语输入法，整个IME API模块直接失效。
当前按键捕获方案不绑定特定IME底层接口，扩展性更强。

> ✅ 备选方案说明：
> 理论上可以做「IMM API可选分支」，用API读取假名做状态校验，但**不能完全替换本地罗马音解析缓冲区**，只能作为辅助校正，无法替代核心逻辑。
> 若强行完全移除本地缓冲区、全部依赖IME API，会直接丢失核心特性：**单元级智能退格、促音/拗音罗马音解析**。

---

<a id="why-down-instead-of-tab"></a>

## 🔄 Why Down Instead of Tab? / Tab ではなく Down を使う理由 / 为什么使用 Down 而不是 Tab

### 🇬🇧 English

Earlier versions of NoTabKana used `Tab` to initiate candidate selection. In v1.3.5-Beta, the script uses `Down` (`↓`) as its default candidate-navigation key sequence.

The reasons for this design change are:

- To explore a candidate-selection workflow that relies less on `Tab`.
- To reduce unwanted interactions with applications that use `Tab` for focus navigation.
- To simplify the script's candidate-navigation logic and state handling.

This change does not guarantee that `Down` will behave identically in every IME state. Microsoft Japanese IME may handle `Down` differently depending on whether composition, conversion, or a candidate list is active.

### 🇯🇵 日本語

以前の NoTabKana では、候補選択を開始するために `Tab` を使用していました。v1.3.5-Beta では、候補操作の既定キーとして `Down`（`↓`）を使用する方式に変更しました。

主な理由は次のとおりです。

- `Tab` への依存を減らした候補選択フローを検討するため。
- アプリケーション側のフォーカス移動に `Tab` が使われる場合の意図しない干渉を減らすため。
- 候補操作のロジックと状態管理を簡潔にするため。

ただし、すべての IME 状態で `Down` が同じように動作することを保証するものではありません。変換中か、候補一覧が表示されているかなどによって、Microsoft 日本語 IME の動作は異なる場合があります。

### 🇨🇳 简体中文

早期版本的 NoTabKana 使用 `Tab` 启动候选词选择流程。从 v1.3.5-Beta 开始，默认改用 `Down`（`↓`）作为候选导航按键。

此次调整主要出于以下考虑：

- 尝试减少候选词选择流程对 `Tab` 的依赖。
- 降低 `Tab` 与应用程序焦点切换操作发生意外交互的可能性。
- 简化候选词导航逻辑和状态管理。

这并不意味着 `Down` 在所有输入法状态下都会有完全相同的行为。微软日语输入法可能会根据当前是否正在组合输入、是否处于转换状态，以及候选列表是否显示，采用不同的按键处理方式。

---

<a id="self-test"></a>

## 🧪 Self-Test / セルフテスト / 自检

### 🇬🇧 English

NoTabKana includes a built-in test mode for checking supported script logic without running the normal candidate-selection handlers.

If your AutoHotkey v2 executable is available as `AutoHotkey.exe`, you can try:

```powershell
AutoHotkey.exe "NoTabKana.ahk" test
```

Replace `NoTabKana.ahk` with the actual script filename. Check the script directory for `selftest.log` after the test finishes.

A successful self-test indicates that the tested logic passed. It does **not** prove that synthetic key events will behave correctly in every Microsoft IME state or application.

### 🇯🇵 日本語

NoTabKana には、通常の候補選択処理を実行せずに、対応するスクリプトロジックを確認するためのテストモードがあります。

AutoHotkey v2 の実行ファイルが `AutoHotkey.exe` として利用できる場合、次のコマンドを試してください。

```powershell
AutoHotkey.exe "NoTabKana.ahk" test
```

`NoTabKana.ahk` は実際のスクリプトファイル名に置き換えてください。テスト終了後、スクリプトのフォルダーに `selftest.log` が生成されているか確認します。

セルフテストの成功は、テスト対象のロジックが正常に動作したことを示します。ただし、すべての Microsoft IME の状態やアプリケーションで、合成キー入力が正常に動作することを保証するものではありません。

### 🇨🇳 简体中文

NoTabKana 内置了测试模式，可以在不执行常规候选词选择处理程序的情况下，检查脚本中的部分逻辑。

如果 AutoHotkey v2 的可执行文件可以通过 `AutoHotkey.exe` 调用，可以尝试运行：

```powershell
AutoHotkey.exe "NoTabKana.ahk" test
```

请将 `NoTabKana.ahk` 替换为实际脚本文件名。测试完成后，检查脚本所在目录中是否生成了 `selftest.log`。

自检通过只代表被测试的逻辑通过了检查，**不代表**合成按键在所有微软日语输入法状态和应用程序中都能正常工作。

---

<a id="known-limitations"></a>

## ⚠️ Known Limitations / 制限事項 / 已知限制

### 🇬🇧 English

Please keep the following limitations in mind:

1. **IME state is inferred.** NoTabKana tracks keyboard input and does not directly read the IME's private composition buffer.
2. **Candidate behavior varies.** Candidate order, candidate-window behavior, and navigation results depend on Microsoft Japanese IME.
3. **Synthetic keys are not physical keystrokes.** Applications and IME components may process generated key events differently from physical keyboard input.
4. **Editing can desynchronize the buffer.** Complex deletion, cursor movement, mouse interactions, or unusual input sequences may cause the internal state to diverge from the IME.
5. **Compatibility is limited.** Third-party IMEs and unusual application environments have not been established as supported targets.
6. **Beta stability is not guaranteed.** The script may need further testing and adjustment.

### 🇯🇵 日本語

次の制限事項にご注意ください。

1. **IME 状態は推定値です。** NoTabKana はキーボード入力を追跡しますが、IME の非公開の変換バッファを直接読み取りません。
2. **候補の動作は環境に依存します。** 候補の順序、候補ウィンドウの動作、移動結果は Microsoft 日本語 IME の状態によって異なります。
3. **合成キー入力は物理キー入力と同じではありません。** アプリケーションや IME が、スクリプトから送信されたキーイベントを異なる方法で処理する場合があります。
4. **編集操作で状態がずれる可能性があります。** 複雑な削除、カーソル移動、マウス操作、特殊な入力列によって、内部状態と IME の状態が一致しなくなる場合があります。
5. **互換性には制限があります。** サードパーティ製 IME や特殊なアプリケーション環境での動作は、サポート対象として確立されていません。
6. **ベータ版の安定性は保証されません。** 今後も検証や調整が必要になる可能性があります。

### 🇨🇳 简体中文

请注意以下限制：

1. **输入法状态是推测出来的。** NoTabKana 追踪键盘输入，但不会直接读取输入法的私有组合缓冲区。
2. **候选词行为因状态而异。** 候选顺序、候选窗口行为和导航结果取决于微软日语输入法的实际状态。
3. **模拟按键不等于物理按键。** 应用程序和输入法组件可能会以不同方式处理脚本发送的按键事件。
4. **编辑操作可能造成状态不同步。** 复杂删除、光标移动、鼠标操作或特殊输入序列，都可能导致脚本内部状态与输入法实际状态不一致。
5. **兼容性存在限制。** 第三方输入法和特殊应用程序环境尚未被确认为支持目标。
6. **测试版稳定性不作保证。** 项目仍可能需要进一步测试和调整。

---

<a id="changelog"></a>

## 🔄 Changelog / 更新履歴 / 更新日志

## Changelog
### v1.3.6
> Optimization release, bugfix only, no new features. Fully backward compatible with
> 最適化リリース、不具合修正のみで新機能追加なし。v1.3.5と完全に下位互換があります。
> 优化版本，仅Bug修复，无新增功能。与v1.3.5完全向下兼容。

 v1.3.5.

**简体中文**
1. 【核心修复】重构数字键热键判定逻辑，解决旧版日语输入法下，未在假名输入状态时数字键依然被脚本捕获的穿透问题。
   - 现在仅日语IME(LangID=1041) + 假名输入模式开启时，才接管数字按键处理候选；
   - 不在假名输入状态时，数字键原生直接穿透，AHK不再拦截，消除多余开销与微小延迟。
2. 代码改为静态热键声明，结构更清晰，便于后续维护迭代。
3. 完全向下兼容：罗马音解析、退格防抖、看门狗、候选翻页等全部原有逻辑不变，自检全部通过。
4. 【优化】优化按键消息拦截逻辑，**避免抢占键盘消息**。游戏、BongoCat桌宠等第三方程序可正常接收键盘输入，解决因脚本劫持按键导致桌宠动作失效、游戏按键无响应的问题。

**English**
1. 【Core Fix】Refactored number key hotkey condition. Fixed the pass-through bug in old version: number keys were captured by script even when kana input was inactive under Japanese IME.
   - Number keys are only intercepted for candidate selection when Japanese IME (LangID=1041) AND kana mode is active;
   - When kana mode is off, number keys pass natively to system without AHK interception, removing redundant overhead and minor latency.
2. Rewrote hotkeys as static declarations for cleaner code and easier maintenance.
3. Full backward compatibility: Romaji parser, backspace debounce, watchdog, candidate page controls and other functions unchanged. All self-tests passed.
4. 【Optimization】Improved key interception logic to prevent grabbing keyboard messages. Third-party applications such as games and BongoCat desktop pet can receive keyboard input normally. Fixed the issue where the script occupied key messages and caused desktop pet actions or in-game key inputs to stop working.

**日本語**
1. 【核心修正】数字キーのホットキー判定ロジックを再構築。旧バージョンで、仮名入力中ではないにもかかわらず数字キーがスクリプトに捕捉されてしまう透過問題を解消。
   - 日本語IME(1041) かつ 仮名入力モード有効時のみ数字キーを捕捉して変換候補操作を実行；
   - 仮名入力モードがオフの場合、数字キーはシステム側にそのまま透過、AHKの介入がなくなり、余分な処理と微細な遅延を除去。
2. ホットキーを静的定義に変更、コード構造が整理され保守しやすくなった。
3. 完全な下位互換：ローマ字解析、バックスペースデバウンス、ウォッチドッグ、候補ページ送りなど既存機能は全てそのまま、自動テストも全て合格。
4. 【最適化】キー入力の横取りを回避するように処理ロジックを改善。ゲームやBongoCatデスクトップペットなどのサードパーティソフトがキー入力を正常に受け取れるようになり、スクリプトによるキー奪取が原因でデスクトップペットの動作やゲームのキー操作が無効になる不具合を解消。

---

### v1.3.5-Beta

**简体中文**
- 围绕内部罗马字缓冲区和解析器，重新整理输入追踪机制。
- 增加对常见假名组合的识别，包括拗音、促音和拨音相关序列。
- 通过防抖机制改进 Backspace 状态追踪。
- 增加针对窗口变化、输入语言变化、无操作超时和候选页超时的状态恢复检查。
- 将候选操作的启动方式从 `Tab` 改为 `Down`。
- 增加内置自检模式。
- 调整输入状态追踪与重置逻辑。

**English**
- Reworked input tracking around an internal romaji buffer and parser.
- Added recognition of common kana combinations, including contracted sounds, geminate consonants, and syllabic nasal sequences.
- Improved Backspace tracking with a debounce mechanism.
- Added state-recovery checks for window changes, input-language changes, inactivity, and candidate-page timeouts.
- Changed the candidate-entry approach from `Tab` to `Down`.
- Included a built-in self-test mode.
- Refined input-state tracking and reset handling.

**日本語**
- 内部ローマ字バッファと解析処理を中心に、入力追跡の仕組みを見直しました。
- 拗音、促音、撥音を含む一般的なかな入力パターンの認識を追加しました。
- デバウンス処理により Backspace の追跡を改善しました。
- ウィンドウ変更、入力言語変更、無操作時間、候補ページのタイムアウトに対する状態復旧処理を追加しました。
- 候補操作の開始方法を `Tab` から `Down` に変更しました。
- セルフテストモードを追加しました。
- 入力状態の追跡とリセット処理を調整しました。
## 🛠️ Troubleshooting / トラブルシューティング / 故障排查

### 🇬🇧 English

**The number key does not select a candidate.**

- Confirm that Microsoft Japanese IME is active.
- Ensure that the script is running.
- Check whether the IME is in the expected composition or candidate-selection state.
- Try reproducing the issue with a short, simple input sequence.

**The script behaves unexpectedly after Backspace or mouse interaction.**

- The internal buffer may no longer match the IME's actual composition.
- Cancel the current composition or switch focus and retry.
- If the issue persists, report the exact steps that reproduce it.

**The self-test command does not run.**

- Confirm that AutoHotkey v2 is installed.
- Check the script filename and executable path.
- Review any error message and the generated `selftest.log`, if available.

### 🇯🇵 日本語

**数字キーで候補を選択できない場合**

- Microsoft 日本語 IME が有効になっていることを確認してください。
- スクリプトが起動していることを確認してください。
- IME が想定する入力中または候補選択中の状態になっているか確認してください。
- 短く単純な入力列で問題を再現できるか試してください。

**Backspace やマウス操作の後に動作がおかしくなる場合**

- 内部バッファと IME の実際の入力状態が一致していない可能性があります。
- 現在の入力を取り消すか、フォーカスを切り替えてから再試行してください。
- 問題が続く場合は、再現手順を具体的に報告してください。

**セルフテストを実行できない場合**

- AutoHotkey v2 がインストールされていることを確認してください。
- スクリプトのファイル名と実行ファイルのパスを確認してください。
- エラーメッセージと、生成されている場合は `selftest.log` を確認してください。

### 🇨🇳 简体中文

**按数字键无法选择候选词**

- 确认当前使用的是微软日语输入法。
- 确认脚本已经正常启动。
- 检查输入法是否处于预期的组合输入或候选选择状态。
- 尝试使用简短、简单的输入序列复现问题。

**Backspace 或鼠标操作后脚本行为异常**

- 内部缓冲区可能已与输入法的实际组合状态不同步。
- 尝试取消当前输入，或切换焦点后重新输入。
- 如果问题仍然存在，请记录并提交具体复现步骤。

**自检命令无法运行**

- 确认已安装 AutoHotkey v2。
- 检查脚本文件名和可执行文件路径。
- 查看报错信息，以及存在时生成的 `selftest.log`。

---

<a id="contributing"></a>

## 🤝 Contributing / コントリビューション / 参与贡献

### 🇬🇧 English

Contributions are welcome, including:

- Bug reports and reproducible test cases
- Compatibility testing
- Code improvements
- Documentation corrections and translations
- Feature suggestions

Before submitting a report, please check existing Issues and include your Windows version, AutoHotkey v2 version, reproduction steps, and expected versus actual behavior.

### 🇯🇵 日本語

以下のような貢献を歓迎します。

- バグ報告と再現可能なテストケース
- 互換性の検証
- コードの改善
- ドキュメントの修正と翻訳
- 機能の提案

報告の前に既存の Issue を確認し、Windows と AutoHotkey v2 のバージョン、再現手順、期待する動作と実際の動作を記載してください。

### 🇨🇳 简体中文

欢迎通过以下方式参与项目：

- 提交 Bug 报告和可复现的测试案例
- 测试不同环境下的兼容性
- 改进代码
- 修正文档或参与翻译
- 提出功能建议

提交问题前，请先检查已有的 Issues，并尽量附上 Windows 版本、AutoHotkey v2 版本、复现步骤，以及预期行为与实际行为的差异。

---

<a id="license"></a>

## 📄 License / ライセンス / 许可证

### 🇬🇧 English

This project is released under the [MIT License](LICENSE). See the `LICENSE` file for the complete license text.

### 🇯🇵 日本語

本プロジェクトは [MIT License](LICENSE) のもとで公開されています。ライセンスの全文は `LICENSE` ファイルをご確認ください。

### 🇨🇳 简体中文

本项目采用 [MIT License](LICENSE) 开源许可证。完整许可条款请参阅仓库中的 `LICENSE` 文件。

---

<a id="disclaimer"></a>

## ⚠️ Disclaimer / 免責事項 / 免责声明

### 🇬🇧 English

NoTabKana is provided **as is**, without warranties of any kind, to the extent permitted by applicable law.

The script sends keyboard events and tracks input state. Unexpected behavior may affect text entry or keyboard-driven interactions in the active application. The project does not guarantee compatibility with every Windows configuration, IME state, or application.

Use the beta version at your own discretion. Please save important work before testing and report reproducible issues through GitHub Issues.

### 🇯🇵 日本語

NoTabKana は、適用される法律で認められる範囲において、いかなる保証も付さず「現状のまま」提供されます。

本スクリプトはキーボードイベントを送信し、入力状態を追跡します。予期しない動作によって、アクティブなアプリケーションでの文字入力やキー操作に影響が出る場合があります。すべての Windows 環境、IME の状態、アプリケーションとの互換性を保証するものではありません。

ベータ版の利用は自己責任でお願いします。テスト前に重要な作業を保存し、再現可能な問題は GitHub Issues から報告してください。

### 🇨🇳 简体中文

NoTabKana 按「现状」提供，在适用法律允许的范围内不作任何形式的保证。

本脚本会发送键盘事件并追踪输入状态。意外行为可能影响当前应用程序中的文字输入或键盘操作。本项目不保证能够兼容所有 Windows 配置、输入法状态和应用程序。

使用测试版的风险由使用者自行承担。测试前请保存重要工作；如遇到可复现的问题，欢迎通过 GitHub Issues 反馈。

---

**Made for a smoother Japanese typing workflow.**
**より快適な日本語入力環境を目指して。**
**让日语输入更加流畅。**
