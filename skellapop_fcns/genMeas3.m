function meas = genMeas3(setOfPoints,ceilParams,dataParams)
%GENMEAS3 generates the measured response of the SPAD for illumination of
%planar facets of the particular (distance to nearest point, reflectivity, height,
%rotation) listed in the set of points.

numPoints = size(setOfPoints,1);

meas = funcCeilResponse(ceilParams,dataParams);

if numPoints > 0
    sortPoints = sortrows(setOfPoints); % Ensures point distances ascending

    % ------------ First facet ------------------
    u1 = sortPoints(1,1);           % Distance to nearest point on planar facet
    height1 = sortPoints(1,3);      % Height of planar facet
    refl1 = sortPoints(1,2);        % Reflectivity of planar facet
    phi1 = sortPoints(1,4);         % Rotation angle
    magPhi1 = abs(phi1);            % Rotation angle magnitude

    meas = meas + rotPlaneResponse(u1,refl1,height1,magPhi1,dataParams);

    if numPoints > 1
        gamma = dataParams.angleWidth/2;

        
        if dataParams.occlusion
            % Get coordinate representation of top facet corners:
            % Choose 'cartes','cylind','sphere'
            [pA,pB] =  funcFacetCorners(u1,phi1,height1,gamma,'cylind');

    %         ----------- Subsequent Facets ----------------------
            for ii = 2:numPoints
                u2 = sortPoints(ii,1);          % Distance to nearest point on planar facet
                height2 = sortPoints(ii,3);     % Height of planar facet
                refl2 = sortPoints(ii,2);       % Reflectivity of planar facet
                phi2 = sortPoints(ii,4);        % Rotation angle
                magPhi2 = abs(phi2);            % Rotation angle magnitude

                measUnoccluded = rotPlaneResponse(u2,refl2,height2,magPhi2,dataParams);

                % Get cylindrical representation of top facet corners
                [pFcyl,pGcyl] =  funcFacetCorners(u2,phi2,height2,gamma,'cylind');

                heightC = pFcyl(1)*pA(3)/pA(1);
                heightD = pGcyl(1)* pB(3)/pB(1);

                if heightC < pFcyl(3) && heightD < pGcyl(3)
                    % If facet above visibility plane everywhere
                    measC = rotPlaneResponse(u2,refl2,heightC,magPhi2,dataParams);
                    measD = rotPlaneResponse(u2,refl2,heightD,magPhi2,dataParams);

                    % Rectangular Approximation
                    meas = meas + measUnoccluded -(measC+measD)/2;

                    % Update occluding facet in case of subsequent facets
                    pA = pFcyl;
                    pB = pGcyl;

                else
                    % Cartesian coordinates
                    pCcar = [pFcyl(1)*cos(pFcyl(2)); pFcyl(1)*sin(pFcyl(2)); heightC];
                    pDcar = [pGcyl(1)*cos(pGcyl(2)); pGcyl(1)*sin(pGcyl(2)); heightD];

                    pEcar = pCcar + (pDcar-pCcar)*((height2-pCcar(3))/(pDcar(3)-pCcar(3)));

    %                 pEcyl = [sqrt(pEcar(1)^2+pEcar(2)^2);atan2]

                    if heightC > pFcyl(3) && heightD < pGcyl(3)

                    elseif heightC < pFcyl(3) && heightD > pGcyl(3)

                    end
                end
            end
        else
        %  ----------- Subsequent Facets ----------------------
            for ii = 2:numPoints
                u2 = sortPoints(ii,1);          % Distance to nearest point on planar facet
                height2 = sortPoints(ii,3);     % Height of planar facet
                refl2 = sortPoints(ii,2);       % Reflectivity of planar facet
                phi2 = sortPoints(ii,4);        % Rotation angle
                magPhi2 = abs(phi2);            % Rotation angle magnitude
                measUnoccluded = rotPlaneResponse(u2,refl2,height2,magPhi2,dataParams);
            
                meas = meas + measUnoccluded;
            end
        end
    end
end
    
end

