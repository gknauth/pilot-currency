#lang racket
;; pilot-currency/main.rkt
;; Copyright Geoffrey S. Knauth. See file "info.rkt".

(require web-server/servlet
         web-server/servlet-env
         (only-in web-server/templates
                  include-template)
         db
         db/util/datetime
         format-ymd
         format-numbers
         (file "~/.flying-dbaccess.rkt")
         (file "~/.flying-prefs.rkt"))

(define today (today->ymd8))

(define db-source
  ((cond [(eq? db-engine 'mysql) mysql-data-source]
         [(eq? db-engine 'postgres) postgresql-data-source]
         [else (error "invalid db-engine")])
   #:server db-host #:port db-port
   #:user db-user #:password db-passwd
   #:database db-schema))

(define (connect!)
  (dsn-connect db-source))

(define the-db
  (virtual-connection (connection-pool connect!)))

(define (first-answer con qstr)
  (let* ([rows (query-rows con qstr)]
         [x (vector-ref (first rows) 0)])
    (if (sql-null? x) 0 x)))

(define computer-generated
  (string-append "computer generated as of " (ymd8->ymd10 today)))

(define isnull
  (cond [(eq? db-engine 'mysql) "ifnull"]
        [(eq? db-engine 'postgres) "coalesce"]
        [else (error "invalid db-engine")]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Instrument Approaches

(define (date-within-last-n-days date n)
  (cond [(eq? db-engine 'mysql)
         (format "to_days(~a) >= to_days(now()) - ~a"
                 date (number->string n))]
        [(eq? db-engine 'postgres)
         (format "age(current_timestamp, ~a) <= cast('~a days' as interval)"
                 date (number->string n))]
        [else (error "invalid db-engine")]))

(define qstr-inst-app-last-30-days
  (string-append "select sum(" isnull "(inst_app,0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 30)))

(define qstr-inst-app-last-90-days
  (string-append "select sum(" isnull "(inst_app,0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 90)))

(define qstr-inst-app-last-180-days
  (string-append "select sum(" isnull "(inst_app,0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 180)))

(define qstr-inst-app-last-365-days
  (string-append "select sum(" isnull "(inst_app,0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 365)))

(define qstr-inst-app
  (string-append "select sum(" isnull "(inst_app,0)) from logbook"))

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
  (string-append "select sum(" isnull "(landings,0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 30)))

(define qstr-landings-last-90-days
  (string-append "select sum(" isnull "(landings,0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 90)))

(define qstr-landings-last-180-days
  (string-append "select sum(" isnull "(landings,0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 180)))

(define qstr-landings-last-365-days
  (string-append "select sum(" isnull "(landings,0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 365)))

(define qstr-landings
  (string-append "select sum(" isnull "(landings,0)) from logbook"))

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
  (string-append "select sum(" isnull "(nitelndgs,0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 30)))

(define qstr-night-landings-last-90-days
  (string-append "select sum(" isnull "(nitelndgs,0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 90)))

(define qstr-night-landings-last-180-days
  (string-append "select sum(" isnull "(nitelndgs,0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 180)))

(define qstr-night-landings-last-365-days
  (string-append "select sum(" isnull "(nitelndgs,0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 365)))

(define qstr-night-landings
  (string-append "select sum(" isnull "(nitelndgs,0)) from logbook"))

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
  (string-append "select sum(" isnull "(act_inst, 0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 30)))

(define qstr-inst-act-last-90-days
  (string-append "select sum(" isnull "(act_inst, 0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 90)))

(define qstr-inst-act-last-180-days
  (string-append "select sum(" isnull "(act_inst, 0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 180)))

(define qstr-inst-act-last-365-days
  (string-append "select sum(" isnull "(act_inst, 0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 365)))

(define qstr-inst-act-pic
  (string-append "select sum(" isnull "(act_inst, 0)) from logbook where act_inst > 0 and " isnull "(pic, 0) > " isnull "(act_inst, 0)"))

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
;; Instrument Simulated (Hood)

(define qstr-inst-sim-last-30-days
  (string-append "select sum(" isnull "(sim_inst, 0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 30)))

(define qstr-inst-sim-last-90-days
  (string-append "select sum(" isnull "(sim_inst, 0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 90)))

(define qstr-inst-sim-last-180-days
  (string-append "select sum(" isnull "(sim_inst, 0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 180)))

(define qstr-inst-sim-last-365-days
  (string-append "select sum(" isnull "(sim_inst, 0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 365)))

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
;; Simulator

(define qstr-simulator-last-30-days
  (string-append "select sum(" isnull "(simulator, 0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 30)))

(define qstr-simulator-last-90-days
  (string-append "select sum(" isnull "(simulator, 0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 90)))

(define qstr-simulator-last-180-days
  (string-append "select sum(" isnull "(simulator, 0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 180)))

(define qstr-simulator-last-365-days
  (string-append "select sum(" isnull "(simulator, 0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 365)))

(define qstr-simulator
  "select sum(simulator) from logbook")

(define simulator-last-30-days
  (first-answer the-db qstr-simulator-last-30-days))

(define simulator-last-90-days
  (first-answer the-db qstr-simulator-last-90-days))

(define simulator-last-180-days
  (first-answer the-db qstr-simulator-last-180-days))

(define simulator-last-365-days
  (first-answer the-db qstr-simulator-last-365-days))

(define simulator
  (first-answer the-db qstr-simulator))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hours

(define qstr-hours-last-30-days
  (string-append "select sum(" isnull "(duration,0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 30)))

(define qstr-hours-last-90-days
  (string-append "select sum(" isnull "(duration,0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 90)))

(define qstr-hours-last-180-days
  (string-append "select sum(" isnull "(duration,0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 180)))

(define qstr-hours-last-365-days
  (string-append "select sum(" isnull "(duration,0)) from logbook where "
                 (date-within-last-n-days "logbook.date" 365)))

(define qstr-hours
  (string-append "select sum(" isnull "(duration,0)) from logbook"))

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; List Instrument Approaches in the Last Year

(define qstr-approaches-list
  (string-append "select date, inst_app, remarks from logbook where inst_app > 0 and "
                 (date-within-last-n-days "date" 365)
                 " order by date desc"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; List Night Landings in the Last Half Year

(define qstr-night-landings-list
  (string-append "select date, nitelndgs, remarks from logbook where nitelndgs > 0 and "
                 (date-within-last-n-days "date" 180)
                 " order by date desc"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Civil Air Patrol

(define qstr-cap-read-mission-participation
  "select id, bkpgln, date, msym, mission_num, sortie, cap_ac, role from mission_participation order by bkpgln")

(struct cap-participation (id bkpgln date msym msn snum ac role) #:transparent)

(define qstr-cap-read-logbook
  (string-append "select bkpgln, date, " isnull "(nav,0) as 'nav', " isnull "(duration,0) as 'dur', remarks from logbook order by bkpgln"))

(struct caplog (bkpgln date nav dur remarks) #:transparent)

(define qstr-cap-mission-recency
  #<<ZZ
select distinct mp.date, (current_date - mp.date) as days, b.tailnum, mp.msym, ms.description from mission_participation mp
join logbook b on b.bkpgln = mp.bkpgln 
join mission_symbols ms on mp.msym = ms.msym and mp.date >= (current_date - interval '1 year')
order by days
ZZ
  )

(struct msnrec (date days tailnum msym description) #:transparent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; GLIDER

(define qstr-glider-dual-flights
  "select count(*) from glider_logbook where dual_dh > 0")

(define qstr-glider-dual-flights-last-30-days
  (string-append "select count(*) from glider_logbook where dual_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 30)))

(define qstr-glider-dual-flights-last-90-days
  (string-append "select count(*) from glider_logbook where dual_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 90)))

(define qstr-glider-dual-flights-last-180-days
  (string-append "select count(*) from glider_logbook where dual_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 180)))

(define qstr-glider-dual-flights-last-365-days
  (string-append "select count(*) from glider_logbook where dual_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 365)))


(define qstr-glider-dual-given-flights
  "select count(*) from glider_logbook where dual_given_dh > 0")

(define qstr-glider-dual-given-flights-last-30-days
  (string-append "select count(*) from glider_logbook where dual_given_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 30)))

(define qstr-glider-dual-given-flights-last-90-days
  (string-append "select count(*) from glider_logbook where dual_given_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 90)))

(define qstr-glider-dual-given-flights-last-180-days
  (string-append "select count(*) from glider_logbook where dual_given_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 180)))

(define qstr-glider-dual-given-flights-last-365-days
  (string-append "select count(*) from glider_logbook where dual_given_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 365)))


(define qstr-glider-dual-given-hours
  "select sum(dual_given_dh) from glider_logbook")

(define qstr-glider-dual-given-hours-last-30-days
  (string-append "select sum(" isnull "(dual_given_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 30)))

(define qstr-glider-dual-given-hours-last-90-days
  (string-append "select sum(" isnull "(dual_given_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 90)))

(define qstr-glider-dual-given-hours-last-180-days
  (string-append "select sum(" isnull "(dual_given_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 180)))

(define qstr-glider-dual-given-hours-last-365-days
  (string-append "select sum(" isnull "(dual_given_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 365)))


(define qstr-glider-dual-hours
  "select sum(dual_dh) from glider_logbook")

(define qstr-glider-dual-hours-last-30-days
  (string-append "select sum(" isnull "(dual_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 30)))

(define qstr-glider-dual-hours-last-90-days
  (string-append "select sum(" isnull "(dual_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 90)))

(define qstr-glider-dual-hours-last-180-days
  (string-append "select sum(" isnull "(dual_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 180)))

(define qstr-glider-dual-hours-last-365-days
  (string-append "select sum(" isnull "(dual_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 365)))


(define qstr-glider-flights
  "select count(*) from glider_logbook where duration_dh > 0")

(define qstr-glider-flights-last-30-days
  (string-append "select count(*) from glider_logbook where duration_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 30)))

(define qstr-glider-flights-last-90-days
  (string-append "select count(*) from glider_logbook where duration_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 90)))

(define qstr-glider-flights-last-180-days
  (string-append "select count(*) from glider_logbook where duration_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 180)))

(define qstr-glider-flights-last-365-days
  (string-append "select count(*) from glider_logbook where duration_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 365)))


(define qstr-glider-hours
  "select sum(duration_dh) from glider_logbook")

(define qstr-glider-hours-last-30-days
  (string-append "select sum(" isnull "(duration_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 30)))

(define qstr-glider-hours-last-90-days
  (string-append "select sum(" isnull "(duration_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 90)))

(define qstr-glider-hours-last-180-days
  (string-append "select sum(" isnull "(duration_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 180)))

(define qstr-glider-hours-last-365-days
  (string-append "select sum(" isnull "(duration_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 365)))


(define qstr-glider-pic-flights
  "select count(*) from glider_logbook where pic_dh > 0")

(define qstr-glider-pic-flights-last-30-days
  (string-append "select count(*) from glider_logbook where pic_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 30)))

(define qstr-glider-pic-flights-last-90-days
  (string-append "select count(*) from glider_logbook where pic_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 90)))

(define qstr-glider-pic-flights-last-180-days
  (string-append "select count(*) from glider_logbook where pic_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 180)))

(define qstr-glider-pic-flights-last-365-days
  (string-append "select count(*) from glider_logbook where pic_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 365)))


; pic
(define qstr-glider-pic-hours
  "select sum(pic_dh) from glider_logbook")

(define qstr-glider-pic-hours-last-30-days
  (string-append "select sum(" isnull "(pic_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 30)))

(define qstr-glider-pic-hours-last-90-days
  (string-append "select sum(" isnull "(pic_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 90)))

(define qstr-glider-pic-hours-last-180-days
  (string-append "select sum(" isnull "(pic_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 180)))

(define qstr-glider-pic-hours-last-365-days
  (string-append "select sum(" isnull "(pic_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 365)))


; solo
(define qstr-glider-solo-flights
  "select count(*) from glider_logbook where solo_dh > 0")

(define qstr-glider-solo-flights-last-30-days
  (string-append "select count(*) from glider_logbook where solo_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 30)))

(define qstr-glider-solo-flights-last-90-days
  (string-append "select count(*) from glider_logbook where solo_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 90)))

(define qstr-glider-solo-flights-last-180-days
  (string-append "select count(*) from glider_logbook where solo_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 180)))

(define qstr-glider-solo-flights-last-365-days
  (string-append "select count(*) from glider_logbook where solo_dh > 0 and "
                 (date-within-last-n-days "glider_logbook.date" 365)))


; solo
(define qstr-glider-solo-hours
  "select sum(solo_dh) from glider_logbook")

(define qstr-glider-solo-hours-last-30-days
  (string-append "select sum(" isnull "(solo_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 30)))

(define qstr-glider-solo-hours-last-90-days
  (string-append "select sum(" isnull "(solo_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 90)))

(define qstr-glider-solo-hours-last-180-days
  (string-append "select sum(" isnull "(solo_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 180)))

(define qstr-glider-solo-hours-last-365-days
  (string-append "select sum(" isnull "(solo_dh,0)) from glider_logbook where "
                 (date-within-last-n-days "glider_logbook.date" 365)))

;;;; ----------------------------------------------------------------------
(define glider-dual-flights
  (first-answer the-db qstr-glider-dual-flights))

(define glider-dual-flights-last-30-days
  (first-answer the-db qstr-glider-dual-flights-last-30-days))

(define glider-dual-flights-last-90-days
  (first-answer the-db qstr-glider-dual-flights-last-90-days))

(define glider-dual-flights-last-180-days
  (first-answer the-db qstr-glider-dual-flights-last-180-days))

(define glider-dual-flights-last-365-days
  (first-answer the-db qstr-glider-dual-flights-last-365-days))


(define glider-dual-given-flights
  (first-answer the-db qstr-glider-dual-given-flights))

(define glider-dual-given-flights-last-30-days
  (first-answer the-db qstr-glider-dual-given-flights-last-30-days))

(define glider-dual-given-flights-last-90-days
  (first-answer the-db qstr-glider-dual-given-flights-last-90-days))

(define glider-dual-given-flights-last-180-days
  (first-answer the-db qstr-glider-dual-given-flights-last-180-days))

(define glider-dual-given-flights-last-365-days
  (first-answer the-db qstr-glider-dual-given-flights-last-365-days))


(define glider-dual-given-hours
  (first-answer the-db qstr-glider-dual-given-hours))

(define glider-dual-given-hours-last-30-days
  (first-answer the-db qstr-glider-dual-given-hours-last-30-days))

(define glider-dual-given-hours-last-90-days
  (first-answer the-db qstr-glider-dual-given-hours-last-90-days))

(define glider-dual-given-hours-last-180-days
  (first-answer the-db qstr-glider-dual-given-hours-last-180-days))

(define glider-dual-given-hours-last-365-days
  (first-answer the-db qstr-glider-dual-given-hours-last-365-days))

(define glider-dual-hours
  (first-answer the-db qstr-glider-dual-hours))

(define glider-dual-hours-last-30-days
  (first-answer the-db qstr-glider-dual-hours-last-30-days))

(define glider-dual-hours-last-90-days
  (first-answer the-db qstr-glider-dual-hours-last-90-days))

(define glider-dual-hours-last-180-days
  (first-answer the-db qstr-glider-dual-hours-last-180-days))

(define glider-dual-hours-last-365-days
  (first-answer the-db qstr-glider-dual-hours-last-365-days))

(define glider-flights
  (first-answer the-db qstr-glider-flights))

(define glider-flights-last-30-days
  (first-answer the-db qstr-glider-flights-last-30-days))

(define glider-flights-last-90-days
  (first-answer the-db qstr-glider-flights-last-90-days))

(define glider-flights-last-180-days
  (first-answer the-db qstr-glider-flights-last-180-days))

(define glider-flights-last-365-days
  (first-answer the-db qstr-glider-flights-last-365-days))


(define glider-hours
  (first-answer the-db qstr-glider-hours))

(define glider-hours-last-30-days
  (first-answer the-db qstr-glider-hours-last-30-days))

(define glider-hours-last-90-days
  (first-answer the-db qstr-glider-hours-last-90-days))

(define glider-hours-last-180-days
  (first-answer the-db qstr-glider-hours-last-180-days))

(define glider-hours-last-365-days
  (first-answer the-db qstr-glider-hours-last-365-days))

(define glider-pic-flights
  (first-answer the-db qstr-glider-pic-flights))

(define glider-pic-flights-last-30-days
  (first-answer the-db qstr-glider-pic-flights-last-30-days))

(define glider-pic-flights-last-90-days
  (first-answer the-db qstr-glider-pic-flights-last-90-days))

(define glider-pic-flights-last-180-days
  (first-answer the-db qstr-glider-pic-flights-last-180-days))

(define glider-pic-flights-last-365-days
  (first-answer the-db qstr-glider-pic-flights-last-365-days))


(define glider-pic-hours
  (first-answer the-db qstr-glider-pic-hours))

(define glider-pic-hours-last-30-days
  (first-answer the-db qstr-glider-pic-hours-last-30-days))

(define glider-pic-hours-last-90-days
  (first-answer the-db qstr-glider-pic-hours-last-90-days))

(define glider-pic-hours-last-180-days
  (first-answer the-db qstr-glider-pic-hours-last-180-days))

(define glider-pic-hours-last-365-days
  (first-answer the-db qstr-glider-pic-hours-last-365-days))

(define glider-solo-flights
  (first-answer the-db qstr-glider-solo-flights))

(define glider-solo-flights-last-30-days
  (first-answer the-db qstr-glider-solo-flights-last-30-days))

(define glider-solo-flights-last-90-days
  (first-answer the-db qstr-glider-solo-flights-last-90-days))

(define glider-solo-flights-last-180-days
  (first-answer the-db qstr-glider-solo-flights-last-180-days))

(define glider-solo-flights-last-365-days
  (first-answer the-db qstr-glider-solo-flights-last-365-days))


(define glider-solo-hours
  (first-answer the-db qstr-glider-solo-hours))

(define glider-solo-hours-last-30-days
  (first-answer the-db qstr-glider-solo-hours-last-30-days))

(define glider-solo-hours-last-90-days
  (first-answer the-db qstr-glider-solo-hours-last-90-days))

(define glider-solo-hours-last-180-days
  (first-answer the-db qstr-glider-solo-hours-last-180-days))

(define glider-solo-hours-last-365-days
  (first-answer the-db qstr-glider-solo-hours-last-365-days))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Utility

(define (sql-date->ymd10 d)
  (format "~a-~a-~a"
          (sql-date-year d)
          (fmt-i-02d (sql-date-month d))
          (fmt-i-02d (sql-date-day d))))

(define (days-since-sql-date d)
  (error "unimplemented: days-since-sql-date"))

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

(define (get-cap-mission-recency)
  (let ([rows (query-rows the-db qstr-cap-mission-recency)])
    (map (λ (row)
           (msnrec (sql-date->ymd10 (vector-ref row 0))
                   (vector-ref row 1)
                   (vector-ref row 2)
                   (vector-ref row 3)
                   (vector-ref row 4)))
         rows)))

(define mission-recency-list (get-cap-mission-recency))

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

(define (mission-currency-table-rows msnrecs)
  (map (lambda (r)
         `(tr
           (td ,(msnrec-date r))
           (td ,(number->string (msnrec-days r)))
           (td ,(msnrec-tailnum r))
           (td ,(msnrec-msym r))
           (td ,(msnrec-description r))))
       msnrecs))

(define approaches-table
  (append `(table (tr (th "Date") (th "#") (th "Instrument Approach Details")))
          (detail-table-rows approaches-list)))

(define night-landings-table
  (append `(table (tr (th "Date") (th "#") (th "Night Landings Details")))
          (detail-table-rows night-landings-list)))

(define glider-table
  `(table (tr (th) (th "Dual Flights") (th "Dual Hours")
              (th "Solo Flights") (th "Solo Hours")
              (th "PIC Flights") (th "PIC Hours")
              (th "Dual Given Flights") (th "Dual Given Hours")
              (th "Flights") (th "Hours"))
          (tr (td "30 days")
              ,(td-int    glider-dual-flights-last-30-days)
              ,(td-flthrs glider-dual-hours-last-30-days)
              ,(td-int    glider-solo-flights-last-30-days)
              ,(td-flthrs glider-solo-hours-last-30-days)
              ,(td-int    glider-pic-flights-last-30-days)
              ,(td-flthrs glider-pic-hours-last-30-days)
              ,(td-int    glider-dual-given-flights-last-30-days)
              ,(td-flthrs glider-dual-given-hours-last-30-days)
              ,(td-int    glider-flights-last-30-days)
              ,(td-flthrs glider-hours-last-30-days))
          (tr (td "90 days")
              ,(td-int    glider-dual-flights-last-90-days)
              ,(td-flthrs glider-dual-hours-last-90-days)
              ,(td-int    glider-solo-flights-last-90-days)
              ,(td-flthrs glider-solo-hours-last-90-days)
              ,(td-int    glider-pic-flights-last-90-days)
              ,(td-flthrs glider-pic-hours-last-90-days)
              ,(td-int    glider-dual-given-flights-last-90-days)
              ,(td-flthrs glider-dual-given-hours-last-90-days)
              ,(td-int    glider-flights-last-90-days)
              ,(td-flthrs glider-hours-last-90-days))
          (tr (td "180 days")
              ,(td-int    glider-dual-flights-last-180-days)
              ,(td-flthrs glider-dual-hours-last-180-days)
              ,(td-int    glider-solo-flights-last-180-days)
              ,(td-flthrs glider-solo-hours-last-180-days)
              ,(td-int    glider-pic-flights-last-180-days)
              ,(td-flthrs glider-pic-hours-last-180-days)
              ,(td-int    glider-dual-given-flights-last-180-days)
              ,(td-flthrs glider-dual-given-hours-last-180-days)
              ,(td-int    glider-flights-last-180-days)
              ,(td-flthrs glider-hours-last-180-days))
          (tr (td "365 days")
              ,(td-int    glider-dual-flights-last-365-days)
              ,(td-flthrs glider-dual-hours-last-365-days)
              ,(td-int    glider-solo-flights-last-365-days)
              ,(td-flthrs glider-solo-hours-last-365-days)
              ,(td-int    glider-pic-flights-last-365-days)
              ,(td-flthrs glider-pic-hours-last-365-days)
              ,(td-int    glider-dual-given-flights-last-365-days)
              ,(td-flthrs glider-dual-given-hours-last-365-days)
              ,(td-int    glider-flights-last-365-days)
              ,(td-flthrs glider-hours-last-365-days))
          (tr (td "total")
              ,(td-int    glider-dual-flights)
              ,(td-flthrs glider-dual-hours)
              ,(td-int    glider-solo-flights)
              ,(td-flthrs glider-solo-hours)
              ,(td-int    glider-pic-flights)
              ,(td-flthrs glider-pic-hours)
              ,(td-int    glider-dual-given-flights)
              ,(td-flthrs glider-dual-given-hours)
              ,(td-int    glider-flights)
              ,(td-flthrs glider-hours))))


(define mission-recency-table
  (append `(table (tr (th "Date") (th "Days") (th "tailnum") (th "msym") (th "One Year Mission Recency")))
          (mission-currency-table-rows mission-recency-list)))

(define summary-table
  `(table (tr (th) (th "Instrument Approaches")
              (th "Landings")
              (th "Night Landings")
              (th "Act Inst")
              (th "Hood")
              (th "Simulator")
              (th "Hours"))
          (tr (td "30 days")
              ,(td-int inst-app-last-30-days)
              ,(td-int landings-last-30-days)
              ,(td-int night-landings-last-30-days)
              ,(td-flthrs inst-act-last-30-days)
              ,(td-flthrs inst-sim-last-30-days)
              ,(td-flthrs simulator-last-30-days)
              ,(td-flthrs hours-last-30-days))
          (tr (td "90 days")
              ,(td-int inst-app-last-90-days)
              ,(td-int-threshhold landings-last-90-days 3)
              ,(td-int-threshhold night-landings-last-90-days 3)
              ,(td-flthrs inst-act-last-90-days)
              ,(td-flthrs inst-sim-last-90-days)
              ,(td-flthrs simulator-last-90-days)
              ,(td-flthrs hours-last-90-days))
          (tr (td "180 days")
              ,(td-int-threshhold inst-app-last-180-days 6)
              ,(td-int landings-last-180-days)
              ,(td-int night-landings-last-180-days)
              ,(td-flthrs inst-act-last-180-days)
              ,(td-flthrs inst-sim-last-180-days)
              ,(td-flthrs simulator-last-180-days)
              ,(td-flthrs hours-last-180-days))
          (tr (td "365 days")
              ,(td-int inst-app-last-365-days)
              ,(td-int landings-last-365-days)
              ,(td-int night-landings-last-365-days)
              ,(td-flthrs inst-act-last-365-days)
              ,(td-flthrs inst-sim-last-365-days)
              ,(td-flthrs simulator-last-365-days)
              ,(td-flthrs hours-last-365-days))
          (tr (td "total")
              ,(td-int inst-app)
              ,(td-int landings)
              ,(td-int night-landings)
              ,(td-flthrs inst-act)
              ,(td-flthrs inst-sim)
              ,(td-flthrs simulator)
              ,(td-flthrs hours))))

(define the-page
  `(html (head (title ,head-title)
               (link ((rel "stylesheet")
                      (href ,css-path)
                      (type "text/css")))
               (body (div ((class "test"))
                          (h1 ,(string-append "Pilot Currency -- " pilot-name))
                          (p ((class "compgen")) ,computer-generated)
                          (h2 "Powered")
                          ,summary-table
                          (br)
                          ,approaches-table
                          (br)
                          ,night-landings-table
                          (h2 "Glider")
                          ,glider-table
                          (h2 "CAP Mission Recency")
                          ,mission-recency-table)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Process Web Request

;; request? -> response?
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
