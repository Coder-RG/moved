module suberc20::token {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    
    /// Error codes
    const ENOT_MINTER: u64 = 2;
    const EUSER_EXISTS: u64 = 3;
    const EINSUFFICIENT_BALANCE: u64 = 4;
    const ESUPPLY_NOT_INSTANTIATED: u64 = 5;
    const ESINGLE_APPROVAL_ONLY: u64 = 6;
    const EEMPTY_APPROVAL: u64 = 7;
    
    struct TokenInfo has key {
        id: UID,
        name: vector<u8>,
        symbol: vector<u8>,
        owner: address,
        decimals: u8,
    }

    struct Approval has key {
        id: UID,
        addr: address,
        allowance: u64,
    }

    struct Coin has key {
        id: UID,
        amount: u64,
    }

    struct Supply has key {
        id: UID,
        amount: u64,
    }

    fun init(ctx: &mut TxContext) {
        // initialize token supply to zero
        let token_supply = Supply {
            id: object::new(ctx),
            amount: 0,
        };
        // save value under the admin
        transfer::transfer(token_supply, tx_context::sender(ctx));
    }

    public fun name(info: &TokenInfo): vector<u8> {
        info.name
    }

    public fun symbol(info: &TokenInfo): vector<u8> {
        info.symbol
    }

    public fun decimals(info: &TokenInfo): u8 {
        info.decimals
    }

    public fun total_supply(supply: &Supply): u64 {
        supply.amount
    }

    public fun balance_of(coin: &Coin): u64 {
        coin.amount
    }

    public entry fun create_coin(name: vector<u8>, symbol: vector<u8>, decimals: u8, ctx: &mut TxContext) {
        // create token info struct
        let coin_info = TokenInfo {
            id: object::new(ctx),
            name,
            symbol,
            owner: tx_context::sender(ctx),
            decimals
        };
        // save at sender address
        transfer::transfer(coin_info, tx_context::sender(ctx));
    }

    public entry fun mint(
        recipient: address,
        amount: u64,
        supply: &mut Supply,
        ctx: &mut TxContext,
        ) {
        // Mint new coin
        let minted_coin = Coin {
            id: object::new(ctx),
            amount: amount,
        };
        // transfer to recipient
        transfer::transfer(minted_coin, recipient);
        // Increase the supply
        supply.amount = supply.amount + amount;
    }

    public entry fun transfer(
        coin: &mut Coin,
        recipient: address,
        amount: u64,
        ctx: &mut TxContext,
        ) {
        // Assert enough balance in sender's account
        assert!(coin.amount >= amount, EINSUFFICIENT_BALANCE);
        // Withdraw amount from sender's account
        let transfer_coin = Coin {
            id: object::new(ctx),
            amount: amount,
        };

        coin.amount = coin.amount - amount;
        // Transfer to recipient
        transfer::transfer(transfer_coin, recipient);
    }
}