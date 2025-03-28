type t =
  {
    name : string;
    alphabet : string list;
    blank : string;
    states : string list;
    initial : string;
    finals : string list;
    transitions : (string * Transition.t list) list;
  }

let to_string (m : t) =
  Printf.sprintf "**********  %s  **********\n" m.name
    ^ Printf.sprintf "Alphabet: [ %s ]\n" (List.fold_left (fun acc x -> acc ^ (if acc = "" then "" else ", ") ^ x) "" m.alphabet)
    ^ Printf.sprintf "States: [ %s ]\n" (List.fold_left (fun acc x -> acc ^ (if acc = "" then "" else ", ") ^ x) "" m.states)
    ^ Printf.sprintf "Initial: [ %s ]\n" m.initial
    ^ Printf.sprintf "Finals: [ %s ]\n" (List.fold_left (fun acc x -> acc ^ (if acc = "" then "" else ", ") ^ x) "" m.finals)
    ^ Printf.sprintf "%s" (List.fold_left (fun acc (state, transitions) ->
        List.fold_left (fun acc t -> acc ^ (Transition.to_string t)) acc transitions) "" m.transitions)
