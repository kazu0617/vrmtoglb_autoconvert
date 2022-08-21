# これなに
VRMをNeosVRでインポートしやすいように変換する
Blenderだけ入れてればOKにした

Blenderはversion3.0以降でのみ動作します(付属するblendファイルの関係上)

# 使い方
1. Blenderをインストールする
2. convert.batにvrmファイルをD&Dする
3. glbが出ない場合はlicense-check.batにvrmファイルをD&Dする
4. license-check後、出来る人は_convert_manual.batでvrmをD&D後、[N]キー -> VRM -> VRM ** Meta -> インポート時に怒られた問題を修正 -> 修正後 ファイル -> エクスポート -> VRM

# 備考
- Neosのインポート時の単位(「自動スケール」とかのやつ)は「メートル(m)」でうまくいく、はず
- ライセンス問題のあるvrmは動かない->_convert_manual.batで対応
- 複数ファイルも動く、と思う
- エラーチェックできてないので問題あれば下の二人まで

# 連絡先
Twitter: @lill_azk
Neos: lill

# 改変連絡先
Twitter: @Gameofthebest
Neos: kazu

