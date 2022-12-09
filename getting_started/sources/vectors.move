module 0x4::vector_tutorial {
    #[test_only]
    use std::vector;

    fun new_vector() {
        let _empty_vector: vector<u8> = vector[];
        let _new_vector: vector<u8> = vector[23];
    }

    fun create_vec<T>(): vector<T> {
        let new_vector: vector<T> = vector[];
        new_vector
    }

    #[test]
    fun test_vec_is_empty() {
        let new_vector = create_vec<u8>();
        
        assert!(vector::is_empty(&new_vector), 1);
    }

    #[test]
    #[expected_failure]
    fun test_vec_not_empty() {
        let new_vector = create_vec<u8>();
        
        assert!(vector::is_empty(&new_vector), 1);

        vector::push_back(&mut new_vector, 12u8);

        assert!(vector::is_empty(&new_vector), 1);
    }

    #[test]
    fun test_mutability() {
        let new_vector = vector[1u8, 2u8, 3u8, 4u8];
        vector::swap(&mut new_vector, 0, 3);

        assert!(vector::borrow(&new_vector, 0) == &4u8, 1);
        assert!(vector::borrow(&new_vector, 3) == &1u8, 1);
    }
}