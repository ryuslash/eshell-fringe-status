;;; eshell-fringe-status.el --- Show last status in fringe  -*- lexical-binding: t; -*-

;; Copyright (C) 2014  Tom Willemse

;; Author: Tom Willemse <tom@ryuslash.org>
;; Keywords:
;; Version: 0.1.0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Show an indicator of the status of the last command run in eshell.
;; To use, enable `eshell-fringe-status-mode' in `eshell-mode'.  The
;; easiest way to do this is by adding a hook:

;; : (add-hook 'eshell-mode-hook #'eshell-fringe-status-mode)

;; This mode uses a rather hackish way to try and keep everything
;; working in regard to `eshell-prompt-regexp', so if anything breaks
;; please let me know.

;;; Code:

(require 'em-prompt)

(defgroup eshell-fringe-status
  nil
  "Settings for command exit status shown in Emacs' fringe."
  :group 'eshell
  :prefix "eshell-fringe")

(defface eshell-fringe-status-success
  '((t (:foreground "#00ff00")))
  "Face used to indicate success status."
  :group 'eshell-fringe-status)

(defface eshell-fringe-status-failure
  '((t (:foreground "#ff0000")))
  "Face used to indicate failed status."
  :group 'eshell-fringe-status)

(define-fringe-bitmap 'efs--arrow-bitmap
  [#b10000
   #b11000
   #b11100
   #b11110
   #b11111
   #b11110
   #b11100
   #b11000
   #b10000] 9 5 'center)

(defun efs--extend-prompt-regexp ()
  "Add a space at the beginning of `eshell-prompt-regexp'.

Since the fringe bitmap is added as a space with a special
display value, any existing regexp in `eshell-prompt-regexp'
which doesn't accept at least one space will break."
  (let ((first (aref eshell-prompt-regexp 0)))
    (when (eql first ?^)
      (setq eshell-prompt-regexp
            (format "%c ?%s" first (substring eshell-prompt-regexp 1))))))

(defun efs--revert-prompt-regexp ()
  "The counterpart for `efs--extend-prompt-regexp', remove a space.

Since when the mode is started a space is added to the beginning
of `eshell-prompt-regexp' it should also be removed when
disabling the mode."
  (let ((first (aref eshell-prompt-regexp 0)))
    (when (and (eql first ?^)
               (eql (aref eshell-prompt-regexp 1) ?\s))
      (setq eshell-prompt-regexp
            (format "%c%s" first (substring eshell-prompt-regexp 3))))))

(defun eshell-fringe-status ()
  "Display an indication of the last command's exit status.

This indication is shown as a bitmap in the left fringe of the
window."
  (save-excursion
    (beginning-of-line)
    (insert
     (propertize " " 'display
                 `((left-fringe efs--arrow-bitmap
                                ,(if (zerop eshell-last-command-status)
                                     'eshell-fringe-status-success
                                   'eshell-fringe-status-failure)))))))

;;;###autoload
(define-minor-mode eshell-fringe-status-mode
  "Show exit status of last command in fringe."
  nil nil nil
  (if eshell-fringe-status-mode
      (progn
        (efs--extend-prompt-regexp)
        (add-hook 'eshell-after-prompt-hook
                  #'eshell-fringe-status nil :local))
    (efs--revert-prompt-regexp)
    (remove-hook 'eshell-after-prompt-hook
                 #'eshell-fringe-status :local)))

(provide 'eshell-fringe-status)
;;; eshell-fringe-status.el ends here
