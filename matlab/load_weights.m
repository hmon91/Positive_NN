function W = load_weights(folder, prefix, nLayers)
%LOAD_WEIGHTS  Load ordered NN weight matrices from CSV files.
%
%   W = LOAD_WEIGHTS(FOLDER) loads W1.csv, W2.csv, ... from FOLDER into the
%   cell array W = {W1, W2, ...}, stopping at the first missing index.
%
%   W = LOAD_WEIGHTS(FOLDER, PREFIX) uses <PREFIX>1.csv, <PREFIX>2.csv, ...
%   (default PREFIX = 'W').
%
%   W = LOAD_WEIGHTS(FOLDER, PREFIX, NLAYERS) loads exactly NLAYERS files
%   and errors if any is missing.
%
%   Each file is read with READMATRIX (comma-delimited, no header). Weight
%   i must have size (n_i x n_{i-1}) so that v_i = W_i * w_{i-1}.
%
%   See also NN_FORWARD, SECTOR_BOUND.

    if nargin < 2 || isempty(prefix), prefix = 'W'; end
    if nargin < 3, nLayers = Inf; end

    W = {};
    i = 1;
    while i <= nLayers
        f = fullfile(folder, sprintf('%s%d.csv', prefix, i));
        if ~isfile(f)
            if isfinite(nLayers)
                error('load_weights:missing', 'Missing weight file: %s', f);
            end
            break
        end
        W{i} = readmatrix(f); %#ok<AGROW>
        i = i + 1;
    end
    if isempty(W)
        error('load_weights:none', ...
              'No weight files (%s1.csv ...) found in %s', prefix, folder);
    end
end
