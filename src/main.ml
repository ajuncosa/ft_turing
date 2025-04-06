let rec transition (machine : Machine.t) (tape : Tape.t) (state : Transition.state) = 
  let trans = Machine.find_transition machine tape state in
  print_endline ((Tape.to_string tape) ^ " " ^ (Transition.to_string trans))

let run_turing description input =
  let machine = Parser.parse_machine_description description in
  print_endline (Machine.to_string machine);
  let tape : Tape.t = {
    tape = List.init (String.length input) (fun i -> String.make 1 (String.get input i));
    head_pos = 0
  } in
  transition machine tape machine.initial

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
  run_turing jsonfile input

let main () = Cmd.eval ft_turing_cmd
let () = if !Sys.interactive then () else exit (main ())
