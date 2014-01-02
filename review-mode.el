;;; review-mode.el --- major mode for ReVIEW

;; Copyright 2007-2013 Kenshi Muto <kmuto@debian.org>

;; Author: Kenshi Muto <kmuto@debian.org>
;; URL: https://github.com/kmuto/review-el

;;; Commentary:

;; ReVIEW編集支援モード
;; License:
;;   GNU General Public License version 2 (see COPYING)

;; C-c C-a ユーザーから編集へのメッセージ
;; C-c C-k ユーザー注
;; C-c C-d DTPへのメッセージ
;; C-c C-r 参照先をあとで確認
;; C-c C-h =タイトル挿入
;; C-c 1   近所のURIを検索してブラウザを開く
;; C-c 2   範囲をURIとしてブラウザを開く
;; C-c !   作業途中を示す
;; C-c (   全角(
;; C-c )   全角)
;; C-c [   【
;; C-c ]    】
;; C-c -    −

;;; Code:

(run-hooks 'review-load-hook)

(defconst review-version "1.4"
  "編集モードバージョン")

;; 基本設定
(defvar review-load-hook nil
  "編集モードフック")

(defvar review-mode-map (make-sparse-keymap)
  "編集モードキーマップ")

(defvar review-highlight-face-list
  '(review-underline
    review-bold
    review-italic
    review-comment
    )
  "編集モードface")

(defvar review-name-list 
  '(("編集者" . "編集注")
    ("翻訳者" . "翻訳注")
    ("監訳" . "監注")
    ("著者" . "注")
    ("kmuto" . "注") ; ユーザーの名前で置き換え
    )
  "編集モードの名前リスト"
)
(defvar review-dtp-list
  '("DTP連絡")
  "DTP担当名リスト"
)

(defvar review-mode-name "監訳" "ユーザーの権限")
(defvar review-mode-tip-name "監注" "注釈時の名前")
(defvar review-mode-dtp "DTP連絡" "DTP担当の名前")
(defvar review-comment-start "◆→" "編集タグの開始文字")
(defvar review-comment-end "←◆" "編集タグの終了文字")
(defvar review-index-start "@<hidx>{" "索引タグの開始文字")
(defvar review-index-end "}" "索引タグの終了文字")
(defvar review-use-skk-mode nil "t:SKKモードで開始")

(defvar review-key-mapping
  '(
   ("[" . "【")
   ("]" . "】")
   ("(" . "（")
   (")" . "）")
   ("8" . "（")
   ("9" . "）")
   ("-" . "−")
   ("*" . "＊")
   ("/" . "／")
   ("\\" . "￥")
   (" " . "　")
   (":" . "：")
   ("<" . "<\\<>")
   )
  "全角置換キー")

(defvar review-uri-regexp "\\(\\b\\(s?https?\\|ftp\\|file\\|gopher\\|news\\|telnet\\|wais\\|mailto\\):\\(//[-a-zA-Z0-9_.]+:[0-9]*\\)?[-a-zA-Z0-9_=?#$@~`%&*+|\\/.,]*[-a-zA-Z0-9_=#$@~`%&*+|\\/]+\\)\\|\\(\\([^-A-Za-z0-9!_.%]\\|^\\)[-A-Za-z0-9._!%]+@[A-Za-z0-9][-A-Za-z0-9._!]+[A-Za-z0-9]\\)" "URI選択部分正規表現")

