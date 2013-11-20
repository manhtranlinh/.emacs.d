(require 'ublt-util)

;;; Font, colors, text appearance

(eval-when-compile
  (require 'cl))



;; Default size, cursor
(case system-type
  ('darwin (modify-all-frames-parameters
            '((top . 0) (left . 0)      ;(width . 1280) (height . 800)
              (cursor-type . bar))))
  ('windows-nt (modify-all-frames-parameters
                '((cursor-type . bar))))
  ('gnu/linux (modify-all-frames-parameters
               '((top . 0) (left . 0) (width . 119)
                 (fullscreen . fullheight) (cursor-type . bar)
                 ;; FIX: This may be specific to my laptop
                 ;; (screen-gamma . 2.205)
                 ;; Night
                 ;; (screen-gamma . 2.5)
                 ;; (screen-gamma . nil)
                 ;; And this, my new monitor, even after calibration?!?
                 (screen-gamma . 2.7)
                 ;; Daylight adaptation
                 ;; (screen-gamma . 4)
                 ))))

;;; Fonts
(when window-system
  ;; Font-mixing obsession
  (ublt/set-up 'ublt-font
  ;; Non-code text reads better in proportional font
  (dolist (hook '(erc-mode-hook
                  Info-mode-hook
                  help-mode-hook
                  ess-help-mode-hook
                  lyric-mode-hook
                  Man-mode-hook woman-mode-hook
                  twittering-mode-hook
                  emms-playlist-mode-hook
                  skype--chat-mode-hook
                  org-mode-hook
                  markdown-mode-hook
                  html-mode-hook
                  dired-mode-hook
                  git-commit-mode-hook
                  twittering-edit-mode-hook))
    (add-hook hook (ublt/on-fn 'variable-pitch-mode)))
  ;; This isn't pretty, but the alternative is using a variable-pitch
  ;; font as the default, and creating a `fixed-pitch-mode'.
  (defun ublt/variable-pitch-if-fundamental ()
    (when (eq major-mode 'fundamental-mode)
      (variable-pitch-mode +1)))
  (add-hook 'find-file-hook 'ublt/variable-pitch-if-fundamental)))


;;; Ubolonton's theme
;;; TODO: Fix highlight-parentheses-mode so that switching theme
;;; switches parentheses' colors correctly.
(ublt/set-up 'ublt-themes
  (color-theme-ubolonton-dark))


;;; Whitespaces
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; FIX: `whitespace-mode' faces inherit the default face, thus would
;; not work with mixed fixed-width/variable-width fonts (which means
;; most of my buffer now!). It's the same situation with
;; `idle-highlight'. For these modes to be useful some workarounds are
;; needed, probably using overlays.

;; ;; `http://xahlee.org/emacs/whitespace-mode.html'
;; (setq whitespace-style
;;       '(face spaces tabs newline space-mark tab-mark newline-mark))
;; (setq whitespace-display-mappings
;;       '(
;;         (space-mark 32 [?\ ] [46])           ; whitespace
;;         (space-mark 160 [164] [95])
;;         (space-mark 2208 [2212] [95])
;;         (space-mark 2336 [2340] [95])
;;         (space-mark 3616 [3620] [95])
;;         (space-mark 3872 [3876] [95])
;;                                         ;   (newline-mark ?\n [8629 ?\n] [182 ?\n]) ; new-line
;;         (newline-mark ?\n [?¶ ?\n] [182 ?\n]) ; new-line
;;                                         ;   (tab-mark ?\t [9654 ?\t] [92 ?\t])         ; tab
;;         (tab-mark ?\t [?» ?\t] [92 ?\t])         ; tab
;;       ))


;;; Rainbow parentheses for coding modes
(defun turn-on-hl-paren ()
  (interactive)
  (highlight-parentheses-mode +1))
;; (add-hook 'prog-mode-hook 'turn-on-hl-paren t)
;; Work-around for a bug in highlight-parentheses-mode which messes up
;; the overlays, making the colors off if the mode is turned on twice
;; (e.g. by prog-mode-hook and by desktop-mode, which keeps track of
;; active minor modes from last session)
(defadvice highlight-parentheses-mode (around work-around-hl-bug activate)
  (unless (and highlight-parentheses-mode
               (= 1 (ad-get-arg 0)))
    ad-do-it))


;;; Code folding

;;; FIX: Figure out why `web-mode' does not highlight code if this
;; section is not present, even though it complains about not
;; supporting `hideshow'.
;;; XXX: This makes terminal Emacs hang, so only use if there's a
;; window system
(when window-system
  (ublt/set-up 'fold-dwim-org
    ;; Like org-mode TAB and S-TAB
    (setq fold-dwim-org/trigger-keys-block '((kbd "TAB")))
    (defun ublt/code-folding-setup ()
      (hs-minor-mode 1)
      (fold-dwim-org/minor-mode 1)
      (hideshowvis-enable))
    (add-hook 'prog-mode-hook 'ublt/code-folding-setup)))

;; (ublt/set-up 'hideshowvis
;;   (define-fringe-bitmap 'hs-marker [0 24 24 126 126 24 24 0])
;;   (defcustom hs-fringe-face 'hs-fringe-face
;;     "*Specify face used to highlight the fringe on hidden regions."
;;     :type 'face
;;     :group 'hideshow)
;;   (defface hs-fringe-face
;;     '((t (:foreground "#888" :box (:line-width 2 :color "grey75" :style released-button))))
;;     "Face used to highlight the fringe on folded regions"
;;     :group 'hideshow)
;;   (defcustom hs-face 'hs-face
;;     "*Specify the face to to use for the hidden region indicator"
;;     :type 'face
;;     :group 'hideshow)
;;   (defface hs-face
;;     '((t (:background "#ff8" :box t)))
;;     "Face to hightlight the ... area of hidden regions"
;;     :group 'hideshow)
;;   (defun display-code-line-counts (ov)
;;     (when (eq 'code (overlay-get ov 'hs))
;;       (let* ((marker-string "*fringe-dummy*")
;;              (marker-length (length marker-string))
;;              (display-string (format "(%d)..." (count-lines (overlay-start ov) (overlay-end ov))))
;;              )
;;         (overlay-put ov 'help-echo "Hiddent text. C-c,= to show")
;;         (put-text-property 0 marker-length 'display (list 'left-fringe 'hs-marker 'hs-fringe-face) marker-string)
;;         (overlay-put ov 'before-string marker-string)
;;         (put-text-property 0 (length display-string) 'face 'hs-face display-string)
;;         (overlay-put ov 'display display-string)
;;         )))
;;   (setq hs-set-up-overlay 'display-code-line-counts
;;         hideshowvis-ignore-same-line nil))


;;; ^L visualization
;; (require 'pp-c-l)

;; (ublt/set-up 'pp-c-l
;;   (pretty-control-l-mode +1)
;;   (setq pp^L-^L-string "────────────────────────────── Section ───────────────────────────────"
;;         pp^L-^L-string-pre "\n"
;;         pp^L-^L-string-post "\n"))

(ublt/set-up 'page-break-lines
  (setq page-break-lines-char ?━)
  (dolist (mode '(sh-mode
                  conf-mode
                  js-mode
                  js2-mode))
    (add-to-list 'page-break-lines-modes mode))
  (global-page-break-lines-mode +1))


(defun ublt/toggle-fullscreen ()
  "Tested only in X."
  (interactive)
  (let* ((types '(fullboth fullheight ;; fullwidth
                           ))
         (i (get this-command 'pos))
         (N (length types)))
    (setq i (if i (% i N) 0))
    (modify-frame-parameters nil (list (cons 'fullscreen (nth i types))))
    (message "Fullscreen: %s" (nth i types))
    (put this-command 'pos (% (1+ i) N))))


;;; Sometimes we need to see through
(defun ublt/toggle-alpha ()
  (interactive)
  (let ((a (frame-parameter nil 'alpha)))
    (if (or (not (numberp a)) (= a  100))
        (set-frame-parameter nil 'alpha 88)
      (set-frame-parameter nil 'alpha 100))))


;;; Looks like only tweaking visual-line-mode is needed (I was
;;; probably confused by global/local variables)

;;; This affects how lines are wrapped (we want wrapping at word
;;; boundary not in the middle of a word)
(setq-default word-wrap t)

;;; This seems to be a superset of word-wrap?
(global-visual-line-mode -1)

;;; Is this really necessary? (maybe, because visual-line-mode is off
;;; by default)
(setq-default truncate-lines t)

;;; No wrap please
(dolist (hook '(emms-browser-show-display-hook
                archive-zip-mode-hook
                dired-mode-hook
                org-agenda-mode-hook))  ; XXX: not working
  (add-hook hook (ublt/off-fn 'visual-line-mode)))

;;; Always wrap please
(dolist (hook '(twittering-mode-hook))
  (add-hook hook (ublt/on-fn 'visual-line-mode)))


;;; Sometimes buffers have the same names
;; from `http://trey-jackson.blogspot.com/2008/01/emacs-tip-11-uniquify.html'
(ublt/set-up 'uniquify
  (setq uniquify-buffer-name-style 'reverse
        uniquify-separator "  "
        ;; Rename after killing uniquified
        uniquify-after-kill-buffer-p t
        ;; Don't muck with special buffers
        uniquify-ignore-buffers-re "^\\*"))


;; Uncluttered shell prompt
;; (setq eshell-prompt-function (lambda ()
;;                                (concat
;;                                 (eshell-user-name)
;;                                 (abbreviate-file-name (eshell/pwd))
;;                                 "")
;;                                ;; (concat
;;                                ;;  "\n╭─ " (eshell-user-name)
;;                                ;;  "  " (abbreviate-file-name (eshell/pwd))
;;                                ;;  "\n╰─ ")
;;                                )
;;       eshell-prompt-regexp "^╭─ .*\\(?:\n\\).*╰─ $")


;;; mode-line appearance
(defgroup ubolonton nil ""
  :group 'personal)

(defface ublt/mode-line-major-mode
  '((t :bold t))
  "Face for mode-line major mode string")
(defface ublt/mode-line-clock
  '((t :bold t))
  "Face for mode-line clock")

(ublt/set-up 'powerline
  ;; FIX: This code duplicates powerline, which duplicates Emacs'
  (defpowerline ublt/powerline-narrow-indicator
    (let (real-point-min real-point-max)
      (save-excursion
        (save-restriction
          (widen)
          (setq real-point-min (point-min)
                real-point-max (point-max))))
      (when (or (/= real-point-min (point-min))
                (/= real-point-max (point-max)))
        (propertize "η"
                    'mouse-face 'mode-line-highlight
                    'help-echo "mouse-1: Remove narrowing from the current buffer"
                    'local-map (make-mode-line-mouse-map
                                'mouse-1 'mode-line-widen)))))

  (defpowerline ublt/powerline-clock
    (concat "["
            (propertize (format-time-string "%H:%M %d/%m")
                        'face 'ublt/mode-line-clock
                        'help-echo (concat (format-time-string "%c") "; "
                                           (emacs-uptime "Uptime: %hh")))
            "]"))

  (defun ublt/powerline ()
    (interactive)
    (setq-default
     mode-line-format
     ;; ("%e" mode-line-front-space
     ;;  mode-line-mule-info
     ;;  mode-line-client
     ;;  mode-line-modified
     ;;  mode-line-remote
     ;;  mode-line-frame-identification
     ;;  mode-line-buffer-identification
     ;;  "   " mode-line-position
     ;;  (vc-mode vc-mode)
     ;;  "  " mode-line-modes
     ;;  mode-line-misc-info
     ;;  mode-line-end-spaces)
     '("%e"
       (:eval
        (let* ((active (powerline-selected-window-active))
               (mode-line (if active 'mode-line 'mode-line-inactive)))
          (list (powerline-raw mode-line-mule-info)
                (powerline-raw mode-line-remote)
                (powerline-raw mode-line-modified)

                (powerline-raw " ")
                (powerline-buffer-size)

                (powerline-raw " ")
                (powerline-raw mode-line-buffer-identification)

                (powerline-raw " ")
                (ublt/powerline-narrow-indicator)

                (powerline-raw " ")
                (powerline-raw evil-mode-line-tag)

                (powerline-raw " ")
                (powerline-raw "%4l" 'ublt/default-fixed-width) ; line
                (powerline-raw ":" 'ublt/default-fixed-width)
                (powerline-raw "%2c" 'ublt/default-fixed-width) ; column
                (powerline-raw " " 'ublt/default-fixed-width)
                (powerline-raw "%p" 'ublt/default-fixed-width) ; percent

                (powerline-raw " ")
                (powerline-vc)

                (powerline-raw " ")
                (powerline-raw "(")
                (powerline-major-mode 'ublt/mode-line-major-mode)
                (powerline-raw " ")
                (powerline-minor-modes mode-line)
                (powerline-raw ")")

                (powerline-raw " ")
                (ublt/powerline-clock)

                (powerline-raw mode-line-misc-info)))))))

  (ublt/powerline))


;;; Bigger minibuffer text
(defun ublt/minibuffer-setup ()
  (set (make-local-variable 'face-remapping-alist)
       '((default :height 1.2)))
  (setq line-spacing 0.3))
(add-hook 'minibuffer-setup-hook 'ublt/minibuffer-setup)


;;; Make mode-line uncluttered by changing how minor modes are shown

;;; TODO: Use images (propertize "mode" 'display (find-images ...))
;;; XXX: This looks so weird
(ublt/set-up 'diminish
  (defun ublt/diminish (mode-name display-text &optional feature)
    (condition-case err
        (if feature
            (eval-after-load feature
              `(condition-case err
                   (diminish ',mode-name ,display-text)
                 (error (message (format "Error diminishing \"%s\": %s" ,mode-name err)))))
          (diminish mode-name display-text))
      (error (message (format "Error diminishing \"%s\": %s" mode-name err)))))
  ;; mode name - displayed text - feature name (file name)
  (dolist (m '((paredit-mode              "  (Π)"   paredit)
               (eproject-mode             "  eP" eproject)
               (projectile-mode           "  Πρ" projectile)
               (undo-tree-mode            "  ⌘-Z"  undo-tree)
               (yas-minor-mode            "  γas"  yasnippet)
               (flymake-mode              "  !"   flymake)
               (flyspell-mode             "  !"   flyspell)
               (hs-minor-mode             "  ⊕" hideshow)
               (auto-fill-function        "  ⏎")
               (auto-complete-mode        "  αc" auto-complete)
               (rainbow-mode              "  ❂" rainbow-mode)
               (anzu-mode                 "  Σ" anzu)
               (isearch                   "  Σ")
               (slime-mode                "SLIME")
               (haskell-indentation-mode  "･" haskell-indentation)
               ;; (narrow                    " η")
               (whole-line-or-region-mode "" whole-line-or-region)
               (buffer-face-mode          "" face-remap)
               (volatile-highlights-mode  "" volatile-highlights)
               (elisp-slime-nav-mode      "" elisp-slime-nav)
               (hi-lock-mode              "" hi-lock)
               (eldoc-mode                "")
               (page-break-lines-mode     "")
               ))
    (destructuring-bind (mode display &optional feature) m
      (ublt/diminish mode display feature))))



(font-lock-add-keywords
 'org-mode `(("\\(=>\\)"
              (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                        ?⇒ 'decompose-region)
                        nil)))
             ("\\(<=\\)"
              (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                        ?⇐ 'decompose-region)
                        nil)))))
(font-lock-add-keywords
 'web-mode `(("\\(function\\)"
              (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                        ?ƒ 'decompose-region)
                        nil)))))
(font-lock-add-keywords
 'php-mode `(("\\(-\\)>"
              (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                        ?. 'decompose-region
                                        ;; ?→
                                        ))))
             ("-\\(>\\)"
              (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                        ?. 'decompose-region))))
             ("\\(=>\\)"
              (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                        ?⇒ 'decompose-region)
                        nil)))
             ("\\(array\\)("
              (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                        ?▸ 'decompose-region)
                        nil)))
             ("\\(function\\)"
              (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                        ?ƒ 'decompose-region)
                        nil)))
             ("{\\|}\\|;\\|\\$" . 'esk-paren-face)
             ("\\(ret\\)urn"
              (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                        ?▸ 'decompose-region)
                        nil)))
             ("ret\\(urn\\)"
              (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                        ?▸ 'decompose-region)
                        nil)))))
(dolist (mode '(js-mode js2-mode web-mode))
  (font-lock-add-keywords
   mode `(("{\\|}\\|;" . 'esk-paren-face)
          ("\\(ret\\)urn"
           (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                     ?▸ 'decompose-region)
                     nil)))
          ("ret\\(urn\\)"
           (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                     ?▸ 'decompose-region)
                     nil))))))

;;; Don't use. This destroys magit's fontification. Magit does something special
;; (defun ublt/prettify-magit-log ()
;;   (font-lock-add-keywords
;;    nil '(;; ("|"
;;          ;;  (0 (progn (compose-region (match-beginning 1) (match-end 1)
;;          ;;                            ?│))))
;;          ("\\(*\\)"
;;           (0 (progn (compose-region (match-beginning 1) (match-end 1)
;;                                     ?∙ 'decompose-region)
;;                     nil))))))
;; (add-hook 'magit-log-mode-hook 'ublt/prettify-magit-log)

;; (remove-hook 'magit-log-mode-hook 'ublt/prettify-magit-log)




;;; Misc

(setq
 ;; 2x70 instead of the default 2x80 so that side-by-side is preferable
 split-width-threshold 120

 ;; Tile ediff windows horizontally
 ediff-split-window-function 'split-window-horizontally

 ;; Bells suck, both visible and audible
 visible-bell (case system-type
                ('gnu/linux nil)
                ('darwin nil))

 show-paren-delay 0

 ;; Limit minibuffer to 20% frame height
 max-mini-window-height 0.2

 ;; Echo keystrokes faster
 echo-keystrokes 0.2

 ;; woman settings
 woman-fill-column 80
 woman-fill-frame t
 woman-default-indent 7
 )

(setq-default
 ;; Sparse lines
 ;; TODO: 0.15 or 0.2?
 line-spacing 0.15

 ;; 70-char column width
 fill-column 70
 )


;; Technicolor
(require 'info+)

;; Buffed-up help system
(require 'help-macro+)
(require 'help+)
(require 'help-fns+)

;;; Show current function name in mode-line
(which-func-mode +1)

;; Fringe
;; (set-fringe-mode '(8 . 0))

;;; FIX: Make them compatible
(defun ublt/maybe-number-font-lock-mode ()
  (when (not (eq major-mode 'web-mode))
    (number-font-lock-mode +1)))

(ublt/set-up 'number-font-lock-mode
  (add-hook 'prog-mode-hook #'ublt/maybe-number-font-lock-mode))

;;; XXX: Don't overwrite other packages' functions
(defun esk-add-watchwords ()
  (font-lock-add-keywords
   nil '(("\\<\\(FIXME\\|TODO\\|FIX\\|XXX\\|HACK\\|REFACTOR\\|NOCOMMIT\\|NTA\\)"
          1 font-lock-warning-face t))))

(ublt/set-up 'eval-sexp-fu
  (setq eval-sexp-fu-flash-duration 0.5
        eval-sexp-fu-flash-error-duration 0.5))

(ublt/set-up 'volatile-highlights
  (volatile-highlights-mode +1))

(ublt/set-up 'anzu
  (setq anzu-minimum-input-length 2
        anzu-search-threshold 100)
  (global-anzu-mode +1))

(ublt/set-up 'adaptive-wrap
  ;; FIX: Don't overwrite, change the source
  (defun adaptive-wrap-prefix-function (beg end)
    "Indent the region between BEG and END with adaptive filling."
    (goto-char beg)
    (while (< (point) end)
      (let ((lbp (line-beginning-position)))
        (put-text-property (point)
                           (progn (search-forward "\n" end 'move) (point))
                           'wrap-prefix
                           (propertize (adaptive-wrap-fill-context-prefix lbp (point))
                                       ;; For it to work with `variable-pitch-mode'
                                       'face 'default)))))
  (defadvice visual-line-mode (after adaptive-wrap activate)
    (if (and visual-line-mode adaptive-fill-mode)
        (progn
          (adaptive-wrap-prefix-mode +1)
          (auto-fill-mode -1))
      (adaptive-wrap-prefix-mode -1))))

(provide 'ublt-appearance)
