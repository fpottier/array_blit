(* -------------------------------------------------------------------------- *)

(* The implementation that we wish to benchmark. *)

open Array

(* -------------------------------------------------------------------------- *)

(* Set. *)

let chrono msg f x =
  let start = Unix.gettimeofday() in
  let y = f x in
  let stop = Unix.gettimeofday() in
  Printf.eprintf "%s = %.6f seconds\n%!" msg (stop -. start);
  y

let init n =
  let dummy = 42 in
  let v = make n dummy in
  v

let init n =
  chrono "initialization time" init n

let sum v n =
  let s = ref 0 in
  for i = 0 to n-1 do
    s := !s + unsafe_get v i
  done;
  Printf.printf "%d\n" !s

let sum v n =
  chrono "  finalization time" (sum v) n

let repetitions =
  200

let blit_poly src dst =
  let n = Array.length src in
  let i = ref 0 in
  while !i < n do
    unsafe_set dst !i (unsafe_get src !i);
    i := !i + 1
  done

let blit_mono (src : int array) dst =
  let n = Array.length src in
  let i = ref 0 in
  while !i < n do
    unsafe_set dst !i (unsafe_get src !i);
    i := !i + 1
  done

let blit_stdlib src dst =
  let n = Array.length src in
  Array.blit src 0 dst 0 n

external __blit : int array -> int array -> int -> unit = "hector_memcpy"

let unsafe_blit src dst =
  let n = Array.length src in
  __blit src dst n

let benchmark_poly n =
  (* Initialization: *)
  let src, dst = init n, init n in
  for _ = 1 to repetitions do
    (* Benchmark: *)
    blit_poly src dst;
  done;
  (* Dummy final read: *)
  sum dst n

let benchmark_mono n =
  (* Initialization: *)
  let src, dst = init n, init n in
  for _ = 1 to repetitions do
    (* Benchmark: *)
    blit_mono src dst;
  done;
  (* Dummy final read: *)
  sum dst n

let benchmark_stdlib n =
  (* Initialization: *)
  let src, dst = init n, init n in
  for _ = 1 to repetitions do
    (* Benchmark: *)
    blit_stdlib src dst;
  done;
  (* Dummy final read: *)
  sum dst n

let benchmark_unsafe n =
  (* Initialization: *)
  let src, dst = init n, init n in
  for _ = 1 to repetitions do
    (* Benchmark: *)
    unsafe_blit src dst;
  done;
  (* Dummy final read: *)
  sum dst n

(* -------------------------------------------------------------------------- *)

(* Main. *)

let n =
  100_000

type setting =
  | Mono
  | Poly
  | Stdlib
  | Unsafe

let setting =
  let setting = ref Mono in
  Arg.parse [
    "--mono", Arg.Unit (fun () -> setting := Mono), " Test monomorphic code.";
    "--poly", Arg.Unit (fun () -> setting := Poly), " Test polymorphic code.";
    "--stdlib", Arg.Unit (fun () -> setting := Stdlib), " Test Array.blit.";
    "--unsafe", Arg.Unit (fun () -> setting := Unsafe), " Test memcpy.";
  ] (fun _ -> ()) "Usage: main.exe [--mono | --poly | --stdlib | --unsafe]";
  !setting

let () =
  match setting with
  | Mono ->
      benchmark_mono n
  | Poly ->
      benchmark_poly n
  | Stdlib ->
      benchmark_stdlib n
  | Unsafe ->
      benchmark_unsafe n
