(provide "uchardet/defs")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "foreign")
  (unless (find-package "uchardet")
    (defpackage "uchardet"
      (:use "lisp" "foreign"))))

(in-package "uchardet")
(export '(*uchardet-dll-path*))

(defvar *uchardet-dll-path* nil)
(unless *uchardet-dll-path*
  (setq *uchardet-dll-path* (merge-pathnames "uchardet.dll" (si:system-root))))
