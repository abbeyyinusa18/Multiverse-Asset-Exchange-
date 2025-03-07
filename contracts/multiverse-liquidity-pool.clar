;; Multiverse Liquidity Pool Management Contract

(define-map liquidity-pools
  { pool-id: uint }
  {
    reality-id: uint,
    total-liquidity: uint,
    reward-rate: uint
  }
)

(define-map user-liquidity
  { pool-id: uint, user: principal }
  { amount: uint }
)

(define-data-var next-pool-id uint u0)

(define-public (create-pool (reality-id uint) (initial-liquidity uint) (reward-rate uint))
  (let
    ((new-id (+ (var-get next-pool-id) u1)))
    (var-set next-pool-id new-id)
    (map-set liquidity-pools
      { pool-id: new-id }
      {
        reality-id: reality-id,
        total-liquidity: initial-liquidity,
        reward-rate: reward-rate
      }
    )
    (map-set user-liquidity
      { pool-id: new-id, user: tx-sender }
      { amount: initial-liquidity }
    )
    (ok new-id)
  )
)

(define-public (add-liquidity (pool-id uint) (amount uint))
  (let
    ((pool (unwrap! (map-get? liquidity-pools { pool-id: pool-id }) (err u404)))
     (user-liq (default-to { amount: u0 } (map-get? user-liquidity { pool-id: pool-id, user: tx-sender }))))
    (map-set liquidity-pools
      { pool-id: pool-id }
      (merge pool { total-liquidity: (+ (get total-liquidity pool) amount) })
    )
    (map-set user-liquidity
      { pool-id: pool-id, user: tx-sender }
      { amount: (+ (get amount user-liq) amount) }
    )
    (ok true)
  )
)

(define-read-only (get-pool (pool-id uint))
  (map-get? liquidity-pools { pool-id: pool-id })
)

(define-read-only (get-user-liquidity (pool-id uint) (user principal))
  (map-get? user-liquidity { pool-id: pool-id, user: user })
)

