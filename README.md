# NOCaml

### Make OCaml high level again

Despite OCaml claiming to be a high level language, many of its features still feel like Assembly. `NOCaml` (for Klausur purposes referred to as `Noc`) is a simple, single-module, exam-ready library to de-patternize common patterns in OCaml data manipulation and operations and help you pass the TUM FPV Klausur.

It's **very opinionated** - by design. It's designed with a simple and unambiguous syntax designed for students.

- **Imperative-style:** replaces the `iter` pattern with a simple C-style for and while loop while remaining purely FP.
- **Fail fast and loud**: No `option`. Don't chain `None` through 3 different functions.
- **Compliant**: Fully FP, embeddable into any OCaml project as a single module. Artemis supports modules. Technically not cheating.

## Usage

Drop `noc.ml` into your project's `src/` directory and open it:

```ocaml
open Noc
let _ = Noc.sum [1; 2; 3]
```

Coming soon: drop as a single-line module into any .ml file. Accepted by Artemis.

## Comparisons

### 1. Power

Vorlesung-style OCaml:
```ocaml
let rec iter f n start =
  if n < 1 then start else iter f (n - 1) (f start) in
  let power = iter x n (fun -> a * x) n 1 in
power 2 10
```

Correct OCaml (stdlib):
```ocaml
let rec pow b n = match n with
  | 0 -> 1
  | n -> b * pow b (n - 1) in
pow 2 10
```

NOCaml:
```ocaml
Noc.pow 2 10
```

### 2. Higher order functions

Vorlesung-style OCaml:
```ocaml
let rec sum =
  if n < 1 then 0 else sum f (n - 1) + f n in
  let gauss n = sum (fun i -> i) n in
gauss 10
```

NOCaml:
```ocaml
let gauss n = Noc.for_acc 0 n 1 0 (fun acc i -> acc + i) in
gauss 10
```

NOCaml mirrors C syntax while remaining pure FP:
```c
int acc = 0; int n = 10;
for (int i = 0; i < n; i++) {
  acc += i;
}
```

### 3. Lists

```ocaml
(* last element without pattern matching boilerplate *)
Noc.last [1; 2; 3]           (* 3 *)

(* find first match — no Option.get gymnastics *)
Noc.first (fun x -> x > 2) [1; 2; 3; 4]   (* 3 *)

(* python-style slicing *)
Noc.slice 1 4 1 [0; 1; 2; 3; 4; 5]        (* [1; 2; 3] *)
Noc.slice 0 6 2 [0; 1; 2; 3; 4; 5]        (* [0; 2; 4] *)
```

## API Reference

### Loops

| Function | Signature | Description |
|----------|-----------|-------------|
| `for_` | `int -> int -> int -> (int -> unit) -> unit` | C-style for loop. `for_ start stop step f` |
| `for_acc` | `int -> int -> int -> 'a -> ('a -> int -> 'a) -> 'a` | For loop with accumulator |
| `while_` | `('a -> bool) -> ('a -> 'a) -> 'a -> 'a` | While loop. Runs `step` while `pred` holds |
| `while_acc` | `('a -> bool) -> ('a -> 'a) -> 'a -> ('a -> 'a -> 'a) -> 'a` | While loop with accumulator and combiner |

### Lists

| Function | Signature | Description |
|----------|-----------|-------------|
| `sum` | `int list -> int` | Sum of all elements |
| `avg` | `int list -> float` | Arithmetic mean (fails on empty list) |
| `last` | `'a list -> 'a` | Last element (fails on empty list) |
| `first` | `('a -> bool) -> 'a list -> 'a` | First element matching predicate |
| `any` | `('a -> bool) -> 'a list -> bool` | True if any element matches |
| `all` | `('a -> bool) -> 'a list -> bool` | True if all elements match |
| `flatten` | `'a list list -> 'a list` | Flatten nested lists |
| `interleave` | `'a list -> 'a list -> 'a list` | Alternate elements from two lists |
| `interleave_many` | `'a list list -> 'a list` | Round-robin interleave across many lists |
| `slice` | `int -> int -> int -> 'a list -> 'a list` | Python-style `[start:stop:step]` |
### Strings

| Function | Signature | Description |
|----------|-----------|-------------|
| `chars` | `string -> string list` | Split string into single-char strings |
| `contains` | `string -> string -> bool` | `contains sub target` — substring check |
| `join` | `string -> string list -> string` | Join strings with separator |
| `split` | `char -> string -> string list` | Split string on delimiter char |

### Math

| Function | Signature | Description |
|----------|-----------|-------------|
| `pow` | `int -> int -> int` | `pow x n` — integer exponentiation |
| `sqrt_of_int` | `int -> int` | Integer square root (floor) |

## Running Tests

```bash
dune runtest
```

51 tests (20 QCheck property tests + 31 unit tests) covering every function.

## License

MIT
