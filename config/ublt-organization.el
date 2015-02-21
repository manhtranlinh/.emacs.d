(require 'ublt-util)

(require 'org)

(ublt/set-up 'org-indent
  (add-hook 'org-mode-hook (ublt/on-fn 'org-indent-mode)))

(ublt/set-up 'org-bullets
  (setq org-bullets-bullet-list
        ;; TODO
        '("•"))
  (add-hook 'org-mode-hook (ublt/on-fn 'org-bullets-mode)))

(setq
 ;; Intelligent (dwim) bindings
 org-special-ctrl-a/e t
 org-special-ctrl-k t

 ;; Show all headlines by default
 org-startup-folded t

 ;; Disallow editing folded content
 org-catch-invisible-edits 'error

 org-use-sub-superscripts '{}
 org-export-with-sub-superscripts '{}

 ;; org-show-entry-below t

 ;; Don't use isearch there, normal isearch is enough
 org-goto-auto-isearch nil
 ;; Don't use `outline-path-completion'. `ido-imenu' is better
 org-goto-interface 'outline

 ;; Don't split current heading, create a new one
 org-M-RET-may-split-line nil
 ;; Create new heading after the current content
 org-insert-heading-respect-content t

 ;; Heading visual indentation
 org-indent-indentation-per-level 2
 ;; List additional (on top of 2) indentation
 org-list-indent-offset 1

 ;; Allow using alphabetical bullets
 org-alphabetical-lists t

 ;; 2 lines to terminate lists
 org-empty-line-terminates-plain-lists nil

 org-list-use-circular-motion t

 ;; Different list levels should use different bullets
 org-list-demote-modify-bullet '(("-" . "+")
                                 ("+" . "-")
                                 ("1." . "1)")
                                 ("1)" . "1."))

 ;; org-footnote-auto-adjust t

 ;; Fontify code blocks
 org-src-fontify-natively t

 org-export-htmlize-output-type 'css

 org-tags-column -97

 org-completion-use-ido t
 ;; Whole path instead of level-by-level navigation
 org-outline-path-complete-in-steps nil
 org-refile-use-outline-path t

 org-indirect-buffer-display 'current-window)

;; (add-to-list 'auto-mode-alist '("\\.\\(org\\)$" . org-mode))

(add-hook 'org-mode-hook (ublt/on-fn 'hl-line-mode))

;; Use external browser
(add-to-list 'org-file-apps '("\\.x?html?\\'" browse-url file))

;;; Evaluation of embedded code
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (clojure . t)
   (sh . t)))


;;; Task management, GTD

;;; TODO: Define tags (upper-case: specific, lower-case: generic)
;;; home | work
;;; computer
;;; read
;;; think
;;; learn
;;; teach
;;; chore
;;; diary
;;; note
;;; Emacs

;;; TODO: Habits

(setq
 ;; TODO: Maybe just file-local
 org-todo-keywords
 '((sequence "TODO(t!)" "STARTED(s!)" "|" "DONE(d@)")
   (sequence "THINK" "WRITE(w)" "|" "PUBLISHED(p)")
   (sequence "DESIGN" "IMPLEMENT(i)" "TEST" "|" "DONE(d)")
   (sequence "|" "CANCELLED(c)"))

 ;; TODO: Add more colors
 org-todo-keyword-faces '(("TODO" :foreground "Red" :weight normal)
                          ("DEFERRED" :foreground "DeepSkyBlue" :weight normal)
                          ("STARTED" :foreground "DarkGoldenRod" :weight normal)
                          ("CANCELLED" :foreground "Gray15" :weight normal)
                          ("DONE" :foreground "LightGreen" :weight normal))

 org-use-fast-todo-selection t

 ;; Allow S-<left> and S-<right> to change state without logging the change
 org-treat-S-cursor-todo-selection-as-state-change nil

 ;; Use with `org-toggle-ordered-property'
 org-enforce-todo-dependencies t

 ;; org-stuck-projects '("+PROJECT/-DONE" ("DONE") ("*") "")
 ;; org-stuck-projects '("" nil nil "")

 ;; Log a lot
 org-log-done 'note
 org-log-reschedule 'note
 org-log-repeat 'note
 org-log-redeadline t
 org-log-note-clock-out t)

(ublt/set-up 'org-clock
  (org-clock-persistence-insinuate)

  (defun ublt/clock-in-to-next (kw)
    (when (equal kw "TODO")
      "STARTED"))

  (setq
   org-clock-history-length 24
   org-clock-in-resume t

   org-clock-into-drawer t
   org-clock-out-remove-zero-time-clocks t
   org-clock-out-when-done t
   org-clock-persistent t

   org-clock-in-switch-to-state 'ublt/clock-in-to-next
   ))


(ublt/set-up 'org-agenda
  (defun ublt/verify-refile-target ()
    (not (member (nth 2 (org-heading-components)) org-done-keywords)))

  (setq
   org-agenda-dim-blocked-tasks t
   org-agenda-start-on-weekday nil
   org-agenda-skip-scheduled-if-deadline-is-shown nil
   org-agenda-skip-deadline-if-done nil
   org-agenda-skip-scheduled-if-done nil
   org-agenda-span 'week

   org-agenda-time-grid '((daily today require-timed)
                          "-----------------------"
                          (800 1000 1200 1400 1600 1800 2000 2200 2300))

   ;; org-scheduled-past-days 365

   org-agenda-log-mode-items '(closed clock state)

   org-agenda-tags-column -196
   org-agenda-window-setup 'current-window
   org-agenda-restore-windows-after-quit t

   ;; TODO: Maybe more
   org-agenda-files '("~/org/gtd/gtd.org"
                      "~/org/gtd/journal.org"
                      "~/org/gtd/projects.org")

   ;; TODO: Use another file, as this is meant for notes not actually tasks
   org-default-notes-file "~/org/gtd/someday.org"

   ;; TODO: Restructure
   org-refile-targets '((("~/org/gtd/projects.org") . (:maxlevel . 2))
                        (("~/org/gtd/gtd.org") . (:maxlevel . 1))
                        (("~/org/gtd/someday.org") . (:maxlevel . 1)))

   org-refile-allow-creating-parent-nodes 'confirm
   org-refile-target-verify-function 'ublt/verify-refile-target

   ;; org-columns-default-format "%TODO %50ITEM %TAGS %CATEGORY"

   ;; TODO: More
   org-agenda-custom-commands
   '(("P" "Projects summary"
      ((tags "PROJECT" ((org-agenda-todo-list-sublevels nil)))))
     ("p" "Projects details"
      ((tags "PROJECT" )))
     ("D" "Daily action list"
      ((agenda "" ((org-agenda-ndays 1)
                   (org-agenda-sorting-strategy
                    '((agenda time-up priority-down tag-up)))
                   (org-deadline-warning-days 0)
                   (org-agenda-prefix-format '((agenda  . " %i %-12:c%?-12t% s")))))))
     ("S" "\"Someday\" task list"
      ((todo "TODO" ((org-agenda-files '("~/org/gtd/someday.org"))
                     (org-agenda-prefix-format '((todo . "  ")))))))
     ("u" "Test"
      ((agenda "")
       (tags-todo "Work")))))

  (add-hook 'org-agenda-mode-hook (ublt/on-fn 'hl-line-mode)))

;;; Task creation (capturing/remembering)
(ublt/set-up 'org-capture
  (setq
   org-capture-templates
   '(
     ("t" "Todo"
      entry (file+headline "~/org/gtd/gtd.org" "Tasks")
      "** TODO %^{Brief Description} %^g\n   - Added: %U\n%?\n")
     ("s" "Someday"
      entry (file "~/org/gtd/someday.org")
      "** TODO %^{Do this someday} %^g\n   - Added: %U\n%?\n")
     ("d" "Diary"
      entry (file "~/org/gtd/journal.org")
      "** %U %^{Diary} :Diary:%^g\n%i%?")
     ("i" "Idea"
      entry (file "~/org/gtd/journal.org")
      "** %U %^{Thought} :Thought:%^g\n%i%?")
     ("r" "Review"
      entry (file "~/org/gtd/journal.org")
      "** %t Daily Review :Coach:\n%[~/org/gtd/daily-review.txt]\n" )
     ("p" "Project"
      entry (file+headline "~/org/gtd/projects.org" "Projects")
      "** TODO %^{Project Name}\n  - Added: %U\n%?")
     )))


;;; Slides for presentation

(ublt/set-up 'ox-reveal
  (setq org-reveal-root "reveal.js/"

        org-reveal-transition "linear"
        org-reveal-transition-speed "fast"

        org-reveal-history t
        org-reveal-control t
        org-reveal-progress t
        org-reveal-rolling-links nil))


;;; PDF export

(ublt/set-up 'ox-latex
  ;; Use minted for code highlighting in exported pdf files
  ;; http://joat-programmer.blogspot.nl/2013/07/org-mode-version-8-and-pdf-export-with.html
  (add-to-list 'org-latex-packages-alist '("" "minted"))
  (setq org-latex-listings 'minted
        org-latex-pdf-process '("xelatex -shell-escape -interaction nonstopmode %f"
                                "xelatex -shell-escape -interaction nonstopmode %f")
        org-latex-toc-command ""
        ;; Don't use `inputenc', `fontenc' (xelatex `fontspec' is
        ;; supposed to handle unicode better)
        org-latex-default-packages-alist
        '(("" "fixltx2e" nil)
          ("" "graphicx" t)
          ("" "longtable" nil)
          ("" "float" nil)
          ("" "wrapfig" nil)
          ("" "rotating" nil)
          ("normalem" "ulem" t)
          ("" "amsmath" t)
          ("" "textcomp" t)
          ("" "marvosym" t)
          ("" "wasysym" t)
          ("" "amssymb" t)
          ("" "hyperref" nil)
          "\\tolerance=1000"))
  (add-to-list 'org-latex-classes
               `("ublt-org-article"
                 ,(ublt/get-string-from-file "~/.emacs.d/config/ublt-org-article.tex")
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))



(provide 'ublt-organization)
