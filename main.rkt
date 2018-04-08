#lang racket
;; pilot-currency/main.rkt
;; Copyright Geoffrey S. Knauth. See file "info.rkt".

(require web-server/servlet
         web-server/servlet-env
         db
         db/util/datetime
         format-ymd
         format-numbers
         (file "~/.flying-dbaccess.rkt")
         (file "~/.flying-prefs.rkt"))

(define today (today->ymd8))

(define db-source
  (mysql-data-source #:server db-host #:port db-port
                     #:user db-user #:password db-passwd
                     #:database db-schema))

(define (connect!)
  (dsn-connect db-source))

(define the-db
  (virtual-connection (connection-pool connect!)))

(define (first-answer con qstr)
  (let ((rows (query-rows con qstr)))
    (vector-ref (first rows) 0)))

(define computer-generated
  (string-append "computer generated as of " (ymd8->ymd10 today)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Instrument Approaches

(define qstr-inst-app-last-30-days
  "select sum(ifnull(inst_app,0)) from logbook where to_days(logbook.date) >= to_days(now()) - 30")

(define qstr-inst-app-last-90-days
  "select sum(ifnull(inst_app,0)) from logbook where to_days(logbook.date) >= to_days(now()) - 90")

(define qstr-inst-app-last-180-days
  "select sum(ifnull(inst_app,0)) from logbook where to_days(logbook.date) >= to_days(now()) - 180")

(define qstr-inst-app-last-365-days
  "select sum(ifnull(inst_app,0)) from logbook where to_days(logbook.date) >= to_days(now()) - 365")

(define qstr-inst-app
  "select sum(ifnull(inst_app,0)) from logbook")

(define inst-app-last-30-days
  (first-answer the-db qstr-inst-app-last-30-days))

(define inst-app-last-90-days
  (first-answer the-db qstr-inst-app-last-90-days))

(define inst-app-last-180-days
  (first-answer the-db qstr-inst-app-last-180-days))

(define inst-app-last-365-days
  (first-answer the-db qstr-inst-app-last-365-days))

(define inst-app
  (first-answer the-db qstr-inst-app))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Landings

(define qstr-landings-last-30-days
  "select sum(ifnull(landings,0)) from logbook where to_days(logbook.date) >= to_days(now()) - 30")

(define qstr-landings-last-90-days
  "select sum(ifnull(landings,0)) from logbook where to_days(logbook.date) >= to_days(now()) - 90")

(define qstr-landings-last-180-days
  "select sum(ifnull(landings,0)) from logbook where to_days(logbook.date) >= to_days(now()) - 180")

(define qstr-landings-last-365-days
  "select sum(ifnull(landings,0)) from logbook where to_days(logbook.date) >= to_days(now()) - 365")

(define qstr-landings
  "select sum(ifnull(landings,0)) from logbook")

(define landings-last-30-days
  (first-answer the-db qstr-landings-last-30-days))

(define landings-last-90-days
  (first-answer the-db qstr-landings-last-90-days))

(define landings-last-180-days
  (first-answer the-db qstr-landings-last-180-days))

(define landings-last-365-days
  (first-answer the-db qstr-landings-last-365-days))

(define landings
  (first-answer the-db qstr-landings))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Night Landings

(define qstr-night-landings-last-30-days
  "select sum(ifnull(nitelndgs,0)) from logbook where to_days(logbook.date) >= to_days(now()) - 30")

(define qstr-night-landings-last-90-days
  "select sum(ifnull(nitelndgs,0)) from logbook where to_days(logbook.date) >= to_days(now()) - 90")

(define qstr-night-landings-last-180-days
  "select sum(ifnull(nitelndgs,0)) from logbook where to_days(logbook.date) >= to_days(now()) - 180")

(define qstr-night-landings-last-365-days
  "select sum(ifnull(nitelndgs,0)) from logbook where to_days(logbook.date) >= to_days(now()) - 365")

(define qstr-night-landings
  "select sum(ifnull(nitelndgs,0)) from logbook")

(define night-landings-last-30-days
  (first-answer the-db qstr-night-landings-last-30-days))

(define night-landings-last-90-days
  (first-answer the-db qstr-night-landings-last-90-days))

(define night-landings-last-180-days
  (first-answer the-db qstr-night-landings-last-180-days))

(define night-landings-last-365-days
  (first-answer the-db qstr-night-landings-last-365-days))

(define night-landings
  (first-answer the-db qstr-night-landings))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Instrument Actual

(define qstr-inst-act
  "select sum(act_inst) from logbook")

(define qstr-inst-act-last-30-days
  "select sum(ifnull(act_inst, 0)) from logbook where to_days(date) >= to_days(now()) - 30")

(define qstr-inst-act-last-90-days
  "select sum(ifnull(act_inst, 0)) from logbook where to_days(date) >= to_days(now()) - 90")

(define qstr-inst-act-last-180-days
  "select sum(ifnull(act_inst, 0)) from logbook where to_days(date) >= to_days(now()) - 180")

(define qstr-inst-act-last-365-days
  "select sum(ifnull(act_inst, 0)) from logbook where to_days(date) >= to_days(now()) - 365")

(define qstr-inst-act-pic
  "select sum(ifnull(act_inst, 0)) from logbook where act_inst > 0 and ifnull(pic, 0) > ifnull(act_inst, 0)")

(define inst-act
  (first-answer the-db qstr-inst-act))

(define inst-act-last-30-days
  (first-answer the-db qstr-inst-act-last-30-days))

(define inst-act-last-90-days
  (first-answer the-db qstr-inst-act-last-90-days))

(define inst-act-last-365-days
  (first-answer the-db qstr-inst-act-last-365-days))

(define inst-act-last-180-days
  (first-answer the-db qstr-inst-act-last-180-days))

(define inst-act-pic
  (first-answer the-db qstr-inst-act-pic))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Instrument Simulated

(define qstr-inst-sim-last-30-days
  "select sum(ifnull(sim_inst, 0)) from logbook where to_days(date) >= to_days(now()) - 30")

(define qstr-inst-sim-last-90-days
  "select sum(ifnull(sim_inst, 0)) from logbook where to_days(date) >= to_days(now()) - 90")

(define qstr-inst-sim-last-180-days
  "select sum(ifnull(sim_inst, 0)) from logbook where to_days(date) >= to_days(now()) - 180")

(define qstr-inst-sim-last-365-days
  "select sum(ifnull(sim_inst, 0)) from logbook where to_days(date) >= to_days(now()) - 365")

(define qstr-inst-sim
  "select sum(sim_inst) from logbook")

(define inst-sim-last-30-days
  (first-answer the-db qstr-inst-sim-last-30-days))

(define inst-sim-last-90-days
  (first-answer the-db qstr-inst-sim-last-90-days))

(define inst-sim-last-180-days
  (first-answer the-db qstr-inst-sim-last-180-days))

(define inst-sim-last-365-days
  (first-answer the-db qstr-inst-sim-last-365-days))

(define inst-sim
  (first-answer the-db qstr-inst-sim))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hours

(define qstr-hours-last-30-days
  "select sum(ifnull(duration,0)) from logbook where to_days(logbook.date) >= to_days(now()) - 30")

(define qstr-hours-last-90-days
  "select sum(ifnull(duration,0)) from logbook where to_days(logbook.date) >= to_days(now()) - 90")

(define qstr-hours-last-180-days
  "select sum(ifnull(duration,0)) from logbook where to_days(logbook.date) >= to_days(now()) - 180")

(define qstr-hours-last-365-days
  "select sum(ifnull(duration,0)) from logbook where to_days(logbook.date) >= to_days(now()) - 365")

(define qstr-hours
  "select sum(ifnull(duration,0)) from logbook")

(define hours-last-30-days
  (first-answer the-db qstr-hours-last-30-days))

(define hours-last-90-days
  (first-answer the-db qstr-hours-last-90-days))

(define hours-last-180-days
  (first-answer the-db qstr-hours-last-180-days))

(define hours-last-365-days
  (first-answer the-db qstr-hours-last-365-days))

(define hours
  (first-answer the-db qstr-hours))

(define adjusted-hours (+ hours 20)) ; add glider hours in different logbook

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; List Instrument Approaches in the Last Year

(define qstr-approaches-list
  "select date, inst_app, remarks from logbook where inst_app > 0 and to_days(date) >= to_days(now()) - 365 order by date desc")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; List Night Landings in the Last Half Year

(define qstr-night-landings-list
  "select date, nitelndgs, remarks from logbook where nitelndgs > 0 and to_days(date) >= to_days(now()) - 180 order by date desc")

(define (sql-date->ymd10 d)
  (format "~a-~a-~a"
          (sql-date-year d)
          (fmt-i-02d (sql-date-month d))
          (fmt-i-02d (sql-date-day d))))

(define (days-since-sql-date d)
  0)

(define (item a b)
  (list (string-append a ": " b)))

(define (td-flthrs n)
  (td-class-n "flthrs" (if (sql-null? n) 0 n) 1))

(define (td-int n)
  (list 'td '((class "int")) (number->string (if (sql-null? n) 0 n))))

(define (td-int-threshhold n threshhold)
  (list 'td `((class ,(if (< n threshhold) "redint" "greenint"))) (number->string n)))

(define (td-class-n class n decimals)
  (list 'td `((class ,class)) (format-float n decimals)))

(define (td-class-s class s)
  (list 'td `((class ,class)) s))

(define (get-date-count-remarks query currency-days-going-back)
  (let ([rows (query-rows the-db query)]
        [today10 (ymd8->ymd10 today)])
    (map (λ (row)
           (list (ymd10-d1-within-days-following-d0? (sql-date->ymd10 (vector-ref row 0))
                                                     currency-days-going-back
                                                     today10)
                 (sql-date->ymd10 (vector-ref row 0))
                 (vector-ref row 1)
                 (vector-ref row 2)))
         rows)))

(define approaches-list
  (get-date-count-remarks qstr-approaches-list 180))

(define night-landings-list
  (get-date-count-remarks qstr-night-landings-list 90))

(define (detail-table-rows results-list)
  (map (lambda (info)
         `(tr 
           ,(td-class-s (if (first info) "green" "red") (second info))
           (td ,(number->string (third info)))
           (td ,(fourth info))))
       results-list))

(define approaches-table
  (append `(table (tr (th "Date") (th "#") (th "Instrument Approach Details")))
          (detail-table-rows approaches-list)))

(define night-landings-table
  (append `(table (tr (th "Date") (th "#") (th "Night Landings Details")))
          (detail-table-rows night-landings-list)))

(define summary-table
  `(table (tr (th) (th "Instrument Approaches")
                                (th "Landings")
                                (th "Night Landings")
                                (th "Act Inst")
                                (th "Sim Inst")
                                (th "Hours"))
                            (tr (td "30 days")
                                ,(td-int inst-app-last-30-days)
                                ,(td-int landings-last-30-days)
                                ,(td-int night-landings-last-30-days)
                                ,(td-flthrs inst-act-last-30-days)
                                ,(td-flthrs inst-sim-last-30-days)
                                ,(td-flthrs hours-last-30-days))
                            (tr (td "90 days")
                                ,(td-int inst-app-last-90-days)
                                ,(td-int-threshhold landings-last-90-days 3)
                                ,(td-int-threshhold night-landings-last-90-days 3)
                                ,(td-flthrs inst-act-last-90-days)
                                ,(td-flthrs inst-sim-last-90-days)
                                ,(td-flthrs hours-last-90-days))
                            (tr (td "180 days")
                                ,(td-int-threshhold inst-app-last-180-days 6)
                                ,(td-int landings-last-180-days)
                                ,(td-int night-landings-last-180-days)
                                ,(td-flthrs inst-act-last-180-days)
                                ,(td-flthrs inst-sim-last-180-days)
                                ,(td-flthrs hours-last-180-days))
                            (tr (td "365 days")
                                ,(td-int inst-app-last-365-days)
                                ,(td-int landings-last-365-days)
                                ,(td-int night-landings-last-365-days)
                                ,(td-flthrs inst-act-last-365-days)
                                ,(td-flthrs inst-sim-last-365-days)
                                ,(td-flthrs hours-last-365-days))
                            (tr (td "total")
                                ,(td-int inst-app)
                                ,(td-int landings)
                                ,(td-int night-landings)
                                ,(td-flthrs inst-act)
                                ,(td-flthrs inst-sim)
                                ,(td-flthrs adjusted-hours))))

(define the-page
  `(html (head (title head-title)
                (link ((rel "stylesheet")
                       (href ,css-path)
                       (type "text/css")))
                (body (div ((class "test"))
                           (h1 ,(string-append "Pilot Currency -- " pilot-name))
                           (p ((class "compgen")) ,computer-generated)
                           ,summary-table
                           (br)
                           ,approaches-table
                           (br)
                           ,night-landings-table)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Process Web Request

(define (start req)
  (response/xexpr the-page))

(serve/servlet start
               #:extra-files-paths
               (list
                (build-path site-path)))

(module+ test
  (require rackunit))

;; Notice
;; To install (from within the package directory):
;;   $ raco pkg install
;; To install (once uploaded to pkgs.racket-lang.org):
;;   $ raco pkg install <<name>>
;; To uninstall:
;;   $ raco pkg remove <<name>>
;; To view documentation:
;;   $ raco docs <<name>>
;;
;; For your convenience, we have included a LICENSE.txt file, which links to
;; the GNU Lesser General Public License.
;; If you would prefer to use a different license, replace LICENSE.txt with the
;; desired license.
;;
;; Some users like to add a `private/` directory, place auxiliary files there,
;; and require them in `main.rkt`.
;;
;; See the current version of the racket style guide here:
;; http://docs.racket-lang.org/style/index.html

;; Code here

(module+ test
  ;; Tests to be run with raco test
  )

(module+ main
  ;; Main entry point, executed when run with the `racket` executable or DrRacket.
  )
