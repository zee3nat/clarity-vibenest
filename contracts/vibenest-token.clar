;; VibeNest Token Contract

(define-fungible-token vibenest)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant token-decimals u6)
(define-constant err-owner-only (err u100))
(define-constant err-transfer-failed (err u101))
(define-constant err-mint-failed (err u102))
(define-constant err-burn-failed (err u103))
(define-constant err-insufficient-balance (err u104))

;; Token info
(define-data-var token-name (string-ascii 32) "VibeNest Token")
(define-data-var token-symbol (string-ascii 10) "VIBE")
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var total-supply uint u0)
(define-data-var contract-paused bool false)

;; Public functions
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (var-get contract-paused)) err-transfer-failed)
    (match (ft-mint? vibenest amount recipient)
      success (begin
        (var-set total-supply (+ (var-get total-supply) amount))
        (ok success))
      error (err err-mint-failed))
  )
)

(define-public (burn (amount uint) (owner principal))
  (begin
    (asserts! (is-eq tx-sender owner) err-owner-only)
    (asserts! (not (var-get contract-paused)) err-transfer-failed)
    (match (ft-burn? vibenest amount owner)
      success (begin
        (var-set total-supply (- (var-get total-supply) amount))
        (ok success))
      error (err err-burn-failed))
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

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (var-set token-uri new-uri))
  )
)

;; Read only functions
(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-read-only (get-decimals)
  (ok token-decimals)
)
