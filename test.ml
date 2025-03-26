open OUnit2

let test1 test_ctxt =
    let test_machine : Machine.machine = 
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
                action = Machine.Right;
              };
              {
                from_state = "scanright";
                read = "1";
                to_state = "scanright";
                write = "1";
                action = Machine.Right;
              };
              {
                from_state = "scanright";
                read = "-";
                to_state = "scanright";
                write = "-";
                action = Machine.Right;
              };
              {
                from_state = "scanright";
                read = "=";
                to_state = "eraseone";
                write = ".";
                action = Machine.Left;
              }
             ]);
            "eraseone", [
              {
                from_state = "eraseone";
                read = "1";
                to_state = "subone";
                write = "=";
                action = Machine.Left;
              };
              {
                from_state = "eraseone";
                read = "-";
                to_state = "HALT";
                write = ".";
                action = Machine.Left;
              }
            ];
            "subone", [
              {
                from_state = "subone";
                read = "1";
                to_state = "subone";
                write = "1";
                action = Machine.Left;
              };
              {
                from_state = "subone";
                read = "-";
                to_state = "skip";
                write = "-";
                action = Machine.Left;
              }
            ];
            "skip", [
              {
                from_state = "skip";
                read = ".";
                to_state = "skip";
                write = ".";
                action = Machine.Left;
              };
              {
                from_state = "skip";
                read = "1";
                to_state = "scanright";
                write = ".";
                action = Machine.Right;
              }
            ]
          ]
      }
    in let parsed_machine = Parser.parse_machine_description "machine_descriptions/unary_sub.json"
    in
    (* assert_equal test_machine parsed_machine ~printer:Main.string_of_machine_description; *)
    assert_equal test_machine.name parsed_machine.name ~printer:Fun.id;
    List.iter2 (assert_equal ~printer:Fun.id) test_machine.alphabet parsed_machine.alphabet;
    assert_equal test_machine.blank parsed_machine.blank ~printer:Fun.id;
    List.iter2 (assert_equal ~printer:Fun.id) test_machine.states parsed_machine.states;
    assert_equal test_machine.initial parsed_machine.initial ~printer:Fun.id;
    List.iter2 (assert_equal ~printer:Fun.id) test_machine.finals parsed_machine.finals;
    List.iter2 (fun (state1, transitions1) (state2, transitions2) ->
        assert_equal state1 state2 ~printer:Fun.id;
      List.iter2 (fun (t1 : Machine.transition) (t2 : Machine.transition) ->
        assert_equal t1.from_state t2.from_state ~printer:Fun.id;
        assert_equal t1.read t2.read ~printer:Fun.id;
        assert_equal t1.to_state t2.to_state ~printer:Fun.id;
        assert_equal t1.write t2.write ~printer:Fun.id;
        assert_equal t1.action t2.action ~printer:(fun action -> if action = Machine.Left then "Left" else "Right")
      ) transitions1 transitions2)
      test_machine.transitions parsed_machine.transitions

(* let test2 test_ctxt = assert_equal 100 (Foo.unity 100) *)

(* Name the test cases and group them together *)
let machine_description_parser_suite = "test suite for the machine description parser" >:::
  [
    "test1" >:: test1;
    (* "test2" >:: test2 *)
  ]

let () =
  run_test_tt_main machine_description_parser_suite
