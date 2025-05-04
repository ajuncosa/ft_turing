module Json = Yojson.Basic

let validate_alphabet (alphabet : string list) : string list =
  if List.for_all (fun c -> String.length c == 1) alphabet = false
    then invalid_arg "All items in the alphabet must be strings of length 1";
  alphabet

let parse_machine_description (file_path : string) : MachineDescription.t =
  let json = try Json.from_file file_path
    with Yojson.Json_error msg -> Printf.printf "Json error while parsing machine description: %s\n" msg; exit 1
  in try
  {
    name = json |> Json.Util.member "name" |> Json.Util.to_string;
    alphabet = json |> Json.Util.member "alphabet" |> Json.Util.convert_each Json.Util.to_string |> validate_alphabet;
    blank = json |> Json.Util.member "blank" |> Json.Util.to_string;
    states = json |> Json.Util.member "states" |> Json.Util.convert_each Json.Util.to_string;
    initial = json |> Json.Util.member "initial" |> Json.Util.to_string;
    finals = json |> Json.Util.member "finals" |> Json.Util.convert_each Json.Util.to_string;
    transitions = json |> Json.Util.member "transitions" |> Json.Util.to_assoc |> List.map (fun (state, transitions) -> (state, Json.Util.convert_each (fun t:Transition.t ->
      {
        from_state = state;
        read = t |> Json.Util.member "read" |> Json.Util.to_string;
        to_state = t |> Json.Util.member "to_state" |> Json.Util.to_string;
        write = t |> Json.Util.member "write" |> Json.Util.to_string;
        action = if (t |> Json.Util.member "action" |> Json.Util.to_string) = "LEFT" then Left else Right;
      }) transitions));
  }
  with
    | Yojson.Json_error msg -> Printf.printf "Json error while parsing machine description: %s\n" msg; exit 1
    | Json.Util.Type_error (msg, elem) -> Printf.printf "Type error while parsing machine description: %s (%s)\n" msg (Json.pretty_to_string elem); exit 1
    | Invalid_argument (msg) -> Printf.printf "Error while parsing machine description: %s\n" msg; exit 1
