(*Generated by Lem from list_extra.lem.*)
open HolKernel Parse boolLib bossLib;
open lem_boolTheory lem_maybeTheory lem_basic_classesTheory lem_tupleTheory lem_numTheory lem_listTheory lem_assert_extraTheory;

val _ = numLib.prefer_num();



val _ = new_theory "lem_list_extra"



(*open import Bool Maybe Basic_classes Tuple Num List Assert_extra*)

(* ------------------------- *)
(* head of non-empty list    *)
(* ------------------------- *)
(*val head : forall 'a. list 'a -> 'a*)
(*let head l=  match l with | x::xs -> x | [] -> failwith "List_extra.head of empty list" end*)


(* ------------------------- *)
(* tail of non-empty list    *)
(* ------------------------- *)
(*val tail : forall 'a. list 'a -> list 'a*)
(*let tail l=  match l with | x::xs -> xs | [] -> failwith "List_extra.tail of empty list" end*)


(* ------------------------- *)
(* last                      *)
(* ------------------------- *)
(*val last : forall 'a. list 'a -> 'a*)
(*let rec last l=  match l with | [x] -> x | x1::x2::xs -> last (x2 :: xs) | [] -> failwith "List_extra.last of empty list" end*)


(* ------------------------- *)
(* init                      *)
(* ------------------------- *)

(* All elements of a non-empty list except the last one. *)
(*val init : forall 'a. list 'a -> list 'a*)
(*let rec init l=  match l with | [x] -> [] | x1::x2::xs -> x1::(init (x2::xs)) | [] -> failwith "List_extra.init of empty list" end*)


(* ------------------------- *)
(* foldl1 / foldr1           *)
(* ------------------------- *)

(* folding functions for non-empty lists,
    which don`t take the base case *)
(*val foldl1 : forall 'a. ('a -> 'a -> 'a) -> list 'a -> 'a*)
val _ = Define `
 ((foldl1:('a -> 'a -> 'a) -> 'a list -> 'a) f (x :: xs)=  (FOLDL f x xs))
/\ ((foldl1:('a -> 'a -> 'a) -> 'a list -> 'a) f ([])=  (failwith "List_extra.foldl1 of empty list"))`;


(*val foldr1 : forall 'a. ('a -> 'a -> 'a) -> list 'a -> 'a*)
val _ = Define `
 ((foldr1:('a -> 'a -> 'a) -> 'a list -> 'a) f (x :: xs)=  (FOLDR f x xs))
/\ ((foldr1:('a -> 'a -> 'a) -> 'a list -> 'a) f ([])=  (failwith "List_extra.foldr1 of empty list"))`;


  
(* ------------------------- *)
(* nth element               *)
(* ------------------------- *)

(* get the nth element of a list *)
(*val nth : forall 'a. list 'a -> nat -> 'a*)
(*let nth l n=  match index l n with Just e -> e | Nothing -> failwith "List_extra.nth" end*)


(* ------------------------- *)
(* Find_non_pure             *)
(* ------------------------- *)
(*val findNonPure : forall 'a. ('a -> bool) -> list 'a -> 'a*) 
val _ = Define `
 ((findNonPure:('a -> bool) -> 'a list -> 'a) P l=  ((case (list_find_opt P l) of 
    SOME e      => e
  | NONE     => failwith "List_extra.findNonPure"
)))`;



(* ------------------------- *)
(* zip same length           *)
(* ------------------------- *)

(*val zipSameLength : forall 'a 'b. list 'a -> list 'b -> list ('a * 'b)*) 
(*let rec zipSameLength l1 l2=  match (l1, l2) with
  | (x :: xs, y :: ys) -> (x, y) :: zipSameLength xs ys
  | ([], []) -> []
  | _ -> failwith "List_extra.zipSameLength of different length lists"

end*)

(*val     unfoldr: forall 'a 'b. ('a -> Maybe.maybe ('b * 'a)) -> 'a -> list 'b*)
 val unfoldr_defn = Hol_defn "unfoldr" `
 ((unfoldr:('a ->('b#'a)option) -> 'a -> 'b list) f x=  
 ((case f x of
      SOME (y, x') =>
        y :: unfoldr f x'
    | NONE =>
        []
  )))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) Defn.save_defn unfoldr_defn;

val _ = export_theory()

