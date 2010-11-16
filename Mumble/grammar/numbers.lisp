;;; -*- Mode: Lisp; Syntax: Common-lisp; Package: mumble; -*-;;; copyright (c) 1999-2000 David D. McDonald, all rights reserved;;; $Id$;;; Copyright (c) 2006-2009 BBNT Solutions LLC. All Rights Reserved;;;;;;     file: "numbers";;;   module: "/Mumble/grammar";;;  version: December 2009;; written in March 1999, file created 5/30/99. Started reworking it to use;; Krisp numbers 7/5. Debugging in here 8/00.;; 12/27/09 Moved here from stravinsky: ts-readers;basics since it's already;;   doing a lot of the heavy lifting even if it is still in bundle-speak.;;   Only changed enough to load and execute.(in-package :mumble);;;-------------;;; entry point;;;-------------(defun construct-lspec-for-number (n)  (let ((value (or (when (numberp n) n)		   (sparser::value-of 'sparser::value n)		   (break "New type for number: ~a%~a"			  (type-of n) n))))    (multiple-value-bind (trillion billion million thousand one fraction)	(distribute-number-illions n)      (cond	;; Do pure decimals as digits	((< value 0)	 (contruct-lspec/number-as-digits-sequence n))	;; Simple numbers also	((and (< value 100)	      (null fraction))	 (contruct-lspec/number-as-digits-sequence n))     	;; "10.1 billiion" 	((two-consecutive-high-illions-values	  n trillion billion million thousand one fraction))	;; "10 million"	((one-high-illion-value	  n trillion billion million thousand one fraction))	;; If nothing more specific applies, drop back to digits	(t (contruct-lspec/number-as-digits-sequence n))))));;;---------------------;;; cases: "10 million"  ;;;---------------------;; note that it's singular. This is the quantifier pattern.#|    Can't yet find where ap/digit+multiplier is defined(define-lspec-schema-for  number-of-quantity  :bundle  minimal-bundle  :kernel  qp/digit+multiplier  ;; This still feels awkward -- the singular should fall out from the  ;; location in the surface structure. On the otherhand, this stuff  ;; is pure quantity, so its realization as a quantifier phrase  ;; continues to feel good, if a little unexpected.   :accessors (get-digit-of-numbers-single-illions-binding              get-illion-of-numbers-single-illions-binding))|#;;--- Access functions for plucking units out of illions bindings;; Grossly ad-hoc. Needs full revision when we have substantive;; word-based spelling outs of numbers ("10 million, three hundred thousand");; and/or real decisions about how to realize numbers and not these;; hacks that just get things off the ground.(register-lspec-access-function  'sparser::get-digit-of-numbers-single-illions-binding)(register-lspec-access-function 'sparser::get-illion-of-numbers-single-illions-binding)(defun sparser::get-digit-of-numbers-single-illions-binding (n)  (let ((illions-object         (sparser::bound-in n :body-type 'sparser::illions-distribution)))    (unless illions-object      (break "Setup bug: no bound-in illions-distribution on n:~%~a" n))    (sparser::value-of 'sparser::value illions-object)))(defun sparser::get-illion-of-numbers-single-illions-binding (n)  (let ((illions-object         (sparser::bound-in n :body-type 'sparser::illions-distribution)))    (unless illions-object      (break "Setup bug: no bound-in illions-distribution on n:~%~a" n))    (sparser::value-of 'sparser::illion illions-object)));;;-------------------------;;; illions, e.g. "million";;;-------------------------(register-category-as-realized-as-a-word 'multiplier);;--- words(define-word "trillion" (noun))(define-word "billion" (noun))(define-word "million" (noun))(define-word "thousand" (noun));;;----------------------------;;; sequences of digit triples;;;----------------------------(defun contruct-lspec/number-as-digits-sequence (n)  (multiple-value-bind (trillion billion million thousand one fraction)                       (distribute-number-illions n)    (when (or (or trillion billion million)              (and fraction                   (not thousand)))      (break "Need to write more phrases to cover numbers with more ~              illions in them"))    (multiple-value-bind (phrase list-of-argument-objects)                         (digits-sequence-phrase-dispatch                          trillion billion million thousand one fraction)      (let* ((list-of-arguments              (loop for number in list-of-argument-objects                    as s-word = (cadr (memq :digit-sequence                                            (sparser::indiv-plist number)))                    as m-word = (get-mumble-word-for-sparser-word s-word)                    collect m-word))             (single-choice              (mumble::wrap-in-a-default-single-choice phrase))             (kernel (make-kernel-specification                       :realization-function single-choice)))        (mumble::set-arguments kernel list-of-arguments)        (let ((b (mumble::make-a-bundle 'mumble::general-np)))          (mumble::set-bundle-head b kernel)          (mumble::singular b)          (mumble::no-determiner b)          (mumble::neuter-&-third-person b)          (mumble::link-to-underlying-object b n)          b )))));;--- Pre-constructed choices of multi-digit phrases(defun digits-sequence-phrase-dispatch       (trillion billion million thousand one fraction)  (cond ((and thousand fraction)         (values (phrase-named 'mumble::digit-sequence/thousands-point)                 `(,thousand ,one ,fraction)))        (thousand         (values (phrase-named 'mumble::digit-sequence/thousands-point)                 `(,thousand ,one)))        (one         (values (phrase-named 'mumble::digit-sequence/ones)                 `(,one)))        (t (break "No case defined for this pattern of what digit ~                   sequence fields have values"))));;/// generic -- move somewhere(defvar *n*)(defvar *b*)(defvar *illions*)(defun distribute-number-illions (n)  ;; Distributes the value of the number across its component  ;; illions: trillion billion million thousand one fraction  (setq *n* n)  (let ((illions-bindings         (sparser::bound-in n :all t                            :body-type 'sparser::illions-distribution))        (illions (sparser::category-named 'illions-distribution))        (trillions-illion (sparser::find-individual                            'sparser::multiplier                           :name "trillion"))        (billion-illion (sparser::find-individual                            'sparser::multiplier                           :name "billion"))        (million-illion (sparser::find-individual                            'sparser::multiplier                           :name "million"))        (thousand-illion (sparser::find-individual                            'sparser::multiplier                           :name "thousand"))        (one-illion (sparser::find-individual                            'sparser::multiplier                           :name "one"))        (fraction-illion (sparser::find-individual                            'sparser::multiplier                           :name "fraction"))        trillion  billion  million  thousand  one  fraction )    (setq *illions* illions)    (dolist (b illions-bindings)      (setq *b* b)      (let ((illion (sparser::up-and-over b 'sparser::illion)))        (cond         ((eq illion trillions-illion)          (setq trillion (sparser::up-and-over b 'sparser::value illions)))         ((eq illion billion-illion)          (setq billion (sparser::up-and-over b 'sparser::value illions)))         ((eq illion million-illion)          (setq million (sparser::up-and-over b 'sparser::value illions)))         ((eq illion thousand-illion)          (setq thousand (sparser::up-and-over b 'sparser::value illions)))         ((eq illion one-illion)          (setq one (sparser::up-and-over b 'sparser::value illions)))         ((eq illion fraction-illion)          (setq fraction (sparser::up-and-over b 'sparser::value illions)))         (t (error "The 'illion' ~a fell through" illion)))))    (values trillion billion million thousand one fraction)));;;---------------------------------------------------------------;;; predicates to test for specific cases and also make the lspec;;;---------------------------------------------------------------(defun one-high-illion-value       (n trillion billion million thousand one fraction)  (let ((populated-illion         (loop for illion-symbol in               '(trillion billion million thousand one fraction)               when (symbol-value illion-symbol)               collect illion-symbol)))    (break)))#|         (let ( illion-symbols         (dolist (illion-symbol                  '(trillion billion million thousand one fraction))           (when (symbol-value illion-symbol)             (push illion-symbol |#;; when you get on the roof you can see New York City, the house of it,;; but you need a flashlight.(defun two-consecutive-high-illions-values       (n trillion billion million thousand one fraction)  (break "stub"))#|;; "14 and 15 million" -- that would make "million" the head(define-number-realization-template small-illions  ;; possibility-test checks that there are values in two  ;; adjacent illion segments, so we just have to check whether  ;; it's billions or millions we're talking about.  (let ( major minor head-number-word )    (if (not (= billions 0))      (setq head-number-word (word-named 'billion)            major billions            minor millions)      (if (not (= millions 0))        (setq head-number-word (word-named 'million)              major millions              minor thousands)        (break "neither million or billion applies")))    (setq minor (strip-final-zeros (format nil "~a" minor)))    (let ((digits-word (define-word (format nil "~a.~a" major minor)                         (number))))      ;; build the lspec (this should be a template)      (let ((kernel (make-a-kernel 'np-compound-head                                   digits-word head-number-word))            (bundle (make-a-bundle 'general-np)))        (set-bundle-head bundle kernel)        (self-determining-neuter bundle)        bundle ))))(defun strip-final-zeros (string)  ;; very special purpose -- can't be more than two zeros in the  ;; three digit string  (unless (= 3 (length string))    (break "Bad threading: string isn't length three"))  (when (string-equal (elt string 2) "0")    (setq string (subseq string 0 2)))  (when (string-equal (elt string 1) "0")    (setq string (subseq string 0 1)))  string )    ;(say-spec (realize-number 1300000 (list 'small-illions)))|#