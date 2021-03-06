(require 'ublt-util)

(use-package magit
  :custom

  (vc-handled-backends (delq 'Git vc-handled-backends))

  ;; ;; Show original windows when quitting magit.
  ;; magit-restore-window-configuration t

  ;; magit status buffer should not be a pop-up (in the sense of
  ;; not being volatile or temporary like helm buffer). This is
  ;; important for small screens.
  (magit-display-buffer-function 'magit-display-buffer-same-window-except-diff-v1)

  (magit-refresh-status-buffer nil)

  ;; XXX: Doesn't work. WTF. https://github.com/magit/magit/issues/1743
  ;; ;; 2-way diff for staging is much more useful than 3-way.
  ;; magit-ediff-dwim-show-on-hunks t

  ;; Git directories
  (magit-repository-directories '(("~/dotfiles". 0)
                                  ("~/.emacs.d". 0)
                                  ("~/Programming/projects" . 1)
                                  ("~/Programming/lib" . 1)
                                  ("~/Programming/Tools" . 1)
                                  ("~/.emacs.d/straight/repos" . 1)))

  (magit-status-margin '(t age-abbreviated magit-log-margin-width t 10))

  ;; `all' would be nice, but it's too slow for large diffs
  (magit-diff-refine-hunk t)
  (magit-diff-paint-whitespace 'status)
  ;; Gravatars.
  (magit-revision-show-gravatars '("^Author:     " .  "^Commit:     "))

  (magit-log-margin '(t age-abbreviated magit-log-margin-width t 10))
  (magit-log-show-refname-after-summary t)

  ;; Other
  (magit-blame-mode-lighter "🔥")
  (magit-blame-time-format "%F")

  (magit-refs-show-commit-count 'branch)

  :config
  ;; XXX: The initialization of this is icky. We use `global-auto-revert-mode' anyway, so disable it here.
  (magit-auto-revert-mode -1)

  ;; TODO: Move this definition somewhere else.
  (defun ublt/disable-line-spacing ()
    (setq line-spacing 0))
  (add-hook 'magit-revision-mode-hook #'ublt/disable-line-spacing)

  ;; Our default value for `fill-column' can be different.
  (add-hook 'git-commit-mode-hook
            (lambda () (setq fill-column 80)))

  ;; ;; XXX: `magit-patch-id' calls out to shell, which suffers shell initialization delay. This is
  ;; ;; a temporary workaround. The proper fix is probably writing a C extension or something that
  ;; ;; calls git directly. The mid-term fix is probably calling git directly, not going through shell.
  ;; ;; Either that, or going through shell without initialization.
  ;; (defadvice magit-patch-id (around speed-up activate)
  ;;   (let ((shell-file-name "sh"))
  ;;     ad-do-it))

  ;; ;; XXX
  ;; (defadvice magit-process (around dont-switch activate)
  ;;   (save-selected-window
  ;;     ad-do-it))
  )

(use-package diff-hl
  :hook (magit-post-refresh . diff-hl-magit-post-refresh))

(use-package git-commit
  :custom (git-commit-summary-max-length 70))

(use-package transient
  :custom (transient-default-level 7)
  :config (dolist (addition '(("=m" ("-M" "Show merges only" "--merges"))))
            (apply #'transient-append-suffix 'magit-log addition)))

(use-package magit-libgit2
  :ensure nil :straight nil
  :load-path ("~/Programming/projects/magit-libgit2/elisp"
              "~/Programming/projects/magit-libgit2/target/debug"))

(use-package git-timemachine)

(provide 'ublt-git)
