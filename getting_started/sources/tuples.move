module 0x6::tuples_tutorial {
    #[test]
    fun init_tuple() {
        let (a, b, c) = (1u8, 2u8, 3u8);
        assert!(a == 1u8, 1);
        assert!(b == 2u8, 1);
        assert!(c == 3u8, 1);
    }

    #[test_only]
    fun return_tuple(): (u8, address) {
        (1, @0x1)
    }

    #[test]
    fun test_variable_scope() {
        let a = 5u8;

        {
            let b = 6u8;
            let _c = b;
        };

        let _d = a;
    }

    #[test]
    fun init_tuple_2() {
        let (id, addr) = return_tuple();

        assert!(id == 1u8, 1);
        assert!(addr == @0x1, 1);
    }
}