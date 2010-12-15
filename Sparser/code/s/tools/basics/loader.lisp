;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; copyright (c) 1992,1993,1994,1995  David D. McDonald  -- all rights reserved
;;; extensions copyright (c) 2009 BBNT Solutions LLC. All Rights Reserved
;;; $Id: loader.lisp 359 2010-08-13 20:13:38Z dmcdonal $
;;;
;;;      File:  "loader"
;;;    Module:   "tools:basics"
;;;   Version:   September 2009

;; 7/23/09 Added 'debugging' with Jake's tools. Uncommented loading of no-breaks.
;; 9/10 Added the SFL macro for creating CLOS classes
;; 8/2/10 -- adding items here in preparation for a make-over for a common
;;  repository of lisp utilities

(in-package :sparser)

(lload "sugar;loader")
(lload "basic tools;time")
(lload "basic tools;no breaks")
(lload "basic tools;debug stack")
(lload "basic tools;SFL Clos")
(lload "basic tools;sorting")
