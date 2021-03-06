; Copyright (C) 2002, 2003 RiskMap srl
;
; This file is part of QuantLib, a free-software/open-source library
; for financial quantitative analysts and developers - http://quantlib.org/
;
; QuantLib is free software developed by the QuantLib Group; you can
; redistribute it and/or modify it under the terms of the QuantLib License;
; either version 1.0, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; QuantLib License for more details.
;
; You should have received a copy of the QuantLib License along with this
; program; if not, please email quantlib-dev@lists.sf.net
;
; The QuantLib License is also available at <http://quantlib.org/license.shtml>
; The members of the QuantLib Group are listed in the QuantLib License

(load "unittest.scm")
(use-modules (QuantLib))

(greg-assert/display
 "Testing observability of stocks"
 (let ((flag #f))
   (let* ((me1 (new-SimpleQuote 0.0))
          (me2 (new-SimpleQuote 0.0))
          (h (new-RelinkableQuoteHandle me1))
          (s (new-Stock h))
          (obs (new-Observer (lambda () (set! flag #t)))))
     (let ((temp (Instrument->Observable s)))
       (Observer-register-with obs temp))
     (and
      (begin (Instrument-NPV s)
             (SimpleQuote-value-set! me1 3.14)
             (check flag
                    "Observer was not notified of instrument change"))
      (begin (Instrument-NPV s)
             (set! flag #f)
             (RelinkableQuoteHandle-link-to! h me2)
             (check flag
                    "Observer was not notified of instrument change"))
      (begin (Instrument-NPV s)
             (set! flag #f)
             (Instrument-freeze! s)
             (SimpleQuote-value-set! me2 2.71)
             (check (not flag)
                    "Observer was notified of frozen instrument change"))
      (begin (Instrument-unfreeze! s)
             (check flag
                    "Observer was not notified of instrument change"))))))
