open OUnit2

let test1 test_ctxt =
    let test_machine : Machine.t = 
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
                action = Transition.Right;
              };
              {
                from_state = "scanright";
                read = "1";
                to_state = "scanright";
                write = "1";
                action = Transition.Right;
              };
              {
                from_state = "scanright";
                read = "-";
                to_state = "scanright";
                write = "-";
                action = Transition.Right;
              };
              {
                from_state = "scanright";
                read = "=";
                to_state = "eraseone";
                write = ".";
                action = Transition.Left;
              }
             ]);
            "eraseone", [
              {
                from_state = "eraseone";
                read = "1";
                to_state = "subone";
                write = "=";
                action = Transition.Left;
              };
              {
                from_state = "eraseone";
                read = "-";
                to_state = "HALT";
                write = ".";
                action = Transition.Left;
              }
            ];
            "subone", [
              {
                from_state = "subone";
                read = "1";
                to_state = "subone";
                write = "1";
                action = Transition.Left;
              };
              {
                from_state = "subone";
                read = "-";
                to_state = "skip";
                write = "-";
                action = Transition.Left;
              }
            ];
            "skip", [
              {
                from_state = "skip";
                read = ".";
                to_state = "skip";
                write = ".";
                action = Transition.Left;
              };
              {
                from_state = "skip";
                read = "1";
                to_state = "scanright";
                write = ".";
                action = Transition.Right;
              }
            ]
          ]
      }
    in let parsed_machine = Parser.parse_machine_description "machine_descriptions/unary_sub.json"
    in
    (* assert_equal test_machine parsed_machine ~printer:Machine.to_string; *)
    assert_equal test_machine.name parsed_machine.name ~printer:Fun.id;
    assert_equal (List.length test_machine.alphabet) (List.length parsed_machine.alphabet) ~printer:string_of_int;
    List.iter2 (assert_equal ~printer:Fun.id) test_machine.alphabet parsed_machine.alphabet;
    assert_equal test_machine.blank parsed_machine.blank ~printer:Fun.id;
    assert_equal (List.length test_machine.states) (List.length parsed_machine.states) ~printer:string_of_int;
    List.iter2 (assert_equal ~printer:Fun.id) test_machine.states parsed_machine.states;
    assert_equal test_machine.initial parsed_machine.initial ~printer:Fun.id;
    assert_equal (List.length test_machine.finals) (List.length parsed_machine.finals) ~printer:string_of_int;
    List.iter2 (assert_equal ~printer:Fun.id) test_machine.finals parsed_machine.finals;
    assert_equal (List.length test_machine.transitions) (List.length parsed_machine.transitions) ~printer:string_of_int;
    List.iter2 (fun (state1, transitions1) (state2, transitions2) ->
      assert_equal state1 state2 ~printer:Fun.id;
      assert_equal (List.length transitions1) (List.length transitions2) ~printer:string_of_int;
      List.iter2 (fun (t1 : Transition.t) (t2 : Transition.t) ->
      assert_equal t1.from_state t2.from_state ~printer:Fun.id;
      assert_equal t1.read t2.read ~printer:Fun.id;
      assert_equal t1.to_state t2.to_state ~printer:Fun.id;
      assert_equal t1.write t2.write ~printer:Fun.id;
      assert_equal t1.action t2.action ~printer:(fun action -> if action = Transition.Left then "Left" else "Right")
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
