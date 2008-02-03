;;; $Id$
;;;
;; ***** BEGIN LICENSE BLOCK *****
;; Version: MPL 1.1/GPL 2.0/LGPL 2.1
;;
;; The contents of this file are subject to the Mozilla Public License Version
;; 1.1 (the "License"); you may not use this file except in compliance with
;; the License. You may obtain a copy of the License at
;; http://www.mozilla.org/MPL/
;;
;; Software distributed under the License is distributed on an "AS IS" basis,
;; WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
;; for the specific language governing rights and limitations under the
;; License.
;;
;; The Original Code is Mozilla Universal charset detector code.
;;
;; The Initial Developer of the Original Code is
;; Netscape Communications Corporation.
;; Portions created by the Initial Developer are Copyright (C) 2001
;; the Initial Developer. All Rights Reserved.
;;
;; Contributor(s):
;;          NANRI Masaoki <southy@gmail.com>
;;
;; Alternatively, the contents of this file may be used under the terms of
;; either the GNU General Public License Version 2 or later (the "GPL"), or
;; the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
;; in which case the provisions of the GPL or the LGPL are applicable instead
;; of those above. If you wish to allow use of your version of this file only
;; under the terms of either the GPL or the LGPL, and not to allow others to
;; use your version of this file under the terms of the MPL, indicate your
;; decision by deleting the provisions above and replace them with the notice
;; and other provisions required by the GPL or the LGPL. If you do not delete
;; the provisions above, a recipient may use your version of this file under
;; the terms of any one of the MPL, the GPL or the LGPL.
;;
;; ***** END LICENSE BLOCK *****

(provide "uchardet/uchardet")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "uchardet/defs"))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (in-package "editor")
  (import '(point-min point-max buffer-substring) "uchardet")
  (import '(*encoding-auto* *encoding-sjis* *encoding-euc-jp* *encoding-jis* *encoding-utf8* *encoding-utf8n*
            *encoding-windows-cyrillic* *encoding-windows-latin1* *encoding-windows-greek* *encoding-iso-8859-5*
            *encoding-iso-8859-7* *encoding-big5* *encoding-iso-2022-cn* *encoding-iso-2022-kr* *encoding-euc-kr*)
          "uchardet"))

(in-package "uchardet")

#|
;; from universalchardet.h
(*define CHARDET_ENCODING_ISO_2022_JP    "ISO-2022-JP")
(*define CHARDET_ENCODING_ISO_2022_CN    "ISO-2022-CN")
(*define CHARDET_ENCODING_ISO_2022_KR    "ISO-2022-KR")
(*define CHARDET_ENCODING_ISO_8859_5     "ISO-8859-5")
(*define CHARDET_ENCODING_ISO_8859_7     "ISO-8859-7")
(*define CHARDET_ENCODING_ISO_8859_8     "ISO-8859-8")
(*define CHARDET_ENCODING_BIG5           "BIG5")
(*define CHARDET_ENCODING_GB18030        "GB18030")
(*define CHARDET_ENCODING_EUC_JP         "EUC-JP")
(*define CHARDET_ENCODING_EUC_KR         "EUC-KR")
(*define CHARDET_ENCODING_EUC_TW         "EUC-TW")
(*define CHARDET_ENCODING_SHIFT_JIS      "SHIFT_JIS")
(*define CHARDET_ENCODING_IBM855         "IBM855")
(*define CHARDET_ENCODING_IBM866         "IBM866")
(*define CHARDET_ENCODING_KOI8_R         "KOI8-R")
(*define CHARDET_ENCODING_MACCYRILLIC    "MACCYRILLIC")
(*define CHARDET_ENCODING_WINDOWS_1251   "WINDOWS-1251")
(*define CHARDET_ENCODING_WINDOWS_1252   "WINDOWS-1252")
(*define CHARDET_ENCODING_WINDOWS_1253   "WINDOWS-1253")
(*define CHARDET_ENCODING_WINDOWS_1255   "WINDOWS-1255")
(*define CHARDET_ENCODING_UTF_8          "UTF-8")
(*define CHARDET_ENCODING_UTF_16BE       "UTF-16BE")
(*define CHARDET_ENCODING_UTF_16LE       "UTF-16LE")
(*define CHARDET_ENCODING_UTF_32BE       "UTF-32BE")
(*define CHARDET_ENCODING_UTF_32LE       "UTF-32LE")
(*define CHARDET_ENCODING_HZ_GB_2312     "HZ-GB-2312")
(*define CHARDET_ENCODING_X_ISO_10646_UCS_4_3412 "X-ISO-10646-UCS-4-3412")
(*define CHARDET_ENCODING_X_ISO_10646_UCS_4_2143 "X-ISO-10646-UCS-4-2143")
|#

