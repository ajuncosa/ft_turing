module Json = Yojson.Basic

let validate_input (input : string) (description: MachineDescription.t) =
  let letter_in_alphabet letter = List.exists (fun c -> c = letter) description.alphabet in
  if not (String.for_all (fun l -> (letter_in_alphabet (String.make 1 l))) input)
  then failwith "Letter in input is not in alphabet."

let validate_alphabet (alphabet : string list) =
  if not (List.for_all (fun c -> String.length c = 1) alphabet)
  then failwith "All letters in the alphabet must be strings of length 1."

let validate_blank (blank : string) (alphabet : string list) =
  if not (List.exists (fun l -> l = blank) alphabet)
  then failwith (Printf.sprintf "Blank '%s' does not exist in alphabet." blank)

let validate_initial_state (state : string) (states: Transition.state list) =
  if not (List.exists (fun s -> s = state) states)
  then failwith (Printf.sprintf "Initial state '%s' does not exist." state)

let validate_transitions (description : MachineDescription.t) =
  let state_exists (state : string) =
    if not (List.exists (fun s -> s = state) description.states)
    then failwith (Printf.sprintf "State '%s' does not exist." state)
  in let letter_in_alphabet (letter : string) =
    if not (List.exists (fun c -> c = letter) description.alphabet)
    then failwith (Printf.sprintf "Letter '%s' is not in the alphabet." letter)
  in let valid_action (action : Transition.action) = match action with
    | Left | Right -> ()
    | Invalid -> failwith (Printf.sprintf "Invalid action.")
in List.iter (fun (key, transition_list) -> (
      state_exists key;
      List.iter (fun (t : Transition.t) -> (
        state_exists t.to_state;
        letter_in_alphabet t.read;
        letter_in_alphabet t.write;
        valid_action t.action
      )) transition_list
  )) description.transitions

let validate_machine_description (description : MachineDescription.t) =
  try
    validate_alphabet description.alphabet;
    validate_blank description.blank description.alphabet;
    validate_initial_state description.initial description.states;
    validate_transitions description
  with
  | Failure e -> failwith ("Invalid machine description: " ^ e)

let parse_machine_description (file_path : string) : MachineDescription.t =
  try
    let json = Json.from_file file_path in
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
                    else if (t |> Json.Util.member "action" |> Json.Util.to_string) = "RIGHT" then Right
                    else Invalid;
        }) transitions));
    }
  with
    | Yojson.Json_error msg -> failwith (Printf.sprintf "Json error while parsing machine description: %s\n" msg)
    | Json.Util.Type_error (msg, elem) -> failwith (Printf.sprintf "Type error while parsing machine description: %s (%s)\n" msg (Json.pretty_to_string elem))
    | Invalid_argument (msg) -> failwith (Printf.sprintf "Error while parsing machine description: %s\n" msg)
