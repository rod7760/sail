(*Generated by Lem from list.lem.*)
open HolKernel Parse boolLib bossLib;
open lem_boolTheory lem_maybeTheory lem_basic_classesTheory lem_functionTheory lem_tupleTheory lem_numTheory lemTheory listTheory rich_listTheory sortingTheory;

val _ = numLib.prefer_num();



val _ = new_theory "lem_list"

 

(*open import Bool Maybe Basic_classes Function Tuple Num*)

(*open import {coq} `Coq.Lists.List`*)
(*open import {isabelle} `$LIB_DIR/Lem`*)
(*open import {hol} `lemTheory` `listTheory` `rich_listTheory` `sortingTheory`*)

(* ========================================================================== *)
(* Basic list functions                                                       *)
(* ========================================================================== *)

(* The type of lists as well as list literals like [], [1;2], ... are hardcoded. 
   Thus, we can directly dive into derived definitions. *)


(* ----------------------- *)
(* cons                    *)
(* ----------------------- *)

(*val :: : forall 'a. 'a -> list 'a -> list 'a*)


(* ----------------------- *)
(* Emptyness check         *)
(* ----------------------- *)

(*val null : forall 'a. list 'a -> bool*)
(*let null l=  match l with [] -> true | _ -> false end*)

(* ----------------------- *)
(* Length                  *)
(* ----------------------- *)

(*val length : forall 'a. list 'a -> nat*)
(*let rec length l= 
  match l with
    | [] -> 0
    | x :: xs -> (Instance_Num_NumAdd_nat.+) (length xs) 1
  end*)

(* ----------------------- *)
(* Equality                *)
(* ----------------------- *)