(*define-dll-entry int chardet-create ((void* *))
                   *uchardet-dll-path* "chardet_create")
(*define-dll-entry void chardet-destroy (void*)
                   *uchardet-dll-path* "chardet_destroy")
(*define-dll-entry int chardet-handle-data (void* (char *) u_int)
                   *uchardet-dll-path* "chardet_handle_data")
(*define-dll-entry int chardet-data-end (void*)
                   *uchardet-dll-path* "chardet_data_end")
(*define-dll-entry int chardet-reset (void*)
                   *uchardet-dll-path* "chardet_reset")
(*define-dll-entry int chardet-get-charset (void* (char *) u_int)
                   *uchardet-dll-path* "chardet_get_charset")

(export '(detect-encoding-from-string detect-encoding))

(defvar *chardet-encoding-list* `(("SHIFT_JIS" . ,*encoding-sjis*)
                                  ("EUC-JP"    . ,*encoding-euc-jp*)
                                  ("ISO-2022-JP" . ,*encoding-jis*)
                                  ("UTF-8"     . ,*encoding-utf8n*)
                                  ("WINDOWS-1251" . ,*encoding-windows-cyrillic*)
                                  ("WINDOWS-1252" . ,*encoding-windows-latin1*)
                                  ("WINDOWS-1253" . ,*encoding-windows-greek*)
                                  ("ISO-8859-5" . ,*encoding-iso-8859-5*)
                                  ("ISO-8859-7" . ,*encoding-iso-8859-7*)
                                  ("BIG5" . ,*encoding-big5*)
                                  ("ISO-2022-CN" . ,*encoding-iso-2022-cn*)
                                  ("ISO-2022-KR" . ,*encoding-iso-2022-kr*)
                                  ("EUC-KR" . ,*encoding-euc-kr*)))

(defun detect-encoding-from-string (str)
  (let ((ptr (si:make-chunk nil 4))
        (enc (si:make-chunk :string 32))
        (str-chunk (si:make-string-chunk str))
        (det nil))
    (chardet-create ptr)
    (setq det (si:unpack-uint32 ptr 0))
    (chardet-handle-data det str-chunk (1- (si:chunk-size str-chunk)))
    (chardet-data-end det)
    (chardet-get-charset det enc 32)
    (chardet-destroy det)
    (si:unpack-string enc 0 32)))

(defun detect-encoding ()
  (when (= (point-min) (point-max))
    (return-from detect-encoding *encoding-auto*))
  (let ((enc (cdr (assoc (detect-encoding-from-string (buffer-substring (point-min) (point-max)))
                         *chardet-encoding-list*
                         :test #'string=))))
    (or enc *encoding-auto*)))

(setq ed::*auto-encoding-alist*  '((".*" . detect-encoding)))

(in-package "editor")

;; $XYZZy/lisp/files.l
(defun find-file-auto-encoding (filename)
  (let ((b (buffer-fileio-encoding)))
    (unwind-protect
        (let ((encoding
               (let ((*expected-fileio-encoding* *encoding-binary*))
                 (declare (special *expected-fileio-encoding*))
                 (ignore-errors (insert-file-contents filename t nil 4096))
                 (goto-char (point-min))
                 (dolist (x *auto-encoding-alist* nil)
                   (when (string-matchp (car x) filename)
                     (return (funcall (cdr x))))))))
          (when (stringp encoding)
            (setq encoding (gethash encoding
                                    *mime-charset-name-hash-table*)))
          (if (char-encoding-p encoding)
              encoding
            (gethash (cdr (assoc "encoding" (find-file-scan-params)
                                 :test #'string-equal))
                     *mime-charset-name-hash-table*)))
      (erase-buffer (selected-buffer))
      (set-buffer-fileio-encoding b))))
