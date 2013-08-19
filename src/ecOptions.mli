(* -------------------------------------------------------------------- *)
type command = [
| `Compile of cmp_option
| `Cli     of cli_option
| `Config
]

and options = {
  o_options : glb_options;
  o_command : command;
}

and cmp_option = {
  cmpo_input    : string;
  cmpo_provers  : prv_options;
  cmpo_loader   : ldr_options;
}

and cli_option = {
  clio_emacs   : bool;
  clio_provers : prv_options;
  clio_loader  : ldr_options;
}

and prv_options = {
  prvo_maxjobs  : int;
  prvo_provers  : string list option;
  pvro_checkall : bool;
}

and ldr_options = {
  ldro_idirs : string list;
  ldro_boot  : bool;
}

and glb_options = {
  o_why3 : string option;
}

(* -------------------------------------------------------------------- *)
val parse : string array -> options
