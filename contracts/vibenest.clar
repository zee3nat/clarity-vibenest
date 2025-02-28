;; VibeNest Main Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u404))
(define-constant err-unauthorized (err u401))
(define-constant err-invalid-input (err u400))
(define-constant err-transfer-failed (err u402))
(define-constant err-already-processed (err u403))

;; Data structures
(define-map playlists
  { id: uint }
  {
    owner: principal,
    name: (string-utf8 64),
    description: (string-utf8 256),
    songs: (list 50 (string-utf8 128)),
    likes: uint,
    created-at: uint,
    version: uint
  }
)

(define-map user-follows
  { follower: principal, following: principal }
  { timestamp: uint }
)

(define-map playlist-comments
  { playlist-id: uint, comment-id: uint }
  {
    author: principal,
    content: (string-utf8 256),
    timestamp: uint
  }
)

;; Data vars
(define-data-var playlist-counter uint u0)
(define-data-var comment-counter uint u0)
(define-data-var contract-paused bool false)

;; Private functions
(define-private (validate-playlist-name (name (string-utf8 64)))
  (let ((length (len name)))
    (and (> length u0) (<= length u64))
  )
)

(define-private (is-contract-owner)
  (is-eq tx-sender contract-owner)
)

;; Public functions
(define-public (create-playlist (name (string-utf8 64)) (description (string-utf8 256)))
  (let (
    (playlist-id (+ (var-get playlist-counter) u1))
  )
    (asserts! (not (var-get contract-paused)) err-unauthorized)
    (asserts! (validate-playlist-name name) err-invalid-input)
    (map-set playlists
      { id: playlist-id }
      {
        owner: tx-sender,
        name: name,
        description: description,
        songs: (list),
        likes: u0,
        created-at: block-height,
        version: u1
      }
    )
    (var-set playlist-counter playlist-id)
    (ok playlist-id)
  )
)

(define-public (transfer-playlist-ownership (playlist-id uint) (new-owner principal))
  (let (
    (playlist (unwrap! (get-playlist playlist-id) err-not-found))
  )
    (asserts! (not (var-get contract-paused)) err-unauthorized)
    (asserts! (is-eq (get owner playlist) tx-sender) err-unauthorized)
    (ok (map-set playlists
      { id: playlist-id }
      (merge playlist { 
        owner: new-owner,
        version: (+ (get version playlist) u1)
      })
    ))
  )
)

;; Admin functions
(define-public (set-contract-pause (paused bool))
  (begin
    (asserts! (is-contract-owner) err-unauthorized)
    (ok (var-set contract-paused paused))
  )
)

;; Read only functions
(define-read-only (get-playlist (playlist-id uint))
  (map-get? playlists { id: playlist-id })
)

(define-read-only (get-user-playlists (user principal))
  (filter playlists (lambda (playlist)
    (is-eq (get owner playlist) user)
  ))
)
