open Printf ;;
open Interp_ast ;;
open Interp_utilities ;;
open Interp_interface ;;
open Interp_inter_imp ;;

open Big_int ;;

let lit_to_string = function
 | L_unit -> "unit"
 | L_zero -> "0b0"
 | L_one -> "0b1"
 | L_true -> "true"
 | L_false -> "false"
 | L_num n -> string_of_big_int n
 | L_hex s -> "0x"^s
 | L_bin s -> "0b"^s
 | L_undef -> "undefined"
 | L_string s -> "\"" ^ s ^ "\""
;;

let id_to_string = function
  | Id_aux(Id s,_) | Id_aux(DeIid s,_) -> s
;;

let loc_to_string = function
  | Unknown -> "location unknown"
  | Int(s,_) -> s
  | Range(s,fline,fchar,tline,tchar) -> 
      if fline = tline
      then sprintf "%s:%d:%d" s fline fchar
      else sprintf "%s:%d:%d-%d:%d" s fline fchar tline tchar
;;

let collapse_leading s =
  if String.length s <= 8 then s else
  let first_bit = s.[0] in
  let templ = sprintf "%c...%c" first_bit first_bit in
  let regexp = Str.regexp "^\\(000000*\\|111111*\\)" in
  Str.replace_first regexp templ s
;;

let bitvec_to_string l = "0b" ^ collapse_leading (String.concat "" (List.map (function
  | Interp.V_lit(L_aux(L_zero, _)) -> "0"
  | Interp.V_lit(L_aux(L_one, _)) -> "1"
  | Interp.V_lit(L_aux(L_undef, _)) -> "u"
  | Interp.V_unknown -> "?"
  | v -> (Printf.printf "bitvec found a non bit %s%!\n" (Interp.string_of_value v));assert false) l))
;;

(* pp the bytes of a Bytevector as a hex value *)

type bits_lifted_homogenous = 
  | Bitslh_concrete of bit list
  | Bitslh_undef
  | Bitslh_unknown

