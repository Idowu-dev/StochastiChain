;; Define contract owner principal
(define-constant contract-owner tx-sender)

(define-data-var last-random uint u0)
(define-data-var seed uint u998877)
(define-data-var nonce uint u0)

;; Map to store user-specific entropy contributions
(define-map user-entropy principal uint)

;; Constants for the linear congruential generator
(define-constant MULTIPLIER u1664525)
(define-constant INCREMENT u1013904223) 
(define-constant MODULUS u4294967296) ;; 2^32

;; Error codes
(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-INVALID-RANGE u402)

;; Get block info as part of entropy
(define-private (get-block-entropy)
  (let ((block-time (default-to u0 (get-block-info? time u0))))
    ;; Combine block time with seed using XOR
    (xor (var-get seed) block-time)))

;; Linear Congruential Generator implementation
(define-private (lcg-next (current-seed uint))
  (mod (+ (* current-seed MULTIPLIER) INCREMENT) MODULUS))

;; Add user-provided entropy to the generator
(define-public (add-entropy (user-value uint))
  (begin
    (map-set user-entropy tx-sender user-value)
    (ok true)))

;; Generate a random number between 0 and max-value (inclusive)
(define-public (generate-random (max-value uint))
  (begin
    (asserts! (> max-value u0) (err ERR-INVALID-RANGE))
    
    ;; Combine multiple sources of entropy
    (let ((entropy (xor (xor (var-get seed) 
                             (default-to u0 (map-get? user-entropy tx-sender)))
                        (xor (get-block-entropy)
                             (var-get nonce)))))
      
      ;; Update internal state
      (var-set seed (lcg-next entropy))
      (var-set nonce (+ (var-get nonce) u1))
      (var-set last-random (mod (var-get seed) (+ max-value u1)))
      
      (ok (var-get last-random)))))

;; Get the last generated random number
(define-read-only (get-last-random)
  (ok (var-get last-random)))

;; Generate a random number in a custom range [min-value, max-value]
(define-public (generate-in-range (min-value uint) (max-value uint))
  (begin
    (asserts! (< min-value max-value) (err ERR-INVALID-RANGE))
    (let ((random-result (unwrap! (generate-random (- max-value min-value)) (err ERR-INVALID-RANGE))))
      (ok (+ min-value random-result)))))

;; Initialize the generator with a custom seed (contract deployer only)
(define-public (initialize-generator (initial-seed uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err ERR-UNAUTHORIZED))
    (var-set seed initial-seed)
    (var-set nonce u0)
    (ok true)))

;; Get information about the current state of the RNG
(define-read-only (get-rng-info)
  (ok {
    last-random: (var-get last-random),
    nonce: (var-get nonce)
  }))