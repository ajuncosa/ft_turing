let run_machine description input =
  let machine = Parser.parse_machine_description description in
  print_endline (Machine.to_string machine)
(* let command =
  Core.Command.basic
    ~summary:"Wow this is a very cool Turing machine"
    Core.Command.Param.(map 
      (both
        (anon ("jsonfile" %: string))
        (anon ("input" %: string)))
      ~f:(fun (jsonfile, input) () ->
        run_machine jsonfile input))

let () =
  Command_unix.run command; *)
    (* Format.printf "Parsed to %a" Json.pp (parse_json "machine_descriptions/unary_sub.json") *)

open Cmdliner
open Cmdliner.Term.Syntax
let jsonfile =
  let doc = "the path to the JSON machine description" in
  Arg.(required & pos 0 (some string) None & info [] ~doc ~docv:"JSON_FILE")

let input =
  let doc = "input of the machine" in
  Arg.(required & pos 0 (some string) None & info [] ~doc ~docv:"INPUT")


let ft_turing_cmd =
  let doc = "wow this is a very cool Turing machine" in
  Cmd.v (Cmd.info "ft_turing" ~doc) @@
  let+ jsonfile and+ input in
  run_machine jsonfile input

let main () = Cmd.eval ft_turing_cmd
let () = if !Sys.interactive then () else exit (main ())