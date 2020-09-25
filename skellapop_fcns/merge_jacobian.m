function out = merge_jacobian(point1,point2,deltas)

out = 0;

% delta_r = deltas(2);
% delta_h = deltas(3);
% delta_alpha = deltas(4);
% out = -(1.15*m_alpha*exp(m_h + m_r)*exp(delta_alpha*(u1 + u2 - 1.0))*(1.0*m_alpha - 1.05)*(u1 - 1.0*u2 + 1.0))/((exp(m_h) + delta_h*u1)*(exp(m_r) + delta_r*u1)*(m_alpha*exp(delta_alpha*u1) - 1.0*m_alpha + 1.05)^2*(exp(m_h) - 1.0*delta_h + delta_h*u1)*(exp(m_r) - 1.0*delta_r + delta_r*u1)*(1.0*m_alpha*exp(delta_alpha*(u2 - 1.0)) - 1.0*m_alpha + 1.05)^2);
 
end