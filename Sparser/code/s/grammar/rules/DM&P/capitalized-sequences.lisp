;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; copyright (c) 1994  David D. McDonald  -- all rights reserved
;;;
;;;      File:  "capitalized sequences"
;;;    Module:  "grammar;rules:DM&P:"
;;;   version:  September 1994

;; initiated 9/28/94 v2.3. Tweeked ...10/31

;;;--------
;;; driver
;;;--------

(defun dm&p-Cap-Seq-Data (start-pos end-pos)
  ;; called from Make-edge-over-capitalized-sequence. Returns the data
  ;; that it uses to make the edge
  (pfwpnf start-pos end-pos)
    ;; this handles polywords and edges over terminals

  (let ((region-description
         ;; this gets the rest
         (if (eq end-pos (chart-position-after start-pos)) ;; one word long
           (analyze-segment-layout start-pos end-pos)
           (parse-between-boundaries start-pos end-pos))))

    (ecase region-description
      ;; should never get :null-span or :span-is-longer-than-segment
      (:single-span  ;; e.g. a pair term
       (dm&p/single-span-cap-seq start-pos end-pos))
      (:no-edges ;; all new words
       (dm&p/new-words-cap-seq start-pos end-pos))
      (:has-unknown-words  ;; some known, some new
       (dm&p/some-known-cap-seq start-pos end-pos))
      (:contiguous-edges
       (dm&p/some-known-cap-seq start-pos end-pos)))))


;;;----------------
;;; dispatch cases
;;;----------------

(defun dm&p/Single-Span-cap-seq (start-pos end-pos)
  (let ((edge (right-treetop-at start-pos)))
    (when (eq edge :multiple-initial-edges)
      (setq edge (single-best-edge-over-word start-pos)))
    
    (let* ((referent (edge-referent edge))
           (carrier-segment (define-segment start-pos end-pos))
           (result (when referent
                     (list referent))))
      
      (when (or (edge-over-literal? edge)
                (null referent))
        ;; a polyword will produce an edge w/o a referent, and
        ;; we can get a literal when the word is mentioned in a
        ;; polyword.  In both cases we need to mine a term
        (setq result (mine-treetops/indeterminate-relationship
                      start-pos end-pos carrier-segment))
        (setq referent (first result)))

      (categorize-segment carrier-segment result)
      
      ;;/// annotation of a capitalized instance of the term goes here
      
      (values category::capitalized-sequence   ;; category
              category::np                     ;; form
              referent
              :dm&p-Cap-Seq/single-span        ;; rule
              nil                              ;; daughters
              start-pos end-pos))))
  


(defun dm&p/New-Words-cap-seq (start-pos end-pos)
  (let* ((carrier-segment (define-segment start-pos end-pos))
         (result (mine-treetops/indeterminate-relationship
                  ;; notes the adjacency relationships between the terms
                  ;; and calls reifier for them
                  start-pos end-pos
                  carrier-segment)))

    (categorize-segment carrier-segment result)

    (values category::capitalized-sequence  ;; category
            category::np                    ;; form
            (car result)                    ;; referent
            :dm&p-Cap-Seq/new-words         ;; rule
            nil                             ;; daughters
            start-pos end-pos)))


(defun dm&p/Some-known-cap-seq (start-pos end-pos)
  ;; this case is similar in some respects to Scan-treetops-and-mine
  ;; in that it should checkout the prefix, if any, and consider
  ;; whether it belongs in the sequence, e.g.
  ;;     "</para> The Sound control panel appears."
  ;; If there is a prefix, then it should be left out, which is
  ;; done by changing the positions that are returned with the
  ;; values

  (let ((prefix (edge-starting-at start-pos))
        (1st-word (pos-terminal start-pos)))
    (cond
     (prefix
      (if (determinant-segment-prefix prefix start-pos)
        (let ((pos-after (pos-edge-ends-at prefix)))
          ;; the question is whether to include the prefix as part of
          ;; the capitalized sequence or to assume that, like "the", it
          ;; should stay out of it.
          (if (eq pos-after end-pos)  ;; the seq. is all prefix
            (values nil nil nil :all-prefix nil end-pos end-pos)
            (if (function-word? 1st-word)
              ;; this gets a subset of the prefixes, in particular
              ;; it leaves out content verbs:  ".. choose Show All .."
              (hack-standard-case/dm&p/Some-known-cap-seq
               pos-after end-pos)
              ;; leave it in
              (hack-standard-case/dm&p/Some-known-cap-seq
               start-pos end-pos))))

        ;; the prefix isn't syntactically interesting, so assume that
        ;; it belongs in the sequence
        (hack-standard-case/dm&p/Some-known-cap-seq
         start-pos end-pos)))

     ((function-word? 1st-word)
      ;; leave it out
      (hack-standard-case/dm&p/Some-known-cap-seq
       (chart-position-after start-pos) end-pos))
      
     (t (hack-standard-case/dm&p/Some-known-cap-seq
         start-pos end-pos)))))



(defun hack-standard-case/dm&p/Some-known-cap-seq (start-pos end-pos)
  (let* ((carrier-segment (define-segment start-pos end-pos))
         (result (mine-treetops/indeterminate-relationship
                  ;; notes the adjacency relationships between the terms
                  ;; and calls reifier for them
                  start-pos end-pos carrier-segment)))

    (categorize-segment carrier-segment result)

    (values category::capitalized-sequence category::np
            carrier-segment :dm&p-Cap-Seq/new-words nil
            start-pos end-pos)))

