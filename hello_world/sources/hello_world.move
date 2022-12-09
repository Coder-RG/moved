module 0x1::hello {
    fun plus_one(a: u8): u8 {
        a + 1
    }

    #[test]
    fun test_plus_one() {
        let val = 2u8;
        let val_plus_one = plus_one(val);

        assert!(val_plus_one == 3u8, 0);
    }

    #[test]
    #[expected_failure]
    fun plus_one_OF() {
        let val = 255u8;
        let _val_plus_one = plus_one(val);
    }

    #[test]
    fun plus_one_no_OF() {
        let val = 54u8;
        let val_plus_one = plus_one(val);

        assert!(val_plus_one == 55u8, 0);
    }
}
