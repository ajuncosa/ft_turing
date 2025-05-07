type t =
  {
    tape : string list;
    head_pos : int;
    state : Transition.state;
  }

let to_string (t : t) =
  Printf.sprintf "[ %s ]" (fst (List.fold_left (fun (acc, pos) c ->
    (acc ^ (if pos = t.head_pos then ("<" ^ c ^ ">") else c), pos + 1)) ("", 0) t.tape))

let execute_transition (machine : t) (transition : Transition.t) : t =
  let (m : t) = {
    tape = List.mapi (fun idx letter -> if idx = machine.head_pos then transition.write else letter) machine.tape;
    (* TODO: check that head_pos is not out of bounds *)
    head_pos = if transition.action = Left then (machine.head_pos - 1) else (machine.head_pos + 1);
    state = transition.to_state;
  } in m

let rec run (machine : t) (description : MachineDescription.t) =
  if (machine.head_pos < 0) || (machine.head_pos >= (List.length machine.tape)) then failwith "Machine out of tape";
  let transition = Transition.find (List.assoc machine.state description.transitions) (List.nth machine.tape machine.head_pos) in
  print_endline ((to_string machine) ^ " " ^ (Transition.to_string transition));
  let updated_machine = execute_transition machine transition in
  if (List.exists (fun final -> final = updated_machine.state) description.finals) then ()
  else run updated_machine description
