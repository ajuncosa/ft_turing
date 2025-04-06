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

let find_transition (machine : t) (tape : Tape.t) (state : Transition.state) =
  let rec aux (transition_list : Transition.t list) =
    match transition_list with
      | [] -> raise Not_found
      | trans :: _ when trans.read = List.nth tape.tape tape.head_pos -> trans
      | _ :: tail -> aux tail
  in aux (List.assoc state machine.transitions)
