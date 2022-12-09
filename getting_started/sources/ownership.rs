use std::marker::Copy;

#[derive(Copy, Clone)]
struct S {
    f: u8,
}

fn main() {
    let s = S { f: 42u8 };
    reference_copies(s);
}

fn reference_copies(mut s: S) {
  let _s_copy1 = s; // ok
  let _s_extension = &mut s.f; // also ok
  let _s_copy2 = s; // still ok
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn first_test() {
        main();
    }
}