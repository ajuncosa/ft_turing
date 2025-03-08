type action = Left | Right

type transition =
  {
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

module Json = Yojson.Basic

let parse_machine_description file_path =
  let json = try Json.from_file file_path
    with Yojson.Json_error e -> Printf.printf "Error: %s\n" e; exit 1 in
  {
    name = json |> Json.Util.member "name" |> Json.Util.to_string;
    alphabet = json |> Json.Util.member "alphabet" |> Json.Util.convert_each Json.Util.to_string;
    blank = json |> Json.Util.member "blank" |> Json.Util.to_string;
    states = json |> Json.Util.member "states" |> Json.Util.convert_each Json.Util.to_string;
    initial = json |> Json.Util.member "initial" |> Json.Util.to_string;
    finals = json |> Json.Util.member "finals" |> Json.Util.convert_each Json.Util.to_string;
    transitions = json |> Json.Util.member "transitions" |> Json.Util.to_assoc |> List.map (fun (state, transitions) -> (state, Json.Util.convert_each (fun t ->
      {
        read = t |> Json.Util.member "read" |> Json.Util.to_string;
        to_state = t |> Json.Util.member "to_state" |> Json.Util.to_string;
        write = t |> Json.Util.member "write" |> Json.Util.to_string;
        action = if (t |> Json.Util.member "action" |> Json.Util.to_string) = "LEFT" then Left else Right;
      }) transitions));
  }

let print_machine_description m =
  let print_transition t =
    Printf.printf "  read=%s, to_state=%s, write=%s, action=%s\n" t.read t.to_state t.write (if t.action = Left then "Left" else "Right")
  in
  print_endline ("name: " ^ m.name);
  print_endline ("alphabet: " ^ (List.fold_left (fun acc x -> acc ^ " " ^ x) "" m.alphabet));
  print_endline ("blank: " ^ m.blank);
  print_endline ("states: " ^ (List.fold_left (fun acc x -> acc ^ " " ^ x) "" m.states));
  print_endline ("initial: " ^ m.initial);
  print_endline ("finals: " ^ (List.fold_left (fun acc x -> acc ^ " " ^ x) "" m.finals));
  print_endline "transitions: ";
  List.iter (fun (state, transitions) -> print_endline ("  " ^ state ^ ": "); List.iter (fun t -> print_transition t) transitions) m.transitions

let () =
  let machine = parse_machine_description "machine_descriptions/unary_sub.json" in
  print_machine_description machine
    (* Format.printf "Parsed to %a" Json.pp (parse_json "machine_descriptions/unary_sub.json") *)