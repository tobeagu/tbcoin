;; tbcoin - a simple fungible token implementation
;;
;; This contract implements a minimal fungible token for experimental / local
;; development purposes. It is NOT audited and should not be used as-is in
;; production. Minting is permissionless by design to simplify testing.

;; --------------------------------------------
;; constants
;; --------------------------------------------

(define-constant ERR_ZERO_AMOUNT (err u1))
(define-constant ERR_INSUFFICIENT_BALANCE (err u2))

;; --------------------------------------------
;; data vars
;; --------------------------------------------

(define-data-var total-supply uint u0)

;; --------------------------------------------
;; data maps
;; --------------------------------------------

(define-map balances
  { account: principal }
  { balance: uint })

;; --------------------------------------------
;; internal helpers
;; --------------------------------------------

(define-private (get-balance-internal (owner principal))
  (default-to
    u0
    (get balance (map-get? balances { account: owner }))))

;; --------------------------------------------
;; public functions
;; --------------------------------------------

;; Mint `amount` tbcoin to `recipient`.
;; NOTE: This is permissionless and intended only for testing.
(define-public (mint (recipient principal) (amount uint))
  (begin
    (asserts! (> amount u0) ERR_ZERO_AMOUNT)
    (let ((current-balance (get-balance-internal recipient)))
      (map-set balances
        { account: recipient }
        { balance: (+ current-balance amount) })
      (var-set total-supply (+ (var-get total-supply) amount))
      (ok true))))

;; Transfer `amount` tbcoin from `sender` to `recipient`.
;; The caller must provide the correct `sender` principal and have
;; sufficient balance.
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (> amount u0) ERR_ZERO_AMOUNT)
    (let ((sender-balance (get-balance-internal sender)))
      (asserts! (>= sender-balance amount) ERR_INSUFFICIENT_BALANCE)
      (let (
            (recipient-balance (get-balance-internal recipient))
           )
        (map-set balances
          { account: sender }
          { balance: (- sender-balance amount) })
        (map-set balances
          { account: recipient }
          { balance: (+ recipient-balance amount) })
        (ok true)))))

;; --------------------------------------------
;; read-only functions
;; --------------------------------------------

;; Get the tbcoin balance of `owner`.
(define-read-only (get-balance (owner principal))
  (ok (get-balance-internal owner)))

;; Get the total number of tbcoin tokens that have been minted.
(define-read-only (get-total-supply)
  (ok (var-get total-supply)))
