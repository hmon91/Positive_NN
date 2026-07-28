function tf = is_metzler(M, tol)
%IS_METZLER  True if M is a Metzler matrix (off-diagonal entries >= 0).
%
%   TF = IS_METZLER(M) returns true when every off-diagonal entry of the
%   square matrix M is non-negative.
%
%   TF = IS_METZLER(M, TOL) allows a tolerance, treating entries >= -TOL
%   as non-negative (default TOL = 0).
%
%   See also IS_HURWITZ, VERIFY_STABILITY.

    if nargin < 2, tol = 0; end
    n       = size(M, 1);
    offDiag = M(~eye(n));
    tf      = all(offDiag >= -tol);
end
