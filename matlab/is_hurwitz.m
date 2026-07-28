function tf = is_hurwitz(M, tol)
%IS_HURWITZ  True if every eigenvalue of M has strictly negative real part.
%
%   TF = IS_HURWITZ(M) returns true when max(real(eig(M))) < 0.
%
%   TF = IS_HURWITZ(M, TOL) requires real parts < -TOL (default TOL = 0).
%
%   See also IS_METZLER, VERIFY_STABILITY.

    if nargin < 2, tol = 0; end
    tf = all(real(eig(M)) < -tol);
end