let rec bits_lifted_homogenous_of_bit_lifteds' (bls:bit_lifted list) (acc:bits_lifted_homogenous) = 
  match (bls,acc) with
  | ([], _) -> Some acc
  | (Bitl_zero::bls', Bitslh_concrete bs) -> bits_lifted_homogenous_of_bit_lifteds' bls' (Bitslh_concrete (bs@[Bitc_zero]))
  | (Bitl_one::bls', Bitslh_concrete bs) -> bits_lifted_homogenous_of_bit_lifteds' bls' (Bitslh_concrete (bs@[Bitc_one]))
  | (Bitl_undef::bls', Bitslh_undef) ->  bits_lifted_homogenous_of_bit_lifteds' bls' Bitslh_undef
  | (Bitl_unknown::bls', Bitslh_unknown) ->  bits_lifted_homogenous_of_bit_lifteds' bls' Bitslh_unknown
  | (_,_) -> None

let bits_lifted_homogenous_of_bit_lifteds (bls:bit_lifted list) : bits_lifted_homogenous option = 
  let bls',acc0 = 
    match bls with
    | [] -> [], Bitslh_concrete [] 
    | Bitl_zero::bls' -> bls', Bitslh_concrete [Bitc_zero] 
    | Bitl_one::bls' -> bls', Bitslh_concrete [Bitc_one] 
    | Bitl_undef::bls' -> bls', Bitslh_undef
    | Bitl_unknown::bls' ->  bls', Bitslh_unknown in
  bits_lifted_homogenous_of_bit_lifteds' bls' acc0 

(*let byte_it_lifted_to_string = function
  | Bitl_zero -> "0"
  | Bitl_one ->  "1"
  | Bitl_undef -> "u"
  | Bitl_unknown -> "?"
*)

let bit_lifted_to_string = function
  | Bitl_zero -> "0"
  | Bitl_one ->  "1"
  | Bitl_undef -> "u"
  | Bitl_unknown -> "?"

let hex_int_to_string i = 
  let s = (Printf.sprintf "%x" i) in if (String.length s = 1) then "0"^s else s

let bytes_lifted_homogenous_to_string = function
  | Bitslh_concrete bs -> 
      let i = Big_int.int_of_big_int (Interp_interface.integer_of_bit_list bs) in
      hex_int_to_string i
  | Bitslh_undef -> "uu"
  | Bitslh_unknown -> "??"

let simple_bit_lifteds_to_string bls (show_length_and_start:bool) (starto: int option) =  
  let s = 
    String.concat "" (List.map bit_lifted_to_string bls) in
  let s = 
    collapse_leading s in
  let len = string_of_int (List.length bls) in 
  if show_length_and_start then 
    match starto with 
    | None ->       len ^ "b" ^s 
    | Some start -> len ^ "b" ^ "_" ^string_of_int start ^"'" ^ s
  else
    "0b"^s

(* if a multiple of 8 lifted bits and each chunk of 8 is homogenous,
print as lifted hex, otherwise print as lifted bits *)
let bit_lifteds_to_string (bls: bit_lifted list) (show_length_and_start:bool) (starto: int option) =  
  let l = List.length bls in
  if l mod 8 = 0 then  (*  if List.mem l [8;16;32;64;128] then *)
    let bytesl = List.map (fun (Byte_lifted bs) -> bs) (Interp_interface.byte_lifteds_of_bit_lifteds bls) in
    let byteslhos = List.map bits_lifted_homogenous_of_bit_lifteds bytesl in
    match maybe_all byteslhos with 
    | None -> (* print as bitvector after all *)
        simple_bit_lifteds_to_string bls show_length_and_start starto
    | Some (byteslhs: bits_lifted_homogenous list) -> 
        let s = String.concat "" (List.map bytes_lifted_homogenous_to_string byteslhs) in
        if show_length_and_start then 
          match starto with 
          | None ->       "0x" ^ s 
          | Some start -> "0x" ^ "_" ^string_of_int start ^"'" ^ s
        else
          "0x"^s
  else
    simple_bit_lifteds_to_string bls show_length_and_start starto


  

let register_value_to_string rv = 
  bit_lifteds_to_string rv.rv_bits true (Some rv.rv_start)   

let memory_value_to_string mv = 
  let bls = List.concat(List.map (fun (Byte_lifted bs) -> bs) mv)  in
  bit_lifteds_to_string bls true None

let logfile_register_value_to_string rv = 
  bit_lifteds_to_string rv.rv_bits false (Some rv.rv_start)   

let logfile_memory_value_to_string mv = 
  let bls = List.concat(List.map (fun (Byte_lifted bs) -> bs) mv)  in
  bit_lifteds_to_string bls false None

let byte_list_to_string bs =
  let bs' = List.map byte_lifted_of_byte bs in
  memory_value_to_string bs' 

let logfile_address_to_string a =
  let bs' = List.map byte_lifted_of_byte (byte_list_of_address a) in
  logfile_memory_value_to_string bs'
  

(*let bytes_to_string bytes = 
  (String.concat ""
     (List.map (fun i -> hex_int_to_string i) 
	(List.map (fun (Byte_lifted bs) -> bits_to_word8 bs) bytes)))*)


let bit_to_string = function
  | Bitc_zero -> "0"
  | Bitc_one -> "1"



let reg_value_to_string v = "deprecated"
(*  let l = List.length v.rv_bits in
  let start = string_of_int v.rv_start in
  if List.mem l [8;16;32;64;128] then
    let bytes = Interp_inter_imp.to_bytes v.rv_bits in
    "0x" ^ "_" ^ start ^ "'" ^ bytes_to_string bytes
  else (string_of_int l) ^ "_" ^ start ^ "'b" ^ 
    collapse_leading (List.fold_right (^) (List.map bit_lifted_to_string v.rv_bits) "")*)

let ifield_to_string v =
  "0b"^ collapse_leading (List.fold_right (^) (List.map bit_to_string v) "")

(*let val_to_string v = match v with
  | Bitvector(bools, inc, fst)-> 
      let l = List.length bools in
      if List.mem l [8;16;32;64;128] then 
        let Bytevector bytes = Interp_inter_imp.coerce_Bytevector_of_Bitvector v in
        "0x" ^
        "_" ^ (string_of_int (Big_int.int_of_big_int fst)) ^ "'" ^
        bytes_to_string bytes
      else
(*    (string_of_int l) ^ " bits -- 0b" ^ collapse_leading (String.concat "" (List.map (function | true -> "1" | _ -> "0") bools))*)
        (string_of_int l) ^ "_" ^ (string_of_int (Big_int.int_of_big_int fst)) ^ "'b" ^ collapse_leading (String.concat "" (List.map (function | true -> "1" | _ -> "0") bools))
  | Bytevector bytes ->
    (* let l = List.length words in *)
    (*(string_of_int l) ^ " bytes -- " ^*) 
      "0x" ^
      bytes_to_string bytes
  | Unknown0 -> "Unknown"*)

let half_byte_to_hex v = 
  match v with
    | [false;false;false;false] -> "0"
    | [false;false;false;true ] -> "1"
    | [false;false;true ;false] -> "2"
    | [false;false;true ;true ] -> "3"
    | [false;true ;false;false] -> "4"
    | [false;true ;false;true ] -> "5"
    | [false;true ;true ;false] -> "6"
    | [false;true ;true ;true ] -> "7"
    | [true ;false;false;false] -> "8"
    | [true ;false;false;true ] -> "9"
    | [true ;false;true ;false] -> "a"
    | [true ;false;true ;true ] -> "b"
    | [true ;true ;false;false] -> "c"
    | [true ;true ;false;true ] -> "d"
    | [true ;true ;true ;false] -> "e"
    | [true ;true ;true ;true ] -> "f"

let rec bit_to_hex v = 
  match v with
    | [] -> ""
    | a::b::c::d::vs -> half_byte_to_hex [a;b;c;d] ^ bit_to_hex vs
    | _ -> "bitstring given not divisible by 4"

(*let val_to_hex_string v = match v with
  | Bitvector(bools, _, _) -> "0x" ^ bit_to_hex bools
  | Bytevector words -> val_to_string v
  | Unknown0 -> "Error: cannot turn Unknown into hex"
;;*)

let reg_name_to_string = function
  | Reg0(s,_) -> s
  | Reg_slice(s,(first,second)) -> 
    s ^ "[" ^ string_of_big_int first ^ (if (eq_big_int first second) then "" else ".." ^ (string_of_big_int second)) ^ "]"
  | Reg_field(s,f,_) -> s ^ "." ^ f
  | Reg_f_slice(s,f,_,(first,second)) -> s ^ "." ^ f ^ "]" ^ string_of_big_int first ^ (if (eq_big_int first second) then "" else ".." ^ (string_of_big_int second)) ^ "]"

let dependencies_to_string dependencies = String.concat ", " (List.map reg_name_to_string dependencies)

let rec val_to_string_internal ((Interp.LMem (_,memory)) as mem) = function
 | Interp.V_boxref(n, t) -> val_to_string_internal mem (Pmap.find n memory)
 | Interp.V_lit (L_aux(l,_)) -> sprintf "%s" (lit_to_string l)
 | Interp.V_tuple l ->
     let repr = String.concat ", " (List.map (val_to_string_internal mem) l) in
     sprintf "(%s)" repr
 | Interp.V_list l ->
     let repr = String.concat "; " (List.map (val_to_string_internal mem) l) in
     sprintf "[||%s||]" repr
 | Interp.V_vector (first_index, inc, l) ->
     let last_index = add_int_big_int (if inc then List.length l - 1 else 1 - List.length l) first_index  in
     let repr =
       try bitvec_to_string l
       with Failure _ ->
         sprintf "[%s]" (String.concat "; " (List.map (val_to_string_internal mem) l)) in
     sprintf "%s [%s..%s]" repr (string_of_big_int first_index) (string_of_big_int last_index)
 | (Interp.V_vector_sparse(first_index,last_index,inc,l,default) as v) -> 
   val_to_string_internal mem (Interp_lib.fill_in_sparse v)
 | Interp.V_record(_, l) ->
     let pp (id, value) = sprintf "%s = %s" (id_to_string id) (val_to_string_internal mem value) in
     let repr = String.concat "; " (List.map  pp l) in
     sprintf "{%s}" repr
 | Interp.V_ctor (id,_, value) ->
     sprintf "%s %s" (id_to_string id) (val_to_string_internal mem value)
 | Interp.V_register _ | Interp.V_register_alias _ ->
     sprintf "reg-as-value" 
 | Interp.V_unknown -> "unknown"
 | Interp.V_track(v,_) -> (val_to_string_internal mem v)
;;

let rec top_frame_exp_state = function
  | Interp.Top -> raise (Invalid_argument "top_frame_exp")
  | Interp.Hole_frame(_, e, _, env, mem, Top)
  | Interp.Thunk_frame(e, _, env, mem, Top) -> (e,(env,mem))
  | Interp.Thunk_frame(_, _, _, _, s)
  | Interp.Hole_frame(_, _, _, _, _, s) -> top_frame_exp_state s

let tunk = Unknown, None
let ldots = E_aux(E_id (Id_aux (Id "...", Unknown)), tunk)
let rec compact_exp (E_aux (e, l)) =
  let wrap e = E_aux (e, l) in
  match e with
 | E_block (e :: _) -> compact_exp e
 | E_nondet (e :: _) -> compact_exp e
 | E_if (e, _, _) ->
     wrap(E_if(compact_exp e, ldots, E_aux(E_block [], tunk)))
 | E_for (i, e1, e2, e3, o, e4) ->
    wrap(E_for(i, compact_exp e1, compact_exp e2, compact_exp e3, o, ldots))
 | E_case (e, _) ->
     wrap(E_case(compact_exp e, []))
 | E_let (bind, _) -> wrap(E_let(bind, ldots))
 | E_app (f, args) -> wrap(E_app(f, List.map compact_exp args))
 | E_app_infix (l, op, r) -> wrap(E_app_infix(compact_exp l, op, compact_exp r))
 | E_tuple exps -> wrap(E_tuple(List.map compact_exp exps))
 | E_vector exps -> wrap(E_vector(List.map compact_exp exps))
 | E_vector_access (e1, e2) ->
     wrap(E_vector_access(compact_exp e1, compact_exp e2))
 | E_vector_subrange (e1, e2, e3) ->
     wrap(E_vector_subrange(compact_exp e1, compact_exp e2, compact_exp e3))
 | E_vector_update (e1, e2, e3) ->
     wrap(E_vector_update(compact_exp e1, compact_exp e2, compact_exp e3))
 | E_vector_update_subrange (e1, e2, e3, e4) ->
     wrap(E_vector_update_subrange(compact_exp e1, compact_exp e2, compact_exp e3, compact_exp e4))
 | E_vector_append (e1, e2) ->
     wrap(E_vector_append(compact_exp e1, compact_exp e2))
 | E_list exps -> wrap(E_list(List.map compact_exp exps))
 | E_cons (e1, e2) ->
     wrap(E_cons(compact_exp e1, compact_exp e2))
 | E_record_update (e, fexps) ->
     wrap(E_record_update (compact_exp e, fexps))
 | E_field (e, id) ->
     wrap(E_field(compact_exp e, id))
 | E_assign (lexp, e) -> wrap(E_assign(lexp, compact_exp e))
 | E_block [] | E_nondet [] | E_cast (_, _) | E_internal_cast (_, _)
 | E_id _|E_lit _|E_vector_indexed (_, _)|E_record _|E_internal_exp _ | E_exit _->
     wrap e

(* extract, compact and reverse expressions on the stack;
 * the top of the stack is the head of the returned list. *)
let rec compact_stack ?(acc=[]) = function
  | Interp.Top -> acc
  | Interp.Hole_frame(_,e,_,env,mem,s)
  | Interp.Thunk_frame(e,_,env,mem,s) -> compact_stack ~acc:(((compact_exp e),(env,mem)) :: acc) s
;;  

let sub_to_string = function None -> "" | Some (x, y) -> sprintf " (%s, %s)"
  (string_of_big_int x) (string_of_big_int y)
;;

let rec format_events = function
  | [] -> 
    "     Done\n"
  | [E_error s] -> 
    "     Failed with message : " ^ s ^ "\n"
  | (E_error s)::events ->
    "     Failed with message : " ^ s ^ " but continued on erroneously\n"
  | (E_read_mem(read_kind, (Address_lifted location), length, tracking))::events ->
    "     Read_mem at " ^ (memory_value_to_string location) ^ " for " ^ (string_of_big_int length) ^ " bytes \n" ^
    (format_events events)
  | (E_write_mem(write_kind,(Address_lifted location), length, tracking, value, v_tracking))::events ->
    "     Write_mem at " ^ (memory_value_to_string location) ^ " writing " ^ (memory_value_to_string value) ^ " across " ^ (string_of_big_int length) ^ " bytes\n" ^
    (format_events events)
  | ((E_barrier b_kind)::events) ->
    "     Memory_barrier occurred\n" ^ 
    (format_events events)
  | (E_read_reg reg_name)::events ->
    "     Read_reg of " ^ (reg_name_to_string reg_name) ^ "\n" ^
    (format_events events)
  | (E_write_reg(reg_name, value))::events ->
    "     Write_reg of " ^ (reg_name_to_string reg_name) ^ " writing " ^ (register_value_to_string value) ^ "\n" ^
    (format_events events)
;;

(* ANSI/VT100 colors *)
type ppmode = 
  | Interp_latex
  | Interp_ascii
  | Interp_html
let ppmode = ref Interp_ascii
let set_interp_ppmode ppm = ppmode := ppm 

let disable_color = ref false
let color bright code s =
  if !disable_color then s
  else sprintf "\x1b[%s3%dm%s\x1b[m" (if bright then "1;" else "") code s
let red s = 
  match !ppmode with 
  | Interp_html -> "<fontcolor='red'>"^ s ^"</font>"
  | Interp_latex -> "\\myred{" ^ s ^"}"
  | Interp_ascii -> color true 1 s 
let green = color false 2
let yellow = color true 3
let blue = color true 4
let grey = color false 7

let exp_to_string env e = Pretty_interp.pp_exp env red e

let get_loc (E_aux(_, (l, (_ : tannot)))) = loc_to_string l
let print_exp printer env e =
  printer ((get_loc e) ^ ": " ^ (Pretty_interp.pp_exp env red e) ^ "\n")

let instruction_state_to_string stack =
  let env = () in
  List.fold_right (fun (e,(env,mem)) es -> (exp_to_string env e) ^ "\n" ^ es) (compact_stack stack) ""

let top_instruction_state_to_string stack = let (exp,(env,_)) = top_frame_exp_state stack in exp_to_string env exp

let rec option_map f xs = 
  match xs with 
  | [] -> [] 
  | x::xs -> 
      ( match f x with 
      | None -> option_map f xs 
      | Some x -> x :: (option_map f xs) ) 

let local_variables_to_string stack = 
  let (_,(env,mem)) = top_frame_exp_state stack in 
  match env with
    | LEnv(_,env) -> 
      String.concat ", " (option_map (fun (id,value)-> 
	match id with
	  | Id_aux(Id "0",_) -> None (*Let's not print out the context hole again*)
	  | _ -> Some (id_to_string id ^ "=" ^ val_to_string_internal mem value)) env)

let instr_parm_to_string (name, typ, value) = 
  name ^"="^
  match typ with
    | Other -> "Unrepresentable external value"
    | _ -> let intern_v = (Interp_inter_imp.intern_ifield_value value) in
	      match Interp_lib.to_num Interp_lib.Unsigned intern_v with
		| V_lit (L_aux(L_num n, _)) -> string_of_big_int n
		| _ -> ifield_to_string value

let rec instr_parms_to_string ps = 
  match ps with
    | [] -> ""
    | [p] -> instr_parm_to_string p
    | p::ps -> instr_parm_to_string p ^ " " ^ instr_parms_to_string ps

let pad n s = if String.length s < n then s ^ String.make (n-String.length s) ' ' else s

let instruction_to_string (name, parms, base_effects) = 
  ((*pad 5*) (String.lowercase name)) ^ " " ^ instr_parms_to_string parms 

let print_backtrace_compact printer stack = List.iter (fun (e,(env,mem)) -> print_exp printer env e) (compact_stack stack)
let print_continuation printer stack = let (e,(env,mem)) = top_frame_exp_state stack in print_exp printer env e
let print_instruction printer instr = printer (instruction_to_string instr)
