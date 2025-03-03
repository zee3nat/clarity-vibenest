;; VibeNest Main Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u404))
(define-constant err-unauthorized (err u401))
(define-constant err-invalid-input (err u400))
(define-constant err-transfer-failed (err u402))
(define-constant err-already-processed (err u403))
(define-constant err-playlist-locked (err u405))

;; Events
(define-data-var last-event-id uint u0)
(define-map events
  { id: uint }
  {
    event-type: (string-ascii 24),
    playlist-id: uint,
    user: principal,
    timestamp: uint
  }
)

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
    version: uint,
    deleted: bool
  }
)

;; [Previous data structures remain unchanged]

;; Private functions
(define-private (log-event (event-type (string-ascii 24)) (playlist-id uint))
  (let ((new-id (+ (var-get last-event-id) u1)))
    (var-set last-event-id new-id)
    (map-set events
      { id: new-id }
      {
        event-type: event-type,
        playlist-id: playlist-id,
        user: tx-sender,
        timestamp: block-height
      }
    )
    (ok new-id)
  )
)

;; [Previous private functions remain unchanged]

;; Public functions
(define-public (create-playlist (name (string-utf8 64)) (description (string-utf8 256)))
  (let ((playlist-id (+ (var-get playlist-counter) u1)))
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
        version: u1,
        deleted: false
      }
    )
    (var-set playlist-counter playlist-id)
    (try! (log-event "playlist_created" playlist-id))
    (ok playlist-id)
  )
)

(define-public (delete-playlist (playlist-id uint))
  (let ((playlist (unwrap! (get-playlist playlist-id) err-not-found)))
    (asserts! (is-eq (get owner playlist) tx-sender) err-unauthorized)
    (asserts! (not (get deleted playlist)) err-already-processed)
    (map-set playlists
      { id: playlist-id }
      (merge playlist { deleted: true })
    )
    (try! (log-event "playlist_deleted" playlist-id))
    (ok true)
  )
)

;; [Other existing functions remain unchanged]

;; Read only functions
(define-read-only (get-event (event-id uint))
  (map-get? events { id: event-id })
)

;; [Previous read-only functions remain unchanged]
