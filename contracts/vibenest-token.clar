;; VibeNest Token Contract

(define-fungible-token vibenest)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))

;; Token info
(define-data-var token-name (string-ascii 32) "VibeNest Token")
(define-data-var token-symbol (string-ascii 10) "VIBE")

;; Public functions
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ft-mint? vibenest amount recipient)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (ft-transfer? vibenest amount sender recipient)
)
