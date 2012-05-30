% S' = harmony_boost(S)
%
% written by Richard Lange 5/1/12
%
% given a sparse boolean song matrix S, adds float values for harmonies by
%   iteratively computing the next state based on the current, and
%   normalizing the max value to 1

function harmony = harmony_boost(song, N, harmony_weights)
    harmony = song;
    nnotes = size(song, 2);
    
    if (nargin < 2)
        N = 1;
    end
    if (nargin < 3)
        others = 0;
        major = 0;
        minor = 0;
        fourth = 0;
        seventh = 0;
        octave = 0.375;
        harmony_weights = zeros(1, 13);
        harmony_weights(1) = 1;
        harmony_weights([2, 3, 7, 9, 12]) = others;
        harmony_weights([5, 8]) = major;
        harmony_weights(6) = fourth;
        harmony_weights([4, 10]) = minor;
        harmony_weights(11) = seventh;
        harmony_weights(13) = octave;
    end
    
    harm_cols = repmat(harmony_weights, nnotes, 1);
    diags = 0:12;
    
    iter_mat = spdiags(harm_cols, diags, nnotes, nnotes);
    iter_mat = iter_mat + spdiags(harm_cols(:, 2:end), -diags(2:end), nnotes, nnotes);
    
    for i=1:N
        harmony = harmony * iter_mat;
        harmony = harmony / max(max(abs(harmony)));
    end
    
end