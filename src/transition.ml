type action = Left | Right | Invalid

type state = string

type t =
  {
    from_state : state;
    read : string;
    to_state : state;
    write : string;
    action : action;
  }

let to_string (t : t) =
  Printf.sprintf "(%s, %s) -> (%s, %s, %s)" t.from_state t.read t.to_state t.write (if t.action = Left then "LEFT" else "RIGHT")

let rec find (transition_list : t list) (current_letter : string) =
  match transition_list with
    | [] -> raise Not_found
    | transition :: _ when transition.read = current_letter -> transition
    | _ :: tail -> find tail current_letter
