chapter \<open>Generated by Lem from ../../src/gen_lib/prompt_monad.lem.\<close>

theory "Prompt_monad" 

imports 
 	 Main
	 "Lem_pervasives_extra" 
	 "Sail_instr_kinds" 
	 "Sail_values" 

begin 

(*open import Pervasives_extra*)
(*open import Sail_impl_base*)
(*open import Sail_instr_kinds*)
(*open import Sail_values*)

type_synonym register_name =" string "
type_synonym address =" bitU list "

datatype( 'regval, 'a, 'e) monad =
    Done " 'a "
  (* Read a number of bytes from memory, returned in little endian order *)
  | Read_mem " read_kind " " address " " nat " " ( memory_byte list \<Rightarrow> ('regval, 'a, 'e) monad)"
  (* Read the tag of a memory address *)
  | Read_tag " address " " (bitU \<Rightarrow> ('regval, 'a, 'e) monad)"
  (* Tell the system a write is imminent, at address lifted, of size nat *)
  | Write_ea " write_kind " " address " " nat " " ('regval, 'a, 'e) monad "
  (* Request the result of store-exclusive *)
  | Excl_res " (bool \<Rightarrow> ('regval, 'a, 'e) monad)"
  (* Request to write memory at last signalled address. Memory value should be 8
     times the size given in ea signal, given in little endian order *)
  | Write_memv " memory_byte list " " (bool \<Rightarrow> ('regval, 'a, 'e) monad)"
  (* Request to write the tag at given address. *)
  | Write_tag " address " " bitU " " (bool \<Rightarrow> ('regval, 'a, 'e) monad)"
  (* Tell the system to dynamically recalculate dependency footprint *)
  | Footprint " ('regval, 'a, 'e) monad "
  (* Request a memory barrier *)
  | Barrier " barrier_kind " " ('regval, 'a, 'e) monad "
  (* Request to read register, will track dependency when mode.track_values *)
  | Read_reg " register_name " " ('regval \<Rightarrow> ('regval, 'a, 'e) monad)"
  (* Request to write register *)
  | Write_reg " register_name " " 'regval " " ('regval, 'a, 'e) monad "
  | Undefined " (bool \<Rightarrow> ('regval, 'a, 'e) monad)"
  (* Print debugging or tracing information *)
  | Print " string " " ('regval, 'a, 'e) monad "
  (*Result of a failed assert with possible error message to report*)
  | Fail " string "
  (* Exception of type 'e *)
  | Exception " 'e "

(*val return : forall 'rv 'a 'e. 'a -> monad 'rv 'a 'e*)
definition return  :: " 'a \<Rightarrow>('rv,'a,'e)monad "  where 
     " return a = ( Done a )"


(*val bind : forall 'rv 'a 'b 'e. monad 'rv 'a 'e -> ('a -> monad 'rv 'b 'e) -> monad 'rv 'b 'e*)
function (sequential,domintros)  bind  :: "('rv,'a,'e)monad \<Rightarrow>('a \<Rightarrow>('rv,'b,'e)monad)\<Rightarrow>('rv,'b,'e)monad "  where 
     " bind (Done a) f = ( f a )"
|" bind (Read_mem rk a sz k) f = ( Read_mem rk a sz (\<lambda> v .  bind (k v) f))"
|" bind (Read_tag a k) f = (       Read_tag a       (\<lambda> v .  bind (k v) f))"
|" bind (Write_memv descr k) f = ( Write_memv descr (\<lambda> v .  bind (k v) f))"
|" bind (Write_tag a t k) f = (    Write_tag a t    (\<lambda> v .  bind (k v) f))"
|" bind (Read_reg descr k) f = (   Read_reg descr   (\<lambda> v .  bind (k v) f))"
|" bind (Excl_res k) f = (         Excl_res         (\<lambda> v .  bind (k v) f))"
|" bind (Undefined k) f = (        Undefined        (\<lambda> v .  bind (k v) f))"
|" bind (Write_ea wk a sz k) f = ( Write_ea wk a sz (bind k f))"
|" bind (Footprint k) f = (        Footprint        (bind k f))"
|" bind (Barrier bk k) f = (       Barrier bk       (bind k f))"
|" bind (Write_reg r v k) f = (    Write_reg r v    (bind k f))"
|" bind (Print msg k) f = (        Print msg        (bind k f))"
|" bind (Fail descr) f = (         Fail descr )"
|" bind (Exception e) f = (        Exception e )" 
by pat_completeness auto


(*val exit : forall 'rv 'a 'e. unit -> monad 'rv 'a 'e*)
definition exit0  :: " unit \<Rightarrow>('rv,'a,'e)monad "  where 
     " exit0 _ = ( Fail (''exit''))"


(*val undefined_bool : forall 'rv 'e. unit -> monad 'rv bool 'e*)
definition undefined_bool  :: " unit \<Rightarrow>('rv,(bool),'e)monad "  where 
     " undefined_bool _ = ( Undefined return )"


(*val assert_exp : forall 'rv 'e. bool -> string -> monad 'rv unit 'e*)
definition assert_exp  :: " bool \<Rightarrow> string \<Rightarrow>('rv,(unit),'e)monad "  where 
     " assert_exp exp msg = ( if exp then Done ()  else Fail msg )"


(*val throw : forall 'rv 'a 'e. 'e -> monad 'rv 'a 'e*)
definition throw  :: " 'e \<Rightarrow>('rv,'a,'e)monad "  where 
     " throw e = ( Exception e )"


(*val try_catch : forall 'rv 'a 'e1 'e2. monad 'rv 'a 'e1 -> ('e1 -> monad 'rv 'a 'e2) -> monad 'rv 'a 'e2*)
function (sequential,domintros)  try_catch  :: "('rv,'a,'e1)monad \<Rightarrow>('e1 \<Rightarrow>('rv,'a,'e2)monad)\<Rightarrow>('rv,'a,'e2)monad "  where 
     " try_catch (Done a) h = (             Done a )"
|" try_catch (Read_mem rk a sz k) h = ( Read_mem rk a sz (\<lambda> v .  try_catch (k v) h))"
|" try_catch (Read_tag a k) h = (       Read_tag a       (\<lambda> v .  try_catch (k v) h))"
|" try_catch (Write_memv descr k) h = ( Write_memv descr (\<lambda> v .  try_catch (k v) h))"
|" try_catch (Write_tag a t k) h = (    Write_tag a t    (\<lambda> v .  try_catch (k v) h))"
|" try_catch (Read_reg descr k) h = (   Read_reg descr   (\<lambda> v .  try_catch (k v) h))"
|" try_catch (Excl_res k) h = (         Excl_res         (\<lambda> v .  try_catch (k v) h))"
|" try_catch (Undefined k) h = (        Undefined        (\<lambda> v .  try_catch (k v) h))"
|" try_catch (Write_ea wk a sz k) h = ( Write_ea wk a sz (try_catch k h))"
|" try_catch (Footprint k) h = (        Footprint        (try_catch k h))"
|" try_catch (Barrier bk k) h = (       Barrier bk       (try_catch k h))"
|" try_catch (Write_reg r v k) h = (    Write_reg r v    (try_catch k h))"
|" try_catch (Print msg k) h = (        Print msg        (try_catch k h))"
|" try_catch (Fail descr) h = (         Fail descr )"
|" try_catch (Exception e) h = (        h e )" 
by pat_completeness auto


(* For early return, we abuse exceptions by throwing and catching
   the return value. The exception type is either 'r 'e, where Right e
   represents a proper exception and Left r an early return of value r. *)
type_synonym( 'rv, 'a, 'r, 'e) monadR =" ('rv, 'a, ( ('r, 'e)sum)) monad "

(*val early_return : forall 'rv 'a 'r 'e. 'r -> monadR 'rv 'a 'r 'e*)
definition early_return  :: " 'r \<Rightarrow>('rv,'a,(('r,'e)sum))monad "  where 
     " early_return r = ( throw (Inl r))"


(*val catch_early_return : forall 'rv 'a 'e. monadR 'rv 'a 'a 'e -> monad 'rv 'a 'e*)
definition catch_early_return  :: "('rv,'a,(('a,'e)sum))monad \<Rightarrow>('rv,'a,'e)monad "  where 
     " catch_early_return m = (
  try_catch m
    (\<lambda>x .  (case  x of   Inl a => return a | Inr e => throw e )))"


(* Lift to monad with early return by wrapping exceptions *)
(*val liftR : forall 'rv 'a 'r 'e. monad 'rv 'a 'e -> monadR 'rv 'a 'r 'e*)
definition liftR  :: "('rv,'a,'e)monad \<Rightarrow>('rv,'a,(('r,'e)sum))monad "  where 
     " liftR m = ( try_catch m (\<lambda> e .  throw (Inr e)))"


(* Catch exceptions in the presence of early returns *)
(*val try_catchR : forall 'rv 'a 'r 'e1 'e2. monadR 'rv 'a 'r 'e1 -> ('e1 -> monadR 'rv 'a 'r 'e2) ->  monadR 'rv 'a 'r 'e2*)
definition try_catchR  :: "('rv,'a,(('r,'e1)sum))monad \<Rightarrow>('e1 \<Rightarrow>('rv,'a,(('r,'e2)sum))monad)\<Rightarrow>('rv,'a,(('r,'e2)sum))monad "  where 
     " try_catchR m h = (
  try_catch m
    (\<lambda>x .  (case  x of   Inl r => throw (Inl r) | Inr e => h e )))"


(*val maybe_fail : forall 'rv 'a 'e. string -> maybe 'a -> monad 'rv 'a 'e*)
definition maybe_fail  :: " string \<Rightarrow> 'a option \<Rightarrow>('rv,'a,'e)monad "  where 
     " maybe_fail msg = ( \<lambda>x .  
  (case  x of   Some a => return a | None => Fail msg ) )"


(*val read_mem_bytes : forall 'rv 'a 'b 'e. Bitvector 'a, Bitvector 'b => read_kind -> 'a -> integer -> monad 'rv (list memory_byte) 'e*)
definition read_mem_bytes  :: " 'a Bitvector_class \<Rightarrow> 'b Bitvector_class \<Rightarrow> read_kind \<Rightarrow> 'a \<Rightarrow> int \<Rightarrow>('rv,((memory_byte)list),'e)monad "  where 
     " read_mem_bytes dict_Sail_values_Bitvector_a dict_Sail_values_Bitvector_b rk addr sz = (
  Read_mem rk ((bits_of_method   dict_Sail_values_Bitvector_a) addr) (nat_of_int sz) return )"


(*val read_mem : forall 'rv 'a 'b 'e. Bitvector 'a, Bitvector 'b => read_kind -> 'a -> integer -> monad 'rv 'b 'e*)
definition read_mem  :: " 'a Bitvector_class \<Rightarrow> 'b Bitvector_class \<Rightarrow> read_kind \<Rightarrow> 'a \<Rightarrow> int \<Rightarrow>('rv,'b,'e)monad "  where 
     " read_mem dict_Sail_values_Bitvector_a dict_Sail_values_Bitvector_b rk addr sz = (
  bind
    (read_mem_bytes dict_Sail_values_Bitvector_a dict_Sail_values_Bitvector_a rk addr sz)
    (\<lambda> bytes . 
       maybe_fail (''bits_of_mem_bytes'') (
  (of_bits_method   dict_Sail_values_Bitvector_b) (bits_of_mem_bytes bytes))))"


(*val read_tag : forall 'rv 'a 'e. Bitvector 'a => 'a -> monad 'rv bitU 'e*)
definition read_tag  :: " 'a Bitvector_class \<Rightarrow> 'a \<Rightarrow>('rv,(bitU),'e)monad "  where 
     " read_tag dict_Sail_values_Bitvector_a addr = ( Read_tag (
  (bits_of_method   dict_Sail_values_Bitvector_a) addr) return )"


(*val excl_result : forall 'rv 'e. unit -> monad 'rv bool 'e*)
definition excl_result  :: " unit \<Rightarrow>('rv,(bool),'e)monad "  where 
     " excl_result _ = ( 
  (let k = (\<lambda> successful .  (return successful)) in Excl_res k) )"


