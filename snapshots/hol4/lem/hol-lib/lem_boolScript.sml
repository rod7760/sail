(*Generated by Lem from bool.lem.*)
open HolKernel Parse boolLib bossLib;
val _ = numLib.prefer_num();



val _ = new_theory "lem_bool"

 

(* The type bool is hard-coded, so are true and false *)

(* ----------------------- *)
(* not                     *)
(* ----------------------- *)

(*val not : bool -> bool*)
(*let not b=  match b with
  | true -> false
  | false -> true
end*)

(* ----------------------- *)
(* and                     *)
(* ----------------------- *)

(*val && [and] : bool -> bool -> bool*)
(*let && b1 b2=  match (b1, b2) with
  | (true, true) -> true
  | _ -> false
end*)


(* ----------------------- *)
(* or                      *)
(* ----------------------- *)

(*val || [or] : bool -> bool -> bool*)
(*let || b1 b2=  match (b1, b2) with
  | (false, false) -> false
  | _ -> true
end*)


(* ----------------------- *)
(* implication             *)
(* ----------------------- *)

(*val --> [imp] : bool -> bool -> bool*)
(*let --> b1 b2=  match (b1, b2) with
  | (true, false) -> false
  | _ -> true
end*)


(* ----------------------- *)
(* equivalence             *)
(* ----------------------- *)

(*val <-> [equiv] : bool -> bool -> bool*)
(*let <-> b1 b2=  match (b1, b2) with
  | (true, true) -> true
  | (false, false) -> true
  | _ -> false
end*)


(* ----------------------- *)
(* xor                     *)
(* ----------------------- *)

(*val xor : bool -> bool -> bool*)

val _ = export_theory()

