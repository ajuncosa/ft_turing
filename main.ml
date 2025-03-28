let jsonfile_param =
  let open Core.Command.Param in
  anon ("jsonfile" %: string)

let command =
  Core.Command.basic
    ~summary:"Wow this is a very cool Turing machine"
    ~readme:(fun () -> "More detailed information")
    (Core.Command.Param.map jsonfile_param ~f:(fun filename () ->
          print_endline ("FILE:" ^ filename)))

let () =
  Command_unix.run command;
  let machine = Parser.parse_machine_description "machine_descriptions/unary_sub.json" in
  print_endline (Machine.to_string machine)
    (* Format.printf "Parsed to %a" Json.pp (parse_json "machine_descriptions/unary_sub.json") *)

