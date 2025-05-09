let start_turing json input =
  try
    let description = Parser.parse_machine_description json in
    print_endline (MachineDescription.to_string description);
    let valid_description = Parser.validate_machine_description description in
    let valid_input = Parser.validate_input input description in
    if (valid_description = false || valid_input = false) then ()
    else
      let (machine : Machine.t) = {
        tape = String.fold_right (fun c acc -> (String.make 1 c) :: acc) input [];
        head_pos = 0;
        state = description.initial;
      } in
    Machine.run machine description
  with Failure e -> print_endline e; exit 1

open Cmdliner
open Cmdliner.Term.Syntax
let jsonfile =
  let doc = "the path to the JSON machine description" in
  Arg.(required & pos 0 (some string) None & info [] ~doc ~docv:"JSON_FILE")

let input =
  let doc = "input of the machine" in
  Arg.(required & pos 1 (some string) None & info [] ~doc ~docv:"INPUT")

let ft_turing_cmd =
  let doc = "wow this is a very cool Turing machine" in
  Cmd.v (Cmd.info "ft_turing" ~doc ~exits:[]) @@
  let+ jsonfile and+ input in
  start_turing jsonfile input

let main () = Cmd.eval ft_turing_cmd
let () = if !Sys.interactive then () else exit (main ())
