function [w1,w2] = compute_merge_weights(point1,point2)

w1 = exp(point1(2))/point1(1)^2;
w2 = exp(point2(2))/point2(1)^2;

w1 = w1/(w1+w2);
w2 = 1-w1;

end