open OUnit2;;

let test1 test_ctxt =
    let test_machine : Main.machine = 
      {
        name = "unary_sub";
        alphabet = [ "1"; "."; "-"; "=" ];
        blank = ".";
        states = [ "scanright"; "eraseone"; "subone"; "skip"; "HALT" ];
        initial = "scanright";
        finals = [ "HALT" ];
        transitions =
          [
            ("scanright", [
              {
                from_state = "scanright";
                read = ".";
                to_state = "scanright";
                write = ".";
                action = Main.Right;
              };
              {
                from_state = "scanright";
                read = "1";
                to_state = "scanright";
                write = "1";
                action = Main.Right;
              };
              {
                from_state = "scanright";
                read = "-";
                to_state = "scanright";
                write = "-";
                action = Main.Right;
              };
              {
                from_state = "scanright";
                read = "=";
                to_state = "eraseone";
                write = ".";
                action = Main.Left;
              }
             ]);
            "eraseone", [
              {
                from_state = "eraseone";
                read = "1";
                to_state = "subone";
                write = "=";
                action = Main.Left;
              };
              {
                from_state = "eraseone";
                read = "-";
                to_state = "HALT";
                write = ".";
                action = Main.Left;
              }
            ];
            "subone", [
              {
                from_state = "subone";
                read = "1";
                to_state = "subone";
                write = "1";
                action = Main.Left;
              };
              {
                from_state = "subone";
                read = "-";
                to_state = "skip";
                write = "-";
                action = Main.Left;
              }
            ];
            "skip", [
              {
                from_state = "skip";
                read = ".";
                to_state = "skip";
                write = ".";
                action = Main.Left;
              };
              {
                from_state = "skip";
                read = "1";
                to_state = "scanright";
                write = ".";
                action = Main.Right;
              }
            ]
          ]
      }
    in assert_equal test_machine (Main.parse_machine_description "machine_descriptions/unary_sub.json");;

(* let test2 test_ctxt = assert_equal 100 (Foo.unity 100);; *)

(* Name the test cases and group them together *)
let suite =
"suite" >:::
 ["test1" >:: test1]
  (* "test2" >:: test2] *)
;;

let () =
  run_test_tt_main suite
;;