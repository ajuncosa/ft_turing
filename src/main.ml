(* let rec transition (machine : MachineDescription.t) (tape : Tape.t) (state : Transition.state) = 
  let trans = MachineDescription.find_transition machine tape state in
  print_endline ((Tape.to_string tape) ^ " " ^ (Transition.to_string trans))

let run_turing description input =
  let machine = Parser.parse_machine_description description in
  print_endline (MachineDescription.to_string machine);
  let tape : Tape.t = {
    tape = List.init (String.length input) (fun i -> String.make 1 (String.get input i));
    head_pos = 0
  } in
  transition machine tape machine.initial *)

let execute_transition (machine : Machine.t) (transition : Transition.t) =
  let (machine : Machine.t) = {
    tape = List.mapi (fun idx letter -> if idx = machine.head_pos then transition.write else letter) machine.tape;
    (* TODO: check that head_pos is not out of bounds *)
    head_pos = if transition.action = Left then (machine.head_pos - 1) else (machine.head_pos + 1);
    state = transition.to_state;
  } in
  machine

let rec run (machine : Machine.t) (description : MachineDescription.t) =
  let transition = Machine.find_transition (List.assoc machine.state description.transitions) machine in
  print_endline ((Machine.to_string machine) ^ " " ^ (Transition.to_string transition));
  let updated_machine = execute_transition machine transition in
  if (List.exists (fun final -> final = updated_machine.state) description.finals) then ()
  else run updated_machine description

let start_turing json input =
  let description = Parser.parse_machine_description json in
  print_endline (MachineDescription.to_string description);
  let (machine : Machine.t) = {
    tape = input;
    head_pos = 0;
    state = description.initial;
  } in
  run machine description

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
