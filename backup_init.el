;; Package repositories.
 (require 'package)
 (dolist (source '(("org" . "https://orgmode.org/elpa/")
                       ("melpa-stable" . "https://stable.melpa.org/packages/")
                       ("melpa" . "https://melpa.org/packages/")
                       ))
       (add-to-list 'package-archives source t))
     ;; Prefer stable packages.
     (setq package-archive-priorities '(("melpa-stable" . 1)
					("melpa" . 2)))

;; Pin  `org'.
     (when (boundp 'package-pinned-packages)
       (setq package-pinned-packages
             '((org . "org"))))

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))


;;Package list
(defvar linh/packages
  '(helm helm-ag rg magit paredit use-package monokai-theme erlang elixir-mode flycheck lsp-mode))

;;Run the defined packages if not install will be install
(dolist (p linh/packages)
  (unless (package-installed-p p)
    (package-install p)))

;; Hook mode vi du nhu paredit-mode khoi dong cung emacs
(use-package paredit
  :hook (emacs-lisp-mode . paredit-mode)
  :hook (erlang-mode . paredit-mode)
  :hook (scheme-mode . paredit-mode))

;; Hook erlang-mode with flycheck-mode
(use-package flycheck
  :hook (erlang-mode . flycheck-mode))

;;Cau hinh Magit
(use-package magit
  :bind ("s-m" . magit-status))

;;Cau hinh Helm
(use-package helm
  :bind (("s-h" . helm-mini)
	 ("M-x" . helm-M-x)) 
  :config (helm-mode +1))

;; Hook helm variable-pitch-mode
(use-package org
  :hook (org-mode . variable-pitch-mode))
;;Config Helm-ag
(use-package helm-ag
  :bind ("s-f" . helm-ag))
;; Config package search rg 
(use-package rg
  :bind ("s-r" . rg))

;; Config erlang mode for emacs
(setq load-path (cons "/usr/lib/erlang/lib/tools-3.3/emacs" load-path))
(setq erlang-root-dir "/usr/lib/erlang")
(setq exec-path (cons "/usr/lib/erlang/bin" exec-path))
(require 'erlang-start)

;; Config for Elixir mode
(add-to-list 'load-path "~/.emacs.d/vendor")
(require 'elixir-mode)

;; Highlights *.elixir2 as well
(add-to-list 'auto-mode-alist '("\\.elixir2\\'" . elixir-mode))


;; Config for Scheme in course SICP
(setq scheme-program-name "/usr/local/bin/stk-simply")




(define-key global-map (kbd "s-c") 'kill-ring-save)

;;Goi package theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'zenburn t)


;;Config for Golang
(add-to-list 'load-path "~/.emacs.d/go/")
(autoload 'go-mode "go-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))

(add-hook 'go-mode-hook 'lsp-deferred)

(use-package lsp-mode
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  :init (setq lsp-keymap-prefix "s-l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (go-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands (lsp lsp-deferred))

;; optionally
(use-package lsp-ui :commands lsp-ui-mode)
(use-package company-lsp :commands company-lsp)
;; if you are helm user
(use-package helm-lsp :commands helm-lsp-workspace-symbol)
;; if you are ivy user
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)





;; Xu dung custom file cho chua nhung thong so Emacs tu gen
(setq custom-file "~/.emacs.d/custom.el")
(condition-case err
    (load custom-file)
  (error (message "Error loading custom file")))

