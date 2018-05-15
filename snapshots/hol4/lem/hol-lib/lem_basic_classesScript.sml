(*Generated by Lem from basic_classes.lem.*)
open HolKernel Parse boolLib bossLib;
open lem_boolTheory;

val _ = numLib.prefer_num();



val _ = new_theory "lem_basic_classes"

(******************************************************************************)
(* Basic Type Classes                                                         *)
(******************************************************************************)

(*open import Bool*) 

(*open import {coq} `Coq.Strings.Ascii`*)

(* ========================================================================== *)
(* Equality                                                                   *)
(* ========================================================================== *)

(* Lem`s default equality (=) is defined by the following type-class Eq.
   This typeclass should define equality on an abstract datatype 'a. It should
   always coincide with the default equality of Coq, HOL and Isabelle.
   For OCaml, it might be different, since abstract datatypes like sets
   might have fancy equalities. *)

(*class ( Eq 'a ) 
  val = [isEqual] : 'a -> 'a -> bool
  val <> [isInequal] : 'a -> 'a -> bool
end*)


(* (=) should for all instances be an equivalence relation 
   The isEquivalence predicate of relations could be used here.
   However, this would lead to a cyclic dependency. *)

(* TODO: add later, once lemmata can be assigned to classes 
lemma eq_equiv: ((forall x. (x = x)) &&
                 (forall x y. (x = y) <-> (y = x)) &&
                 (forall x y z. ((x = y) && (y = z)) --> (x = z)))
*)

(* Structural equality *)

(* Sometimes, it is also handy to be able to use structural equality.
   This equality is mapped to the build-in equality of backends. This equality
   differs significantly for each backend. For example, OCaml can`t check equality
   of function types, whereas HOL can.  When using structural equality, one should 
   know what one is doing. The only guarentee is that is behaves like 
   the native backend equality.

   A lengthy name for structural equality is used to discourage its direct use.
   It also ensures that users realise it is unsafe (e.g. OCaml can`t check two functions
   for equality *)
(*val unsafe_structural_equality : forall 'a. 'a -> 'a -> bool*)

(*val unsafe_structural_inequality : forall 'a. 'a -> 'a -> bool*)
(*let unsafe_structural_inequality x y=  not (unsafe_structural_equality x y)*)


(* ========================================================================== *)
(* Orderings                                                                  *)
(* ========================================================================== *)

(* The type-class Ord represents total orders (also called linear orders) *)
val _ = Hol_datatype `
 ordering = LT | EQ | GT`;


val _ = Define `
 ((orderingIsLess:ordering -> bool) LT=        T)
/\ ((orderingIsLess:ordering -> bool) _=        F)`;

val _ = Define `
 ((orderingIsGreater:ordering -> bool) GT=     T)
/\ ((orderingIsGreater:ordering -> bool) _=     F)`;

val _ = Define `
 ((orderingIsEqual:ordering -> bool) EQ=       T)
/\ ((orderingIsEqual:ordering -> bool) _=       F)`;


val _ = Define `
 ((ordering_cases:ordering -> 'a -> 'a -> 'a -> 'a) r lt eq gt=  
 (if orderingIsLess r then lt else
  if orderingIsEqual r then eq else gt))`;



(*val orderingEqual : ordering -> ordering -> bool*)

val _ = Hol_datatype `
(*  'a *) Ord_class= <| 
  compare_method                 : 'a -> 'a -> ordering;
  isLess_method         : 'a -> 'a -> bool;
  isLessEqual_method    : 'a -> 'a -> bool;
  isGreater_method      : 'a -> 'a -> bool;
  isGreaterEqual_method : 'a -> 'a -> bool 
|>`;



(* Ocaml provides default, polymorphic compare functions. Let's use them
   as the default. However, because used perhaps in a typeclass they must be 
   defined for all targets. So, explicitly declare them as undefined for
   all other targets. If explictly declare undefined, the type-checker won't complain and
   an error will only be raised when trying to actually output the function for a certain
   target. *)
(*val defaultCompare   : forall 'a. 'a -> 'a -> ordering*)
(*val defaultLess      : forall 'a. 'a -> 'a -> bool*)
(*val defaultLessEq    : forall 'a. 'a -> 'a -> bool*)
(*val defaultGreater   : forall 'a. 'a -> 'a -> bool*)
(*val defaultGreaterEq : forall 'a. 'a -> 'a -> bool*) 


val _ = Define `
 ((genericCompare:('a -> 'a -> bool) ->('a -> 'a -> bool) -> 'a -> 'a -> ordering) (less: 'a -> 'a -> bool) (equal: 'a -> 'a -> bool) (x : 'a) (y : 'a)=  
 (if less x y then
    LT
  else if equal x y then
    EQ
  else
    GT))`;



(*
(* compare should really be a total order *)
lemma ord_OK_1: (
  (forall x y. (compare x y = EQ) <-> (compare y x = EQ)) &&
  (forall x y. (compare x y = LT) <-> (compare y x = GT)))

lemma ord_OK_2: (
  (forall x y z. (x <= y) && (y <= z) --> (x <= z)) &&
  (forall x y. (x <= y) || (y <= x))
)
*)

(* let's derive a compare function from the Ord type-class *)
(*val ordCompare : forall 'a. Eq 'a, Ord 'a => 'a -> 'a -> ordering*)
val _ = Define `
 ((ordCompare:'a Ord_class -> 'a -> 'a -> ordering)dict_Basic_classes_Ord_a x y=  
 (if ( dict_Basic_classes_Ord_a.isLess_method x y) then LT else
  if (x = y) then EQ else GT))`;


val _ = Hol_datatype `
(*  'a *) OrdMaxMin_class= <| 
  max_method : 'a -> 'a -> 'a;
  min_method : 'a -> 'a -> 'a
|>`;


(*val minByLessEqual : forall 'a. ('a -> 'a -> bool) -> 'a -> 'a -> 'a*)
val _ = Define `
 ((minByLessEqual:('a -> 'a -> bool) -> 'a -> 'a -> 'a) le x y=  (if (le x y) then x else y))`;


(*val maxByLessEqual : forall 'a. ('a -> 'a -> bool) -> 'a -> 'a -> 'a*)
val _ = Define `
 ((maxByLessEqual:('a -> 'a -> bool) -> 'a -> 'a -> 'a) le x y=  (if (le y x) then x else y))`;


(*val defaultMax : forall 'a. Ord 'a => 'a -> 'a -> 'a*)

(*val defaultMin : forall 'a. Ord 'a => 'a -> 'a -> 'a*)

val _ = Define `
((instance_Basic_classes_OrdMaxMin_var_dict:'a Ord_class -> 'a OrdMaxMin_class)dict_Basic_classes_Ord_a= (<|

  max_method := (maxByLessEqual  
  dict_Basic_classes_Ord_a.isLessEqual_method);

  min_method := (minByLessEqual  
  dict_Basic_classes_Ord_a.isLessEqual_method)|>))`;



(* ========================================================================== *)
(* SetTypes                                                                   *)
(* ========================================================================== *)

(* Set implementations use often an order on the elements. This allows the OCaml implementation
   to use trees for implementing them. At least, one needs to be able to check equality on sets.
   One could use the Ord type-class for sets. However, defining a special typeclass is cleaner
   and allows more flexibility. One can make e.g. sure, that this type-class is ignored for
   backends like HOL or Isabelle, which don't need it. Moreover, one is not forced to also instantiate
   the functions "<", "<=" ... *)

(*class ( SetType 'a ) 
  val {ocaml;coq} setElemCompare : 'a -> 'a -> ordering
end*)

val _ = Define `
 ((boolCompare:bool -> bool -> ordering) T T=  EQ)
/\ ((boolCompare:bool -> bool -> ordering) T F=  GT)
/\ ((boolCompare:bool -> bool -> ordering) F T=  LT)
/\ ((boolCompare:bool -> bool -> ordering) F F=  EQ)`;


(* strings *)

(*val charEqual : char -> char -> bool*)

(*val stringEquality : string -> string -> bool*)

(* pairs *)

(*val pairEqual : forall 'a 'b. Eq 'a, Eq 'b => ('a * 'b) -> ('a * 'b) -> bool*)
(*let pairEqual (a1, b1) (a2, b2)=  (a1 = a2) && (b1 = b2)*)

(*val pairEqualBy : forall 'a 'b. ('a -> 'a -> bool) -> ('b -> 'b -> bool) -> ('a * 'b) -> ('a * 'b) -> bool*)

(*val pairCompare : forall 'a 'b. ('a -> 'a -> ordering) -> ('b -> 'b -> ordering) -> ('a * 'b) -> ('a * 'b) -> ordering*)
val _ = Define `
 ((pairCompare:('a -> 'a -> ordering) ->('b -> 'b -> ordering) -> 'a#'b -> 'a#'b -> ordering) cmpa cmpb (a1, b1) (a2, b2)=  
 ((case cmpa a1 a2 of
      LT => LT
    | GT => GT
    | EQ => cmpb b1 b2
  )))`;


val _ = Define `
 ((pairLess:'a Ord_class -> 'b Ord_class -> 'b#'a -> 'b#'a -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b (x1, x2) (y1, y2)=  (( 
  dict_Basic_classes_Ord_b.isLess_method x1 y1) \/ (( dict_Basic_classes_Ord_b.isLessEqual_method x1 y1) /\ ( dict_Basic_classes_Ord_a.isLess_method x2 y2))))`;

val _ = Define `
 ((pairLessEq:'a Ord_class -> 'b Ord_class -> 'b#'a -> 'b#'a -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b (x1, x2) (y1, y2)=  (( 
  dict_Basic_classes_Ord_b.isLess_method x1 y1) \/ (( dict_Basic_classes_Ord_b.isLessEqual_method x1 y1) /\ ( dict_Basic_classes_Ord_a.isLessEqual_method x2 y2))))`;


val _ = Define `
 ((pairGreater:'a Ord_class -> 'b Ord_class -> 'a#'b -> 'a#'b -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b x12 y12=  (pairLess 
  dict_Basic_classes_Ord_b dict_Basic_classes_Ord_a y12 x12))`;

val _ = Define `
 ((pairGreaterEq:'a Ord_class -> 'b Ord_class -> 'a#'b -> 'a#'b -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b x12 y12=  (pairLessEq 
  dict_Basic_classes_Ord_b dict_Basic_classes_Ord_a y12 x12))`;


val _ = Define `
((instance_Basic_classes_Ord_tup2_dict:'a Ord_class -> 'b Ord_class ->('a#'b)Ord_class)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b= (<|

  compare_method := (pairCompare  
  dict_Basic_classes_Ord_a.compare_method  dict_Basic_classes_Ord_b.compare_method);

  isLess_method := 
  (pairLess dict_Basic_classes_Ord_b dict_Basic_classes_Ord_a);

  isLessEqual_method := 
  (pairLessEq dict_Basic_classes_Ord_b dict_Basic_classes_Ord_a);

  isGreater_method := 
  (pairGreater dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b);

  isGreaterEqual_method := 
  (pairGreaterEq dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b)|>))`;



(* triples *)

(*val tripleEqual : forall 'a 'b 'c. Eq 'a, Eq 'b, Eq 'c => ('a * 'b * 'c) -> ('a * 'b * 'c) -> bool*)
(*let tripleEqual (x1, x2, x3) (y1, y2, y3)=  ((Instance_Basic_classes_Eq_tup2.=) (x1, (x2, x3)) (y1, (y2, y3)))*)

(*val tripleCompare : forall 'a 'b 'c. ('a -> 'a -> ordering) -> ('b -> 'b -> ordering) -> ('c -> 'c -> ordering) -> ('a * 'b * 'c) -> ('a * 'b * 'c) -> ordering*)
val _ = Define `
 ((tripleCompare:('a -> 'a -> ordering) ->('b -> 'b -> ordering) ->('c -> 'c -> ordering) -> 'a#'b#'c -> 'a#'b#'c -> ordering) cmpa cmpb cmpc (a1, b1, c1) (a2, b2, c2)=  
 (pairCompare cmpa (pairCompare cmpb cmpc) (a1, (b1, c1)) (a2, (b2, c2))))`;


val _ = Define `
 ((tripleLess:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'a#'b#'c -> 'a#'b#'c -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c (x1, x2, x3) (y1, y2, y3)=  (pairLess 
  (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_b
     dict_Basic_classes_Ord_c) dict_Basic_classes_Ord_a (x1, (x2, x3)) (y1, (y2, y3))))`;

val _ = Define `
 ((tripleLessEq:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'a#'b#'c -> 'a#'b#'c -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c (x1, x2, x3) (y1, y2, y3)=  (pairLessEq 
  (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_b
     dict_Basic_classes_Ord_c) dict_Basic_classes_Ord_a (x1, (x2, x3)) (y1, (y2, y3))))`;


val _ = Define `
 ((tripleGreater:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'c#'b#'a -> 'c#'b#'a -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c x123 y123=  (tripleLess 
  dict_Basic_classes_Ord_c dict_Basic_classes_Ord_b dict_Basic_classes_Ord_a y123 x123))`;

val _ = Define `
 ((tripleGreaterEq:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'c#'b#'a -> 'c#'b#'a -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c x123 y123=  (tripleLessEq 
  dict_Basic_classes_Ord_c dict_Basic_classes_Ord_b dict_Basic_classes_Ord_a y123 x123))`;


val _ = Define `
((instance_Basic_classes_Ord_tup3_dict:'a Ord_class -> 'b Ord_class -> 'c Ord_class ->('a#'b#'c)Ord_class)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c= (<|

  compare_method := (tripleCompare  
  dict_Basic_classes_Ord_a.compare_method  dict_Basic_classes_Ord_b.compare_method  dict_Basic_classes_Ord_c.compare_method);

  isLess_method := 
  (tripleLess dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b
     dict_Basic_classes_Ord_c);

  isLessEqual_method := 
  (tripleLessEq dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b
     dict_Basic_classes_Ord_c);

  isGreater_method := 
  (tripleGreater dict_Basic_classes_Ord_c dict_Basic_classes_Ord_b
     dict_Basic_classes_Ord_a);

  isGreaterEqual_method := 
  (tripleGreaterEq dict_Basic_classes_Ord_c dict_Basic_classes_Ord_b
     dict_Basic_classes_Ord_a)|>))`;


(* quadruples *)

(*val quadrupleEqual : forall 'a 'b 'c 'd. Eq 'a, Eq 'b, Eq 'c, Eq 'd => ('a * 'b * 'c * 'd) -> ('a * 'b * 'c * 'd) -> bool*)
(*let quadrupleEqual (x1, x2, x3, x4) (y1, y2, y3, y4)=  ((Instance_Basic_classes_Eq_tup2.=) (x1, (x2, (x3, x4))) (y1, (y2, (y3, y4))))*)

(*val quadrupleCompare : forall 'a 'b 'c 'd. ('a -> 'a -> ordering) -> ('b -> 'b -> ordering) -> ('c -> 'c -> ordering) ->
                                              ('d -> 'd -> ordering) -> ('a * 'b * 'c * 'd) -> ('a * 'b * 'c * 'd) -> ordering*)
val _ = Define `
 ((quadrupleCompare:('a -> 'a -> ordering) ->('b -> 'b -> ordering) ->('c -> 'c -> ordering) ->('d -> 'd -> ordering) -> 'a#'b#'c#'d -> 'a#'b#'c#'d -> ordering) cmpa cmpb cmpc cmpd (a1, b1, c1, d1) (a2, b2, c2, d2)=  
 (pairCompare cmpa (pairCompare cmpb (pairCompare cmpc cmpd)) (a1, (b1, (c1, d1))) (a2, (b2, (c2, d2)))))`;


val _ = Define `
 ((quadrupleLess:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'd Ord_class -> 'a#'b#'c#'d -> 'a#'b#'c#'d -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d (x1, x2, x3, x4) (y1, y2, y3, y4)=  (pairLess 
  (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_b
     (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_c
        dict_Basic_classes_Ord_d)) dict_Basic_classes_Ord_a (x1, (x2, (x3, x4))) (y1, (y2, (y3, y4)))))`;

val _ = Define `
 ((quadrupleLessEq:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'd Ord_class -> 'a#'b#'c#'d -> 'a#'b#'c#'d -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d (x1, x2, x3, x4) (y1, y2, y3, y4)=  (pairLessEq 
  (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_b
     (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_c
        dict_Basic_classes_Ord_d)) dict_Basic_classes_Ord_a (x1, (x2, (x3, x4))) (y1, (y2, (y3, y4)))))`;


val _ = Define `
 ((quadrupleGreater:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'd Ord_class -> 'd#'c#'b#'a -> 'd#'c#'b#'a -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d x1234 y1234=  (quadrupleLess 
  dict_Basic_classes_Ord_d dict_Basic_classes_Ord_c dict_Basic_classes_Ord_b dict_Basic_classes_Ord_a y1234 x1234))`;

val _ = Define `
 ((quadrupleGreaterEq:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'd Ord_class -> 'd#'c#'b#'a -> 'd#'c#'b#'a -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d x1234 y1234=  (quadrupleLessEq 
  dict_Basic_classes_Ord_d dict_Basic_classes_Ord_c dict_Basic_classes_Ord_b dict_Basic_classes_Ord_a y1234 x1234))`;


val _ = Define `
((instance_Basic_classes_Ord_tup4_dict:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'd Ord_class ->('a#'b#'c#'d)Ord_class)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d= (<|

  compare_method := (quadrupleCompare  
  dict_Basic_classes_Ord_a.compare_method  dict_Basic_classes_Ord_b.compare_method  dict_Basic_classes_Ord_c.compare_method  dict_Basic_classes_Ord_d.compare_method);

  isLess_method := 
  (quadrupleLess dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b
     dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d);

  isLessEqual_method := 
  (quadrupleLessEq dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b
     dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d);

  isGreater_method := 
  (quadrupleGreater dict_Basic_classes_Ord_d dict_Basic_classes_Ord_c
     dict_Basic_classes_Ord_b dict_Basic_classes_Ord_a);

  isGreaterEqual_method := 
  (quadrupleGreaterEq dict_Basic_classes_Ord_d dict_Basic_classes_Ord_c
     dict_Basic_classes_Ord_b dict_Basic_classes_Ord_a)|>))`;


(* quintuples *)

(*val quintupleEqual : forall 'a 'b 'c 'd 'e. Eq 'a, Eq 'b, Eq 'c, Eq 'd, Eq 'e => ('a * 'b * 'c * 'd * 'e) -> ('a * 'b * 'c * 'd * 'e) -> bool*)
(*let quintupleEqual (x1, x2, x3, x4, x5) (y1, y2, y3, y4, y5)=  ((Instance_Basic_classes_Eq_tup2.=) (x1, (x2, (x3, (x4, x5)))) (y1, (y2, (y3, (y4, y5)))))*)

(*val quintupleCompare : forall 'a 'b 'c 'd 'e. ('a -> 'a -> ordering) -> ('b -> 'b -> ordering) -> ('c -> 'c -> ordering) ->
                                              ('d -> 'd -> ordering) -> ('e -> 'e -> ordering) -> ('a * 'b * 'c * 'd * 'e) -> ('a * 'b * 'c * 'd * 'e) -> ordering*)
val _ = Define `
 ((quintupleCompare:('a -> 'a -> ordering) ->('b -> 'b -> ordering) ->('c -> 'c -> ordering) ->('d -> 'd -> ordering) ->('e -> 'e -> ordering) -> 'a#'b#'c#'d#'e -> 'a#'b#'c#'d#'e -> ordering) cmpa cmpb cmpc cmpd cmpe (a1, b1, c1, d1, e1) (a2, b2, c2, d2, e2)=  
 (pairCompare cmpa (pairCompare cmpb (pairCompare cmpc (pairCompare cmpd cmpe))) (a1, (b1, (c1, (d1, e1)))) (a2, (b2, (c2, (d2, e2))))))`;


val _ = Define `
 ((quintupleLess:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'd Ord_class -> 'e Ord_class -> 'a#'b#'c#'d#'e -> 'a#'b#'c#'d#'e -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d dict_Basic_classes_Ord_e (x1, x2, x3, x4, x5) (y1, y2, y3, y4, y5)=  (pairLess 
  (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_b
     (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_c
        (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_d
           dict_Basic_classes_Ord_e))) dict_Basic_classes_Ord_a (x1, (x2, (x3, (x4, x5)))) (y1, (y2, (y3, (y4, y5))))))`;

val _ = Define `
 ((quintupleLessEq:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'd Ord_class -> 'e Ord_class -> 'a#'b#'c#'d#'e -> 'a#'b#'c#'d#'e -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d dict_Basic_classes_Ord_e (x1, x2, x3, x4, x5) (y1, y2, y3, y4, y5)=  (pairLessEq 
  (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_b
     (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_c
        (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_d
           dict_Basic_classes_Ord_e))) dict_Basic_classes_Ord_a (x1, (x2, (x3, (x4, x5)))) (y1, (y2, (y3, (y4, y5))))))`;


val _ = Define `
 ((quintupleGreater:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'd Ord_class -> 'e Ord_class -> 'e#'d#'c#'b#'a -> 'e#'d#'c#'b#'a -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d dict_Basic_classes_Ord_e x12345 y12345=  (quintupleLess 
  dict_Basic_classes_Ord_e dict_Basic_classes_Ord_d dict_Basic_classes_Ord_c dict_Basic_classes_Ord_b dict_Basic_classes_Ord_a y12345 x12345))`;

val _ = Define `
 ((quintupleGreaterEq:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'd Ord_class -> 'e Ord_class -> 'e#'d#'c#'b#'a -> 'e#'d#'c#'b#'a -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d dict_Basic_classes_Ord_e x12345 y12345=  (quintupleLessEq 
  dict_Basic_classes_Ord_e dict_Basic_classes_Ord_d dict_Basic_classes_Ord_c dict_Basic_classes_Ord_b dict_Basic_classes_Ord_a y12345 x12345))`;


val _ = Define `
((instance_Basic_classes_Ord_tup5_dict:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'd Ord_class -> 'e Ord_class ->('a#'b#'c#'d#'e)Ord_class)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d dict_Basic_classes_Ord_e= (<|

  compare_method := (quintupleCompare  
  dict_Basic_classes_Ord_a.compare_method  dict_Basic_classes_Ord_b.compare_method  dict_Basic_classes_Ord_c.compare_method  dict_Basic_classes_Ord_d.compare_method  dict_Basic_classes_Ord_e.compare_method);

  isLess_method := 
  (quintupleLess dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b
     dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d
     dict_Basic_classes_Ord_e);

  isLessEqual_method := 
  (quintupleLessEq dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b
     dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d
     dict_Basic_classes_Ord_e);

  isGreater_method := 
  (quintupleGreater dict_Basic_classes_Ord_e dict_Basic_classes_Ord_d
     dict_Basic_classes_Ord_c dict_Basic_classes_Ord_b
     dict_Basic_classes_Ord_a);

  isGreaterEqual_method := 
  (quintupleGreaterEq dict_Basic_classes_Ord_e dict_Basic_classes_Ord_d
     dict_Basic_classes_Ord_c dict_Basic_classes_Ord_b
     dict_Basic_classes_Ord_a)|>))`;


(* sextuples *)

(*val sextupleEqual : forall 'a 'b 'c 'd 'e 'f. Eq 'a, Eq 'b, Eq 'c, Eq 'd, Eq 'e, Eq 'f => ('a * 'b * 'c * 'd * 'e * 'f) -> ('a * 'b * 'c * 'd * 'e * 'f) -> bool*)
(*let sextupleEqual (x1, x2, x3, x4, x5, x6) (y1, y2, y3, y4, y5, y6)=  ((Instance_Basic_classes_Eq_tup2.=) (x1, (x2, (x3, (x4, (x5, x6))))) (y1, (y2, (y3, (y4, (y5, y6))))))*)

(*val sextupleCompare : forall 'a 'b 'c 'd 'e 'f. ('a -> 'a -> ordering) -> ('b -> 'b -> ordering) -> ('c -> 'c -> ordering) ->
                                              ('d -> 'd -> ordering) -> ('e -> 'e -> ordering) -> ('f -> 'f -> ordering) ->
                                              ('a * 'b * 'c * 'd * 'e * 'f) -> ('a * 'b * 'c * 'd * 'e * 'f) -> ordering*)
val _ = Define `
 ((sextupleCompare:('a -> 'a -> ordering) ->('b -> 'b -> ordering) ->('c -> 'c -> ordering) ->('d -> 'd -> ordering) ->('e -> 'e -> ordering) ->('f -> 'f -> ordering) -> 'a#'b#'c#'d#'e#'f -> 'a#'b#'c#'d#'e#'f -> ordering) cmpa cmpb cmpc cmpd cmpe cmpf (a1, b1, c1, d1, e1, f1) (a2, b2, c2, d2, e2, f2)=  
 (pairCompare cmpa (pairCompare cmpb (pairCompare cmpc (pairCompare cmpd (pairCompare cmpe cmpf)))) (a1, (b1, (c1, (d1, (e1, f1))))) (a2, (b2, (c2, (d2, (e2, f2)))))))`;


val _ = Define `
 ((sextupleLess:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'd Ord_class -> 'e Ord_class -> 'f Ord_class -> 'a#'b#'c#'d#'e#'f -> 'a#'b#'c#'d#'e#'f -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d dict_Basic_classes_Ord_e dict_Basic_classes_Ord_f (x1, x2, x3, x4, x5, x6) (y1, y2, y3, y4, y5, y6)=  (pairLess 
  (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_b
     (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_c
        (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_d
           (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_e
              dict_Basic_classes_Ord_f)))) dict_Basic_classes_Ord_a (x1, (x2, (x3, (x4, (x5, x6))))) (y1, (y2, (y3, (y4, (y5, y6)))))))`;

val _ = Define `
 ((sextupleLessEq:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'd Ord_class -> 'e Ord_class -> 'f Ord_class -> 'a#'b#'c#'d#'e#'f -> 'a#'b#'c#'d#'e#'f -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d dict_Basic_classes_Ord_e dict_Basic_classes_Ord_f (x1, x2, x3, x4, x5, x6) (y1, y2, y3, y4, y5, y6)=  (pairLessEq 
  (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_b
     (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_c
        (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_d
           (instance_Basic_classes_Ord_tup2_dict dict_Basic_classes_Ord_e
              dict_Basic_classes_Ord_f)))) dict_Basic_classes_Ord_a (x1, (x2, (x3, (x4, (x5, x6))))) (y1, (y2, (y3, (y4, (y5, y6)))))))`;


val _ = Define `
 ((sextupleGreater:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'd Ord_class -> 'e Ord_class -> 'f Ord_class -> 'f#'e#'d#'c#'b#'a -> 'f#'e#'d#'c#'b#'a -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d dict_Basic_classes_Ord_e dict_Basic_classes_Ord_f x123456 y123456=  (sextupleLess 
  dict_Basic_classes_Ord_f dict_Basic_classes_Ord_e dict_Basic_classes_Ord_d dict_Basic_classes_Ord_c dict_Basic_classes_Ord_b dict_Basic_classes_Ord_a y123456 x123456))`;

val _ = Define `
 ((sextupleGreaterEq:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'd Ord_class -> 'e Ord_class -> 'f Ord_class -> 'f#'e#'d#'c#'b#'a -> 'f#'e#'d#'c#'b#'a -> bool)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d dict_Basic_classes_Ord_e dict_Basic_classes_Ord_f x123456 y123456=  (sextupleLessEq 
  dict_Basic_classes_Ord_f dict_Basic_classes_Ord_e dict_Basic_classes_Ord_d dict_Basic_classes_Ord_c dict_Basic_classes_Ord_b dict_Basic_classes_Ord_a y123456 x123456))`;


val _ = Define `
((instance_Basic_classes_Ord_tup6_dict:'a Ord_class -> 'b Ord_class -> 'c Ord_class -> 'd Ord_class -> 'e Ord_class -> 'f Ord_class ->('a#'b#'c#'d#'e#'f)Ord_class)dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d dict_Basic_classes_Ord_e dict_Basic_classes_Ord_f= (<|

  compare_method := (sextupleCompare  
  dict_Basic_classes_Ord_a.compare_method  dict_Basic_classes_Ord_b.compare_method  dict_Basic_classes_Ord_c.compare_method  dict_Basic_classes_Ord_d.compare_method  dict_Basic_classes_Ord_e.compare_method  dict_Basic_classes_Ord_f.compare_method);

  isLess_method := 
  (sextupleLess dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b
     dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d
     dict_Basic_classes_Ord_e dict_Basic_classes_Ord_f);

  isLessEqual_method := 
  (sextupleLessEq dict_Basic_classes_Ord_a dict_Basic_classes_Ord_b
     dict_Basic_classes_Ord_c dict_Basic_classes_Ord_d
     dict_Basic_classes_Ord_e dict_Basic_classes_Ord_f);

  isGreater_method := 
  (sextupleGreater dict_Basic_classes_Ord_f dict_Basic_classes_Ord_e
     dict_Basic_classes_Ord_d dict_Basic_classes_Ord_c
     dict_Basic_classes_Ord_b dict_Basic_classes_Ord_a);

  isGreaterEqual_method := 
  (sextupleGreaterEq dict_Basic_classes_Ord_f dict_Basic_classes_Ord_e
     dict_Basic_classes_Ord_d dict_Basic_classes_Ord_c
     dict_Basic_classes_Ord_b dict_Basic_classes_Ord_a)|>))`;

val _ = export_theory()

