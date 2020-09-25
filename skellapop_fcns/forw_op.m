function y = forw_op(x,type)

switch (type)
    case 1 % forward A
        
        [L,T] = size(x);
        y = zeros(L,T);
        
        y(1,:) = x(1,:);
        for i=2:L
            y(i,:) = y(i-1,:)+x(i,:);
        end
        
        
    case 2 % transpose A^T
        
        [L,T] = size(x);
        y = zeros(L,T);
        
        y(L,:) = x(L,:);
        
        for i=L-1:-1:1
            y(i,:) = y(i+1,:)+x(i,:);
        end
        
        
end

end