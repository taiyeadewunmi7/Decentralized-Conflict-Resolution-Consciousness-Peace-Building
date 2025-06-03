;; Mediator Verification Contract
;; Validates consciousness peace building practitioners

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-verified (err u102))
(define-constant err-insufficient-experience (err u103))

;; Data structures
(define-map mediators principal {
  verified: bool,
  experience-years: uint,
  certifications: uint,
  reputation-score: uint,
  active-cases: uint,
  verification-date: uint
})

(define-map mediator-skills principal (list 10 (string-ascii 50)))

;; Read-only functions
(define-read-only (get-mediator (mediator principal))
  (map-get? mediators mediator)
)

(define-read-only (is-verified-mediator (mediator principal))
  (match (map-get? mediators mediator)
    mediator-data (get verified mediator-data)
    false
  )
)

(define-read-only (get-mediator-reputation (mediator principal))
  (match (map-get? mediators mediator)
    mediator-data (get reputation-score mediator-data)
    u0
  )
)

;; Public functions
(define-public (register-mediator (experience-years uint) (certifications uint) (skills (list 10 (string-ascii 50))))
  (let (
    (existing-mediator (map-get? mediators tx-sender))
  )
    (asserts! (is-none existing-mediator) err-already-verified)
    (asserts! (>= experience-years u1) err-insufficient-experience)

    (map-set mediators tx-sender {
      verified: false,
      experience-years: experience-years,
      certifications: certifications,
      reputation-score: u0,
      active-cases: u0,
      verification-date: u0
    })

    (map-set mediator-skills tx-sender skills)
    (ok true)
  )
)

(define-public (verify-mediator (mediator principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-some (map-get? mediators mediator)) err-not-found)

    (map-set mediators mediator
      (merge (unwrap-panic (map-get? mediators mediator)) {
        verified: true,
        verification-date: block-height
      })
    )
    (ok true)
  )
)

(define-public (update-reputation (mediator principal) (new-score uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-some (map-get? mediators mediator)) err-not-found)

    (map-set mediators mediator
      (merge (unwrap-panic (map-get? mediators mediator)) {
        reputation-score: new-score
      })
    )
    (ok true)
  )
)
