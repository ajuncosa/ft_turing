module Json = Yojson.Basic

let parse_machine_description (file_path : string) : Machine.machine =
  let json = try Json.from_file file_path
    with Yojson.Json_error e -> Printf.printf "Error: %s\n" e; exit 1 in
  {
    name = json |> Json.Util.member "name" |> Json.Util.to_string;
    alphabet = json |> Json.Util.member "alphabet" |> Json.Util.convert_each Json.Util.to_string;
    blank = json |> Json.Util.member "blank" |> Json.Util.to_string;
    states = json |> Json.Util.member "states" |> Json.Util.convert_each Json.Util.to_string;
    initial = json |> Json.Util.member "initial" |> Json.Util.to_string;
    finals = json |> Json.Util.member "finals" |> Json.Util.convert_each Json.Util.to_string;
    transitions = json |> Json.Util.member "transitions" |> Json.Util.to_assoc |> List.map (fun (state, transitions) -> (state, Json.Util.convert_each (fun t:Machine.transition ->
      {
        from_state = state;
        read = t |> Json.Util.member "read" |> Json.Util.to_string;
        to_state = t |> Json.Util.member "to_state" |> Json.Util.to_string;
        write = t |> Json.Util.member "write" |> Json.Util.to_string;
        action = if (t |> Json.Util.member "action" |> Json.Util.to_string) = "LEFT" then Left else Right;
      }) transitions));
  }
