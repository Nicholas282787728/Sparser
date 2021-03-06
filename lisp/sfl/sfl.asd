;;; -*- Syntax: Common-Lisp; Package: user -*-


;;; 				Copyright
;;; 		             BBN Technologies
;;; 			   All Rights Reserved
;;; 	                          2007


;;; :ld /omar/lisp/core-omar/languages/sfl/defsystem.lisp
;;; .i.e., loading this file will compile and load a free standing version of SFL

;; Revised 4/9/07 (ddm) to use an asdf style of defsystem

(in-package :cl-user)

(defpackage core-omar
  (:nicknames co)
  (:export defconcept name named-object-mixin obj defobject concept concept-name))

(asdf:defsystem :sfl
  :serial t
  :components
    (
     (:file "vsfl-master")
     (:file "variables")
     (:file "hacks")
     (:file "macros")
     (:file "simple-logic")
     (:file "extended-vr")
     (:file "comparison-functions")
     (:file "basic-mixins")
     (:file "inheritance")
     (:file "slots")
     (:file "slot-handling")
     (:file "make-classes")
     (:file "concept-role")
     (:file "instances")
     (:file "functions")
     (:file "connect")
     (:file "completion")
     (:file "define")
     (:file "load")
     (:file "save")
     (:file "kill")))


#|  Original, Allegro-based defsystem

(defsystem :sfl (:default-pathname "/omar/lisp/core-omar/languages/sfl/")
  (:serial
   "vsfl-master"
   "variables"
   "hacks"
   "macros"
   "simple-logic"
   "extended-vr"
   "comparison-functions"
   "basic-mixins"
   "inheritance"
   "slots"
   "slot-handling"
   "make-classes"
   "concept-role"
   "instances"
   "functions"
   "connect"
   "completion"
   "define"
   "load"
   "save"
   "kill"
   ))

(compile-system :sfl)

(provide :sfl)
  |#