(*val listEqual : forall 'a. Eq 'a => list 'a -> list 'a -> bool*)
(*val listEqualBy : forall 'a. ('a -> 'a -> bool) -> list 'a -> list 'a -> bool*)

 val _ = Define `
 ((listEqualBy:('a -> 'a -> bool) -> 'a list -> 'a list -> bool) eq ([]) ([])=  T)
/\ ((listEqualBy:('a -> 'a -> bool) -> 'a list -> 'a list -> bool) eq ([]) (_::_)=  F)
/\ ((listEqualBy:('a -> 'a -> bool) -> 'a list -> 'a list -> bool) eq (_::_) ([])=  F)
/\ ((listEqualBy:('a -> 'a -> bool) -> 'a list -> 'a list -> bool) eq (x::xs) (y :: ys)=  (eq x y /\ listEqualBy eq xs ys))`;



(* ----------------------- *)
(* compare                 *)
(* ----------------------- *)

(*val lexicographicCompare : forall 'a. Ord 'a => list 'a -> list 'a -> Basic_classes.ordering*)
(*val lexicographicCompareBy : forall 'a. ('a -> 'a -> Basic_classes.ordering) -> list 'a -> list 'a -> Basic_classes.ordering*)

 val _ = Define `
 ((lexicographic_compare:('a -> 'a -> lem_basic_classes$ordering) -> 'a list -> 'a list -> lem_basic_classes$ordering) cmp ([]) ([])=  EQ)
/\ ((lexicographic_compare:('a -> 'a -> lem_basic_classes$ordering) -> 'a list -> 'a list -> lem_basic_classes$ordering) cmp ([]) (_::_)=  LT)
/\ ((lexicographic_compare:('a -> 'a -> lem_basic_classes$ordering) -> 'a list -> 'a list -> lem_basic_classes$ordering) cmp (_::_) ([])=  GT)
/\ ((lexicographic_compare:('a -> 'a -> lem_basic_classes$ordering) -> 'a list -> 'a list -> lem_basic_classes$ordering) cmp (x::xs) (y::ys)=  ((
      (case cmp x y of 
          LT => LT
        | GT => GT
        | EQ => lexicographic_compare cmp xs ys
      )
    )))`;


(*val lexicographicLess : forall 'a. Ord 'a => list 'a -> list 'a -> bool*)
(*val lexicographicLessBy : forall 'a. ('a -> 'a -> bool) -> ('a -> 'a -> bool) -> list 'a -> list 'a -> bool*)
 val _ = Define `
 ((lexicographic_less:('a -> 'a -> bool) ->('a -> 'a -> bool) -> 'a list -> 'a list -> bool) less less_eq ([]) ([])=  F)
/\ ((lexicographic_less:('a -> 'a -> bool) ->('a -> 'a -> bool) -> 'a list -> 'a list -> bool) less less_eq ([]) (_::_)=  T)
/\ ((lexicographic_less:('a -> 'a -> bool) ->('a -> 'a -> bool) -> 'a list -> 'a list -> bool) less less_eq (_::_) ([])=  F)
/\ ((lexicographic_less:('a -> 'a -> bool) ->('a -> 'a -> bool) -> 'a list -> 'a list -> bool) less less_eq (x::xs) (y::ys)=  ((less x y) \/ ((less_eq x y) /\ (lexicographic_less less less_eq xs ys))))`;


(*val lexicographicLessEq : forall 'a. Ord 'a => list 'a -> list 'a -> bool*)
(*val lexicographicLessEqBy : forall 'a. ('a -> 'a -> bool) -> ('a -> 'a -> bool) -> list 'a -> list 'a -> bool*)
 val _ = Define `
 ((lexicographic_less_eq:('a -> 'a -> bool) ->('a -> 'a -> bool) -> 'a list -> 'a list -> bool) less less_eq ([]) ([])=  T)
/\ ((lexicographic_less_eq:('a -> 'a -> bool) ->('a -> 'a -> bool) -> 'a list -> 'a list -> bool) less less_eq ([]) (_::_)=  T)
/\ ((lexicographic_less_eq:('a -> 'a -> bool) ->('a -> 'a -> bool) -> 'a list -> 'a list -> bool) less less_eq (_::_) ([])=  F)
/\ ((lexicographic_less_eq:('a -> 'a -> bool) ->('a -> 'a -> bool) -> 'a list -> 'a list -> bool) less less_eq (x::xs) (y::ys)=  (less x y \/ (less_eq x y /\ lexicographic_less_eq less less_eq xs ys)))`;



val _ = Define `
((instance_Basic_classes_Ord_list_dict:'a lem_basic_classes$Ord_class ->('a list)lem_basic_classes$Ord_class)dict_Basic_classes_Ord_a= (<|

  compare_method := (lexicographic_compare  
  dict_Basic_classes_Ord_a.compare_method);

  isLess_method := (lexicographic_less  
  dict_Basic_classes_Ord_a.isLess_method  dict_Basic_classes_Ord_a.isLessEqual_method);

  isLessEqual_method := (lexicographic_less_eq  
  dict_Basic_classes_Ord_a.isLess_method  dict_Basic_classes_Ord_a.isLessEqual_method);

  isGreater_method := (\ x y. (lexicographic_less  
  dict_Basic_classes_Ord_a.isLess_method  dict_Basic_classes_Ord_a.isLessEqual_method y x));

  isGreaterEqual_method := (\ x y. (lexicographic_less_eq  
  dict_Basic_classes_Ord_a.isLess_method  dict_Basic_classes_Ord_a.isLessEqual_method y x))|>))`;



(* ----------------------- *)
(* Append                  *)
(* ----------------------- *)

(*val ++ : forall 'a. list 'a -> list 'a -> list 'a*) (* originally append *)
(*let rec ++ xs ys=  match xs with
                     | [] -> ys
                     | x :: xs' -> x :: (xs' ++ ys)
                   end*)

(* ----------------------- *)
(* snoc                    *)
(* ----------------------- *)

(*val snoc : forall 'a. 'a -> list 'a -> list 'a*)
(*let snoc e l=  l ++ [e]*)


(* ----------------------- *)
(* Reverse                 *)
(* ----------------------- *)

(* First lets define the function [reverse_append], which is
   closely related to reverse. [reverse_append l1 l2] appends the list [l2] to the reverse of [l1].
   This can be implemented more efficienctly than appending and is
   used to implement reverse. *)

(*val reverseAppend : forall 'a. list 'a -> list 'a -> list 'a*) (* originally named rev_append *)
(*let rec reverseAppend l1 l2=  match l1 with 
                                | [] -> l2
                                | x :: xs -> reverseAppend xs (x :: l2)
                               end*)

(* Reversing a list *)
(*val reverse : forall 'a. list 'a -> list 'a*) (* originally named rev *)
(*let reverse l=  reverseAppend l []*)

(* ----------------------- *)
(* Map                     *)
(* ----------------------- *)

(*val map_tr : forall 'a 'b. list 'b -> ('a -> 'b) -> list 'a -> list 'b*)
 val map_tr_defn = Defn.Hol_multi_defns `
 ((map_tr:'b list ->('a -> 'b) -> 'a list -> 'b list) rev_acc f ([])=  (REVERSE rev_acc))
/\ ((map_tr:'b list ->('a -> 'b) -> 'a list -> 'b list) rev_acc f (x :: xs)=  (map_tr ((f x) :: rev_acc) f xs))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) map_tr_defn;

(* taken from: https://blogs.janestreet.com/optimizing-list-map/ *)
(*val count_map : forall 'a 'b. ('a -> 'b) -> list 'a -> nat -> list 'b*)
 val count_map_defn = Defn.Hol_multi_defns `
 ((count_map:('a -> 'b) -> 'a list -> num -> 'b list) f ([]) ctr=  ([]))
/\ ((count_map:('a -> 'b) -> 'a list -> num -> 'b list) f (hd :: tl) ctr=  (f hd :: 
    (if ctr <( 5000 : num) then count_map f tl (ctr +( 1 : num)) 
    else map_tr [] f tl)))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) count_map_defn;
 
(*val map : forall 'a 'b. ('a -> 'b) -> list 'a -> list 'b*)
(*let map f l=  count_map f l 0*)

(* ----------------------- *)
(* Reverse Map             *)
(* ----------------------- *)

(*val reverseMap : forall 'a 'b. ('a -> 'b) -> list 'a -> list 'b*)


(* ========================================================================== *)
(* Folding                                                                    *)
(* ========================================================================== *)

(* ----------------------- *)
(* fold left               *)
(* ----------------------- *)

(*val foldl : forall 'a 'b. ('a -> 'b -> 'a) -> 'a -> list 'b -> 'a*) (* originally foldl *)

(*let rec foldl f b l=  match l with
  | []      -> b
  | x :: xs -> foldl f (f b x) xs
end*)


(* ----------------------- *)
(* fold right              *)
(* ----------------------- *)

(*val foldr : forall 'a 'b. ('a -> 'b -> 'b) -> 'b -> list 'a -> 'b*) (* originally foldr with different argument order *)
(*let rec foldr f b l=  match l with
  | []      -> b
  | x :: xs -> f x (foldr f b xs)
end*)


(* ----------------------- *)
(* concatenating lists     *)
(* ----------------------- *)

(*val concat : forall 'a. list (list 'a) -> list 'a*) (* before also called "flatten" *)
(*let concat=  foldr (++) []*)


(* -------------------------- *)
(* concatenating with mapping *)
(* -------------------------- *)

(*val concatMap : forall 'a 'b. ('a -> list 'b) -> list 'a -> list 'b*)


(* ------------------------- *)
(* universal qualification   *)
(* ------------------------- *)

(*val all : forall 'a. ('a -> bool) -> list 'a -> bool*) (* originally for_all *)
(*let all P l=  foldl (fun r e -> P e && r) true l*)



(* ------------------------- *)
(* existential qualification *)
(* ------------------------- *)

(*val any : forall 'a. ('a -> bool) -> list 'a -> bool*) (* originally exist *)
(*let any P l=  foldl (fun r e -> P e || r) false l*)


(* ------------------------- *)
(* dest_init                 *)
(* ------------------------- *)

(* get the initial part and the last element of the list in a safe way *)

(*val dest_init : forall 'a. list 'a -> Maybe.maybe (list 'a * 'a)*) 

 val _ = Define `
 ((dest_init_aux:'a list -> 'a -> 'a list -> 'a list#'a) rev_init last_elem_seen ([])=  (REVERSE rev_init, last_elem_seen))
/\ ((dest_init_aux:'a list -> 'a -> 'a list -> 'a list#'a) rev_init last_elem_seen (x::xs)=  (dest_init_aux (last_elem_seen::rev_init) x xs))`;


val _ = Define `
 ((dest_init:'a list ->('a list#'a)option) ([])=  NONE)
/\ ((dest_init:'a list ->('a list#'a)option) (x::xs)=  (SOME (dest_init_aux [] x xs)))`;



(* ========================================================================== *)
(* Indexing lists                                                             *)
(* ========================================================================== *)

(* ------------------------- *)
(* index / nth with maybe   *)
(* ------------------------- *)

(*val index : forall 'a. list 'a -> nat -> Maybe.maybe 'a*)

 val _ = Define `
 ((list_index:'a list -> num -> 'a option) ([]) n=  NONE)
/\ ((list_index:'a list -> num -> 'a option) (x :: xs) n=  (if n =( 0 : num) then SOME x else list_index xs (n -( 1 : num))))`;


(* ------------------------- *)
(* findIndices               *)
(* ------------------------- *)

(* [findIndices P l] returns the indices of all elements of list [l] that satisfy predicate [P]. 
   Counting starts with 0, the result list is sorted ascendingly *)
(*val findIndices : forall 'a. ('a -> bool) -> list 'a -> list nat*)

 val _ = Define `
 ((find_indices_aux:num ->('a -> bool) -> 'a list ->(num)list) (i:num) P ([])=  ([]))
/\ ((find_indices_aux:num ->('a -> bool) -> 'a list ->(num)list) (i:num) P (x :: xs)=  (if P x then i :: find_indices_aux (i +( 1 : num)) P xs else find_indices_aux (i +( 1 : num)) P xs))`;

val _ = Define `
 ((find_indices:('a -> bool) -> 'a list ->(num)list) P l=  (find_indices_aux(( 0 : num)) P l))`;




(* ------------------------- *)
(* findIndex                 *)
(* ------------------------- *)

(* findIndex returns the first index of a list that satisfies a given predicate. *)
(*val findIndex : forall 'a. ('a -> bool) -> list 'a -> Maybe.maybe nat*)
val _ = Define `
 ((find_index:('a -> bool) -> 'a list ->(num)option) P l=  ((case find_indices P l of
    [] => NONE
  | x :: _ => SOME x
)))`;


(* ------------------------- *)
(* elemIndices               *)
(* ------------------------- *)

(*val elemIndices : forall 'a. Eq 'a => 'a -> list 'a -> list nat*)

(* ------------------------- *)
(* elemIndex                 *)
(* ------------------------- *)

(*val elemIndex : forall 'a. Eq 'a => 'a -> list 'a -> Maybe.maybe nat*)


(* ========================================================================== *)
(* Creating lists                                                             *)
(* ========================================================================== *)

(* ------------------------- *)
(* genlist                   *)
(* ------------------------- *)

(* [genlist f n] generates the list [f 0; f 1; ... (f (n-1))] *)
(*val genlist : forall 'a. (nat -> 'a) -> nat -> list 'a*)


(*let rec genlist f n= 
  match n with
    | 0 -> []
    | n' + 1 -> snoc (f n') (genlist f n')
  end*)


(* ------------------------- *)
(* replicate                 *)
(* ------------------------- *)

(*val replicate : forall 'a. nat -> 'a -> list 'a*)
(*let rec replicate n x= 
  match n with
    | 0 -> []
    | n' + 1 -> x :: replicate n' x
  end*)


(* ========================================================================== *)
(* Sublists                                                                   *)
(* ========================================================================== *)

(* ------------------------- *)
(* splitAt                   *)
(* ------------------------- *)

(* [splitAt n xs] returns a tuple (xs1, xs2), with "append xs1 xs2 = xs" and 
   "length xs1 = n". If there are not enough elements 
   in [xs], the original list and the empty one are returned. *)
(*val splitAtAcc : forall 'a. list 'a -> nat -> list 'a -> (list 'a * list 'a)*)
 val splitAtAcc_defn = Hol_defn "splitAtAcc" `
 ((splitAtAcc:'a list -> num -> 'a list -> 'a list#'a list) revAcc n l=  
  ((case l of
      []    => (REVERSE revAcc, [])
    | x::xs => if n <=( 0 : num) then (REVERSE revAcc, l) else splitAtAcc (x::revAcc) (n -( 1 : num)) xs
  )))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) Defn.save_defn splitAtAcc_defn;

(*val splitAt : forall 'a. nat -> list 'a -> (list 'a * list 'a)*)
(*let rec splitAt n l=  
   splitAtAcc [] n l*)


(* ------------------------- *)
(* take                      *)
(* ------------------------- *)

(* take n xs returns the prefix of xs of length n, or xs itself if n > length xs *)
(*val take : forall 'a. nat -> list 'a -> list 'a*)
(*let take n l=  fst (splitAt n l)*)

(* ------------------------- *)
(* drop                      *)
(* ------------------------- *)

(* [drop n xs] drops the first [n] elements of [xs]. It returns the empty list, if [n] > [length xs]. *)
(*val drop : forall 'a. nat -> list 'a -> list 'a*)
(*let drop n l=  snd (splitAt n l)*)

(* ------------------------------------ *)
(* splitWhile, takeWhile, and dropWhile *)
(* ------------------------------------ *)

(*val splitWhile_tr : forall 'a. ('a -> bool) -> list 'a -> list 'a -> (list 'a * list 'a)*)
 val _ = Define `
 ((splitWhile_tr:('a -> bool) -> 'a list -> 'a list -> 'a list#'a list) p ([]) acc= 
    (REVERSE acc, []))
/\ ((splitWhile_tr:('a -> bool) -> 'a list -> 'a list -> 'a list#'a list) p (x::xs) acc=    
 (if p x then
      splitWhile_tr p xs (x::acc)
    else
      (REVERSE acc, (x::xs))))`;


(*val splitWhile : forall 'a. ('a -> bool) -> list 'a -> (list 'a * list 'a)*)
val _ = Define `
 ((splitWhile:('a -> bool) -> 'a list -> 'a list#'a list) p xs=  (splitWhile_tr p xs []))`;


(* [takeWhile p xs] takes the first elements of [xs] that satisfy [p]. *)
(*val takeWhile : forall 'a. ('a -> bool) -> list 'a -> list 'a*)
val _ = Define `
 ((takeWhile:('a -> bool) -> 'a list -> 'a list) p l=  (FST (splitWhile p l)))`;


(* [dropWhile p xs] drops the first elements of [xs] that satisfy [p]. *)
(*val dropWhile : forall 'a. ('a -> bool) -> list 'a -> list 'a*)
val _ = Define `
 ((dropWhile:('a -> bool) -> 'a list -> 'a list) p l=  (SND (splitWhile p l)))`;


(* ------------------------- *)
(* isPrefixOf                *)
(* ------------------------- *)

(*val isPrefixOf : forall 'a. Eq 'a => list 'a -> list 'a -> bool*)
(*let rec isPrefixOf l1 l2=  match (l1, l2) with
  | ([], _) -> true
  | (_::_, []) -> false
  | (x::xs, y::ys) -> (x = y) && isPrefixOf xs ys
end*)

(* ------------------------- *)
(* update                    *)
(* ------------------------- *)
(*val update : forall 'a. list 'a -> nat -> 'a -> list 'a*)
(*let rec update l n e=  
  match l with
    | []      -> []
    | x :: xs -> if (Instance_Basic_classes_Eq_nat.=) n 0 then e :: xs else x :: (update xs ((Instance_Num_NumMinus_nat.-) n 1) e)
end*)



(* ========================================================================== *)
(* Searching lists                                                            *)
(* ========================================================================== *)

(* ------------------------- *)
(* Membership test           *)
(* ------------------------- *)

(* The membership test, one of the basic list functions, is actually tricky for
   Lem, because it is tricky, which equality to use. From Lem`s point of 
   perspective, we want to use the equality provided by the equality type - class.
   This allows for example to check whether a set is in a list of sets.

   However, in order to use the equality type class, elem essentially becomes
   existential quantification over lists. For types, which implement semantic
   equality (=) with syntactic equality, this is overly complicated. In
   our theorem prover backend, we would end up with overly complicated, harder
   to read definitions and some of the automation would be harder to apply.
   Moreover, nearly all the old Lem generated code would change and require 
   (hopefully minor) adaptions of proofs.

   For now, we ignore this problem and just demand, that all instances of
   the equality type class do the right thing for the theorem prover backends.   
*)

(*val elem : forall 'a. Eq 'a => 'a -> list 'a -> bool*)
(*val elemBy : forall 'a. ('a -> 'a -> bool) -> 'a -> list 'a -> bool*)

val _ = Define `
 ((elemBy:('a -> 'a -> bool) -> 'a -> 'a list -> bool) eq e l=  (EXISTS (eq e) l))`;

(*let elem=  elemBy (=)*)

(* ------------------------- *)
(* Find                      *)
(* ------------------------- *)
(*val find : forall 'a. ('a -> bool) -> list 'a -> Maybe.maybe 'a*) (* previously not of maybe type *)
 val _ = Define `
 ((list_find_opt:('a -> bool) -> 'a list -> 'a option) P ([])=  NONE)
/\ ((list_find_opt:('a -> bool) -> 'a list -> 'a option) P (x :: xs)=  (if P x then SOME x else list_find_opt P xs))`;



(* ----------------------------- *)
(* Lookup in an associative list *)
(* ----------------------------- *)
(*val lookup   : forall 'a 'b. Eq 'a              => 'a -> list ('a * 'b) -> Maybe.maybe 'b*)
(*val lookupBy : forall 'a 'b. ('a -> 'a -> bool) -> 'a -> list ('a * 'b) -> Maybe.maybe 'b*)

(* DPM: eta-expansion for Coq backend type-inference. *)
val _ = Define `
 ((lookupBy:('a -> 'a -> bool) -> 'a ->('a#'b)list -> 'b option) eq k m=  (OPTION_MAP (\ x .  SND x) (list_find_opt (\p .  
  (case (p ) of ( (k', _) ) => eq k k' )) m)))`;


(* ------------------------- *)
(* filter                    *)
(* ------------------------- *)
(*val filter : forall 'a. ('a -> bool) -> list 'a -> list 'a*)
(*let rec filter P l=  match l with
                       | [] -> []
                       | x :: xs -> if (P x) then x :: (filter P xs) else filter P xs
                     end*)


(* ------------------------- *)
(* partition                 *)
(* ------------------------- *)
(*val partition : forall 'a. ('a -> bool) -> list 'a -> list 'a * list 'a*)
(*let partition P l=  (filter P l, filter (fun x -> not (P x)) l)*)

(*val reversePartition : forall 'a. ('a -> bool) -> list 'a -> list 'a * list 'a*)
(*let reversePartition P l=  partition P (reverse l)*)


(* ------------------------- *)
(* delete first element      *)
(* with certain property     *)
(* ------------------------- *)

(*val deleteFirst : forall 'a. ('a -> bool) -> list 'a -> Maybe.maybe (list 'a)*) 
 val _ = Define `
 ((list_delete_first:('a -> bool) -> 'a list ->('a list)option) P ([])=  NONE)
/\ ((list_delete_first:('a -> bool) -> 'a list ->('a list)option) P (x :: xs)=  (if (P x) then SOME xs else OPTION_MAP (\ xs' .  x :: xs') (list_delete_first P xs)))`;



(*val delete : forall 'a. Eq 'a => 'a -> list 'a -> list 'a*)
(*val deleteBy : forall 'a. ('a -> 'a -> bool) -> 'a -> list 'a -> list 'a*)

val _ = Define `
 ((list_delete:('a -> 'a -> bool) -> 'a -> 'a list -> 'a list) eq x l=  (option_CASE (list_delete_first (eq x) l) l I))`;



(* ========================================================================== *)
(* Zipping and unzipping lists                                                *)
(* ========================================================================== *)

(* ------------------------- *)
(* zip                       *)
(* ------------------------- *)

(* zip takes two lists and returns a list of corresponding pairs. If one input list is short, excess elements of the longer list are discarded. *)
(*val zip : forall 'a 'b. list 'a -> list 'b -> list ('a * 'b)*) (* before combine *)
 val _ = Define `
 ((list_combine:'a list -> 'b list ->('a#'b)list) l1 l2=  ((case (l1, l2) of
    (x :: xs, y :: ys) => (x, y) :: list_combine xs ys
  | _ => []
)))`;


(* ------------------------- *)
(* unzip                     *)
(* ------------------------- *)

(*val unzip: forall 'a 'b. list ('a * 'b) -> (list 'a * list 'b)*)
(*let rec unzip l=  match l with
  | [] -> ([], [])
  | (x, y) :: xys -> let (xs, ys) = unzip xys in (x :: xs, y :: ys)
end*)

(* ------------------------- *)
(* distinct elements         *)
(* ------------------------- *)

(*val allDistinct : forall 'a. Eq 'a => list 'a -> bool*)
(*let rec allDistinct l=  
  match l with
    | [] -> true
    | (x::l') -> not (elem x l') && allDistinct l'
  end*)

(* some more useful functions *)
(*val mapMaybe : forall 'a 'b. ('a -> Maybe.maybe 'b) -> list 'a -> list 'b*)
 val mapMaybe_defn = Defn.Hol_multi_defns `
 ((mapMaybe:('a -> 'b option) -> 'a list -> 'b list) f ([])=  ([]))
/\ ((mapMaybe:('a -> 'b option) -> 'a list -> 'b list) f (x::xs)=      
 ((case f x of
        NONE => mapMaybe f xs
      | SOME y => y :: (mapMaybe f xs)
      )))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) mapMaybe_defn;

(*val mapi : forall 'a 'b. (nat -> 'a -> 'b) -> list 'a -> list 'b*)
 val mapiAux_defn = Defn.Hol_multi_defns `
 ((mapiAux:(num -> 'b -> 'a) -> num -> 'b list -> 'a list) f (n : num) ([])=  ([]))
/\ ((mapiAux:(num -> 'b -> 'a) -> num -> 'b list -> 'a list) f (n : num) (x :: xs)=  ((f n x) :: mapiAux f (n +( 1 : num)) xs))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) mapiAux_defn;
val _ = Define `
 ((mapi:(num -> 'a -> 'b) -> 'a list -> 'b list) f l=  (mapiAux f(( 0 : num)) l))`;


(*val deletes: forall 'a. Eq 'a => list 'a -> list 'a -> list 'a*)
val _ = Define `
 ((deletes:'a list -> 'a list -> 'a list) xs ys=  
 (FOLDL (combin$C (list_delete (=))) xs ys))`;


(* ========================================================================== *)
(* Comments (not clean yet, please ignore the rest of the file)               *)
(* ========================================================================== *)

(* ----------------------- *)
(* skipped from Haskell Lib*)
(* ----------------------- 

intersperse :: a -> [a] -> [a]
intercalate :: [a] -> [[a]] -> [a]
transpose :: [[a]] -> [[a]]
subsequences :: [a] -> [[a]]
permutations :: [a] -> [[a]]
foldl` :: (a -> b -> a) -> a -> [b] -> aSource
foldl1` :: (a -> a -> a) -> [a] -> aSource

and
or
sum
product
maximum
minimum
scanl
scanr
scanl1
scanr1
Accumulating maps

mapAccumL :: (acc -> x -> (acc, y)) -> acc -> [x] -> (acc, [y])Source
mapAccumR :: (acc -> x -> (acc, y)) -> acc -> [x] -> (acc, [y])Source

iterate :: (a -> a) -> a -> [a]
repeat :: a -> [a]
cycle :: [a] -> [a]
unfoldr


takeWhile :: (a -> Bool) -> [a] -> [a]Source
dropWhile :: (a -> Bool) -> [a] -> [a]Source
dropWhileEnd :: (a -> Bool) -> [a] -> [a]Source
span :: (a -> Bool) -> [a] -> ([a], [a])Source
break :: (a -> Bool) -> [a] -> ([a], [a])Source
break p is equivalent to span (not . p).
stripPrefix :: Eq a => [a] -> [a] -> Maybe [a]Source
group :: Eq a => [a] -> [[a]]Source
inits :: [a] -> [[a]]Source
tails :: [a] -> [[a]]Source


isPrefixOf :: Eq a => [a] -> [a] -> BoolSource
isSuffixOf :: Eq a => [a] -> [a] -> BoolSource
isInfixOf :: Eq a => [a] -> [a] -> BoolSource



notElem :: Eq a => a -> [a] -> BoolSource

zip3 :: [a] -> [b] -> [c] -> [(a, b, c)]Source
zip4 :: [a] -> [b] -> [c] -> [d] -> [(a, b, c, d)]Source
zip5 :: [a] -> [b] -> [c] -> [d] -> [e] -> [(a, b, c, d, e)]Source
zip6 :: [a] -> [b] -> [c] -> [d] -> [e] -> [f] -> [(a, b, c, d, e, f)]Source
zip7 :: [a] -> [b] -> [c] -> [d] -> [e] -> [f] -> [g] -> [(a, b, c, d, e, f, g)]Source

zipWith :: (a -> b -> c) -> [a] -> [b] -> [c]Source
zipWith3 :: (a -> b -> c -> d) -> [a] -> [b] -> [c] -> [d]Source
zipWith4 :: (a -> b -> c -> d -> e) -> [a] -> [b] -> [c] -> [d] -> [e]Source
zipWith5 :: (a -> b -> c -> d -> e -> f) -> [a] -> [b] -> [c] -> [d] -> [e] -> [f]Source
zipWith6 :: (a -> b -> c -> d -> e -> f -> g) -> [a] -> [b] -> [c] -> [d] -> [e] -> [f] -> [g]Source
zipWith7 :: (a -> b -> c -> d -> e -> f -> g -> h) -> [a] -> [b] -> [c] -> [d] -> [e] -> [f] -> [g] -> [h]Source


unzip3 :: [(a, b, c)] -> ([a], [b], [c])Source
unzip4 :: [(a, b, c, d)] -> ([a], [b], [c], [d])Source
unzip5 :: [(a, b, c, d, e)] -> ([a], [b], [c], [d], [e])Source
unzip6 :: [(a, b, c, d, e, f)] -> ([a], [b], [c], [d], [e], [f])Source
unzip7 :: [(a, b, c, d, e, f, g)] -> ([a], [b], [c], [d], [e], [f], [g])Source


lines :: String -> [String]Source
words :: String -> [String]Source
unlines :: [String] -> StringSource
unwords :: [String] -> StringSource
nub :: Eq a => [a] -> [a]Source
delete :: Eq a => a -> [a] -> [a]Source

(\\) :: Eq a => [a] -> [a] -> [a]Source
union :: Eq a => [a] -> [a] -> [a]Source
intersect :: Eq a => [a] -> [a] -> [a]Source
sort :: Ord a => [a] -> [a]Source
insert :: Ord a => a -> [a] -> [a]Source


nubBy :: (a -> a -> Bool) -> [a] -> [a]Source
deleteBy :: (a -> a -> Bool) -> a -> [a] -> [a]Source
deleteFirstsBy :: (a -> a -> Bool) -> [a] -> [a] -> [a]Source
unionBy :: (a -> a -> Bool) -> [a] -> [a] -> [a]Source
intersectBy :: (a -> a -> Bool) -> [a] -> [a] -> [a]Source
groupBy :: (a -> a -> Bool) -> [a] -> [[a]]Source
sortBy :: (a -> a -> Ordering) -> [a] -> [a]Source
insertBy :: (a -> a -> Ordering) -> a -> [a] -> [a]Source
maximumBy :: (a -> a -> Ordering) -> [a] -> aSource
minimumBy :: (a -> a -> Ordering) -> [a] -> aSource
genericLength :: Num i => [b] -> iSource
genericTake :: Integral i => i -> [a] -> [a]Source
genericDrop :: Integral i => i -> [a] -> [a]Source
genericSplitAt :: Integral i => i -> [b] -> ([b], [b])Source
genericIndex :: Integral a => [b] -> a -> bSource
genericReplicate :: Integral i => i -> a -> [a]Source


*)


(* ----------------------- *)
(* skipped from Lem Lib    *)
(* ----------------------- 


val for_all2 : forall 'a 'b. ('a -> 'b -> bool) -> list 'a -> list 'b -> bool
val exists2 : forall 'a 'b. ('a -> 'b -> bool) -> list 'a -> list 'b -> bool
val map2 : forall 'a 'b 'c. ('a -> 'b -> 'c) -> list 'a -> list 'b -> list 'c 
val rev_map2 : forall 'a 'b 'c. ('a -> 'b -> 'c) -> list 'a -> list 'b -> list 'c
val fold_left2 : forall 'a 'b 'c. ('a -> 'b -> 'c -> 'a) -> 'a -> list 'b -> list 'c -> 'a
val fold_right2 : forall 'a 'b 'c. ('a -> 'b -> 'c -> 'c) -> list 'a -> list 'b -> 'c -> 'c


(* now maybe result and called lookup *)
val assoc : forall 'a 'b. 'a -> list ('a * 'b) -> 'b
let inline {ocaml} assoc = Ocaml.List.assoc


val mem_assoc : forall 'a 'b. 'a -> list ('a * 'b) -> bool
val remove_assoc : forall 'a 'b. 'a -> list ('a * 'b) -> list ('a * 'b)



val stable_sort : forall 'a. ('a -> 'a -> num) -> list 'a -> list 'a
val fast_sort : forall 'a. ('a -> 'a -> num) -> list 'a -> list 'a

val merge : forall 'a. ('a -> 'a -> num) -> list 'a -> list 'a -> list 'a
val intersect : forall 'a. list 'a -> list 'a -> list 'a


*)

(*val     catMaybes : forall 'a. list (Maybe.maybe 'a) -> list 'a*)
 val catMaybes_defn = Defn.Hol_multi_defns `
 ((catMaybes:('a option)list -> 'a list) ([])=        
 ([]))
/\ ((catMaybes:('a option)list -> 'a list) (NONE :: xs')=        
 (catMaybes xs'))
/\ ((catMaybes:('a option)list -> 'a list) (SOME x :: xs')=        
 (x :: catMaybes xs'))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) catMaybes_defn;
val _ = export_theory()

