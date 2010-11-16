;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; copyright (c) 1993,1994,1995 David D. McDonald  -- all rights reserved
;;; 
;;;     File:  "subj search"
;;;   Module:  "grammar;rules:CA:"
;;;  Version:  May 1995

;; initiated 7/16/93 v2.3.  Gave it some content 4/26/95.  Filled some
;; stubs in a trivial way 5/3

(in-package :sparser)

;;;---------------------------------------------
;;; dispatches from situation in VP-CA-dispatch
;;;---------------------------------------------

(defun subject-search (vp-edge)

  ;; Called from VP-CA-dispatch or the equivalent. Looks up the kind of
  ;; subject this vp calls for and walks to the left looking for it.
  ;; We've ruled out the case of there being an adjacent S and the VP
  ;; being a participle from within the caller, so here we are just
  ;; looking for NPs, presumably stranded ones.
  ;;   If it finds it within reasonable boundaries, it spans the two
  ;; with the edge called for by the rule it used to determine what
  ;; subject np to accept. 

  (if (comma-just-before-edge? vp-edge)
    (subject-search/adjacent-comma vp-edge)
    (subject-search/walk-leftwards-no-comma vp-edge)))


(defun subject-search/adjacent-comma (vp-edge)
  (let ((adjacent-edge  ;; just to the left of the comma
         (edge-ending-at (chart-position-before
                          (pos-edge-starts-at vp-edge)))))
    (if adjacent-edge
      (subject-search/check-adjacent-edge/comma adjacent-edge vp-edge)
      (subject-search/adjacent-comma/no-adj-edge vp-edge))))


(defun subject-search/walk-leftwards-no-comma (vp-edge)
  ;; The caller has done a comma-just-before-edge? and it came out nil.
  ;; From this we can conclude that it's probably not an appositive
  ;; that's separating this VP from its subject. 
  (let ((subj-rule (subject-rule (edge-referent vp-edge))))
    (when subj-rule
      (let ((subj-label (first (cfr-rhs subj-rule))))
        (search-for-subject-and-make-edge-if-found
         subj-label vp-edge subj-rule)))))


(defun search-for-subject-and-make-edge-if-found (subj-label vp-edge
                                                             subj-rule)
  (let ((subject-edge
         (search-left-for subj-label
                          (pos-edge-starts-at vp-edge))))
    (when subject-edge
      (span-separated-subject-and-VP
       subject-edge vp-edge subj-rule
       'subject-search/walk-leftwards-no-comma))))




(defun subject-search/adjacent-comma/no-adj-edge (vp-edge)
  ;; The caller has determined that there is a comma just to the
  ;; left of the vp, but that there is no edge just beyond that.
  ;; We'd conjecture that the subject is on the other side of an
  ;; appositive, but that the grammar hasn't got any/enough coverage
  ;; over what's in it.
  (subject-search/walk-leftwards-no-comma vp-edge))


(defun subject-search/edge-after-comma (adjacent-edge vp-edge
                                        subj-rule subj-label)
  ;; The vp has a comma just to its left, but the edge adjacent
  ;; to the comma doesn't have the right label for the rule
  ;; involved. So walk further to the left and keep looking.
  (declare (ignore adjacent-edge))
  (search-for-subject-and-make-edge-if-found
   subj-label vp-edge subj-rule))
         

  
(defun subject-search/check-adjacent-edge/comma (adjacent-edge vp-edge)
  ;; The caller has determined that there is a comma just to the left
  ;; of the vp and an edge just to the left of the comma.  We check
  ;; whether the label on that edge is what this particular VP is 
  ;; looking for as its subject.
  (let ((subj-rule (subject-rule (edge-referent vp-edge))))
    (when subj-rule
      (let ((subj-label (first (cfr-rhs subj-rule))))
        
        (if (eq subj-label (edge-category adjacent-edge))
          (span-separated-subject-and-VP
           adjacent-edge vp-edge subj-rule
           'subject-search/check-adjacent-edge/comma)
          
          (subject-search/edge-after-comma
           adjacent-edge vp-edge subj-rule subj-label))))))




;;;-----------------
;;; making the edge
;;;-----------------

(defun span-separated-subject-and-VP (subject-edge vp-edge
                                      cfr  calling-routine)
  (let ((edge (make-chart-edge
               :left-edge subject-edge
               :right-edge vp-edge
               :rule cfr)))
    edge ))

