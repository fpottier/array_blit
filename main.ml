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

(* -------------------------------------------------------------------------- *)

(* Main. *)

let n =
  100_000

let mono =
  let mono = ref false in
  Arg.parse [
    "--mono", Arg.Set mono, " Test monomorphic code.";
  ] (fun _ -> ()) "Usage: main.exe [--mono]";
  !mono

let () =
  if mono then
    benchmark_mono n
  else
    benchmark_poly n
