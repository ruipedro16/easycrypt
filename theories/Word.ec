require Bool.
require import Int.

op length: int.
axiom length_pos: 0 <= length.

(* A word only has the get operator: its size is fixed. *)
(* Ideally, we would have cloned bitstrings, but they are equipped with an empty operator. *)
type word.
op "_.[_]": word -> int -> bool.

pred (==)(w0, w1:word) = forall i,
  0 <= i => i < length =>
  w0.[i] = w1.[i].

axiom extensionality: forall w0 w1,
  w0 == w1 => w0 = w1.

(* set *)
op "_.[_<-_]": word -> int -> bool -> word.
axiom set_get: forall w i j b,
  0 <= i => i < length =>
  w.[i <- b].[j] = (i = j) ? b : w.[j].

(* zeros *)
op zeros: word.
axiom zeros_get: forall i,
  0 <= i => i < length =>
  zeros.[i] = false.

(* xor *)
op (^^): word -> word -> word.
axiom xor_get: forall w0 w1 i,
  0 <= i => i < length =>
  (w0 ^^ w1).[i] = Bool.(^^) w0.[i] w1.[i].

lemma xor_nilpotent: forall w,
  w ^^ w = zeros.
proof.
intros w; apply extensionality; smt.
save.

lemma xor_commutative: forall w0 w1,
  w0 ^^ w1 = w1 ^^ w0.
proof.
intros w0 w1; apply extensionality.
cut xorb_commute: (forall i, 0 <= i => i < length =>
                    (w0 ^^ w1).[i] = (w1 ^^ w0).[i]);
smt.
save.

lemma xor_assoc : forall x y z, x ^^ (y ^^ z) = (x ^^ y) ^^ z.
proof.
  intros x y z; apply extensionality.
  intros i Hge Hlt; smt.
save.

lemma xor_zeros: forall w,
  w ^^ zeros = w.
proof.
intros w; apply extensionality.
cut xorb_zeros: (forall i, 0 <= i => i < length =>
                  (w ^^ zeros).[i] = w.[i]);
smt.
save.

lemma xor_opt : forall x y , x ^^ y ^^ y = x.
proof.
 by intros => x y; rewrite -xor_assoc xor_nilpotent xor_zeros //.
save.

(* TODO: Finish writing the conversions *)
require        Array.
op to_array: word -> bool Array.array.
axiom to_array_length: forall w,
  Array.length (to_array w) = length.
axiom to_array_get: forall w i,
  0 <= i => i < length =>
  Array."_.[_]" (to_array w) i = w.[i].

op from_array: bool Array.array -> word.
axiom from_array_get: forall a i,
  Array.length a = length =>
  0 <= i => i < length =>
  (from_array a).[i] = Array."_.[_]" a i.

lemma to_array_from_array: forall a,
  Array.length a = length =>
  to_array (from_array a) = a.
proof.
intros a Length; apply Array.extensionality; smt.
save.

lemma from_array_to_array: forall w,
  from_array (to_array w) = w.
proof.
intros w; apply extensionality; smt.
save.

require import Real.
require import Distr.
require import FSet.

(* Uniform distribution on fixed-length words *)
theory Dword.
  op dword : word distr.

  axiom mu_x_def : forall (w:word), mu_x dword w = 1%r / (2 ^ length)%r.

  axiom lossless : weight dword = 1%r.
  
  lemma supp_def : forall (w:word), in_supp w dword.
  proof.
    intros w; delta in_supp; simplify.
    rewrite (mu_x_def w).
    cut H: (0%r < (2 ^ length)%r); [smt | ].
    cut H1: (0%r < Real.one * inv (2 ^ length)%r).
    rewrite -(Real.Inverse (2 ^ length)%r _); smt.
    smt.  
  qed.

  lemma mu_cpMemw: forall (s : word set),
    mu dword (cpMem s) = (card s)%r *( 1%r / (2^length)%r).
   proof.
    intros X;rewrite (mu_cpMem _ _ ( 1%r / (2^length)%r));last trivial.
    intros x;rewrite mu_x_def;smt.
  qed.
  import FSet.Dexcepted.
  
  lemma lossless_restrw: forall (X : word set),
    FSet.card X < 2^length =>
    weight (dword \ X) = 1%r. 
  proof.
   intros=> X Hcard; rewrite lossless_restr ?lossless ?mu_cpMemw //;
   (apply (real_lt_trans _ ((2^length)%r * (1%r / (2 ^ length)%r)) _);last smt);
   (apply mulrM; last rewrite from_intM //);
   smt.
  qed.
end Dword.
