;; Title: Secure Staking Smart Contract
;; Description: A smart contract for staking tokens and earning rewards

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant REWARD_RATE u10) ;; 10% reward rate per annum
(define-constant SECONDS_IN_YEAR u31536000) ;; Number of seconds in a year
(define-constant ERR_UNAUTHORIZED (err u1))
(define-constant ERR_INVALID_AMOUNT (err u2))
(define-constant ERR_INSUFFICIENT_BALANCE (err u3))
(define-constant ERR_NO_REWARDS (err u4))
(define-constant ERR_NOTHING_TO_WITHDRAW (err u5))

;; Data Maps
(define-map stakes { user: principal } { amount: uint })
(define-map stake-timestamps { user: principal } { timestamp: uint })
(define-map rewards { user: principal } { amount: uint })

;; Error handling functions
(define-private (check-owner)
    (ok (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)))

;; Getter functions with proper typing
(define-private (get-stake (user principal))
    (default-to { amount: u0 }
        (map-get? stakes { user: user })))

(define-private (get-timestamp (user principal))
    (default-to { timestamp: u0 }
        (map-get? stake-timestamps { user: user })))

(define-private (get-reward (user principal))
    (default-to { amount: u0 }
        (map-get? rewards { user: user })))

;; Function to stake tokens
(define-public (stake (amount uint))
    (let (
        (user tx-sender)
        (current-stake (get amount (get-stake user)))
    )
    (begin
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        (asserts! (<= amount (stx-get-balance user)) ERR_INSUFFICIENT_BALANCE)
        (try! (stx-transfer? amount user (as-contract tx-sender)))
        (map-set stakes 
            { user: user }
            { amount: (+ current-stake amount) })
        (map-set stake-timestamps
            { user: user }
            { timestamp: block-height })
        (ok true))))

;; Function to calculate rewards
(define-private (calculate-rewards (user principal))
    (let (
        (stake-info (get-stake user))
        (timestamp-info (get-timestamp user))
        (staked-amount (get amount stake-info))
        (stake-time (get timestamp timestamp-info))
        (duration (- block-height stake-time))
    )
    (if (or (is-eq staked-amount u0) (is-eq duration u0))
        u0
        (/ (* (* staked-amount duration) REWARD_RATE)
           (* SECONDS_IN_YEAR u100)))))

;; Function to claim rewards
(define-public (claim-rewards)
    (let (
        (user tx-sender)
        (earned-rewards (calculate-rewards user))
    )
    (begin
        (asserts! (> earned-rewards u0) ERR_NO_REWARDS)
        (map-set rewards
            { user: user }
            { amount: (+ (get amount (get-reward user)) earned-rewards) })
        (map-set stake-timestamps
            { user: user }
            { timestamp: block-height })
        (ok earned-rewards))))

;; Function to withdraw staked tokens and rewards
(define-public (withdraw)
    (let (
        (user tx-sender)
        (stake-info (get-stake user))
        (reward-info (get-reward user))
        (staked-amount (get amount stake-info))
        (reward-amount (get amount reward-info))
        (total-amount (+ staked-amount reward-amount))
    )
    (begin
        (asserts! (> total-amount u0) ERR_NOTHING_TO_WITHDRAW)
        (asserts! (<= total-amount (stx-get-balance (as-contract tx-sender)))
            ERR_INSUFFICIENT_BALANCE)
        (try! (as-contract (stx-transfer? total-amount tx-sender user)))
        (map-set stakes { user: user } { amount: u0 })
        (map-set rewards { user: user } { amount: u0 })
        (map-set stake-timestamps { user: user } { timestamp: u0 })
        (ok total-amount))))

;; Read-only functions for querying stake and reward information
(define-read-only (get-staked-amount (user principal))
    (ok (get amount (get-stake user))))

(define-read-only (get-user-rewards (user principal))
    (ok (+ (get amount (get-reward user))
           (calculate-rewards user))))

;; Contract management functions
(define-public (emergency-withdraw)
    (begin
        (try! (check-owner))
        (let ((balance (stx-get-balance (as-contract tx-sender))))
            (try! (as-contract (stx-transfer? balance tx-sender CONTRACT_OWNER)))
            (ok balance))))

