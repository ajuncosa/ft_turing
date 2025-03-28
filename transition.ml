type action = Left | Right

type t =
  {
    from_state : string;
    read : string;
    to_state : string;
    write : string;
    action : action;
  }

let to_string (t : t) = 
  Printf.sprintf "(%s, %s) -> (%s, %s, %s)\n" t.from_state t.read t.to_state t.write (if t.action = Left then "Left" else "Right")
