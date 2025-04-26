type t =
  {
    name : string;
    alphabet : string list;
    blank : string;
    states : Transition.state list;
    initial : string;
    finals : string list;
    transitions : (string * Transition.t list) list;
  }

let to_string (m : t) =
  "******************************************\n"
    (* el único propósito de que esta línea sea tan confusa es centrar el nombre para satisfacer mi toc *)
    ^ Printf.sprintf "%*s%*s\n" (21 + String.length m.name / 2) m.name (21 + String.length m.name / 2) ""
    ^ "******************************************\n"
    ^ Printf.sprintf "Alphabet: [ %s ]\n" (List.fold_left (fun acc x -> acc ^ (if acc = "" then "" else ", ") ^ x) "" m.alphabet)
    ^ Printf.sprintf "States: [ %s ]\n" (List.fold_left (fun acc x -> acc ^ (if acc = "" then "" else ", ") ^ x) "" m.states)
    ^ Printf.sprintf "Initial: [ %s ]\n" m.initial
    ^ Printf.sprintf "Finals: [ %s ]\n" (List.fold_left (fun acc x -> acc ^ (if acc = "" then "" else ", ") ^ x) "" m.finals)
    ^ Printf.sprintf "%s" (List.fold_left (fun acc (state, transitions) ->
        List.fold_left (fun acc t -> acc ^ (Transition.to_string t) ^ "\n") acc transitions) "" m.transitions)
    ^ "******************************************"
