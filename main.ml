let run_machine description input =
  let machine = Parser.parse_machine_description description in
  print_endline (Machine.to_string machine)

let command =
  Core.Command.basic
    ~summary:"Wow this is a very cool Turing machine"
    Core.Command.Param.(map 
      (both
        (anon ("jsonfile" %: string))
        (anon ("input" %: string)))
      ~f:(fun (jsonfile, input) () ->
        run_machine jsonfile input))

let () =
  Command_unix.run command;
    (* Format.printf "Parsed to %a" Json.pp (parse_json "machine_descriptions/unary_sub.json") *)

