(require 'ublt-util)

(require 'ruby-mode)

(add-to-list 'auto-mode-alist '("\\.rjs$" . ruby-mode))
(setq-default ruby-indent-level 2)

(provide 'ublt-ruby)
