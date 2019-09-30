;;; flymake-golangci.el --- A flymake handler for go-mode files using Golang CI lint

;; Copyright (c) 2019 Jorge Javier Araya Navarro

;; Author: Jorge Javier Araya Navarro <jorgejavieran@yahoo.com.mx>
;; URL: https://gitlab.com/shackra/flymake-golangci
;; Package-Version: 0
;; Package-Requires: ((flymake-easy "0.1"))

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

;; Usage:
;;   (require 'flymake-golanci)
;;   (add-hook 'go-mode-hook 'flymake-golangci-load)
;;
;; Uses flymake-easy, from https://github.com/purcell/flymake-easy

;;; Code:

(require 'flymake-easy)

(defconst flymake-golangci-err-line-patterns
  `(,(rx bol (group (one-or-more (any alnum punct))) ":" (group (one-or-more digit)) ":" (group (one-or-more digit)) ": " (group (one-or-more (any alnum blank digit))) line-end)
    ,(rx bol (group (one-or-more (any alnum punct))) ":" (group (one-or-more digit)) ":" (group (one-or-more (any alnum blank digit))) line-end)))

(defcustom flymake-golangci-executable "golangci-lint"
  "The Golang CI lint executable to use for syntax checking."
  :safe #'stringp)

(defcustom flymake-golangci-deadline "1m"
  "Timeout for running golangci-lint.")

(defcustom flymake-golangci-tests nil
  "Analyze *_test.go files"
  :safe #'booleanp
  :type 'boolean)

(defcustom flymake-golangci-fast nil
  "Run only fast linters."
  :safe #'booleanp
  :type 'boolean)

(defcustom flymake-golangci-disable-all nil
  "Disable all linters."
  :safe #'booleanp
  :type 'boolean)

(defcustom flymake-golangci-enable-all nil
  "Enable all linters."
  :safe #'booleanp
  :type 'boolean)

(defcustom flymake-golangci-enable-linters nil
  "Enable some linters."
  :type '(repeat (string :tag "linter")))

(defcustom flymake-golangci-disable-linters nil
  "Disable some linters."
  :type '(repeat (string :tag "linter")))

(defun flymake-golangci-command (filename)
  "Construct a command that flymake can use to check golang source in FILENAME."
  (list
   flymake-golangci-executable "run" "--print-issued-lines=false" "--out-format=line-number"
   (when flymake-golangci-fast "--fast")
   (when flymake-golangci-enable-all "--enable-all")
   (when flymake-golangci-disable-all "--disable-all")
   (when flymake-golangci-tests "--tests")
   (when flymake-golangci-enable-linters (concat "--enable=" flymake-golangci-enable-linters))
   (when flymake-golangci-disable-linters (concat "--disable=" flymake-golangci-disable-linters))
   filename))

;;;###autoload
(defun flymake-golangci-load ()
  "Configure flymake mode to check the current buffer's golang code."
  (interactive)
  (flymake-easy-load 'flymake-golangci-command
                     flymake-golangci-err-line-patterns
                     'tempdir
                     "go"))

(provide 'flymake-golangci)
;;; flymake-golangci.el ends here
