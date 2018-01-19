(require 'ublt-util)


;;; Mix-language files

;;; FIX: This must be before web-mode is loaded, which is weird
(setq web-mode-extra-comment-keywords '("NTA" "FIX" "XXX"))
(ublt/set-up 'web-mode
  (add-hook 'web-mode-hook (ublt/off-fn 'auto-fill-mode))

  ;; FreeMarker templates
  (add-to-list 'auto-mode-alist '("\\.ftl$" . web-mode))

  ;; Use `web-mode', as `jsx-mode' is actually not ReactJS's..
  (add-to-list 'auto-mode-alist '("\\.jsx$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tsx$" . web-mode))
  ;; FIX: This is a bad hack
  (defadvice web-mode-highlight-part (around tweak-jsx activate)
    (if (equal web-mode-content-type "jsx")
        (let ((web-mode-enable-part-face nil))
          ad-do-it)
      ad-do-it))
  (defun ublt/web-mode-jsx ()
    (when (equal web-mode-content-type "jsx")
      (paredit-mode +1)))
  (add-hook 'web-mode-hook 'ublt/web-mode-jsx)

  (setq-default
   ;; Padding
   web-mode-script-padding 0
   web-mode-style-padding 2
   ;; Indentation
   web-mode-markup-indent-offset 2
   web-mode-code-indent-offset 2
   web-mode-css-indent-offset 2
   ;; Coloring a lot
   web-mode-enable-current-element-highlight t
   web-mode-enable-block-face t
   web-mode-enable-part-face t
   web-mode-enable-comment-keywords t
   web-mode-enable-element-content-fontification t
   ;; Auto-close when "</" is typed
   web-mode-tag-auto-close-style 1)
  (add-to-list 'auto-mode-alist '("\\.html$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.mako?$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.mjml?$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.handlebars$" . web-mode))
  (add-to-list 'web-mode-engine-file-regexps '("mako" . "\\.mako?\\'"))
  (add-to-list 'auto-mode-alist '("\\.underscore$" . web-mode))

  ;; XXX: Quick-n-dirty hack to highlight `o-blog' templates
  (when (functionp 'org-src-font-lock-fontify-block)
    (defun ublt/web-mode-font-lock-lisp-tags (limit)
      (while (search-forward "<lisp>" limit t)
        (let ((open-end (match-end 0)))
          (if (search-forward "</lisp>" limit t)
              (let ((close-beg (match-beginning 0)))
                ;; TODO: Figure out how to add a face without
                ;; nullifying the effect of `font-lock-add-keywords'
                ;; (font-lock-append-text-property open-end close-beg 'font-lock-face 'web-mode-block-face)
                ;; (font-lock-append-text-property open-end close-beg 'face 'web-mode-block-face)
                (org-src-font-lock-fontify-block "emacs-lisp" open-end close-beg))))))
    (add-to-list 'web-mode-font-lock-keywords 'ublt/web-mode-font-lock-lisp-tags t)
    (font-lock-add-keywords
     'web-mode
     '(("(\\(ob:\\)\\(\\(\\w\\|-\\)+\\)"
        (1 font-lock-variable-name-face)
        (2 font-lock-function-name-face)))
     'append))

  ;; This is a hack to allow using dir-local variables to set
  ;; `web-mode' engine. FIX: `web-mode' should check local variables
  ;; itself.
  ;; `http://stackoverflow.com/questions/5147060/how-can-i-access-directory-local-variables-in-my-major-mode-hooks'
  (defvar ublt/web-mode-engine nil)
  (defun ublt/web-mode-set-engine ()
    (add-hook 'hack-local-variables-hook
              (lambda ()
                (when ublt/web-mode-engine
                  (web-mode-set-engine ublt/web-mode-engine)))
              nil t))
  (add-hook 'web-mode-hook 'ublt/web-mode-set-engine))


;; Emmet (Zen-coding)

(ublt/set-up 'emmet-mode
  (setq emmet-preview-default nil
        emmet-indentation 2)
  (defun ublt/set-up-emmet ()
    (emmet-mode +1)
    ;; Dynamic indentation after expansion based on tab width
    (set (make-local-variable 'emmet-indentation) tab-width))
  (dolist (m '(sgml-mode-hook
               html-mode-hook
               css-mode-hook
               less-css-mode-hook
               web-mode-hook))
    (add-hook m 'ublt/set-up-emmet)))


;;; Misc

;;; TODO: Paredit for css/less

(ublt/set-up 'less-css-mode
  (add-hook 'less-css-mode-hook 'ublt/run-prog-mode-hook))

(ublt/set-up 'css-mode
  (add-hook 'css-mode-hook 'ublt/run-prog-mode-hook)
  (setq css-indent-offset 2)
  (ublt/set-up 'paredit
    (add-hook 'css-mode-hook (ublt/on-fn 'paredit-mode)))
  (ublt/set-up 'aggressive-indent
    (add-hook 'css-mode-hook (ublt/on-fn 'aggressive-indent-mode))))

(ublt/set-up 'sgml-mode
  (add-hook 'html-mode-hook (ublt/off-fn 'auto-fill-mode)))

;;; XXX
(ublt/set-up 'php-mode
  (setq php-mode-coding-style nil)
  (add-hook 'php-mode-hook (lambda () (setq c-basic-offset 4)))
  (ublt/set-up 'flycheck
    (add-hook 'php-mode-hook (ublt/on-fn 'flycheck-mode))))

(provide 'ublt-web)
