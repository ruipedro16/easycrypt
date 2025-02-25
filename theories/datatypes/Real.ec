(* -------------------------------------------------------------------- *)
require import Int Ring AlgTactic CoreReal.

abbrev ( < ) = CoreReal.lt.
abbrev (<= ) = CoreReal.le.
abbrev ( + ) = CoreReal.add.
abbrev ([-]) = CoreReal.opp.
abbrev ( * ) = CoreReal.mul.
abbrev inv   = CoreReal.inv.
abbrev (%r)  = CoreReal.from_int.

abbrev ( - ) (x y : real) = x + (-y).
abbrev ( / ) (x y : real) = x * (inv y).

abbrev [-printing] ( >  ) (x y : real) = y < x.
abbrev [-printing] ( >= ) (x y : real) = y <= x.

(* -------------------------------------------------------------------- *)
op "`|_|" x = if from_int 0 <= x then x else -x.
abbrev b2r (b:bool) = if b then from_int 1 else from_int 0.

(* -------------------------------------------------------------------- *)
lemma fromint0 : 0%r = CoreReal.zero by [].
lemma fromint1 : 1%r = CoreReal.one  by [].

lemma fromintN (z     : int) : (-z)%r = - z%r by smt().

lemma fromintD (z1 z2 : int) : (z1 + z2)%r = z1%r + z2%r by smt().

lemma fromintB (z1 z2 : int) : (z1 - z2)%r = z1%r - z2%r.
proof. by rewrite fromintD fromintN. qed.

lemma fromintM (z1 z2 : int) : (z1 * z2)%r = z1%r * z2%r by smt().

lemma eq_fromint (z1 z2 : int) :
  (z1%r = z2%r) <=> (z1 = z2)
by smt().

lemma le_fromint (z1 z2 : int) :
  (z1%r <= z2%r) <=> (z1 <= z2)
by smt().

lemma lt_fromint (z1 z2 : int) :
  (z1%r < z2%r) <=> (z1 < z2)
by smt().

lemma fromint_abs  (z : int) : `|z|%r = `|z%r| by smt().

hint rewrite lte_fromint : le_fromint lt_fromint.

