;;; $Id: uchardet.l 216 2008-01-21 12:38:30Z raido $
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "uchardet/defs"))

(fmakunbound 'uchardet::chardet-create)
(fmakunbound 'uchardet::chardet-destroy)
(fmakunbound 'uchardet::chardet-handle-data)
(fmakunbound 'uchardet::chardet-data-end)
(fmakunbound 'uchardet::chardet-reset)
(fmakunbound 'uchardet::chardet-get-charset)
(gc)
