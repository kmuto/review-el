[![MELPA](https://melpa.org/packages/review-mode-badge.svg)](https://melpa.org/#/review-mode)

# Re:VIEW mode for Emacs

review-mode.el は、Re:VIEWファイル (reファイル) の作成・変更を支援する Emacs モードです。

## セットアップ

### Emacs のパッケージングシステムを使わない場合
review-mode.el を適当なロードパスに配置した上で、review-mode を読み込んでください。

```elisp
(autoload 'review-mode "review-mode" "Re:VIEW Mode" t)
```

### Emacs のパッケージングシステムを使う場合
[package.el](https://emacs-jp.github.io/packages/package-management/package-el) を用いて、
review-mode.el をパッケージとしてインストールすることも可能です。
MELPA に [review-mode](https://melpa.org/#/review-mode) として登録されているので、
下記を設定ファイルに追加して読み込み直した上で、 `M-x package-install` を実行すればインストールと設定ができます。

```elisp
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
```

パッケージの設定管理に [leaf](https://github.com/conao3/leaf.el) を使用している場合は、
leaf をインストールした上で、下記を設定ファイルに追加して読み込み直せばインストールと設定ができます。

```elisp
(leaf review-mode :ensure t)
```

## 機能
reファイルを開いたときに命令に応じたカラーリングが自動で施され、命令の記述ミスを防止できます。

有効になるショートカットは次のとおりです。

- C-c C-c ビルドを実行する。デフォルトの呼び出しはrake pdfのみだが、編集して実行すれば履歴に登録される

- C-c C-a ユーザーから編集者へのメッセージ擬似マーカー
- C-c C-k ユーザー注釈の擬似マーカー
- C-c C-d DTP担当へのメッセージ擬似マーカー
- C-c C-r 参照先をあとで確認する擬似マーカー
- C-c !   作業途中の擬似マーカー
- C-c C-t 1 作業者名の変更
- C-c C-t 2 DTP担当の変更

- C-c C-e 選択範囲をブロックタグで囲む。選択されていない場合は新規に挿入する。新規タブで補完可
- C-u C-c C-e 直前のブロックタグの名前を変更する
- C-c C-o 選択範囲を //beginchild 〜 //endchild で囲む
- C-c C-f C-f 選択範囲をインラインタグで囲む。選択されていない場合は新規に挿入する。タブで補完可
- C-c C-f b 太字タグ(@\<b\>)で囲む
- C-c C-f C-b 同上
- C-c C-f k キーワードタグ(@\<kw\>)で囲む
- C-c C-f C-k キーワードタグ(@\<kw\>)で囲む
- C-c C-f i イタリックタグ(@\<i\>)で囲む
- C-c C-f C-i 同上
- C-c C-f e 同上（review-use-em が t のときには強調タグ（@\<em\>）で囲む）
- C-c C-f C-e 同上（review-use-em が t のときには強調タグ（@\<em\>）で囲む）
- C-c C-f s 強調タグ(@\<strong\>)で囲む
- C-c C-f C-s 同上
- C-c C-f t 等幅タグ(@\<tt\>)で囲む
- C-c C-f C-t 同上
- C-c C-f u 同上
- C-c C-f C-u 同上
- C-c C-f a 等幅イタリックタグ(@\<tti\>)で囲む
- C-c C-f C-a 同上
- C-c C-f C-h ハイパーリンクタグ(@\<href\>)で囲む
- C-c C-f C-c コードタグ(@\<code\>)で囲む
- C-c C-f C-n 出力付き索引化(@\<idx\>)する

- C-c C-p =見出し挿入(レベルを指定)
- C-c C-b 吹き出しを入れる
- C-c CR  隠し索引(@\<hidx\>)を入れる
- C-c <   rawのHTML開きタグを入れる
- C-c >   rawのHTML閉じタグを入れる

- C-c 1   近所のURIを検索してブラウザを開く
- C-c 2   範囲をURIとしてブラウザを開く
- C-c (   全角(
- C-c 8   同上
- C-c )   全角)
- C-c 9   同上
- C-c [   【
- C-c ]    】
- C-c -    全角ダーシ
- C-c +    全角＋
- C-c *    全角＊
- C-c /    全角／
- C-c =    全角＝
- C-c \    ￥
- C-c SP   全角スペース
- C-c :    全角：

## カスタマイズの例
```
(setq review-mode-name "著者") ; コメントなどに入れる名前を「著者」とする
(setq review-mode-tip-name "注") ; 注を入れる際の名称を「注」とする
(setq review-use-skk-mode t) ; SKKを有効にした状態で開く
(setq review-use-em t) ; C-c C-f C-e で入るタグをiではなくemにする
```

## ライセンス
GNU General Public License version 3 (COPYING を参照してください)
