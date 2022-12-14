# VRM to GLB for Neos

## これなに

VRMをNeosVRでインポートしやすいように変換するツールです。  
Blenderに [VRM_Addon_for_Blender](https://vrm-addon-for-blender.info/) (iCyP様, saturday06様制作)を自動で導入し、いい感じに値を調整しGLBで出力します。

## 前提ツール

Blenderだけ入れてればOK。  
Blenderはversion3.0以降でのみ動作します(厳密には2.93 LTSまで動作確認していますが、今から導入する場合は3系をお勧めします)  
もしまだ入れていない方はこちらからどうぞ: https://www.blender.org/download/release/Blender3.2/blender-3.2.2-windows-x64.msi/

## ダウンロード

1. [ここのリンク](https://github.com/kazu0617/vrmtoglb_autoconvert/releases/latest)をクリックする
2. Source Code(zip) をダウンロードする

## 使い方

1. (ガイダンスに従い)Blenderをインストールする
2. _convert.batにvrmファイルをD&Dする -> vrmファイルがある場所を確認して、正常に変換できている場合はglbとテクスチャのフォルダが出力される
3. glbが出ない場合はガイダンスに従う
4. 生成されたglbが正常でない場合は `_convert_manual.bat` にvrmファイルを D&D する(ライセンス上問題ない必要があります)

## 備考

- Neosのインポート時の単位(「自動スケール」とかのやつ)は「メートル(m)」
- ライセンスチェックで引っかかったアバターは本当に入れて大丈夫か目視で確認してください
- 複数ファイルも動きます。まとめてD&Dしてください
- エラーチェックは随時行っています。GitHubのIssueに直接書いてもらうか、下の二人まで連絡お願いします
- 古いWindows10や8.1を使っているとたまに動かないことがあります。お手数ですが最新版のWindows10にアップデートしてください

## 連絡先(Pythonスクリプト)

- Twitter: @lill_azk  
- Neos: lill

## 改変連絡先(Batchスクリプト)

- Twitter: @Gameofthebest
- Neos: kazu

## ライセンスについて

一応MITで。そのうちMPLにするかも。
