type t =
  {
    tape : string list;
    head_pos : int;
  }

let to_string (t : t) =
  Printf.sprintf "[ %s ]" (fst (List.fold_left (fun (acc, pos) c -> (acc ^ (if pos = t.head_pos then ("<" ^ c ^ ">") else c), pos + 1)) ("", 0) t.tape))
