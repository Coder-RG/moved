module 0x3::empty_module {}

module namedAddr::new_module {

    fun get_namedAddr(): address {
        @namedAddr
    }

    #[test]
    fun test_get_namedAddr() {
        let addr: address = get_namedAddr();

        assert!(addr == @0x2, 0);
    }
}
