function minDist = fcn_shortestDist(A,B)
v = B - A;
w = -A;

c1 = w'*v;
c2 = v'*v;

if c1 <=0 
    minDist = norm(A);
elseif c2 <= c1
    minDist = norm(B);
else
    b = c1/c2;
    Pb = A + b*v;
    minDist = norm(Pb);
end

end

