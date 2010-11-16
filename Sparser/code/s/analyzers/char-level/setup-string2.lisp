;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:(SPARSER LISP) -*-
;;; copyright (c) 1992,1993,1994  David D. McDonald  -- all rights reserved
;;; 
;;;     File:  "setup/string"
;;;   Module:  "analyzers;char-level:"
;;;  Version:  2.2 August 1994

(in-package :sparser)

;; 2.0 (9/25/92 v2.3) redone for new tokenizer
;; 2.1 (10/5) changed it to put a source-start character in at the
;;      beginning so that the chart-drivers can be a bit more rational
;; 2.2 (8/1/94) found a fencepost error

;;;----------------
;;; Initialization
;;;----------------

(defun establish-character-source/string (string)
  (let* ((source-length (length string))
         (usable-length (1- *usable-amount-of-character-buffer*))
            ;; because for the first buffer we have to take up
            ;; cell zero with the source-start character
         (overflow (if (> source-length usable-length)
                     (- source-length usable-length)
                     nil))
         (local-buffer *first-character-input-buffer*))

    (setq *character-buffer-in-use*    *first-character-input-buffer*)
    (setq *the-next-character-buffer*  *second-character-input-buffer*)
    (setq *buffers-in-transition*      nil)

    (setq *length-accumulated-from-prior-buffers* 0)

    (if overflow
      (then
        (setq *original-string* string)
        (replace local-buffer  string
                 :start1 1  :end1 (1+ usable-length)
                 :start2 0  :end2 usable-length)
        )
        
      ;; the string is shorter than the buffer length
      (else (replace local-buffer  string
                     :start1 1  :end1 (1+ source-length)
                     :start2 0  :end2 source-length)
            (setf (elt local-buffer (1+ source-length))
                  #\^B)))  ;; end-of-source

    (setf (elt local-buffer 0) #\^A)  ;; source-start
 ;(break)
    (setq *index-of-next-character* -1)
    (setq *source-exhausted* nil)
    (designate-buffer-refilling-routine :string)
    overflow ))


;;;------------------------------------
;;; refilling with more of the string
;;;------------------------------------

(defun refill-character-buffer/string (old-buffer)
  (let* ((usable-length *usable-amount-of-character-buffer*)
         (position-in-source
          (setq *length-accumulated-from-prior-buffers*
                (+ *length-accumulated-from-prior-buffers*
                   usable-length
                   -1 ))) ;; good fudge factor for buffer 2
         (string *original-string*)
         (remaining (- (length string) position-in-source))
         (overflow (> remaining usable-length))
         new-buffer )

    (setq new-buffer *the-next-character-buffer*)

    (when *trace-invisible-markup*
      (format t "~&~%>>> Refilling the character buffer~
                 ~%  last 15 chars \"~A\"~
                 ~%        next 15 \"~A\"~%~%"
              (subseq old-buffer 980)
              (subseq new-buffer 0 20)))
 ;(break)
    (setq *the-next-character-buffer*  old-buffer)
    (setq *buffers-in-transition*      t)
    (setq *character-buffer-in-use*    new-buffer)
    
    (setq *index-of-next-character* -1)
    
    (if overflow
      (then (replace new-buffer  string
                     :start1 0  :end1 usable-length
                     :start2 position-in-source
                     :end2   (+ position-in-source usable-length)))
      
      (else (replace new-buffer  string
                     :start1 0  :end1 remaining
                     :start2 position-in-source 
                     :end2   (+ position-in-source remaining))
            (setf (elt new-buffer remaining) #\^B)))
    
    overflow ))

