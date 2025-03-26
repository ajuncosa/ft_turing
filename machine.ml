type action = Left | Right

type transition =
  {
    from_state : string;
    read : string;
    to_state : string;
    write : string;
    action : action;
  }

type machine =
  {
    name : string;
    alphabet : string list;
    blank : string;
    states : string list;
    initial : string;
    finals : string list;
    transitions : (string * transition list) list;
  }

let string_of_machine_description (m : machine) =
  let string_of_transition (t : transition) = 
    Printf.sprintf "(%s, %s) -> (%s, %s, %s)\n" t.from_state t.read t.to_state t.write (if t.action = Left then "Left" else "Right")
  in
  Printf.sprintf "**********  %s  **********\n" m.name
    ^ Printf.sprintf "Alphabet: [ %s ]\n" (List.fold_left (fun acc x -> acc ^ (if acc = "" then "" else ", ") ^ x) "" m.alphabet)
    ^ Printf.sprintf "States: [ %s ]\n" (List.fold_left (fun acc x -> acc ^ (if acc = "" then "" else ", ") ^ x) "" m.states)
    ^ Printf.sprintf "Initial: [ %s ]\n" m.initial
    ^ Printf.sprintf "Finals: [ %s ]\n" (List.fold_left (fun acc x -> acc ^ (if acc = "" then "" else ", ") ^ x) "" m.finals)
    ^ Printf.sprintf "%s" (List.fold_left (fun acc (state, transitions) ->
        List.fold_left (fun acc t -> acc ^ (string_of_transition t)) acc transitions) "" m.transitions)
