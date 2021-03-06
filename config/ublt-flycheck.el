(defgroup ubolonton nil ""
  :group 'personal)

(defface ublt/flycheck-message-face
  '((t (:inherit font-lock-warning-face)))
  "Face for current flycheck error message shown in the minibuffer")

;;; XXX FIX: This is monkey-patching of `flycheck-display-error-messages'
(defun ublt/flycheck-display-error-messages (errors)
  "Replacement of `flycheck-display-error-messages' that show the messages in red."
  (let ((messages (delq nil (mapcar #'flycheck-error-message errors))))
    (when (and errors (flycheck-may-use-echo-area-p))
      (display-message-or-buffer (propertize (string-join messages "\n\n")
                                             'face 'ublt/flycheck-message-face)
                                 flycheck-error-message-buffer))))

(use-package flycheck
  :custom ((flycheck-display-errors-delay 0)
           (flycheck-display-errors-function #'ublt/flycheck-display-error-messages)
           ;; FIX: Remove this once we use new versions of `shellcheck' that support --external-sources.
           (flycheck-shellcheck-follow-sources nil)))

(provide 'ublt-flycheck)
