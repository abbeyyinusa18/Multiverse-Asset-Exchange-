;; Inter-reality Asset Tokenization Contract

(define-non-fungible-token multiverse-asset uint)

(define-map tokenized-assets
  { asset-id: uint }
  {
    name: (string-utf8 100),
    reality-id: uint,
    owner: principal,
    metadata: (string-utf8 256)
  }
)

(define-data-var next-asset-id uint u0)

(define-public (tokenize-asset (name (string-utf8 100)) (reality-id uint) (metadata (string-utf8 256)))
  (let
    ((new-id (+ (var-get next-asset-id) u1)))
    (try! (nft-mint? multiverse-asset new-id tx-sender))
    (var-set next-asset-id new-id)
    (ok (map-set tokenized-assets
      { asset-id: new-id }
      {
        name: name,
        reality-id: reality-id,
        owner: tx-sender,
        metadata: metadata
      }
    ))
  )
)

(define-public (transfer-asset (asset-id uint) (recipient principal))
  (begin
    (try! (nft-transfer? multiverse-asset asset-id tx-sender recipient))
    (ok (map-set tokenized-assets
      { asset-id: asset-id }
      (merge (unwrap-panic (map-get? tokenized-assets { asset-id: asset-id }))
             { owner: recipient })
    ))
  )
)

(define-read-only (get-asset (asset-id uint))
  (map-get? tokenized-assets { asset-id: asset-id })
)

