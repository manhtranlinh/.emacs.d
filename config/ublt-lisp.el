(require 'ublt-util)

(defface ublt/lisp-paren-face
  '((((class color) (background dark))
     (:foreground "grey50"))
    (((class color) (background light))
     (:foreground "grey55")))
  "Face used to dim (Lisp) parentheses."
  :group 'personal)

(dolist (mode '(scheme-mode
                emacs-lisp-mode
                lisp-mode
                clojure-mode
                clojurescript-mode))
  (font-lock-add-keywords mode '(("(\\|)" . 'ublt/lisp-paren-face))))

(ublt/set-up 'paredit-mode
  (dolist (hook '(scheme-mode-hook
                  emacs-lisp-mode-hook
                  lisp-mode-hook
                  ielm-mode-hook
                  clojure-mode-hook
                  clojurescript-mode-hook
                  cider-repl-mode-hook))
    (add-hook hook (ublt/on-fn 'paredit-mode) t)))

(ublt/set-up 'lisp-mode
  (ublt/set-up 'eldoc
    (add-hook 'emacs-lisp-mode-hook (ublt/on-fn 'eldoc-mode)))
  (ublt/set-up 'starter-kit-defuns
    ;; FIX
    (defun esk-remove-elc-on-save ()
      "If you're saving an elisp file, likely the .elc is no longer valid."
      (make-local-variable 'after-save-hook)
      (add-hook 'after-save-hook
                (lambda ()
                  (if (file-exists-p (concat buffer-file-name "c"))
                      (delete-file (concat buffer-file-name "c"))))))
    (add-hook 'emacs-lisp-mode-hook 'esk-prog-mode-hook)
    (add-hook 'emacs-lisp-mode-hook 'esk-remove-elc-on-save))
  (ublt/set-up 'elisp-slime-nav
    (add-hook 'emacs-lisp-mode-hook (ublt/on-fn 'elisp-slime-nav-mode))))

;; clojure-mode customization
(ublt/set-up 'clojure-mode
  (add-to-list 'auto-mode-alist '("\\.dtm$" . clojure-mode))
  ;; (define-clojure-indent
  ;;   (describe 'defun)
  ;;   (testing 'defun)
  ;;   (given 'defun)
  ;;   (using 'defun)
  ;;   (with 'defun)
  ;;   (it 'defun)
  ;;   (do-it 'defun))
  )

;;; XXX: Fix durendal instead
(ublt/set-up 'durendal
  ;; For REPL font-lock trick to work in Emacs 24
  (defun ublt/repl-clojure-font-lock ()
    (font-lock-mode -1)
    (clojure-mode-font-lock-setup)
    (font-lock-mode +1))
  (durendal-enable)
  (setq durendal-auto-compile? nil)
;;; TODO: `ublt/set-up' should accept a list of features
  (add-hook 'cider-repl-mode-hook 'ublt/repl-clojure-font-lock))

;;;; ielm settings ---------------
(add-hook 'ielm-mode-hook
          (lambda () (setq comint-input-ring-file-name "~/.emacs.d/.ielm-input.hist")))

;;; @cider: making a keymap available without the mode being provided
;;; is just fucking insane
(ublt/set-up 'cider-repl
  (setq cider-repl-popup-stacktraces t
        cider-repl-use-pretty-printing t
        cider-repl-wrap-history t
        cider-repl-history-file "~/.emacs.d/.nrepl.hist"))
(ublt/set-up 'cider-interaction
  (setq cider-popup-stacktraces nil))

(provide 'ublt-lisp)