;; 編集モードベース関数
;;;###autoload
(defun review-mode ()
  "メジャー編集モード"
  (interactive)
  (kill-all-local-variables)

  (let ()

    (setq major-mode 'review-mode
	  mode-name review-mode-name
	  )
    
    (auto-fill-mode 0)
    (if review-use-skk-mode (skk-mode))

    (make-local-variable 'comment-start)
    (setq comment-start "#@#")

    ;; フェイス
    (require 'font-lock)

    (defcustom review-font-lock-keywords
	`(("◆→[^◆]*←◆" . review-mode-comment-face)
	  ("^#@.*" . review-mode-comment-face)
	  ("^======.*" . review-mode-header5-face)
	  ("^=====.*" . review-mode-header4-face)
	  ("^====.*" . review-mode-header3-face)
	  ("^===.*" . review-mode-header2-face)
	  ("^==.*" . review-mode-header1-face)
	  ("^=.*" . review-mode-title-face)
	  ("@<list>{.*?}" . review-mode-ref-face)
	  ("@<img>{.*?}" . review-mode-ref-face)
	  ("@<table>{.*?}" . review-mode-ref-face)
	  ("@<fn>{.*?}" . review-mode-ref-face)
	  ("@<chap>{.*?}" . review-mode-ref-face)
	  ("@<title>{.*?}" . review-mode-ref-face)
	  ("@<chapref>{.*?}" . review-mode-ref-face)
	  ("@<u>{.*?}" . review-mode-underline-face)
	  ("@<tt>{.*?}" . review-mode-underline-face)
	  ("@<ttbold>{.*?}" . review-mode-underlinebold-face)
	  ("@<ttb>{.*?}" . review-mode-bold-face)
	  ("@<b>{.*?}" . review-mode-bold-face)
	  ("@<strong>{.*?}" . review-mode-bold-face)
	  ("@<em>{.*?}" . review-mode-bold-face)
	  ("@<kw>{.*?}" . review-mode-bold-face)
	  ("@<bou>{.*?}" . review-mode-bold-face)
	  ("@<ami>{.*?}" . review-mode-bold-face)
	  ("@<i>{.*?}" . review-mode-italic-face)
	  ("@<tti>{.*?}" . review-mode-italic-face)
	  ("@<sup>{.*?}" . review-mode-italic-face)
	  ("@<sub>{.*?}" . review-mode-italic-face)
	  ("@<ruby>{.*?}" . review-mode-italic-face)
	  ("@<idx>{.*?}" . review-mode-nothide-face)
	  ("@<hidx>{.*?}" . review-mode-hide-face)
	  ("@<br>{.*?}" . review-mode-bold-face)
	  ("@<m>{.*?}" . review-mode-bold-face)
	  ("@<icon>{.*?}" . review-mode-bold-face)
	  ("@<uchar>{.*?}" . review-mode-bold-face)
	  ("@<href>{.*?}" . review-mode-bold-face)
	  ("@<raw>{.*?[^\\]}" . review-mode-bold-face)
	  ("@<code>{.*?[^\\]}" . review-mode-bold-face)
	  ("@<balloon>{.*?}" . review-mode-ballon-face)
	  ("^//.*{" . review-mode-hide-face)
	  ("^//.*]" . review-mode-hide-face)
	  ("^//}" . review-mode-hide-face)
	  ("<\<>" . review-mode-bracket-face)
	  ("－" . review-mode-fullwidth-hyphen-minus-face)
	  ("−" . review-mode-minus-sign-face)
	  ("‐" . review-mode-hyphen-face)
	  ("‒" . review-mode-figure-dash-face)
	  ("–" . review-mode-en-dash-face)
	  ("—" . review-mode-em-dash-face)
	  ("―" . review-mode-horizontal-bar-face)
	  ("“" . review-mode-left-quote-face)
	  ("”" . review-mode-right-quote-face)
	  ("‟" . review-mode-reversed-quote-face)
	  ("″" . review-mode-double-prime-face)
	  )
	"編集モードのface"
	:group 'review-mode
	:type 'list)

    (defface review-mode-comment-face
      '((t (:foreground "Red")))
      "コメントのフェイス"
      :group 'review-mode)
    (defface review-mode-title-face
      '((t (:bold t :foreground "darkgreen")))
      "タイトルのフェイス"
      :group 'review-mode)
    (defface review-mode-header1-face
      '((t (:bold t :foreground "darkgreen")))
      "ヘッダーのフェイス"
      :group 'review-mode)
    (defface review-mode-header2-face
      '((t (:bold t :foreground "darkgreen")))
      "ヘッダーのフェイス"
      :group 'review-mode)
    (defface review-mode-header3-face
      '((t (:bold t :foreground "darkgreen")))
      "ヘッダーのフェイス"
      :group 'review-mode)
    (defface review-mode-header4-face
      '((t (:bold t :foreground "darkgreen")))
      "ヘッダーのフェイス"
      :group 'review-mode)
    (defface review-mode-header5-face
      '((t (:bold t :foreground "darkgreen")))
      "ヘッダーのフェイス"
      :group 'review-mode)
    (defface review-mode-underline-face
      '((t (:underline t :foreground "DarkBlue")))
      "アンダーラインのフェイス"
      :group 'review-mode)
    (defface review-mode-underlinebold-face
      '((t (:bold t :underline t :foreground "DarkBlue")))
      "アンダーラインボールドのフェイス"
      :group 'review-mode)
    (defface review-mode-bold-face
      '((t (:bold t :foreground "Blue")))
      "ボールドのフェイス"
      :group 'review-mode)
    (defface review-mode-italic-face
      '((t (:italic t :bold t :foreground "DarkRed")))
      "イタリックのフェイス"
      :group 'review-mode)
    (defface review-mode-bracket-face
      '((t (:bold t :foreground "DarkBlue")))
      "<のフェイス"
      :group 'review-mode)
    (defface review-mode-nothide-face
      '((t (:bold t :foreground "SlateGrey")))
      "indexのフェイス"
      :group 'review-mode)
    (defface review-mode-hide-face
      '((t (:bold t :foreground "plum4")))
      "indexのフェイス"
      :group 'review-mode)
    (defface review-mode-balloon-face
      '((t (:foreground "CornflowerBlue")))
      "balloonのフェイス"
      :group 'review-mode)
    (defface review-mode-ref-face
      '((t (:bold t :foreground "yellow3")))
      "参照のフェイス"
      :group 'review-mode)
    (defface review-mode-fullwidth-hyphen-minus-face
      '((t (:foreground "grey90" :bkacground "red")))
      "全角ハイフン/マイナスのフェイス"
      :group 'review-mode)
    (defface review-mode-minus-sign-face
      '((t (:background "grey90")))
      "全角ハイフン/マイナスのフェイス"
      :group 'review-mode)
    (defface review-mode-hyphen-face
      '((t (:background "maroon1")))
      "全角ハイフンのフェイス"
      :group 'review-mode)
    (defface review-mode-figure-dash-face
      '((t (:foreground "white" :background "firebrick")))
      "figureダッシュ(使うべきでない)のフェイス"
      :group 'review-mode)
    (defface review-mode-en-dash-face
      '((t (:foreground "white" :background "sienna")))
      "半角ダッシュ(使うべきでない)のフェイス"
      :group 'review-mode)
    (defface review-mode-em-dash-face
      '((t (:background "honeydew1")))
      "全角ダッシュのフェイス"
      :group 'review-mode)
    (defface review-mode-horizontal-bar-face
      '((t (:background "LightSkyBlue1")))
      "水平バーのフェイス"
      :group 'review-mode)
    (defface review-mode-left-quote-face
      '((t (:foreground "medium sea green")))
      "開き二重引用符のフェイス"
      :group 'review-mode)
    (defface review-mode-right-quote-face
      '((t (:foreground "LightSlateBlue")))
      "閉じ二重引用符のフェイス"
      :group 'review-mode)
    (defface review-mode-reversed-quote-face
      '((t (:foreground "LightCyan" :background "red")))
      "開き逆二重引用符(使うべきでない)のフェイス"
      :group 'review-mode)
    (defface review-mode-double-prime-face
      '((t (:foreground "light steel blue" :background "red")))
      "閉じ逆二重引用符(使うべきでない)のフェイス"
      :group 'review-mode)

    (defvar review-mode-comment-face 'review-mode-comment-face)
    (defvar review-mode-title-face 'review-mode-title-face)
    (defvar review-mode-header1-face 'review-mode-header1-face)
    (defvar review-mode-header2-face 'review-mode-header2-face)
    (defvar review-mode-header3-face 'review-mode-header3-face)
    (defvar review-mode-header4-face 'review-mode-header4-face)
    (defvar review-mode-header5-face 'review-mode-header5-face)
    (defvar review-mode-underline-face 'review-mode-underline-face)
    (defvar review-mode-bold-face 'review-mode-bold-face)
    (defvar review-mode-italic-face 'review-mode-italic-face)
    (defvar review-mode-bracket-face 'review-mode-bracket-face)
    (defvar review-mode-hide-face 'review-mode-hide-face)
    (defvar review-mode-nonhide-face 'review-mode-nonhide-face)
    (defvar review-mode-balloon-face 'review-mode-balloon-face)
    (defvar review-mode-ref-face 'review-mode-ref-face)
    (defvar review-mode-fullwidth-hyphen-minus-face 'review-mode-fullwidth-hyphen-minus-face)
    (defvar review-mode-minus-sign-face 'review-mode-minus-sign-face)
    (defvar review-mode-hyphen-face 'review-mode-hyphen-face)
    (defvar review-mode-figure-dash-face 'review-mode-figure-dash-face)
    (defvar review-mode-en-dash-face 'review-mode-en-dash-face)
    (defvar review-mode-em-dash-face 'review-mode-em-dash-face)
    (defvar review-mode-horizontal-bar-face 'review-mode-horizontal-bar-face)
    (defvar review-mode-left-quote-face 'review-mode-left-quote-face)
    (defvar review-mode-right-quote-face 'review-mode-right-quote-face)
    (defvar review-mode-reversed-quote-face 'review-mode-reversed-quote-face)
    (defvar review-mode-double-prime-face 'review-mode-double-prime-face)

    (make-local-variable 'font-lock-defaults)
    (setq font-lock-defaults '(review-font-lock-keywords t))
    (turn-on-font-lock)

    (define-key review-mode-map "\C-c\C-e" 'review-block-region)
    (define-key review-mode-map "\C-c\C-fb" 'review-bold-region)
    (define-key review-mode-map "\C-c\C-fa" 'review-underline-italic-region)
    (define-key review-mode-map "\C-c\C-fi" 'review-italic-region)
    (define-key review-mode-map "\C-c\C-fe" 'review-italic-region)
    (define-key review-mode-map "\C-c\C-ft" 'review-underline-region)
    (define-key review-mode-map "\C-c\C-fu" 'review-underline-region)
    (define-key review-mode-map "\C-c\C-fk" 'review-keyword-region)
    (define-key review-mode-map "\C-c\C-fn" 'review-index-region)
    (define-key review-mode-map "\C-c\C-f\C-b" 'review-bold-region)
    (define-key review-mode-map "\C-c\C-f\C-i" 'review-italic-region)
    (define-key review-mode-map "\C-c\C-f\C-e" 'review-italic-region)
    (define-key review-mode-map "\C-c\C-f\C-a" 'review-underline-italic-region)
    (define-key review-mode-map "\C-c\C-f\C-t" 'review-underline-region)
    (define-key review-mode-map "\C-c\C-f\C-u" 'review-underline-region)
    (define-key review-mode-map "\C-c\C-f\C-k" 'review-keyword-region)
    (define-key review-mode-map "\C-c\C-f\C-h" 'review-hyperlink-region)
    (define-key review-mode-map "\C-c\C-f\C-c" 'review-code-region)
    (define-key review-mode-map "\C-c\C-f\C-n" 'review-index-region)
    (define-key review-mode-map "\C-c!" 'review-kokomade)
    (define-key review-mode-map "\C-c\C-a" 'review-normal-comment)
    (define-key review-mode-map "\C-c\C-b" 'review-balloon-comment)
    (define-key review-mode-map "\C-c\C-d" 'review-dtp-comment)
    (define-key review-mode-map "\C-c\C-k" 'review-tip-comment)
    (define-key review-mode-map "\C-c\C-r" 'review-reference-comment)
    (define-key review-mode-map "\C-c\C-m" 'review-index-comment)
    (define-key review-mode-map "\C-c\C-p" 'review-header)
    (define-key review-mode-map "\C-c<" 'review-opentag)
    (define-key review-mode-map "\C-c>" 'review-closetag)

    (define-key review-mode-map "\C-c1" 'review-search-uri)
    (define-key review-mode-map "\C-c2" 'review-search-uri2)

    (define-key review-mode-map "\C-c8" 'review-zenkaku-mapping-lparenthesis)
    (define-key review-mode-map "\C-c\(" 'review-zenkaku-mapping-lparenthesis)
    (define-key review-mode-map "\C-c9" 'review-zenkaku-mapping-rparenthesis)
    (define-key review-mode-map "\C-c\)" 'review-zenkaku-mapping-rparenthesis)
    (define-key review-mode-map "\C-c\[" 'review-zenkaku-mapping-langle)
    (define-key review-mode-map "\C-c\]" 'review-zenkaku-mapping-rangle)
    (define-key review-mode-map "\C-c-" 'review-zenkaku-mapping-minus)
    (define-key review-mode-map "\C-c*" 'review-zenkaku-mapping-asterisk)
    (define-key review-mode-map "\C-c/" 'review-zenkaku-mapping-slash)
    (define-key review-mode-map "\C-c\\" 'review-zenkaku-mapping-yen)
    (define-key review-mode-map "\C-c " 'review-zenkaku-mapping-space)
    (define-key review-mode-map "\C-c:" 'review-zenkaku-mapping-colon)

    (define-key review-mode-map "\C-c\C-t1" 'review-change-mode)
    (define-key review-mode-map "\C-c\C-t2" 'review-change-dtp)

    (define-key review-mode-map "\C-c\C-y" 'review-index-change)

    (use-local-map review-mode-map)

    (run-hooks 'review-mode-hook)
    )
  )

;; リージョン取り込み
(defun review-block-region (pattern &optional force start end)
  "選択領域を囲むタグを設定"
  (interactive "sコメント: \nP\nr")

  (save-restriction
    (narrow-to-region start end)
     (goto-char (point-min))
     (insert "//" pattern "{\n")
     (goto-char (point-max))
     (insert "//}\n")
     )
  )

;; フォント付け
(defun review-string-region (markb marke start end)
  "選択領域にフォントを設定"

  (save-restriction
    (narrow-to-region start end)
    (goto-char (point-min))
    (insert markb)
    (goto-char (point-max))
    (insert marke)
    )
  )

(defun review-bold-region (start end)
  "ボールドフォントタグ"
  (interactive "r")
  (review-string-region "@<b>{" "}" start end)
  )


(defun review-keyword-region (start end)
  "キーワードフォントタグ"
  (interactive "r")
  (review-string-region "@<kw>{" "}" start end)
  )

(defun review-italic-region (start end)
  "イタリックフォントタグ"
  (interactive "r")
  (review-string-region "@<i>{" "}" start end)
  )

(defun review-underline-italic-region (start end)
  "TTイタリックフォントタグ"
  (interactive "r")
  (review-string-region "@<tti>{" "}" start end)
  )

(defun review-underline-region (start end)
  "タイプフォントフォントタグ"
  (interactive "r")
  (review-string-region "@<tt>{" "}" start end)
  )

(defun review-hyperlink-region (start end)
  "ハイパーリンクタグ"
  (interactive "r")
  (review-string-region "@<href>{" "}" start end)
  )

(defun review-code-region (start end)
  "コードタグ"
  (interactive "r")
  (review-string-region "@<code>{" "}" start end)
  )

(defun review-index-region (start end)
  "表示型索引タグ"
  (interactive "r")
  (review-string-region "@<idx>{" "}" start end)
  )

;; 吹き出し
(defun review-balloon-comment (pattern &optional force)
  (interactive "s吹き出し: \nP")
  "吹き出しを挿入"
  (insert "@<balloon>{" pattern "}")
  )

;; 編集一時終了
(defun review-kokomade ()
  (interactive)
  "一時終了タグを挿入"
  (insert review-comment-start "ここまで -" review-mode-name review-comment-end  "\n")
  )

;; 編集コメント
(defun review-normal-comment (pattern &optional force)
  (interactive "sコメント: \nP")
  "コメントを挿入"
  (insert review-comment-start pattern " -" review-mode-name review-comment-end)
  )

;; DTP向けコメント
(defun review-dtp-comment (pattern &optional force)
  (interactive "sDTP向けコメント: \nP")
  "DTP向けコメントを挿入"
  (insert review-comment-start review-mode-dtp ":" pattern " -" review-mode-name review-comment-end)
  )

;; 注釈
(defun review-tip-comment (pattern &optional force)
  (interactive "s注釈コメント: \nP")
  "注釈コメントを挿入"
  (insert review-comment-start review-mode-tip-name ":" pattern " -" review-mode-name review-comment-end)
  )

;; 参照
(defun review-reference-comment ()
  (interactive)
  "参照コメントを挿入"
  (insert "◆→参照先確認 -" review-mode-name "←◆")
  )

;; 索引
(defun review-index-comment (pattern &optional force)
  (interactive "s索引: \nP")
  "索引ワードを挿入"
  (insert review-index-start pattern review-index-end)
  )

;; ヘッダ
(defun review-header (pattern &optional force)
  (interactive "sヘッダレベル: \nP")
  "注釈コメントを挿入"
  (insert (make-string (string-to-number pattern) ?=) " "))

;; rawでタグのオープン/クローズ
(defun review-opentag (pattern &optional force)
  (interactive "sタグ: \nP")
  "raw開始タグ"
  (insert "//raw[<" pattern ">]")
)
(defun review-closetag (pattern &optional force)
  (interactive "sタグ: \nP")
  "raw終了タグ"
  (insert "//raw[</" pattern ">]")
)

;; ブラウズ
(defun review-search-uri ()
  (interactive)
  "手近なURIを検索してブラウザで表示"
  (re-search-forward review-uri-regexp)
  (goto-char (match-beginning 1))
  (browser-url (match-string 1))
  )

(defun review-search-uri2 (start end)
  (interactive "r")
  "選択領域をブラウザで表示"
  (message (buffer-substring-no-properties start end))
  (browse-url (buffer-substring-no-properties start end))
  )

;; 全角文字
(defun review-zenkaku-mapping (key)
  "全角文字の挿入"
  (insert (cdr (assoc key review-key-mapping)))
)

(defun review-zenkaku-mapping-lparenthesis () (interactive) "全角(" (review-zenkaku-mapping "("))
(defun review-zenkaku-mapping-rparenthesis () (interactive) "全角)" (review-zenkaku-mapping ")"))
(defun review-zenkaku-mapping-langle () (interactive) "全角[" (review-zenkaku-mapping "["))
(defun review-zenkaku-mapping-rangle () (interactive) "全角[" (review-zenkaku-mapping "]"))
(defun review-zenkaku-mapping-minus () (interactive) "全角-" (review-zenkaku-mapping "-"))
(defun review-zenkaku-mapping-asterisk () (interactive) "全角*" (review-zenkaku-mapping "*"))
(defun review-zenkaku-mapping-slash () (interactive) "全角/" (review-zenkaku-mapping "/"))
(defun review-zenkaku-mapping-yen () (interactive) "全角￥" (review-zenkaku-mapping "\\"))
(defun review-zenkaku-mapping-space () (interactive) "全角 " (review-zenkaku-mapping " "))
(defun review-zenkaku-mapping-colon () (interactive) "全角:" (review-zenkaku-mapping ":"))
(defun review-zenkaku-mapping-lbracket () (interactive) "<タグ" (review-zenkaku-mapping "<"))

;; 基本モードの変更
(defun review-change-mode ()
  (interactive)
  "編集モードの変更"
  (let (key _message _element (_list review-name-list) (sum 0))
    (while _list
      (setq _element (car (car _list)))
      (setq sum ( + sum 1))
      (if _message
	(setq _message (format "%s%d.%s " _message sum _element))
	(setq _message (format "%d.%s " sum _element))
	)
      (setq _list (cdr _list))
      )
    (message (concat "編集モード: " _message ":"))
    (setq key (read-char))
    (cond
     ((eq key ?1) (review-change-mode-sub 0))
     ((eq key ?2) (review-change-mode-sub 1))
     ((eq key ?3) (review-change-mode-sub 2))
     ((eq key ?4) (review-change-mode-sub 3))
     ((eq key ?5) (review-change-mode-sub 4))
     )
    )
  (setq review-mode-tip-name (cdr (assoc review-mode-name review-name-list)))
  (message (concat "現在のモード: " review-mode-name))
  (setq mode-name review-mode-name)
  )

(defun review-change-mode-sub (number)
  "編集モード変更サブルーチン"
  (let (list)
    (setq list (nth number review-name-list))
    (setq review-mode-name (car list))
    )
  )

;; DTP の変更
(defun review-change-dtp ()
  (interactive)
  "DTP担当の変更"
  (let (key _message _element (_list review-dtp-list) (sum 0))
    (while _list
      (setq _element (car _list))
      (setq sum ( + sum 1))
      (if _message
	(setq _message (format "%s%d.%s " _message sum _element))
	(setq _message (format "%d.%s " sum _element))
	)
      (setq _list (cdr _list))
      )
    (message (concat "DTP担当: " _message ":"))
    (setq key (read-char))
    (cond
     ((eq key ?1) (review-change-dtp-mode-sub 0))
     ((eq key ?2) (review-change-dtp-mode-sub 1))
     ((eq key ?3) (review-change-dtp-mode-sub 2))
     ((eq key ?4) (review-change-dtp-mode-sub 3))
     ((eq key ?5) (review-change-dtp-mode-sub 4))
     )
    )
  )

(defun review-change-dtp-mode-sub (number)
  "DTP担当変更サブルーチン"
  (let (list)
    (setq list (nth number review-dtp-list))
    (setq review-dtp-name list)
    (message (concat "現在のDTP: " review-dtp-name))
    )
  )

;; 組の変更
(defun review-change-mode-sub (number)
  "編集モードのサブルーチン"
  (let (list)
     (setq list (nth number review-name-list))
     (setq review-mode-name (car list))
     (setq review-tip-name (cdr list))
    )
  )

(defun review-index-change (start end)
  "選択領域を索引として()とスペースを取る"
  (interactive "r")
  (let (_review-index-buffer)
    
    (save-restriction
      (narrow-to-region start end)
      (setq _review-index-buffer (buffer-substring-no-properties start end))
      (goto-char (point-min))
      (while (re-search-forward "\(\\|\)\\| " nil t)
	(replace-match "" nil nil))
      (goto-char (point-max))
      (insert "@" _review-index-buffer)
      )
    )
  )

(defun page-increment-region (pattern &optional force start end)
  "選択領域のページ数を増減"
  (interactive "n増減値: \nP\nr")
  (save-restriction
    (narrow-to-region start end)
    (let ((pos (point-min)))
      (goto-char pos)
      (while (setq pos (re-search-forward "^\\([0-9][0-9]*\\)\t" nil t))
        (replace-match (concat (number-to-string (+ pattern (string-to-number (match-string 1)))) "\t"))
      )
    )
  )
)

;; Associate .re files with review-mode
;;;###autoload
(setq auto-mode-alist (append '(("\\.re$" . review-mode)) auto-mode-alist))

(provide 'review-mode)

;;; review-mode.el ends here
