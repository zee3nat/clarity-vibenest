;; VibeNest Token Contract

(define-fungible-token vibenest)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-transfer-failed (err u101))
(define-constant err-mint-failed (err u102))

;; Token info
(define-data-var token-name (string-ascii 32) "VibeNest Token")
(define-data-var token-symbol (string-ascii 10) "VIBE")
(define-data-var contract-paused bool false)

;; Public functions
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (var-get contract-paused)) err-transfer-failed)
    (ft-mint? vibenest amount recipient)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (not (var-get contract-paused)) err-transfer-failed)
    (ft-transfer? vibenest amount sender recipient)
  )
)

(define-public (set-token-pause (paused bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (var-set contract-paused paused))
  )
)