(*val write_mem_ea : forall 'rv 'a 'e. Bitvector 'a => write_kind -> 'a -> integer -> monad 'rv unit 'e*)
definition write_mem_ea  :: " 'a Bitvector_class \<Rightarrow> write_kind \<Rightarrow> 'a \<Rightarrow> int \<Rightarrow>('rv,(unit),'e)monad "  where 
     " write_mem_ea dict_Sail_values_Bitvector_a wk addr sz = ( Write_ea wk (
  (bits_of_method   dict_Sail_values_Bitvector_a) addr) (nat_of_int sz) (Done () ))"


(*val write_mem_val : forall 'rv 'a 'e. Bitvector 'a => 'a -> monad 'rv bool 'e*)
definition write_mem_val  :: " 'a Bitvector_class \<Rightarrow> 'a \<Rightarrow>('rv,(bool),'e)monad "  where 
     " write_mem_val dict_Sail_values_Bitvector_a v = ( (case  mem_bytes_of_bits 
  dict_Sail_values_Bitvector_a v of
    Some v => Write_memv v return
  | None => Fail (''write_mem_val'')
))"


(*val write_tag : forall 'rv 'a 'e. Bitvector 'a => 'a -> bitU -> monad 'rv bool 'e*)
definition write_tag  :: " 'a Bitvector_class \<Rightarrow> 'a \<Rightarrow> bitU \<Rightarrow>('rv,(bool),'e)monad "  where 
     " write_tag dict_Sail_values_Bitvector_a addr b = ( Write_tag (
  (bits_of_method   dict_Sail_values_Bitvector_a) addr) b return )"


