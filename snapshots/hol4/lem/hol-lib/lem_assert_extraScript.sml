(*Generated by Lem from assert_extra.lem.*)
open HolKernel Parse boolLib bossLib;
open stringTheory lemTheory;

val _ = numLib.prefer_num();



val _ = new_theory "lem_assert_extra"


(*open import {ocaml} `Xstring`*)
(*open import {hol} `stringTheory` `lemTheory`*)
(*open import {coq} `Coq.Strings.Ascii` `Coq.Strings.String`*)
(*open import {isabelle} `$LIB_DIR/Lem`*)

(* ------------------------------------ *)
(* failing with a proper error message  *)
(* ------------------------------------ *)

(*val failwith: forall 'a. string -> 'a*)

(* ------------------------------------ *)
(* failing without an error message     *)
(* ------------------------------------ *)

(*val fail : forall 'a. 'a*)
val _ = Define `
 ((fail:'a)=  (failwith "fail"))`;


(* ------------------------------------- *)
(* assertions                            *)
(* ------------------------------------- *)

(*val ensure : bool -> string -> unit*)
val _ = Define `
 ((ensure:bool -> string -> unit) test msg=  
 (if test then
    () 
  else
    failwith msg))`;


val _ = export_theory()

