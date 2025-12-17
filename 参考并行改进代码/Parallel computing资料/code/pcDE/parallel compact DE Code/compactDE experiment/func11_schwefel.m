function fit=func11_schwefel(x)
[ps,D]=size(x);
fit=418.9829*D-sum(x.*sin(abs(x).^(1/2)));
end