(*val read_reg : forall 's 'rv 'a 'e. register_ref 's 'rv 'a -> monad 'rv 'a 'e*)
definition read_reg  :: "('s,'rv,'a)register_ref \<Rightarrow>('rv,'a,'e)monad "  where 
     " read_reg reg = ( 
  (let k = (\<lambda> v . 
            (case (of_regval   reg) v of
                  Some v => Done v
              | None => Fail (''read_reg: unrecognised value'')
            )) in Read_reg (name   reg) k) )"


(* TODO
val read_reg_range : forall 's 'r 'rv 'a 'e. Bitvector 'a => register_ref 's 'rv 'r -> integer -> integer -> monad 'rv 'a 'e
let read_reg_range reg i j =
  read_reg_aux of_bits (external_reg_slice reg (nat_of_int i,nat_of_int j))

let read_reg_bit reg i =
  read_reg_aux (fun v -> v) (external_reg_slice reg (nat_of_int i,nat_of_int i)) >>= fun v ->
  return (extract_only_element v)

let read_reg_field reg regfield =
  read_reg_aux (external_reg_field_whole reg regfield)

let read_reg_bitfield reg regfield =
  read_reg_aux (external_reg_field_whole reg regfield) >>= fun v ->
  return (extract_only_element v)*)

definition reg_deref  :: "('d,'c,'b)register_ref \<Rightarrow>('c,'b,'a)monad "  where 
     " reg_deref = ( read_reg )"


