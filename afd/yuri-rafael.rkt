#lang racket

(define english-1
  '((Initial (1))
    (Final (9))
    (From 1 to 3 by NP)
    (From 1 to 2 by DET)
    (From 2 to 3 by N)
    (From 3 to 4 by BV)
    (From 4 to 5 by ADV)
    (From 4 to 5 by |#|)
    (From 5 to 6 by DET)
    (From 5 to 7 by DET)
    (From 5 to 8 by |#|)
    (From 6 to 7 by ADJ)    
    (From 6 to 6 by MOD)
    (From 7 to 9 by N)
    (From 8 to 9 by MOD)
    (From 8 to 8 by ADJ)
    (From 9 to 4 by CNJ)
    (From 9 to 1 by CNJ)))

(define portuguese-1
  '((Initial (1))
    (Final (8))
    (From 1 to 3 by NM)
    (From 1 to 2 by ART)
    (From 2 to 3 by NM)
    (From 3 to 4 by VLA)
    (From 3 to 5 by VLB)
    (From 4 to 6 by ADVI)
    (From 4 to 8 by ADJP)
    (From 5 to 7 by V)
    (From 6 to 6 by ADVI)
    (From 6 to 8 by ADJP)
    (From 7 to 8 by ADVI)))    
    

(define (getf lst key (default null))
    (cond ((null? lst) default)
          ((null? (cdr lst)) default)
          ((eq? (car lst) key) (cadr lst))
          (else (getf (cddr lst) key default))))

(define (initial-nodes network)
  (list-ref (assoc 'Initial network) 1))

(define (final-nodes network)
  (list-ref (assoc 'Final network) 1))

(define (transitions network)
  (cddr network))

(define (trans-node transition)
  (getf transition 'From))

(define (trans-newnode transition)
  (getf transition 'to))

(define (trans-label transition)
  (getf transition 'by))


(define abbreviations
  '((NP kim sandy lee)
    (DET a the her)
    (N consumer man woman)
    (BV is was)
    (CNJ and or)
    (ADJ happy stupid)
    (MOD very)
    (ADV often always sometimes)
    (|#|)
    (ART O A)
    (NM Dominique Alex Ariel)
    (VLA é)
    (VLB vai)
    (V trabalhar estudar jogar)
    (ADVI muito)
    (ADJP importante legal interessante)))

(define (recognize network tape)
  (with-handlers ((boolean? (lambda (z) z)))
    (for ((initialnode (initial-nodes network)))
      (recognize-next initialnode tape network))
    #f))

(define (recognize-next node tape network)
  (if (null? tape)
      (if (member node (final-nodes network))
          (raise #t #t)
          (raise #f #f))
      (for ((transition (transitions network)))
        (if (equal? node (trans-node transition))
            (for ((newtape (recognize-move (trans-label transition) tape)))
              (recognize-next (trans-newnode transition) newtape network))
            empty))))

(define (recognize-move label tape)
  (if (or (equal? label (car tape))
          (member (car tape) (assoc label abbreviations)))
      (list (cdr tape))
      (if (equal? label '|#|)
          (list tape)
          empty)))

(define (generate network)
  (for ((initialnode (initial-nodes network)))
    (generate-next initialnode null network)))

(define (generate-next node tape network)
  (if (or (member node (final-nodes network)) (> (length tape) 6))
      (begin (display tape)
             (newline))
      (for ((transition (transitions network)))
	(if (equal? node (trans-node transition))
	    (for ((newtape (generate-move (trans-label transition) tape)))
	      (generate-next (trans-newnode transition) newtape network))
	    empty))))

(define (generate-move label tape)
  (if (equal? label '|#|)
      (list tape)
      (map (lambda (x) (append tape (list x))) (cdr (assoc label abbreviations))))) 