type t =
  {
    tape : string list;
    head_pos : int;
    state : Transition.state;
  }

let max_transitions = 5000

let to_string (t : t) =
  Printf.sprintf "[ %s ]" (fst (List.fold_left (fun (acc, pos) c ->
    (acc ^ (if pos = t.head_pos then ("<" ^ c ^ ">") else c), pos + 1)) ("", 0) t.tape))

let execute_transition (machine : t) (transition : Transition.t) (blank : string) : t =
  let (m : t) = {
    tape = List.mapi (fun idx letter -> if idx = machine.head_pos then transition.write else letter) machine.tape;
    head_pos = if transition.action = Left then (machine.head_pos - 1) else (machine.head_pos + 1);
    state = transition.to_state;
  }
  in match m.head_pos with
    | h when h < 0 -> { m with tape = blank :: m.tape; head_pos = 0 }
    | h when h >= List.length m.tape -> { m with tape = m.tape @ [blank] }
    | _ -> m

let rec run (machine : t) (description : MachineDescription.t) (n_transitions : int) =
  if n_transitions > max_transitions then failwith (Printf.sprintf "Max number of transitions reached (%d): the input provided for the specified machine description may have caused an infinite loop." max_transitions) else
  let transition = try
    Transition.find (List.assoc machine.state description.transitions) (List.nth machine.tape machine.head_pos)
  with
    | Not_found -> failwith ("Failed to find a suitable transition from state '" ^ machine.state ^ "' for current character '" ^ (List.nth machine.tape machine.head_pos) ^ "'")
  in print_endline ((to_string machine) ^ " " ^ (Transition.to_string transition));
  let updated_machine = execute_transition machine transition description.blank in
  if (List.exists (fun final -> final = updated_machine.state) description.finals)
    then print_endline (to_string updated_machine)
  else run updated_machine description (n_transitions + 1)