(*val write_reg : forall 's 'rv 'a 'e. register_ref 's 'rv 'a -> 'a -> monad 'rv unit 'e*)
definition write_reg  :: "('s,'rv,'a)register_ref \<Rightarrow> 'a \<Rightarrow>('rv,(unit),'e)monad "  where 
     " write_reg reg v = ( Write_reg(name   reg) ((regval_of   reg) v) (Done () ))"


(* TODO
let write_reg reg v =
  write_reg_aux (external_reg_whole reg) v
let write_reg_range reg i j v =
  write_reg_aux (external_reg_slice reg (nat_of_int i,nat_of_int j)) v
let write_reg_pos reg i v =
  let iN = nat_of_int i in
  write_reg_aux (external_reg_slice reg (iN,iN)) [v]
let write_reg_bit = write_reg_pos
let write_reg_field reg regfield v =
  write_reg_aux (external_reg_field_whole reg regfield.field_name) v
let write_reg_field_bit reg regfield bit =
  write_reg_aux (external_reg_field_whole reg regfield.field_name)
                (Vector [bit] 0 (is_inc_of_reg reg))
let write_reg_field_range reg regfield i j v =
  write_reg_aux (external_reg_field_slice reg regfield.field_name (nat_of_int i,nat_of_int j)) v
let write_reg_field_pos reg regfield i v =
  write_reg_field_range reg regfield i i [v]
let write_reg_field_bit = write_reg_field_pos*)

(*val barrier : forall 'rv 'e. barrier_kind -> monad 'rv unit 'e*)
definition barrier  :: " barrier_kind \<Rightarrow>('rv,(unit),'e)monad "  where 
     " barrier bk = ( Barrier bk (Done () ))"


(*val footprint : forall 'rv 'e. unit -> monad 'rv unit 'e*)
definition footprint  :: " unit \<Rightarrow>('rv,(unit),'e)monad "  where 
     " footprint _ = ( Footprint (Done () ))"

end
