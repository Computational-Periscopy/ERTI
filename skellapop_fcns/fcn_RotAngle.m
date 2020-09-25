function phi = fcn_RotAngle(A,B)
% A is position of left corner, B is position of right corner
% rotation angle computed with respect to normal to origin

A = A(:); B = B(:); % ensure column vectors
normA = norm(A);
normB = norm(B);

if normA == normB       % Equally close---flat plane
    phi = 0;
elseif normA > normB    % B is closer
    C = normB*A/normA;
    phi = acos((A-B)'*(C-B)/(norm((A-B))*norm(C-B)));
else
    C = normA*B/normB;
    phi = -acos((B-A)'*(C-A)/(norm((B-A))*norm(C-A)));
end
end

