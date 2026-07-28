function [isStable, info] = verify_stability(A, B, C, Gamma1, Gamma2)
%VERIFY_STABILITY  Positive-Aizerman stability test for an LTI + NN loop.
%
%   [ISSTABLE, INFO] = VERIFY_STABILITY(A, B, C, GAMMA1, GAMMA2) applies
%   Theorem 3 of Montazeri Hedesh & Siami to the closed loop
%
%       xdot = A x + B * pi(C x),
%
%   where the neural controller pi is sector bounded by [GAMMA1, GAMMA2]
%   (see SECTOR_BOUND).  Assuming B >= 0 and C >= 0, the closed loop is
%   globally exponentially stable if
%
%       M1 = A + B*GAMMA1*C   is Metzler,   and
%       M2 = A + B*GAMMA2*C   is Hurwitz.
%
%   ISSTABLE is true only when BOTH conditions hold.  INFO is a struct with
%   fields:
%       M1, M2       - the two test matrices
%       isMetzler    - whether M1 is Metzler
%       isHurwitz    - whether M2 is Hurwitz
%       eigM2        - eigenvalues of M2
%       posBC        - whether the B,C >= 0 assumption is satisfied
%
%   The test is a *sufficient* condition: a "false" result means this
%   certificate does not apply, not that the loop is necessarily unstable.
%
%   See also SECTOR_BOUND, IS_METZLER, IS_HURWITZ.

    M1 = A + B*Gamma1*C;
    M2 = A + B*Gamma2*C;

    info.M1        = M1;
    info.M2        = M2;
    info.isMetzler = is_metzler(M1);
    info.eigM2     = eig(M2);
    info.isHurwitz = is_hurwitz(M2);
    info.posBC     = all(B(:) >= 0) && all(C(:) >= 0);

    isStable = info.isMetzler && info.isHurwitz;

    if ~info.posBC
        warning('verify_stability:posBC', ...
            ['Theorem 3 assumes B >= 0 and C >= 0. This assumption is ' ...
             'violated for the given data, so the certificate does not ' ...
             'apply even if the matrix conditions hold.']);
    end
end