function meas = rotPlaneResponse(u,refl,height,phi,dataParams)
%ROTPLANERESPONSE computes the response from a plane rotated by angle phi
%using the sum or difference of responses for fronto-parallel facets
%(depending on rotation angle vs half-angle width)
gamma = dataParams.angleWidth/2;               % Half-angle of wedge

% Response computation with rotation angle
v = u*cos(max(0,phi-gamma));
d2 = v*tan(phi+gamma);
d1 = v*tan(abs(gamma-phi));
meas2 = funcFPResponse(v,height,d2,dataParams);
meas1 = funcFPResponse(v,height,d1,dataParams);
meas = refl*(meas2+sign(gamma-phi)*meas1)/2;
end

function meas = funcFPResponse(y,height,Delta,dataParams)
%FUNCFPRRESPONSE calculates the reponse from a fronto-parallel plane with
%pointVect = (distance, height, Delta)
Tbin = dataParams.Tbin; % Bin resolution in seconds
numBins = dataParams.numBins;     % Length of measurement vector
c = dataParams.c;       % Speed of light (m/s)

timeBins = Tbin*(1:numBins)';

minTime = floor((2*y/c)/Tbin);

if minTime<1
    minTime = 1;
end
maxTime = min(numBins,floor((2*sqrt(y^2+Delta^2 + height^2)/c)/Tbin));

r1 = sqrt(max(0,(timeBins(minTime:maxTime)*c/2).^2 - y^2));
r2 = sqrt(max(0,((timeBins(minTime:maxTime)+Tbin)*c/2).^2 - y^2));

r_star = 0.5*(r1+r2);

thetaMin = acos(min(1,Delta./r_star));
thetaMax = max(thetaMin,asin(min(height./r_star,1)));

trig = thetaMax - thetaMin + sin(thetaMin).*cos(thetaMin) - ...
    sin(thetaMax).*cos(thetaMax);
measurement = (1/12)*y^2.*(trig).*((3*r1.^2 + y^2)./(r1.^2+y^2).^3 - ...
    (3*r2.^2 + y^2)./(r2.^2 + y^2).^3);
meas = [zeros(minTime-1,1);measurement;zeros(numBins-maxTime,1)];
end

function [pL, pR] = funcFacetCorners(u,phi,h,gamma,coordSys)
magPhi = abs(phi);
v = u*cos(max(0,magPhi-gamma));

% Front corner
d1 = v/cos(abs(magPhi-gamma));

% Back corner
d2 = v/cos(abs(magPhi+gamma));

thetaL = pi/2+gamma;
thetaR = pi/2-gamma;

if phi<0
    dL = d1; dR = d2;
else
    dL = d2; dR = d1;
end

switch coordSys
    case 'cartes'
        % [X; Y; Z;]
        pL = [dL*cos(thetaL); dL*sin(thetaL); h];
        pR = [dR*cos(thetaR); dR*sin(thetaR); h];
        
    case 'cylind'
        % [R, THETA, Z]
        pL = [dL; thetaL; h];
        pR = [dR; thetaR; h];
        
    case 'sphere'
        % [RHO, THETA, PHI (elevation)]
        
    otherwise
        error('Not a valid coordinate system.');
end

end

function meas = funcCeilResponse(ceilParams,dataParams)
%FUNCCEILRESPONSE returns the temporal response from illuminating the
%ceiling component
Tbin = dataParams.Tbin; % Bin resolution in seconds
numBins = dataParams.numBins;     % Length of measurement vector
c = dataParams.c;       % Speed of light (m/s)
tau = dataParams.Tbin;
timeBins = Tbin*(1:numBins)';

z = ceilParams.height;

minTime = floor((2*z/c)/tau);
maxTime = min(numBins,floor((2*sqrt(ceilParams.maxDepth^2+z^2)/c)/tau));

r1 = sqrt(max(0,(timeBins(minTime:maxTime)*c/2).^2 - z^2));
r2 = sqrt(max(0,((timeBins(minTime:maxTime)+tau)*c/2).^2 - z^2));

measurement = ((1/3)*ceilParams.refl*z^2 *dataParams.angleWidth)*...
    (1./(r1.^2+z^2).^3 - 1./(r2.^2+z^2).^3);
meas = [zeros(minTime-1,1);measurement;zeros(numBins-maxTime,1)];

end