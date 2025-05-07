module Json = Yojson.Basic

let validate_alphabet (alphabet : string list) : bool =
  if (List.for_all (fun c -> String.length c = 1)) alphabet then true
    else false

let validate_blank (blank : string) (alphabet : string list) : bool =
  let exists = List.exists (fun l -> l = blank) alphabet in
  if not exists then Printf.printf "Blank '%s' does not exist in alphabet.\n" blank;
  exists

let validate_initial_state (state : string) (states: Transition.state list) =
  let exists = List.exists (fun s -> s = state) states in
  if not exists then Printf.printf "Initial state '%s' does not exist.\n" state;
  exists

let validate_transitions (description : MachineDescription.t) : bool =
  let state_exists (state : string) =
    let exists = List.exists (fun s -> s = state) description.states in
    if not exists then Printf.printf "State '%s' does not exist.\n" state;
    exists
  in

  let letter_in_alphabet (letter: string) =
    let exists = List.exists (fun c -> c = letter) description.alphabet in
    if not exists then Printf.printf "Letter '%s' is not in the alphabet.\n" letter;
    exists
  in

  let valid_action (action: Transition.action) = match action with
    | Left | Right -> true
    | Invalid -> print_endline "Invalid action"; false
  in

  let valid_transition (transitions : (Transition.t list)) = List.for_all ( fun (t : Transition.t) -> (
    (state_exists t.to_state) && (letter_in_alphabet t.read) && (letter_in_alphabet t.write) && (valid_action t.action)
  )) transitions
  in

  if List.for_all ( fun (key, transitions) -> ((state_exists key) && (valid_transition transitions)) ) description.transitions then true
    else (print_endline "ERROR: Invalid machine description."; false)

let check_machine_description (description : MachineDescription.t) : bool =
  (validate_alphabet description.alphabet)
  && (validate_blank description.blank description.alphabet)
  && (validate_initial_state description.initial description.states)
  && (validate_transitions description)

let parse_machine_description (file_path : string) : MachineDescription.t =
  let json = try Json.from_file file_path
    with Yojson.Json_error msg -> Printf.printf "Json error while parsing machine description: %s\n" msg; exit 1
  in try
  {
    name = json |> Json.Util.member "name" |> Json.Util.to_string;
    alphabet = json |> Json.Util.member "alphabet" |> Json.Util.convert_each Json.Util.to_string;
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
        action = if (t |> Json.Util.member "action" |> Json.Util.to_string) = "LEFT" then Left
                  else if (t |> Json.Util.member "action" |> Json.Util.to_string) = "RIGHT" then Right else Invalid;
      }) transitions));
  }
  with
    | Yojson.Json_error msg -> Printf.printf "Json error while parsing machine description: %s\n" msg; exit 1
    | Json.Util.Type_error (msg, elem) -> Printf.printf "Type error while parsing machine description: %s (%s)\n" msg (Json.pretty_to_string elem); exit 1
    | Invalid_argument (msg) -> Printf.printf "Error while parsing machine description: %s\n" msg; exit 1
