address 0xEC20 {
    module token {
        use std::signer;
        
        /// Error codes
        const ENOT_MINTER: u64 = 2;
        const EUSER_EXISTS: u64 = 3;
        const EINSUFFICIENT_BALANCE: u64 = 4;
        const ESUPPLY_NOT_INSTANTIATED: u64 = 5;
        const ESINGLE_APPROVAL_ONLY: u64 = 6;
        const EEMPTY_APPROVAL: u64 = 7;

        const MINTER: address = @0xEC20;
        
        struct TokenInfo has key {
            name: vector<u8>,
            symbol: vector<u8>,
            owner: vector<u8>,
            decimals: u8,
        }

        struct Approval has drop, key {
            addr: address,
            allowance: u64,
        }

        struct Coin has key {
            amount: u64,
        }

        struct Supply has key {
            amount: u64,
        }

        public(friend) fun name(): vector<u8> {
            b"Speak for yourself, peasant.\n"
        }

        public(friend) fun symbol(): vector<u8> {
            b"PHAROAH\n"
        }

        public(friend) fun decimals(): u8 {
            6u8
        }

        public(friend) fun total_supply(): u64 acquires Supply {
            if (exists<Supply>(@0xec20)) {
                let supply: &Supply = borrow_global(@0xec20);
                supply.amount
            } else 0u64
        }

        public(friend) fun balance_of(user: address): u64 acquires Coin {
            if (exists<Coin>(user)) {
                borrow_global<Coin>(user).amount
            } else 0u64
        }

        fun create_account(user: signer) {
            assert!(!exists<Coin>(signer::address_of(&user)), EUSER_EXISTS);
            // Store 0 coins at user address
            move_to(&user, Coin { amount: 0 });
        }

        fun mint(minter: signer, receiver: address, amount: u64) acquires Coin, Supply {
            assert!(signer::address_of(&minter) == MINTER, ENOT_MINTER);

            if (!exists<Supply>(signer::address_of(&minter))) move_to<Supply>(&minter, Supply { amount: 0 });
            let token_supply = borrow_global_mut<Supply>(signer::address_of(&minter));
            token_supply.amount = token_supply.amount + amount;
            
            // Get current balance of `receiver`
            let balance = borrow_global_mut<Coin>(receiver);
            balance.amount = balance.amount + amount;
        }

        public(friend) fun transfer(sender: signer, receiver: address, amount: u64) acquires Coin {
            // Assert enough balance in sender's account
            let balance_sender = &mut borrow_global_mut<Coin>(signer::address_of(&sender)).amount;
            assert!(*balance_sender >= amount, EINSUFFICIENT_BALANCE);
            // Withdraw amount from sender's account
            *balance_sender = *balance_sender - amount;

            let balance_receiver = &mut borrow_global_mut<Coin>(receiver).amount;
            // Deposit amount into receiver's account
            *balance_receiver = *balance_receiver + amount;
        }

        public(friend) fun transfer_from(_from: address, _to: address, _amount: u64): bool {
            false
        }

        public(friend) fun approve(user: signer, spender: address, value: u64, update: bool) acquires Approval {
            assert!(!exists<Approval>(signer::address_of(&user)) || update, ESINGLE_APPROVAL_ONLY);

            if (exists<Approval>(signer::address_of(&user))) {
                move_from<Approval>(signer::address_of(&user));
            };

            move_to<Approval>(&user, Approval { addr: spender, allowance: value });
        }

        public(friend) fun allowance(owner: address, spender: address): u64 acquires Approval {
            assert!(exists<Approval>(owner), EEMPTY_APPROVAL);
            let approval = borrow_global<Approval>(owner);
            if (approval.addr != spender) 0u64 else approval.allowance
        }

        #[test]
        fun total_supply_not_instantiated() acquires Supply {
            let result = total_supply();
            assert!(result == 0, 1);
        }

        #[test]
        fun balance_of_no_user_data() acquires Coin {
            let result = balance_of(@0xAA);
            assert!(result == 0, 1);
        }

        #[test(minter = @0xE20)]
        #[expected_failure(abort_code = ENOT_MINTER)]
        fun mint_invalid_minter(minter: signer) acquires Coin, Supply {
            mint(minter, @0xFF, 20u64);
        }

        #[test(minter = @0xEC20)]
        #[expected_failure]
        fun mint_no_receiver_balance(minter: signer) acquires Coin, Supply {
            mint(minter, @0xAA, 20u64);
        }

        #[test(minter = @0xEC20, receiver = @0xAB)]
        fun mint_after_creating_account(minter: signer, receiver: signer) acquires Coin, Supply {
            let receiver_addr = signer::address_of(&receiver);
            create_account(receiver);
            mint(minter, receiver_addr, 10);
            
            assert!(exists<Coin>(receiver_addr), 1);
            assert!(borrow_global<Coin>(receiver_addr).amount == 10, 1);
            assert!(borrow_global<Supply>(@0xEC20).amount == 10, 1);
        }

        #[test(sender = @0xAA)]
        #[expected_failure]
        fun transfer_no_sender_account(sender: signer) acquires Coin {
            transfer(sender, @0xAB, 10);
        }

        #[test(sender = @0xAA, sender_copy = @0xAA)]
        #[expected_failure]
        fun transfer_no_receiver_account(sender: signer, sender_copy: signer) acquires Coin {
            create_account(sender);
            transfer(sender_copy, @0xAB, 10);
        }

        #[test(sender = @0xAA, receiver = @0xAB)]
        fun transfer_successful(sender: signer, receiver: signer) acquires Coin {
            move_to<Coin>(&sender, Coin { amount: 100 });
            move_to<Coin>(&receiver, Coin { amount: 0 });
            transfer(sender, signer::address_of(&receiver), 10);

            assert!(borrow_global<Coin>(@0xAA).amount == 90, 1);
            assert!(borrow_global<Coin>(@0xAB).amount == 10, 1);
        }

        #[test(sender = @0xAA, receiver = @0xAB)]
        #[expected_failure(abort_code = EINSUFFICIENT_BALANCE)]
        fun transfer_insufficient_balance(sender: signer, receiver: signer) acquires Coin {
            move_to<Coin>(&sender, Coin { amount: 100 });
            move_to<Coin>(&receiver, Coin { amount: 0 });
            transfer(sender, signer::address_of(&receiver), 1000);
        }

        #[test(user = @0xAA)]
        fun approve_new_address(user: signer) acquires Approval {
            approve(user, @0xAB, 1000, false);
        }

        #[test(user = @0xAA, user_copy = @0xAA)]
        #[expected_failure]
        fun approve_address_wo_update(user: signer, user_copy: signer) acquires Approval {
            approve(user, @0xAB, 1000, false);
            approve(user_copy, @0xAC, 1000, false);
        }

        #[test]
        #[expected_failure(abort_code = EEMPTY_APPROVAL)]
        fun approval_no_address_approved() acquires Approval {
            allowance(@0xAA, @0xAB);
        }

        #[test(user = @0xAA)]
        fun approval_approved_address(user: signer) acquires Approval {
            approve(user, @0xAB, 1000, false);
            assert!(allowance(@0xAA, @0xAB) == 1000, 1);
        }

        #[test(user = @0xAA)]
        fun approval_diff_approved_address(user: signer) acquires Approval {
            approve(user, @0xAB, 1000, false);
            assert!(allowance(@0xAA, @0xAC) == 0, 1);
        }
    }
}