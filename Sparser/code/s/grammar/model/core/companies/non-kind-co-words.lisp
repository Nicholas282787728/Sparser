;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; copyright (c) 1993,1994  David D. McDonald  -- all rights reserved
;;;
;;;     File:  "non-kind co words"
;;;   Module:  "model;core:companies:"
;;;  version:  0.2 September 1994

;; initiated 10/29/93 v2.3. Fleshed out the data and added more categories 1/20/94
;; 0.1 (3/15) renamed co-indicating-word company-generalization-word, changed the
;;      rdata to go to company at the NP level, and added grammar modules gates
;;     (7/22) extended the autodefs with examples
;; 0.2 (9/28) added category for company activity word ("publishing")

(in-package :sparser)

#| These are a bit of a missmash. Need more operational criteria and probably
   other contexts of use before their best category system can be really
   nailed down.  |#


;;;--------------------------
;;; "Industries", "holdings"
;;;--------------------------

#| These are valuable as markers that indicate that a name denotes a company. |#

(gate-grammar *company-generalization-words*

(define-category  company-generalization-word
  :instantiates self
  :specializes name-word
  :binds ((word :primitive word))
  :index (:permanent  :key word)
  :realization (:tree-family np-common-noun
                :mapping ((np . company)
                          (n-bar . :self)
                          (np-head . :self))
                :word word))


(define-autodef-data 'company-generalization-word
  :display-string "indicative word"
  :form 'define-company-generalization-word
  :description "a word that names a class of company and might appear in a company's name"
  :examples "\"Airlines\" \"Holdings\" \"Industries\""
  :dossier "dossiers;co indicating words" )

(defun define-company-generalization-word (string)
  (define-individual 'company-generalization-word :word string))

) ;; close gate-grammar



;;;------------------------------
;;; "publishing" "manufacturing"
;;;------------------------------

#| Another kind of marker that indicates that a name denotes a company
   and also gives us some information about what the company does.   |#

(gate-grammar *company-activity-words*

(define-category  company-activity-word
  :instantiates self
  :specializes name-word
  :binds ((word :primitive word))
  :index (:permanent  :key word)
  :realization (:tree-family np-common-noun
                :mapping ((np . company)
                          (n-bar . :self)
                          (np-head . :self))
                :word word))


(define-autodef-data 'company-activity-word
  :display-string "activity word"
  :form 'define-company-activity-word
  :description "a word that names what a company does"
  :examples "\"communications\" \"publishing\" \"manufacturing\""
  :dossier "dossiers;co activity words" )

(defun define-company-activity-word (string)
  (define-individual 'company-activity-word :word string))

) ;; close gate-grammar




;;;-------------------
;;; "company", "firm"
;;;-------------------

#| These are standard heads for companies that are 'generic' rather
   than those types of companies that persue specific businesses that
   have specific anaphoric terms like "newspaper" or "law firm".  |#

(gate-grammar *generic-company-words*

(define-category  generic-co-word
  :instantiates self
  :specializes name-word
  :binds ((word :primitive word))
  :index (:permanent  :key word)
  :realization (:tree-family np-common-noun
                :mapping ((np . company)
                          (n-bar . :self)
                          (np-head . :self))
                :word word))

(defun string/Generic-co-word (cw)
  (word-pname (value-of 'word cw)))


(define-autodef-data 'generic-co-word
  :display-string "generic company"
  :form 'define-generic-company-word
  :description "a general term for a company or organization"
  :examples "\"company\" \"organization\" \"concern\""
  :dossier "dossiers;generic co words" )


(defun define-generic-company-word (string  &key ((:abbrev abbreviations)) )
  (define-individual 'generic-co-word :word string)
  (when abbreviations
    (dolist (abbrev-string abbreviations)
      (define-abbreviation string abbrev-string))))

) ;; close gate-grammar



;;;--------------------------
;;; "manufacturer", "issuer"
;;;--------------------------

#| The are nominalizations of activities that activities that companies
   do which are often used as company-denoting anaphors.  The "/er" variation
   takes prenominal N-bars that would be the verbs' complement. |#

(gate-grammar *company-activity-nominals*

(define-category  co-activity-nominal/er
  :instantiates self
  :specializes  company  ;; vs. name-word ///which is more sensible?
  :binds ((patient)  ;; the complement
          (word :primitive word))
  :index (:permanent :key word)
  :realization (:tree-family np-common-noun
                :mapping ((np . company)
                          (n-bar . :self)
                          (np-head . :self))
                :word word))


(define-autodef-data  'co-activity-nominal/er
  :display-string "'-er' word"
  :form 'define-co-activity-nominal/er
  :description "a general or specific type of company based on an activity"
  :examples "\"manufacturer\" \"contractor\" \"marketer\" \"provider\""
  :dossier "dossiers;co activity nominals-er" )


(defun define-co-activity-nominal/er (string
                                      &key ((:abbrev abbreviations)))
  (let* ((word (define-word/expr string))
        (symbol (intern string *category-package*))
        (cat (category-named symbol))
        rules )

    (unless cat
      (setq cat (define-category/expr symbol
                  `(:specializes ,category::co-activity-nominal/er
                    :instantiates ,`(,category::company ,symbol)
                    ;; // copy the word binding ??
                    )))
      (setq rules
            (list (define-cfr category::co-activity-nominal/er
                              `( ,word )
                    :form category::np-head
                    :referent cat )

                  (define-cfr category::co-activity-nominal/er
                              `( ,(plural-version word) )
                    :form category::np-head
                    :referent `(:head ,cat
                                :subtype ,category::collection))))
      (setf (unit-plist cat)
            `(:rules ,rules ,@(unit-plist cat)))

      (when abbreviations
        (dolist (abbrev-string abbreviations)
          (define-abbreviation string abbrev-string))))

      cat ))

) ;; close gate-grammar

