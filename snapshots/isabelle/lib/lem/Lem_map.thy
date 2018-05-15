chapter \<open>Generated by Lem from map.lem.\<close>

theory "Lem_map" 

imports 
 	 Main
	 "Lem_bool" 
	 "Lem_basic_classes" 
	 "Lem_function" 
	 "Lem_maybe" 
	 "Lem_list" 
	 "Lem_tuple" 
	 "Lem_set" 
	 "Lem_num" 

begin 



(*open import Bool Basic_classes Function Maybe List Tuple Set Num*)
(*open import {hol} `finite_mapTheory` `finite_mapLib`*)

(*type map 'k 'v*)



(* -------------------------------------------------------------------------- *)
(* Map equality.                                                              *)
(* -------------------------------------------------------------------------- *)

(*val mapEqual : forall 'k 'v. Eq 'k, Eq 'v => map 'k 'v -> map 'k 'v -> bool*)
(*val mapEqualBy : forall 'k 'v. ('k -> 'k -> bool) -> ('v -> 'v -> bool) -> map 'k 'v -> map 'k 'v -> bool*)


(* -------------------------------------------------------------------------- *)
(* Map type class                                                             *)
(* -------------------------------------------------------------------------- *)

(*class ( MapKeyType 'a )
  val {ocaml;coq} mapKeyCompare : 'a -> 'a -> ordering
end*)

(* -------------------------------------------------------------------------- *)
(* Empty maps                                                                 *)
(* -------------------------------------------------------------------------- *)

(*val empty : forall 'k 'v. MapKeyType 'k => map 'k 'v*)
(*val emptyBy : forall 'k 'v. ('k -> 'k -> ordering) -> map 'k 'v*)


(* -------------------------------------------------------------------------- *)
(* Insertion                                                                  *)
(* -------------------------------------------------------------------------- *)

(*val insert    : forall 'k 'v. MapKeyType 'k => 'k -> 'v -> map 'k 'v -> map 'k 'v*)


(* -------------------------------------------------------------------------- *)
(* Singleton                                                                  *)
(* -------------------------------------------------------------------------- *)

(*val singleton : forall 'k 'v. MapKeyType 'k => 'k -> 'v -> map 'k 'v*)



(* -------------------------------------------------------------------------- *)
(* Emptyness check                                                            *)
(* -------------------------------------------------------------------------- *)

(*val null  : forall 'k 'v. MapKeyType 'k, Eq 'k, Eq 'v => map 'k 'v -> bool*)


(* -------------------------------------------------------------------------- *)
(* lookup                                                                     *)
(* -------------------------------------------------------------------------- *)

(*val lookupBy : forall 'k 'v. ('k -> 'k -> ordering) -> 'k -> map 'k 'v -> maybe 'v*)

(*val lookup          : forall 'k 'v. MapKeyType 'k => 'k -> map 'k 'v -> maybe 'v*)

(* -------------------------------------------------------------------------- *)
(* findWithDefault                                                            *)
(* -------------------------------------------------------------------------- *)

(*val findWithDefault : forall 'k 'v. MapKeyType 'k => 'k -> 'v -> map 'k 'v -> 'v*)

(* -------------------------------------------------------------------------- *)
(* from lists                                                                 *)
(* -------------------------------------------------------------------------- *)

(*val fromList  : forall 'k 'v. MapKeyType 'k => list ('k * 'v) -> map 'k 'v*)
(*let fromList l=  foldl (fun m (k,v) -> insert k v m) empty l*)


(* -------------------------------------------------------------------------- *)
(* to sets / domain / range                                                   *)
(* -------------------------------------------------------------------------- *)

(*val toSet : forall 'k 'v. MapKeyType 'k, SetType 'k, SetType 'v => map 'k 'v -> set ('k * 'v)*) 
(*val toSetBy : forall 'k 'v. (('k * 'v) -> ('k * 'v) -> ordering) -> map 'k 'v -> set ('k * 'v)*)


(*val domainBy : forall 'k 'v. ('k -> 'k -> ordering) -> map 'k 'v -> set 'k*)
(*val domain : forall 'k 'v. MapKeyType 'k, SetType 'k => map 'k 'v -> set 'k*)


(*val range : forall 'k 'v. MapKeyType 'k, SetType 'v => map 'k 'v -> set 'v*)
(*val rangeBy : forall 'k 'v. ('v -> 'v -> ordering) -> map 'k 'v -> set 'v*)


(* -------------------------------------------------------------------------- *)
(* member                                                                     *)
(* -------------------------------------------------------------------------- *)

(*val member          : forall 'k 'v. MapKeyType 'k, SetType 'k, Eq 'k => 'k -> map 'k 'v -> bool*)

(*val notMember       : forall 'k 'v. MapKeyType 'k, SetType 'k, Eq 'k => 'k -> map 'k 'v -> bool*)

(* -------------------------------------------------------------------------- *)
(* Quantification                                                             *)
(* -------------------------------------------------------------------------- *)

(*val any : forall 'k 'v. MapKeyType 'k, Eq 'v => ('k -> 'v -> bool) -> map 'k 'v -> bool*) 
(*val all : forall 'k 'v. MapKeyType 'k, Eq 'v => ('k -> 'v -> bool) -> map 'k 'v -> bool*) 

(*let all P m=  (forall k v. (P k v && ((Instance_Basic_classes_Eq_Maybe_maybe.=) (lookup k m) (Just v))))*)


(* -------------------------------------------------------------------------- *)
(* Set-like operations.                                                       *)
(* -------------------------------------------------------------------------- *)
(*val deleteBy         : forall 'k 'v. ('k -> 'k -> ordering) -> 'k -> map 'k 'v -> map 'k 'v*)
(*val delete           : forall 'k 'v. MapKeyType 'k => 'k -> map 'k 'v -> map 'k 'v*)
(*val deleteSwap      : forall 'k 'v. MapKeyType 'k => map 'k 'v -> 'k -> map 'k 'v*)

(*val union          : forall 'k 'v. MapKeyType 'k => map 'k 'v -> map 'k 'v -> map 'k 'v*)

(*val unions           : forall 'k 'v. MapKeyType 'k => list (map 'k 'v) -> map 'k 'v*)


(* -------------------------------------------------------------------------- *)
(* Maps (in the functor sense).                                               *)
(* -------------------------------------------------------------------------- *)

(*val map             : forall 'k 'v 'w. MapKeyType 'k => ('v -> 'w) -> map 'k 'v -> map 'k 'w*)

(*val mapi : forall 'k 'v 'w. MapKeyType 'k => ('k -> 'v -> 'w) -> map 'k 'v -> map 'k 'w*)

(* -------------------------------------------------------------------------- *)
(* Cardinality                                                                *)
(* -------------------------------------------------------------------------- *)
(*val size  : forall 'k 'v. MapKeyType 'k, SetType 'k => map 'k 'v -> nat*)

(* instance of SetType *)
definition map_setElemCompare  :: "(('d*'c)set \<Rightarrow>('b*'a)set \<Rightarrow> 'e)\<Rightarrow>('d,'c)Map.map \<Rightarrow>('b,'a)Map.map \<Rightarrow> 'e "  where 
     " map_setElemCompare cmp x y = (
  cmp (map_to_set x) (map_to_set y))"

end
