type state = string

type t =
  {
    tape : string list;
    head_pos : int;
    state : state;
  }

let to_string (t : t) =
  Printf.sprintf "[ %s ]" (fst (List.fold_left (fun (acc, pos) c -> (acc ^ (if pos = t.head_pos then ("<" ^ c ^ ">") else c), pos + 1)) ("", 0) t.tape))

let rec find_transition (transition_list : Transition.t list) (machine : t) =
  match transition_list with
    | [] -> raise Not_found
    | transition :: _ when transition.read = List.nth machine.tape machine.head_pos -> transition
    | _ :: tail -> find_transition tail machine
