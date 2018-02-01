(require 'ublt-util)

;;; Font, colors, text appearance

(eval-when-compile
  (require 'cl))


;; Default size, cursor
(case system-type
  ('darwin (modify-all-frames-parameters
            '((fullscreen . maximized))))
  ('windows-nt (modify-all-frames-parameters
                '((cursor-type . bar))))
  ('gnu/linux (modify-all-frames-parameters
               '((top . 0) (left . 0) (width . 119)
                 (fullscreen . fullheight) (cursor-type . bar)
                 ;; Notes: This section is obsolete. Calibrate whole
                 ;; system using xrandr instead.
                 ;; Old vaio laptop
                 ;; (screen-gamma . 2.205)
                 ;; Night
                 ;; (screen-gamma . 2.5)
                 ;; (screen-gamma . 1.5)
                 (screen-gamma . nil)
                 ;; Dell monitor
                 ;; (screen-gamma . 2.7)
                 ;; Daylight adaptation
                 ;; (screen-gamma . 5)
                 ))))

;;; This is needed when redshift is running, since it overwrites
;;; xrandr's gamma settings
(defun ublt/set-gamma (g)
  (modify-all-frames-parameters
   `((screen-gamma . ,g))))

(defun ublt/toggle-gamma ()
  (interactive)
  (ublt/set-gamma
   (if (equal 2.7 (frame-parameter nil 'screen-gamma))
       nil 2.7)))


;;; Frame title
(defun ublt/frame-title ()
  (if (and (featurep 'projectile) (projectile-project-p))
      (let ((prj (projectile-project-name)))
        (cond
         (buffer-file-name
          (format "[%s] %s" prj
                  ;; TODO: Handle symlinks
                  (car (projectile-make-relative-to-root (list buffer-file-name)))))
         ((eq major-mode 'dired-mode)
          (format "[%s] %s" prj
                  ;; TODO: Handle symlinks
                  (car (projectile-make-relative-to-root (list default-directory)))))
         (t
          (format "[%s] -- %s" prj (buffer-name)))))
    (or buffer-file-name (buffer-name))))

(setq
 frame-title-format '(:eval (ublt/frame-title)))


;; Fonts
(when (display-graphic-p)
  ;; Font-mixing obsession
  (ublt/set-up
      (case system-type
        ('gnu/linux 'ublt-font)
        ('darwin 'ublt-font-osx))
    ;; Non-code text reads better in proportional font
    (defvar ublt/disable-variable-pitch-mode nil)
    (make-local-variable 'ublt/disable-variable-pitch-mode)
    ;; This isn't pretty, but the alternative is using a variable-pitch
    ;; font as the default, and creating a `fixed-pitch-mode'.
    (defun ublt/variable-pitch-mode-maybe ()
      ;; `http://stackoverflow.com/questions/5147060/how-can-i-access-directory-local-variables-in-my-major-mode-hooks'
      (when (not ublt/disable-variable-pitch-mode)
        (variable-pitch-mode +1))
      (add-hook 'hack-local-variables-hook
                (lambda ()
                  (when ublt/disable-variable-pitch-mode
                    (variable-pitch-mode -1)))
                nil t))
    (defun ublt/variable-pitch-mode-fundamental ()
      (when (eq major-mode 'fundamental-mode)
        (ublt/variable-pitch-mode-maybe)))
    (dolist (hook '(erc-mode-hook
                    text-mode-hook
                    Info-mode-hook
                    helpful-mode-hook
                    help-mode-hook
                    apropos-mode-hook
                    ess-help-mode-hook
                    lyric-mode-hook
                    Man-mode-hook woman-mode-hook
                    twittering-mode-hook
                    emms-playlist-mode-hook
                    skype--chat-mode-hook
                    org-mode-hook
                    markdown-mode-hook
                    html-mode-hook
                    git-commit-mode-hook
                    twittering-edit-mode-hook
                    package-menu-mode-hook))
      (add-hook hook 'ublt/variable-pitch-mode-maybe))
    (add-hook 'find-file-hook 'ublt/variable-pitch-mode-fundamental)
    (dolist (hook '(hexl-mode
                    dns-mode-hook))
      (add-hook hook (ublt/off-fn 'variable-pitch-mode)))
    ))


;;;Color theme
(when (y-or-n-p "Load theme?")
  (if (window-system)
      (ublt/set-up 'ublt-dark-theme
        (load-theme 'ublt-dark t))
    (load-theme 'monokai t)))


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
(ublt/set-up 'highlight-parentheses
  (add-hook 'prog-mode-hook (ublt/on-fn 'highlight-parentheses-mode) t))
;; ;; Work-around for a bug in highlight-parentheses-mode which messes up
;; ;; the overlays, making the colors off if the mode is turned on twice
;; ;; (e.g. by prog-mode-hook and by desktop-mode, which keeps track of
;; ;; active minor modes from last session)
;; (defadvice highlight-parentheses-mode (around work-around-hl-bug activate)
;;   (unless (and highlight-parentheses-mode
;;                (= 1 (ad-get-arg 0)))
;;     ad-do-it))


;;; Code folding

;;; FIX: Figure out why `web-mode' does not highlight code if this
;; section is not present, even though it complains about not
;; supporting `hideshow'.
;;; XXX: This makes terminal Emacs hang, so only use if there's a
;; window system
(when window-system
  (ublt/set-up 'hideshow
    (defadvice hs-toggle-hiding (around keep-point activate)
      "Try to keep point after toggling."
      (save-excursion
        ad-do-it))
    (setq
     hs-hide-comments-when-hiding-all nil
     hs-isearch-open t))
  (ublt/set-up 'fold-dwim-org
    ;; XXX FIX `fold-dwim-org'
    (defun looking-at-end-of-line ()
      (looking-at "$"))
    ;; Like org-mode TAB and S-TAB
    (setq fold-dwim-org/trigger-keys-block '((kbd "TAB")))
    (defun ublt/code-folding-setup ()
      (unless (eq major-mode 'web-mode)
        (hs-minor-mode 1)
        (fold-dwim-org/minor-mode 1))
      ;; hideshowvis causes `htmlize-buffer' & `htmlize-file' to stop
      ;; working, and `htmlize' output to contain *hideshowvis*
      ;; garbage text
      ;; (hideshowvis-enable)
      )
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

(ublt/set-up 'page-break-lines
  (setq page-break-lines-char ?━)
  (dolist (mode '(sh-mode
                  conf-mode
                  js-mode
                  js2-mode))
    (add-to-list 'page-break-lines-modes mode))
  (global-page-break-lines-mode +1))


;;; Line number
(ublt/set-up 'linum-relative
  (setq linum-relative-current-symbol "")
  (unless (eq linum-format 'linum-relative)
    (linum-relative-toggle))
  (global-linum-mode +1))


;;; Empty lines at the end of a buffer. TODO: Use this once it doesn't
;; mess with comint modes anymore
;; (ublt/set-up 'vim-empty-lines-mode
;;   (global-vim-empty-lines-mode +1))


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
        (set-frame-parameter nil 'alpha 5)
      (set-frame-parameter nil 'alpha 100))))


;;; Looks like only tweaking visual-line-mode is needed (I was
;;; probably confused by global/local variables)

(setq-default
 ;; This affects how lines are wrapped (we want wrapping at word
 ;; boundary not in the middle of a word)
 word-wrap t
 ;; Is this really necessary? (maybe, because visual-line-mode is off
 ;; by default)
 truncate-lines t)

;;; This seems to be a superset of word-wrap?
(global-visual-line-mode -1)

;;; Don't wrap where alignment is important
(dolist (hook '(emms-browser-show-display-hook
                archive-zip-mode-hook
                dired-mode-hook
                sql-mode-hook
                org-agenda-mode-hook))  ; XXX: not working
  (add-hook hook (ublt/off-fn 'visual-line-mode)))

;;; Always wrap where text should flow
(dolist (hook '(twittering-mode-hook
                markdown-mode-hook
                org-mode-hook
                html-mode-hook))
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

  (when window-system
    (ublt/set-up 'nyan-mode
      (setq nyan-bar-length 24)))

  (unless (functionp 'nyan-create)
    (defun nyan-create () ""))

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
                (powerline-raw "%4l" 'fixed-pitch) ; line
                (powerline-raw ":" 'fixed-pitch)
                (powerline-raw "%2c" 'fixed-pitch) ; column
                (powerline-raw " " 'fixed-pitch)
                (powerline-raw (nyan-create))

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
  '(
   ъ 1 2 3 4 5   6 7 8 9 0 х
     э б ю з н   а п с к д \
     ф щ у г ш   в р е т ы -
     ж й о л ч   и ь ц м я
     ё Б               . =
     )
  ;; mode name - displayed text - feature name (file name)
  (dolist (m '((paredit-mode               "(П)" paredit)
               (projectile-mode            "Пр" projectile)
               (undo-tree-mode             "" undo-tree)
               (yas-minor-mode             "яс" yasnippet)
               (flycheck-mode              " !" flycheck)
               (flymake-mode               " !" flymake)
               (flyspell-mode              " !" flyspell)
               (hs-minor-mode              " ⊕" hideshow)
               (company-mode               "" company)
               (rainbow-mode               " ❂" rainbow-mode)
               (helm-mode                  " ⎈" helm)
               (anzu-mode                  " Σ" anzu)
               (isearch                    " Σ")
               (auto-fill-function         " ⏎")
               (visual-line-mode           " ⤾")
               ;; (slime-mode              "SLIME")
               (haskell-indentation-mode   "･" haskell-indentation)
               (org-indent-mode            "" org-indent)
               (whole-line-or-region-mode  "" whole-line-or-region)
               (buffer-face-mode           "" face-remap)
               (volatile-highlights-mode   "" volatile-highlights)
               (elisp-slime-nav-mode       "" elisp-slime-nav)
               (highlight-parentheses-mode "" highlight-parentheses)
               (hi-lock-mode               "" hi-lock)
               (eldoc-mode                 "")
               (page-break-lines-mode      "")
               ))
    (destructuring-bind (mode display &optional feature) m
      (ublt/diminish mode display feature))))


;;; TODO: Use a prettification mode

;;; - `pretty-symbols': simplistic
;;; - `pretty-symbol-mode': built-in, simplistic (1 symbol ->
;;; 1 char, no conditional).
;;; - `pretty-mode': lots of mapping, not customizable, no conditional.
'(∧∧∧∧∧
  ∨∨∨∨∨
  $this->foo
  $this➞foo
  $this➝foo
  $this➜foo
  $this➔foo
  $this➛foo
  $this→foo
  ⟶⟶⟶
  $this⇾foo
  $this⤞foo)

(defun ublt/show-as (how &optional pred)
  (let* ((beg (match-beginning 1))
         (end (match-end 1))
         (ok (or (not pred) (funcall pred beg end))))
    (when ok
      (compose-region beg end how 'decompose-region))
    nil))

(defun ublt/-not-in-org-src-block (beg end)
  (notany (lambda (overlay)
            (eq (overlay-get overlay 'face) 'org-block-background))
          (overlays-in beg end)))

(defun ublt/-no-ligature-support (beg end)
  (not (and
        (eq window-system 'mac)
        mac-auto-operator-composition-mode)))

(defun ublt/pretty-org (on)
  (let ((f (if on #'font-lock-add-keywords
             #'font-lock-remove-keywords)))
    (funcall
     f 'org-mode `(("\\(#\\+begin_src\\>\\)"
                    (0 (ublt/show-as ?⌨)))
                   ("\\(#\\+BEGIN_SRC\\>\\)"
                    (0 (ublt/show-as ?⌨)))
                   ("\\(#\\+end_src\\>\\)"
                    (0 (ublt/show-as ?⌨)))
                   ("\\(#\\+END_SRC\\>\\)"
                    (0 (ublt/show-as ?⌨)))
                   ("\\(\\[X\\]\\)"
                    (0 (ublt/show-as ?☑)))
                   ("\\(\\[ \\]\\)"
                    (0 (ublt/show-as ?☐)))
                   ;; ("\\[\\(X\\)\\]"
                   ;;  (0 (ublt/show-as ?✓)))
                   ;; Arrows
                   ("\\(=>\\)"
                    (0 (ublt/show-as ?⟹ #'ublt/-not-in-org-src-block)))
                   ("\\(<=\\)"
                    (0 (ublt/show-as ?⟸ #'ublt/-not-in-org-src-block)))
                   ("\\(->\\)"
                    (0 (ublt/show-as ?⟶ #'ublt/-not-in-org-src-block)))
                   ("\\(<-\\)"
                    (0 (ublt/show-as ?⟵ #'ublt/-not-in-org-src-block)))))))
(ublt/pretty-org t)

(font-lock-add-keywords
 'web-mode `(("\\(function\\)"
              (0 (ublt/show-as ?ƒ)))))
(font-lock-add-keywords
 'ess-mode `(("\\(function\\)"
              (0 (ublt/show-as ?ƒ)))))
(font-lock-add-keywords
 'php-mode `(("\\(->\\)"
              (0 (ublt/show-as ?➛ #'ublt/-no-ligature-support)))
             ("\\(=>\\)"
              (0 (ublt/show-as ?⇒ #'ublt/-no-ligature-support)))
             ("\\(array\\)("
              (0 (ublt/show-as ?▸)))
             ("\\(function\\)"
              (0 (ublt/show-as ?ƒ)))
             ("{\\|}\\|;\\|\\$" . 'ublt/lisp-paren-face)
             ("\\(ret\\)urn"
              (0 (ublt/show-as ?▸)))
             ("ret\\(urn\\)"
              (0 (ublt/show-as ?▸)))))
(dolist (mode '(js-mode js2-mode web-mode))
  (font-lock-add-keywords
   mode `(("{\\|}\\|;" . 'ublt/lisp-paren-face)
          ("\\(function\\)"
           (0 (ublt/show-as ?ƒ)))
          ;; yield => γζ
          ("\\(yi\\)eld"
           (0 (ublt/show-as ?γ)))
          ("yi\\(eld\\)"
           (0 (ublt/show-as ?ζ)))
          ;; return => ▸▸
          ("\\(ret\\)urn"
           (0 (ublt/show-as ?▸)))
          ("ret\\(urn\\)"
           (0 (ublt/show-as ?▸))))))
(dolist (mode '(clojure-mode))
  (font-lock-add-keywords
   mode `(("{\\|}\\|;" . 'ublt/lisp-paren-face)
          ;; fn => ƒ
          ("(\\(\\<fn\\>\\)"
           (0 (ublt/show-as ?ƒ))))))
(dolist (mode '(emacs-lisp-mode))
  (font-lock-add-keywords
   mode `(("\\(lambda\\)"
           (0 (ublt/show-as ?λ))))))
(dolist (mode '(python-mode))
  (font-lock-add-keywords
   mode `(
          ;; yield => γζ
          ("\\(yi\\)eld"
           (0 (ublt/show-as ?γ)))
          ("yi\\(eld\\)"
           (0 (ublt/show-as ?ζ)))
          ("\\(lambda\\)"
           (0 (ublt/show-as ?λ))))))
(unless (eq window-system 'mac)
  (font-lock-add-keywords
   'scala-mode `(("\\(=>\\)"
                  (0 (ublt/show-as ?⇒))))))

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


;;; Bigger minibuffer text
(defun ublt/minibuffer-setup ()
  (set (make-local-variable 'face-remapping-alist)
       '((default :height 1.0)))
  (setq line-spacing 0.3))
(add-hook 'minibuffer-setup-hook 'ublt/minibuffer-setup)


;;; Looks like `adaptive-wrap' degrades performance on large buffers (e.g. check
;;; out draft.org). Disable it for now. TODO: Find out why
;; (ublt/set-up 'adaptive-wrap
;;   ;; FIX: Don't overwrite, change the source
;;   (defun adaptive-wrap-prefix-function (beg end)
;;     "Indent the region between BEG and END with adaptive filling."
;;     (goto-char beg)
;;     (while (< (point) end)
;;       (let ((lbp (line-beginning-position)))
;;         (put-text-property (point)
;;                            (progn (search-forward "\n" end 'move) (point))
;;                            'wrap-prefix
;;                            (adaptive-wrap-fill-context-prefix lbp (point))
;;                            ;; (propertize (adaptive-wrap-fill-context-prefix lbp (point))
;;                            ;;             ;; For it to work with `variable-pitch-mode'
;;                            ;;             'face 'default)
;;                            ))))
;;   (defadvice visual-line-mode (after adaptive-wrap activate)
;;     (if (and visual-line-mode adaptive-fill-mode)
;;         (progn
;;           (adaptive-wrap-prefix-mode +1)
;;           (auto-fill-mode -1))
;;       (adaptive-wrap-prefix-mode -1))))

;;; TODO: Move to editing
(defadvice visual-line-mode (after no-hard-wrapping activate)
  "Turn off `auto-fill-mode' (automatic hard wrapping)."
  (when visual-line-mode
    (auto-fill-mode -1)))

;;; Change highlighting
(ublt/set-up 'diff-hl
  (global-diff-hl-mode +1)
  (setq diff-hl-draw-borders nil)
  (if (display-graphic-p)
      (setq diff-hl-side 'right)
    (setq diff-hl-side 'left)
    (diff-hl-margin-mode)))


;;; Misc

(setq
 ;; 2x70 instead of the default 2x80 so that side-by-side is preferable
 split-width-threshold 150

 ;; Tile ediff windows horizontally
 ediff-split-window-function 'split-window-horizontally

 ;; Don't create new frame for ediff's control window
 ediff-window-setup-function 'ediff-setup-windows-plain

 ;; Bells suck, both visible and audible
 visible-bell (case system-type
                ('gnu/linux nil)
                ('darwin nil))

 show-paren-delay 0

 ;; Limit minibuffer to 20% frame height
 max-mini-window-height 0.2
 ;; resize-mini-windows 'grow-only

 ;; Echo keystrokes faster
 echo-keystrokes 0.2

 ;; woman settings
 woman-fill-column 80
 woman-fill-frame t
 woman-default-indent 7
 )

;;; Maybe move other window's point before and after minibuffer invocation
;; ;;; XXX: This is bad
;; (defun ublt/redisplay ()
;;   (message "%s" (selected-window)))
;; (add-hook 'minibuffer-setup-hook 'ublt/redisplay)

(setq-default
 line-spacing 0.1

 ;; Default width that triggers hard-wrap.
 fill-column 120
 )

;; Buffed-up help system
(ublt/set-up 'helpful)

;;; XXX: Find out why `python-mode' is upset by `which-func-mode'
;; ;;; Show current function name in mode-line
;; (which-func-mode +1)

;; ;; Fringe
;; (set-fringe-mode '(8 . 0))

;;; FIX: Make them compatible
(defun ublt/maybe-number-font-lock-mode ()
  (unless (member major-mode '(web-mode))
    (number-font-lock-mode +1)))

(ublt/set-up 'number-font-lock-mode
  (add-hook 'prog-mode-hook #'ublt/maybe-number-font-lock-mode))

(ublt/set-up 'eval-sexp-fu
  (setq eval-sexp-fu-flash-duration 0.4
        eval-sexp-fu-flash-error-duration 0.6))

(ublt/set-up 'volatile-highlights
  (volatile-highlights-mode +1))

(ublt/set-up 'anzu
  (setq anzu-minimum-input-length 2
        anzu-search-threshold 100)
  (global-anzu-mode +1))

(ublt/set-up 'htmlize
  (setq htmlize-ignore-face-size nil
        htmlize-css-name-prefix "htmlize-"
        htmlize-html-major-mode 'html-mode))

;;; TODO: Tweak htmlize instead. `htmlfontify' does not work with org
;;; blocks.
(ublt/set-up 'htmlfontify
  (defun ublt/hfy-page-header (file style)
    ;; FIX: Escape file name???
    (format "<!DOCTYPE html>
<html>
  <head>
    <title>%s</title>
    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">
%s
" file style))
  (setq hfy-page-header 'ublt/hfy-page-header))

(ublt/set-up 'golden-ratio
  (dolist (mode '(ediff-mode))
    (add-to-list 'golden-ratio-exclude-modes mode)))

(provide 'ublt-appearance)
