;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; copyright (c) 1993-2000 David D. McDonald  -- all rights reserved
;;; 
;;;     File:  "ordinals"
;;;   Module:  "model;core:numbers:"
;;;  Version:  2.1 July 2000

;; initiated [ordinals1] 9/18/93 v2.3 as completely new treatment
;; 1.0 (1/7/94) redesigned as specialized categories
;;     (1/9/96) added string printer.
;; 2.0 (7/11/00) Changed the name of the interesting category from position-in-
;;      a-sequence to ordinal, flushing the simple category "ordinal". Reworked
;;      into the new regime as much as possible.
;; 2.1 (7/13) punted on the whole 'each ordinal is its own relation scheme 
;;      since it shouldn' be necessary given psi.

(in-package :sparser)

;;;--------
;;; object
;;;--------

(define-category  ordinal    ;; formerly position-in-a-sequence
  :instantiates self
  :specializes number
  :binds ((number number)
          (word  :primitive word)
          (roman-numeral :primitive word)
          (item)
          (sequence . sequence))
  :realization (:quantifier word))



(defun string/ordinal (category)
  ;; see special check in String-for that gets us here
  (let ((number (value-of 'number category))
        (*print-short* t))
    (format nil "~A" number)))


;;;------
;;; form
;;;------

(defun define-ordinal (string        ;; e.g. "third"
                       lisp-number
                       &key roman-numeral)

  (let* ((number (find-individual 'number :value lisp-number))
         (word (resolve/make string))
         (roman (when roman-numeral (resolve/make roman-numeral)))
         (name (intern (symbol-name (word-symbol word))
                       *category-package*)))
    (declare (ignore roman))

    (unless number
      (break "When defining an ordinal, the corresponding number object ~
              ~%must be defined first. The number for ~A isn't" lisp-number))

    (let ((ordinal (referential-category-named name)))
      (if ordinal
        ordinal
        (else
          (setq ordinal
                (define-individual 'ordinal
                  :number number
                  :word word))
                            
          ;; not reversible yet
          ;(when roman-numeral
          ;  (push (define-cfr category::ordinal `(,roman)
          ;          :form category::adjective
          ;          :referent  ordinal )
          ;        rules))

          ordinal )))))




#|  original definition of Define-ordinal
  (let ((number (find-individual 'number :value lisp-number))
        ord  rules )

    (if (setq ord (find-individual 'position-in-a-sequence
                                   :number number))
      ord
      (let ((word (resolve/make string))
            (roman (when roman-numeral
                     (resolve/make roman-numeral))))

        (setq ord
              (define-individual 'position-in-a-sequence
                :number number
                :word word ))

        (setq rules
              (list (define-cfr category::ordinal `(,word)
                      :form  category::adjective
                      :referent  ord)))

        (when roman-numeral
          (bind-variable 'roman-numeral roman ord)
          (push (define-cfr category::ordinal `(,roman)
                  :form category::adjective
                  :referent  ord )
                rules))

        (setf (unit-plist ord)
              `(:rules ,rules ,@(unit-plist ord)))

        ord ))) |#

;;;------------
;;; operations
;;;------------

(defun nth-ordinal (n)
  ;; ugly, but there aren't too many of these
  (
  (dolist (o (cat-instances category::ordinal))
    (when (
(value-of 'number o)



  (case n
    (1 (category-named 'first))
    (2 (category-named 'second))
    (3 (category-named 'third))
    (4 (category-named 'fourth))
    (5 (category-named 'fifth))
    (6 (category-named 'sixth))
    (7 (category-named 'seventh))
    (8 (category-named 'eighth))
    (9 (category-named 'ninth))
    (10 (category-named 'tenth))
    (11 (category-named 'eleventh))
    (12 (category-named 'twelfth))
    (13 (category-named 'thirteenth))
    (14 (category-named 'fourteenth))
    (15 (category-named 'fifteenth))
    (otherwise (break "Stub: number above 15:  ~A" n))))





;;;------------------------
;;; phrase structure rules
;;;------------------------

#|  /// these should get swallowed into reversible rdata  

(def-cfr ordinal (number "st")
  :referent (:instantiate-individual position-in-a-sequence
                :with (number left-edge)))

(def-cfr ordinal (number "nd")
  :referent (:instantiate-individual position-in-a-sequence
                :with (number left-edge)))

(def-cfr ordinal (number "rd")
  :referent (:instantiate-individual position-in-a-sequence
                :with (number left-edge)))

(def-cfr ordinal (number "th")
  :referent (:instantiate-individual position-in-a-sequence
                :with (number left-edge)))
   |#
