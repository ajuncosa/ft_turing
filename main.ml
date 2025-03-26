
let print_machine_description (m : Machine.machine) =
  print_endline (Machine.string_of_machine_description m)

let () =
  let machine = Parser.parse_machine_description "machine_descriptions/unary_sub.json" in
  print_machine_description machine
    (* Format.printf "Parsed to %a" Json.pp (parse_json "machine_descriptions/unary_sub.json") *)