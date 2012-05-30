function D = denseness(alpha)
%     S     = @(w) log(1 + w^2);
%     S     = @(w) abs(w);
    S = @(w) -exp(-w.^2);
    D = sum(S(alpha));
end