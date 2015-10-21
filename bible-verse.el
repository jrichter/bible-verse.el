;;; bible-verse.el --- Insert Verses                     -*- lexical-binding: t; -*-

;; Copyright (C) 2014 Justin Richter

;; Author: Justin Richter <jrichter@jetfive.com>
;; Keywords: bible
;; Version: 0.0.1

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

;; bible-verse.el aims to insert a bible verse at point. It uses
;; http://bible-api.com to get a verse from the World English Bible.
;;
;; It requires the request package available from melpa or marmalade.
;; M-x package-install request
;; And s.el from https://github.com/magnars/s.el.git or M-x package-install s

;; Translations
;; | Language   | Name                                   | Identifier    |
;; |------------+----------------------------------------+---------------|
;; | Cherokee   | Cherokee New Testament                 | cherokee      |
;; | English    | King James Version                     | kjv           |
;; | English    | World English Bible                    | web (default) |
;; | Latin	| Clementine Latin Vulgate               | clementine    |
;; | Portuguese | João Ferreira de Almeida               | almeida       |
;; | Romanian   | Romanian Corrected Cornilescu Version  | rccv          |

;; Example:
;; Enter a verse: John 3:16 (kjv)
;; Enter a verse: John 3:16
;; Enter a verse: john3:16

;;; Code:
(require 'request)
(require 's)
(require 'json)

(defvar bible-verse-history nil
  "History of previous verses.")

(defun format-verse (verse)
  "Parse json and inset VERSE and reference."
  (let ((obj (json-read-from-string verse)))
    (insert (s-word-wrap 80
                         (replace-regexp-in-string "  +" " "
                         (replace-regexp-in-string "\n" " " (cdr (assoc 'text obj))))))
    (insert "\n")
    (insert " ")
    (insert (cdr (assoc 'reference obj)))))

(defun get-verse (verse)
  "Get the VERSE from bible-api.com."
  (setq verse (replace-regexp-in-string " " "" verse))
  (setq verse (replace-regexp-in-string "(" "?translation=" verse))
  (setq verse (replace-regexp-in-string ")" "" verse))
  (request
   (concat "http://bible-api.com/" verse)
   :parser 'buffer-string
   :success (function* (lambda (&key data &allow-other-keys)
              (when data
                  (format-verse data))))))

(defun bible-verse (ref)
  "Insert a verse at point."
  (interactive (list (read-string "Enter a verse: " nil 'bible-verse-history)) )
  (message "Retrieving %s." ref)
  (get-verse ref))

(provide 'bible-verse)
;;; bible-verse.el ends here
