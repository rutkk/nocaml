(* NOCaml library *)
(* made by Jakub Rutkowski *)
(* https://github.com/rutkk/nocaml *)
module Noc = struct

  (* ── Loops ──────────────────────────────────────────────── *)

  let for_ (start : int) (stop : int) (step : int) (f : int -> unit) : unit =
    if step <= 0 then failwith "ValueError: step must be positive";
    let rec iter i = if i >= stop then () else (f i; iter (i + step)) in
    iter start

  let for_acc (start : int) (stop : int) (step : int) (acc : 'a) (f : 'a -> int -> 'a) : 'a =
    if step <= 0 then failwith "ValueError: step must be positive";
    let rec iter i acc = if i >= stop then acc else iter (i + step) (f acc i) in
    iter start acc

  let while_ (pred : 'a -> bool) (step : 'a -> 'a) (init : 'a) : 'a =
    let rec loop acc = if pred acc then loop (step acc) else acc in
    loop init
  
  let while_acc (pred : 'a -> bool) (step : 'a -> 'a) (acc : 'a) (f : 'a -> 'a -> 'a) : 'a =
    let rec loop acc = if pred acc then loop (f acc (step acc)) else acc in
    loop acc

  (* ── Pipe ───────────────────────────────────────────────── *)

  (* todo: think with_ over -> f x or something else *)

  (* ── Lists ──────────────────────────────────────────────── *)

  let sum (xs : int list) : int =
    List.fold_left (+) 0 xs

  let last_with (xs : 'a list) : 'a =
    if xs = [] then failwith "ValueError: last_with: list must not be empty"
    else List.hd (List.rev xs)

  let any (pred : 'a -> bool) (xs : 'a list) : bool =
    List.exists pred xs

  let all (pred : 'a -> bool) (xs : 'a list) : bool =
    List.for_all pred xs

  let first_with (pred : 'a -> bool) (xs : 'a list) : 'a =
    if xs = [] then failwith "ValueError: first_with: list must not be empty"
    else List.hd (List.filter pred xs)

  let flatten (xss : 'a list list) : 'a list =
    let rec loop res = function
      | [] -> List.rev res
      | h::t -> loop (List.rev_append h res) t
    in
    loop [] xss

  let avg (xs : int list) : float =
    if xs = [] then failwith "ValueError: avg: list must not be empty"
    else float_of_int (sum xs) /. float_of_int (List.length xs)

  let interleave (xs : 'a list) (ys : 'a list) : 'a list =
    let rec interleave_aux xs ys =
      match xs, ys with
      | [], _ -> ys
      | _, [] -> xs
      | x :: xs, y :: ys -> x :: y :: interleave_aux xs ys
    in
    interleave_aux xs ys

  let interleave_many (xss : 'a list list) : 'a list =
    let rec aux acc = function
      | [] -> List.rev acc
      | xss ->
        let heads = List.filter_map (fun xs ->
          match xs with [] -> None | h :: _ -> Some h) xss in
        let tails = List.filter_map (fun xs ->
          match xs with [] -> None | _ :: t -> Some t) xss in
        aux (List.rev_append heads acc) tails
    in
    aux [] xss

  let max (xs : int list) : int =
    if xs = [] then failwith "ValueError: max: list must not be empty"
    else List.fold_left max (List.hd xs) (List.tl xs)

  let min (xs : int list) : int =
    if xs = [] then failwith "ValueError: min: list must not be empty"
    else List.fold_left min (List.hd xs) (List.tl xs)

let counter (xs : 'a list) : ('a * int) list =
  let rec aux acc = function
    | [] -> acc
    | x :: xs' ->
      let seen = List.exists (fun (k, _) -> k = x) acc in
      let acc =
        if seen
        then List.map (fun (k, v) -> if k = x then (k, v + 1) else (k, v)) acc
        else acc @ [(x, 1)]
      in
      aux acc xs'
  in
  aux [] xs

let sort (xs : 'a list) : 'a list =
  let rec aux = function
    | [] -> []
    | x :: xs' ->
      let smaller = List.filter (fun y -> compare y x < 0) xs' in
      let larger = List.filter (fun y -> compare y x >= 0) xs' in
      aux smaller @ (x :: aux larger)
  in
  aux xs

  (* ── Aliases ────────────────────────────────────────────── *)

let reverse (xs: 'a list) : 'a list =
  List.rev xs

let first (xs: 'a list) : 'a =
  if xs = [] then failwith "ValueError: first: list must not be empty"
  else List.hd xs

let last (xs: 'a list) : 'a =
  if xs = [] then failwith "ValueError: last: list must not be empty"
  else List.hd (List.rev xs)

let at (xs: 'a list) (index: int) : 'a =
  if index < 0 then failwith "ValueError: at: index must be non-negative"
  else if index >= List.length xs then failwith "ValueError: at: index out of range"
  else List.nth xs index

  (* ── Strings ────────────────────────────────────────────── *)
  
  let chars (s : string) : string list =
    String.to_seq s |> Seq.map (String.make 1) |> List.of_seq

  let contains (sub : string) (target : string) : bool =
    let sub_len = String.length sub in
    let target_len = String.length target in
    let rec aux i =
      if sub_len = 0 then true
      else if i > target_len - sub_len then false
      else if String.sub target i sub_len = sub then true
      else aux (i + 1)
    in
    aux 0

  let join (sep : string) (xs : string list) : string =
    match xs with
    | [] -> ""
    | [x] -> x
    | x :: rest ->
      List.fold_left (fun acc s -> acc ^ sep ^ s) x rest

  let split (delim : char) (s : string) : string list =
    String.split_on_char delim s

  let slice (start : int) (stop : int) (step : int) (xs : 'a list) : 'a list =
    let rec aux i l acc =
      match l with
      | [] -> List.rev acc
      | x :: xs_tail ->
        if i >= stop then List.rev acc
        else if i >= start && (i - start) mod step = 0
          then aux (i + 1) xs_tail (x :: acc)
          else aux (i + 1) xs_tail acc
    in
    if step <= 0 then failwith "ValueError: slice: step must be positive"
    else aux 0 xs []

  (* ── Math ────────────────────────────────────────────── *)

  let rec pow (x : int) (n : int) : int =
    match n with
    | 0 -> 1
    | 1 -> x
    | n -> x * pow x (n - 1)

  let sqrt_of_int (x: int) : int =
    if x < 0 then failwith "ValueError: sqrt_of_int: negative argument"
    else
      let rec aux low high =
        if low > high then high
        else
          let mid = (low + high) / 2 in
          let mid_sq = mid * mid in
          if mid_sq = x then mid
          else if mid_sq < x then aux (mid + 1) high
          else aux low (mid - 1)
      in
      aux 0 x

  (* ── Anti-dune build warnings ────────────────────── *)

  let _ = (
    for_, for_acc, while_, while_acc,
    sum, last_with, any, all, first_with, flatten, avg,
    interleave, interleave_many, max, min,
    counter, sort, reverse, first, last, at,
    chars, contains, join, split, slice,
    pow, sqrt_of_int
  )

end