(* -------------------------------------------------------------------- *)
theory RField.
  clone include Ring.Field with
    type t <- real,
    op   zeror <- 0%r,
    op   oner  <- 1%r,
    op   ( + ) <- CoreReal.add,
    op   [ - ] <- CoreReal.opp,
    op   ( * ) <- CoreReal.mul,
    op   invr  <- CoreReal.inv
    proof *
  remove abbrev (-) remove abbrev (/).
  realize addrA     by smt().
  realize addrC     by smt().
  realize add0r     by smt().
  realize addNr     by smt().
  realize oner_neq0 by smt().
  realize mulrA     by smt().
  realize mulrC     by smt().
  realize mul1r     by smt().
  realize mulrDl    by smt().
  realize mulVr     by rewrite /left_inverse_in /#.
  realize unitP     by smt().
  realize unitout   by move=> x /= ->. 
  realize mulf_eq0  by smt().

  lemma ofintR (i : int): ofint i = i%r.
  proof.
  have h: forall i, 0 <= i => ofint i = i%r.
  + elim=> [|j j_ge0 ih] //=; first by rewrite ofint0.
    by rewrite ofintS // fromintD ih addrC.
  elim/natind: i=> [n|/#].
  by rewrite -oppz_ge0 -eqr_opp -ofintN -fromintN; exact/h.
  qed.

  lemma intmulr x c : intmul x c = x * c%r.
  proof.
    have h: forall cp, 0 <= cp => intmul x cp = x * cp%r.
      elim=> /= [|cp ge0_cp ih].
        by rewrite mulr0z.
      by rewrite mulrS // ih fromintD mulrDr mulr1 addrC.
    case: (lezWP c 0) => [le0c|_ /h //].
    rewrite -{2}(@oppzK c) fromintN mulrN -h 1:/#.
    by rewrite mulrNz opprK.
  qed.

  lemma double_half (x : real) : x / 2%r + x / 2%r = x.
  proof. by rewrite -ofintR -mulrDl -mul1r2z -mulrA divff // ofintR. qed.

  lemma fromintXn (n k : int) :
    0 <= k => exp (n%r) k = (IntID.exp n k)%r.
  proof.
  elim: k => [|k ge0_k ih]; 1: by rewrite !(expr0, IntID.expr0).
  by rewrite !(exprS, IntID.exprS) // fromintM ih.
  qed.
end RField.
import RField.

abbrev ( ^ ) = RField.exp.

(* -------------------------------------------------------------------- *)
lemma divr0: forall x, x / 0%r = 0%r by done.

lemma divrK (u v : real) : v <> 0%r => u = u / v * v.
proof. by move => neqv0; rewrite -mulrA mulVf. qed.

lemma invr0: inv 0%r = 0%r by done.

(* -------------------------------------------------------------------- *)
lemma b2rE (b : bool): b2r b = (b2i b)%r.
proof. by case: b. qed.

lemma le_b2r (b1 b2 : bool): (b1 => b2) <=> b2r b1 <= b2r b2.
proof. by rewrite /#. qed.

lemma b2r_ge0 (b : bool): 0%r <= b2r b.
proof. by case: b. qed.

lemma b2r0: b2r false = 0%r.
proof. by rewrite b2rE b2i0. qed.

lemma b2r1: b2r true = 1%r.
proof. by rewrite b2rE b2i1. qed.

(* -------------------------------------------------------------------- *)
op lub (E : real -> bool) : real.

op nonempty (E : real -> bool) =
  exists x, E x.

op ub (E : real -> bool) (z : real) =
  forall y, E y => y <= z.

op has_ub  (E : real -> bool) = nonempty (ub E).
op has_lub (E : real -> bool) = nonempty E /\ has_ub E.

axiom lub_upper_bound (E : real -> bool): has_lub E =>
  forall x, E x => x <= lub E.

axiom lub_adherent (E : real -> bool): has_lub E =>
  forall eps, 0%r < eps =>
    exists e, E e /\ (lub E - eps) < e.

(* -------------------------------------------------------------------- *)
op intp x = choiceb (fun i => i%r <= x < (i+1)%r) 0.

axiom le_intp x : (intp x)%r <= x.
axiom gt_intp x : x < (intp x + 1)%r.

lemma leup_intp z x : z%r <= x => z <= intp x.
proof.
by move=> le_zx; have := le_intp x; have := gt_intp x => /#.
qed.

(* -------------------------------------------------------------------- *)
instance ring with real
  op rzero = CoreReal.zero
  op rone  = CoreReal.one
  op add   = CoreReal.add
  op opp   = CoreReal.opp
  op mul   = CoreReal.mul
  op expr  = RField.exp
  op ofint = CoreReal.from_int

  proof oner_neq0 by smt()
  proof addr0     by smt()
  proof addrA     by smt()
  proof addrC     by smt()
  proof addrN     by smt()
  proof mulr1     by smt()
  proof mulrA     by smt()
  proof mulrC     by smt()
  proof mulrDl    by smt()
  proof expr0     by smt(expr0 exprS exprN)
  proof exprS     by smt(expr0 exprS exprN)
  proof ofint0    by smt()
  proof ofint1    by smt()
  proof ofintS    by smt()
  proof ofintN    by smt().

instance field with real
  op rzero = CoreReal.zero
  op rone  = CoreReal.one
  op add   = CoreReal.add
  op opp   = CoreReal.opp
  op mul   = CoreReal.mul
  op expr  = RField.exp
  op ofint = CoreReal.from_int
  op inv   = CoreReal.inv

  proof oner_neq0 by smt()
  proof addr0     by smt()
  proof addrA     by smt()
  proof addrC     by smt()
  proof addrN     by smt()
  proof mulr1     by smt()
  proof mulrA     by smt()
  proof mulrC     by smt()
  proof mulrDl    by smt()
  proof mulrV     by smt()
  proof expr0     by smt(expr0 exprS exprN)
  proof exprS     by smt(expr0 exprS exprN)
  proof exprN     by smt(expr0 exprS exprN)
  proof ofint0    by smt()
  proof ofint1    by smt()
  proof ofintS    by smt()
  proof ofintN    by smt().

(* -------------------------------------------------------------------- *)
op floor : real -> int.
op ceil  : real -> int.

axiom floor_bound (x:real) : x - 1%r < (floor x)%r <= x.
axiom ceil_bound  (x:real) : x <= (ceil x)%r < x + 1%r.
axiom from_int_floor n : floor n%r = n.
axiom from_int_ceil  n : ceil  n%r = n.

lemma floor_gt x : x - 1%r < (floor x)%r.
proof. by case: (floor_bound x). qed.

lemma floor_le x : (floor x)%r <= x.
proof. by case: (floor_bound x). qed.

lemma ceil_ge x : x <= (ceil x)%r.
proof. by case: (ceil_bound x). qed.

lemma ceil_lt x : (ceil x)%r < x + 1%r.
proof. by case: (ceil_bound x). qed.

lemma floorP x n : floor x = n <=> n%r <= x < n%r + 1%r.
proof. smt(floor_bound). qed.

lemma from_int_floor_addl n x : floor (n%r + x) = n + floor x.
proof. smt(floor_bound). qed.

lemma from_int_floor_addr n x : floor (x + n%r) = floor x + n.
proof. smt(floor_bound). qed.

lemma floor_mono (x y : real) : x <= y => floor x <= floor y.
proof. smt(floor_bound). qed.

op isint (x : real) = exists n, x = n%r.

lemma ceil_eqP (x : real) : (ceil x)%r = x <=> isint x.
proof. by split=> [/#|[n ->>]]; last by rewrite from_int_ceil. qed.

lemma floor_eqP (x : real) : (floor x)%r = x <=> isint x.
proof. by split=> [/#|[n ->>]]; last by rewrite from_int_floor. qed.

lemma cBf_eq0P (x : real) : (ceil x - floor x = 0) <=> isint x.
proof.
split=> [|[n ->>]]; last by rewrite from_int_floor from_int_ceil.
smt(ceil_bound floor_bound).
qed.

lemma cBf_eq1P (x : real) : (ceil x - floor x = 1) <=> !isint x.
proof.
move=> /=; case: (isint x) => /= [/cBf_eq0P -> //|].
smt(ceil_bound floor_bound).
qed.

(* -------------------------------------------------------------------- *)
(* WARNING Lemmas used by tactics: *)
lemma upto2_abs (x1 x2 x3 x4 x5:real):
   0%r <= x1 =>
   0%r <= x3 =>
   x1 <= x5 =>
   x3 <= x5 =>
   x2 = x4 =>
   `|x1 + x2 - (x3 + x4)| <= x5 by smt().

lemma upto2_notbad (ev1 ev2 bad1 bad2:bool) :
  ((bad1 <=> bad2) /\ (!bad2 => (ev1 <=> ev2))) =>
  ((ev1 /\ !bad1) <=> (ev2 /\ !bad2)) by smt().

lemma upto2_imp_bad (ev1 ev2 bad1 bad2:bool) :
  ((bad1 <=> bad2) /\ (!bad2 => (ev1 <=> ev2))) =>
  (ev1 /\ bad1) => bad2 by [].

lemma upto_bad_false (ev bad2:bool) :
  !((ev /\ !bad2) /\ bad2) by smt().

lemma upto_bad_or (ev1 ev2 bad2:bool) :
   (!bad2 => ev1 => ev2) => ev1 =>
    ev2 /\ !bad2 \/ bad2 by smt().

lemma upto_bad_sub (ev bad:bool) :
  ev /\ ! bad => ev by [].

lemma eq_upto (E1 E1b E1nb E2 E2b E2nb: real) :
  E1 = E1b + E1nb =>
  E2 = E2b + E2nb =>
  E1nb = E2nb =>
  E1 - E2 = E1b - E2b.
proof. smt(). qed.

lemma upto_abs (E1 E1b E1nb E2 E2b E2nb: real) :
  E1 = E1b + E1nb =>
  E2 = E2b + E2nb =>
  E1nb = E2nb =>
  `| E1 - E2 | <= `|E1b - E2b|.
proof. by move=> h1 h2 h3; rewrite (eq_upto _ _ _ _ _ _ h1 h2 h3). qed.

lemma upto_le (E1 E1b E1nb E2nb E2nb' E1b' : real) : 
  E1 = E1b + E1nb =>
  E1nb = E2nb =>
  E1b <= E1b' => 
  E2nb <= E2nb' => 
  E1 <= E2nb' + E1b'.
proof. smt(). qed.
