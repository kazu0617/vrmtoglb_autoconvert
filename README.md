# VRM to GLB for Neos

## 注意点

NeosVRでインポートするためにこのツールにたどり着いた場合は、まず以下の項目を試してみてください。

1. vrm -> glbへの拡張子を変更してのインポート
  - 現在のUniVRMの最新版でgltf互換としてvrmが出力されている場合(最新のUniVRMから出力されている場合はたいていそうです)  
拡張子の変更のみで動作するようになっています。
2. UniVRMを用いたUnityでの変換
  - 最新版のUniVRMを用いてgltf互換としてvrmが出力されていない場合、この操作を行うことで改善されることがあります。  
**Unityのインストール、UnityのパーソナルLicenseが必要です**。

詳しくは以下のWikiにまとめております。わからない方がいれば以下のWikiを確認してください。  
https://neosvrjp.memo.wiki/d/VROID

こちらのツールはサポートを続けますが、上の操作を行っても改善されない場合、  
もしくは難しい・時間がない(特に2)場合はこのツールを試してみてもらえるとありがたいです。

## これなに

VRMをNeosVRでインポートしやすくするようにGLBへと変換するツールです。  
NeosVR以外でも利用していただけます。
Blenderに [VRM_Addon_for_Blender](https://vrm-addon-for-blender.info/) (iCyP様, saturday06様制作)を自動で導入し、いい感じに値を調整しGLBで出力します。

## 前提ツール

Blenderだけ入れてればOK。  
Blenderはversion3.0以降でのみ動作します(厳密には2.93 LTSまで動作確認していますが、今から導入する場合は3系をお勧めします)  
もしまだ入れていない方はこちらからどうぞ: [Blender公式サイト](https://www.blender.org/download/release/Blender3.4/blender-3.4.1-windows-x64.msi/)

## ダウンロード

1. [ここのリンク](https://github.com/kazu0617/vrmtoglb_autoconvert/archive/refs/heads/master.zip)をクリックする。
2. zip形式でDLされるので適宜解凍してください。

## 使い方

1. (ガイダンスに従い)Blenderをインストールする
2. _convert.batにvrmファイルをD&Dする -> vrmファイルがある場所を確認して、正常に変換できている場合はglbとテクスチャのフォルダが出力される
3. glbが出ない場合はガイダンスに従う
4. 生成されたglbが正常でない場合は `_convert_manual.bat` にvrmファイルを D&D する(ライセンス上問題ない必要があります)

## 処理内容

- secondaryオブジェクト,Colidersコレクション下にあるコライダーオブジェクトはVRM独自のもののため削除。
- VRoidなど、元々UpperChestのあるアバターをセットアップする際にArmature内にあるUpperChestに「<NOIK>」を追記（「<NOIK>UpperChest」）。
- MToonはVRM独自のマテリアルのため、GLBで正しく出力するためにプリンシプルBSDFに、またテクスチャはImage Textureに差し替え。
- セシル変身アバター向けに目のウェイト修正処理。

## 備考

- Neosのインポート時の単位(「自動スケール」とかのやつ)は「メートル(m)」
- ライセンスチェックで引っかかったアバターは本当に入れて大丈夫か目視で確認してください
- 複数ファイルも動きます。まとめてD&Dしてください
- エラーチェックは随時行っています。GitHubのIssueに直接書いてもらうか、下の二人まで連絡お願いします
- 古いWindows10や8.1を使っているとたまに動かないことがあります。お手数ですが最新版のWindows10にアップデートしてください
- Blenderのインストールされている階層が違う場合、環境変数で `BLENDER_LOCATION_OVERRIDE` にblender.exeの入っているフォルダを指定することで動作します。詳しくは「環境変数　設定方法」で検索して、よくわからない場合はデフォルトの階層にインストールしなおしてください。

## 連絡先(Pythonスクリプト)

- Twitter: @lill_azk  
- Neos: lill

## 改変連絡先(Batchスクリプト)

- Twitter: @Gameofthebest
- Neos: kazu

## ライセンスについて

一応MITで。そのうちMPLにするかも。
