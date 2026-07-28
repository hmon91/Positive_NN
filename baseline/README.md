# Baseline: IQC method (Table I comparison)

Table I of the paper compares the run-time of the sector-bound + Metzler/Hurwitz
test against the **IQC / quadratic-constraint method** of

> **[3]** H. Yin, P. Seiler, and M. Arcak, "Stability Analysis Using Quadratic
> Constraints for Systems with Neural Network Controllers," *IEEE Transactions
> on Automatic Control*, vol. 67, no. 4, pp. 1980–1987, 2022.
> arXiv:2006.07579 · code: <https://github.com/heyinUCB/IQCbased_ImitationLearning> (MIT)

and reports the sector bound alongside a **product-of-norms** Lipschitz-style
bound (ref. **[24]** in the paper).

## What is here

`iqc_reference/` contains the IQC benchmark script (`iqc_roa_2d_example.m`) and
its helper (`nnclosedloop.m`), adapted from the MIT-licensed repository above and
re-targeted to this paper's 2-D example. See
[`iqc_reference/NOTICE.md`](iqc_reference/NOTICE.md) for provenance and
[`iqc_reference/UPSTREAM_LICENSE`](iqc_reference/UPSTREAM_LICENSE) for the
required copyright notice. The script solves the local-QC + Lyapunov SDP for the
NN controller and times that solve — this is the "IQC method [3]" entry in the
table.

## Prerequisites (the IQC baseline only)

Unlike the sector-bound method in `matlab/` (which needs nothing beyond base
MATLAB), the IQC baseline needs a semidefinite-programming stack:

- **MATLAB**
- **[CVX](http://cvxr.com/cvx/)** — modeling layer for convex programs
- **An SDP solver**, e.g. **[MOSEK](https://www.mosek.com/)** (commercial; free
  academic licenses are available). SeDuMi/SDPT3 that ship with CVX also work
  but are slower.

## Running it

```matlab
cd baseline/iqc_reference
iqc_roa_2d_example      % builds and solves the QC + Lyapunov SDP; wrap in tic/toc for timing
```

The plant encoded in the script is the discretization (`dt = 0.02`) of the
paper's `A = [-5 1; 3 -5]`, `B = [0.5; 1]`, with the same 10/10/1 imitation
network, so the run-time is directly comparable to Table I.

## Results (Table I of the paper)

| Method | Architecture | Computation time | Bound `−Γ₁ = Γ₂` |
|--------|--------------|------------------|-------------------|
| Sector bound + Metzler/Hurwitz (**this repo**) | 10/10/1     | 2.5 × 10⁻⁵ s | [2.65, 1.61] |
| Sector bound + Metzler/Hurwitz (**this repo**) | 10/15/15/1  | 2.6 × 10⁻⁵ s | [2.75, 1.47] |
| IQC method **[3]**                              | 10/10/1     | 0.68 s        | — *(see note)* |
| Product of norms **[24]**                       | 10/10/1     | —             | 5.83 |
| Product of norms **[24]**                       | 10/15/15/1  | —             | 6.45 |

Notes, as stated in the paper:

- The IQC method **[3]** certifies stability and estimates a region of
  attraction; it does not report an explicit element-wise sector bound for the
  whole network, hence no entry in the last column.
- The **product-of-norms** bound **[24]** is a bound-tightness comparison, not a
  stability test, so no run-time is reported for it.
- The two run-time columns show the qualitative point of the paper: the
  sector-bound test is a small closed-form matrix computation (microseconds),
  whereas the IQC test solves an SDP (sub-second here, and growing with network
  size).

## Two caveats on the timing

1. **These numbers are reproduced from the paper, not re-measured here.** This
   environment has no MATLAB / CVX / MOSEK, so the 0.68 s could not be
   regenerated. To reproduce it yourself, run the script above on your machine.
2. **Wall-clock time is hardware- and solver-dependent.** The absolute value
   depends on CPU, MATLAB version, and SDP solver; treat 0.68 s as indicative of
   the *order of magnitude* (SDP solve vs. closed-form), not an exact target. The
   sector-bound timings come from [`../matlab/benchmark_runtime.m`](../matlab/benchmark_runtime.m).
