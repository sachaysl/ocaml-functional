(* -------------------------------------------------------------------------- *)
(* Author: Brigitte Pientka                                                   *)
(* COMP 302 Programming Languages - FALL 2015                                 *)
(* Copyright © 2012 Brigitte Pientka                                         *)
(* -------------------------------------------------------------------------- *)
(*
  STUDENT NAME(S):
  STUDENT ID(S)  :


  Fill out the templage below.

*)

module type DICT =
sig
  module Elem : ORDERED
  type dict

  exception Error of string

  val create : unit -> dict
  val add    : dict -> Elem.t list -> dict
  val find   : dict -> Elem.t list -> bool
  val iter   : dict -> (unit -> unit) -> (Elem.t -> unit) ->  unit
  val number_of_elem : dict -> int
  val number_of_paths  : dict -> int
end;;

module DictTrie(K : ORDERED) : (DICT with type Elem.t = K.t) =
struct
  module Elem = K

  exception Error  of string

  type trie =
    | End
    | Node of  Elem.t * dict

  (* dictionaries are ordered *)
  and dict = trie list

  let create () = []

  (* ------------------------------------------------------------------------ *)
  (* Adding a list of elements in a trie ; duplicates are not allowed.        *)
  (* add: dict -> Elem.t list -> dict                                         *)
  (* Invariant: dictionary preserves the order                                *)

  let rec add (t:dict) (l: Elem.t list)  =
    match t, l with
    (* Base case: when at the end of the list of elements *)
    (* If End is already at the beginning (i.e., l is already
     * in the dictionary), don't add an extra End *)
    | End::_, [] -> t
    | _, []      -> End :: t

    | [], e::es               -> [Node (e, add [] es)]
    | End::t', e::es          -> End :: add t' l
    | Node(x, children_of_x)::t', e::es ->
       begin
         match Elem.compare x e with
         | Elem.Less    -> Node(x, children_of_x) :: add t' l
         | Elem.Equal   -> Node(x, add children_of_x es) :: t'
         | Elem.Greater -> Node(e, add (create ()) es) :: Node(x, children_of_x) :: t'
       end

  (* find : Elem.t list -> dict -> bool *)
  let rec find dict elem_list =
    match dict, elem_list with
    | [], _ -> false
    | End::_, [] -> true
    | Node(_, _)::_, [] -> false
    | End::t', e::es -> find t' elem_list
    | Node(x, children_of_x)::t, e::es ->
       begin
         match Elem.compare x e with
         | Elem.Less -> find t elem_list
         | Elem.Equal -> find children_of_x es
         | Elem.Greater -> false
       end

  let rec iter dict g f =
    match dict with
    | [] -> ()
    | End :: rest -> (g (); iter rest g f)
    | Node(x, sub) :: rest -> (f x; iter sub g f; iter rest g f)

  let number_of_elem d =
    let count = ref 0 in
    iter d (fun () -> ()) (fun _ -> incr count);
    !count

  let number_of_paths d =
     let count = ref 0 in
     iter d (fun () -> incr count) (fun _ -> ());
     !count
end



module IdNumbers =  DictTrie(IntLt)
module Phrases = DictTrie(StringLt)
module Names = DictTrie(CharLt)
