module 0x5::signer_tutorial {
    use std::signer;
    
    #[test(addr=@0x45)]
    fun test_new_signer(addr: signer) {
        let a = signer::address_of(&addr);
        assert!(a == @0x45, 1);
    }
}