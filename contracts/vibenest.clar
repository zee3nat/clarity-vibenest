;; VibeNest Main Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u404))
(define-constant err-unauthorized (err u401))

;; Data structures
(define-map playlists
  { id: uint }
  {
    owner: principal,
    name: (string-utf8 64),
    description: (string-utf8 256),
    songs: (list 50 (string-utf8 128)),
    likes: uint,
    created-at: uint
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

;; Public functions
(define-public (create-playlist (name (string-utf8 64)) (description (string-utf8 256)))
  (let (
    (playlist-id (+ (var-get playlist-counter) u1))
  )
    (map-set playlists
      { id: playlist-id }
      {
        owner: tx-sender,
        name: name,
        description: description,
        songs: (list),
        likes: u0,
        created-at: block-height
      }
    )
    (var-set playlist-counter playlist-id)
    (ok playlist-id)
  )
)

(define-public (add-song (playlist-id uint) (song-url (string-utf8 128)))
  (let (
    (playlist (unwrap! (get-playlist playlist-id) err-not-found))
  )
    (asserts! (is-eq (get owner playlist) tx-sender) err-unauthorized)
    (ok (map-set playlists
      { id: playlist-id }
      (merge playlist { songs: (unwrap-panic (as-max-len? (append (get songs playlist) song-url) u50)) })
    ))
  )
)

(define-public (like-playlist (playlist-id uint))
  (let (
    (playlist (unwrap! (get-playlist playlist-id) err-not-found))
  )
    (ok (map-set playlists
      { id: playlist-id }
      (merge playlist { likes: (+ (get likes playlist) u1) })
    ))
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
