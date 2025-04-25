type state = string

type t =
  {
    tape : string;
    head_pos : int;
    state : state;
  }

let to_string (t : t) =
  Printf.sprintf "[ %s ]" (fst (String.fold_left (fun (acc, pos) c ->
    let ch = (String.make 1 c) in
    (acc ^ (if pos = t.head_pos then ("<" ^ ch ^ ">") else ch), pos + 1)) ("", 0) t.tape))

let rec find_transition (transition_list : Transition.t list) (machine : t) =
  match transition_list with
    | [] -> raise Not_found
    | transition :: _ when transition.read = String.sub machine.tape machine.head_pos 1 -> transition
    | _ :: tail -> find_transition tail machine
