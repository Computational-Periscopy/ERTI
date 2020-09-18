function [measurement] = simulate_measurement(laser_pos,objects,params)
    % Charles Saunders @ Boston University. April 2019.
    %% Returns the simulated measurement histograms from a scene for some number of laser positions and some objects.

    % laser_pos = Number of positions x 3 vector (so 3D positions of each
    % laser position, usually z=0 for all)
    %
    % objects = struct of objects. N x number of properties. 
    % objects( . 1) = 'wall' or 'cylinder'
    %
    % params -
    % params.c (speed of light)
    % params.wall_discr (discretization resolution, smaller=finer)
    % params.bin_size (size of time bins in seconds)
    % params.FOV_center (center position of FOV [x,y,z])
    % params.FOV_radius (radius of FOV)
    % params.laser_intensity (just an arbitrary scaling)
    % params.laser_pulse_width (pulse width in time, addumes gaussian
    % shape)

    nmz=@(x) x/norm(x); %Normalize vector

    %% Discretize scene into patches
    
    numpatches = 0; %We approximately work out how many patches there'll be so we can pre-allocate matrices for speed
    for o = 1:size(objects,1)
        if strcmp(objects{o,1},'wall') %If this object is a wall
            numpatches = numpatches + round(norm(objects{o,3})/params.wall_discr) * round(norm(objects{o,4})/params.wall_discr);
        else
            numpatches = numpatches + objects{o,4}*0.5*pi*objects{o,3}/(params.cyl_discr);
        end
    end
    
    % Pre-allocate matrices
    scene_pixel = zeros(ceil(numpatches),3);
    scene_pixel_normal = zeros(ceil(numpatches),3);
    scene_pixel_area = params.wall_discr*params.wall_discr;
    scene_pixel_angle = 1000*ones(ceil(numpatches),1);

    % Calculate the angle of each laser position
    v = laser_pos./sqrt(sum(laser_pos.^2,2));
    light_angle = v(:,1);

    patch_count = 1;
    
    for o = 1:size(objects,1)
        if strcmp(objects{o,1},'wall') %If this object is a wall

            for i = linspace(0,1,round(norm(objects{o,3})/params.wall_discr)) %Iterate over surface
                for j = linspace(0,1,round(norm(objects{o,4})/params.wall_discr))
                    
                    if  objects{o,2}(3)+i*objects{o,3}(3)+j*objects{o,4}(3)>0 %Check points above floor level

                        pos = [objects{o,2}(1)+i*objects{o,3}(1)+j*objects{o,4}(1), objects{o,2}(2)+i*objects{o,3}(2)+j*objects{o,4}(2), objects{o,2}(3)+i*objects{o,3}(3)+j*objects{o,4}(3)];

                        oc = false; %False = visible

                        v = nmz(pos(1:2));
                        pixel_angle = -v(1);
                        
%                         if (-scene_pixel_angle+light_angle<0) %if occluded by corner
%                             oc = true;
%                         else
                            for ob = 1:size(objects,1)
                                if strcmp(objects{ob,1},'cylinder')
                                    oc = check_col(pos-laser_pos,objects{ob,2},objects{ob,3},objects{ob,4});
                                if oc
                                    break;
                                end
                                end
                            end
%                         end

                        if ~oc %Not occluded so we add it to list of patches
                            scene_pixel(patch_count,:) = pos;
                            scene_pixel_normal(patch_count,:) = objects{o,5}; 
                            %scene_pixel_area = [scene_pixel_area; params.wall_discr*params.wall_discr];
                            scene_pixel_angle(patch_count,:) = pixel_angle;
                            patch_count = patch_count + 1;
                        end
                    end
                end
            end
        end

        if strcmp(objects{o,1},'cylinder') %If this object is a cylinder

            r = objects{o,3};

            ang_start = atan(objects{o,2}(1)/objects{o,2}(2))+pi/2;
            ang_end = ang_start + 2*pi/2;
            a = linspace(ang_start,ang_end,pi*r/(params.cyl_discr));

            for ang = a(2:end-1)
                for h = linspace(0,objects{o,4}, objects{o,4}/(params.cyl_discr))
                    nm = [sin(ang),cos(ang),0]./norm([sin(ang),cos(ang),0]);
                    if h>0
                        pos = [objects{o,2}(1) + sin(ang)*r,objects{o,2}(2) + cos(ang)*r,h];

                        oc = false; %Visible or not

                        v = nmz(pos(1:2));
                        pixel_angle = -v(1); %angle from corner
                        
%                         if (-scene_pixel_angle+light_angle<0) %if occluded by corner
%                             oc = true;
%                         else
                            for ob = 1:size(objects,1)
                                if strcmp(objects{ob,1},'cylinder') && ob~=o
                                    oc = check_col(pos,objects{ob,2},objects{ob,3},objects{ob,4});
                                if oc
                                    break;
                                end
                                end
                            end
                        %end

                        if ~oc
                            scene_pixel(patch_count,:) =  pos;
                            scene_pixel_normal(patch_count,:) = nm; 
                            %scene_pixel_area = [scene_pixel_area; (params.cyl_discr)*(params.cyl_discr)];
                            scene_pixel_angle(patch_count,:) = pixel_angle;
                            path_count = patch_count + 1;
                        end
                    end
                end
            end
        end


    end



    %% Generate measurement from scene patches
    measurement = zeros(ceil((20/params.c)/params.bin_size),size(laser_pos,1));
    
    
    fourpi = 4*pi*pi;
   
    for lp = 1:size(laser_pos,1) %For each laser position
       
       sp = (-scene_pixel_angle+light_angle(lp)>=0); %Find unoccluded scene patches

       lps = laser_pos(lp,:)-scene_pixel(sp,:);
       fovsp = params.FOV_center-scene_pixel(sp,:);
       d1s = sum(lps.^2,2);
       d2s = sum(fovsp.^2,2);

       d1 = sqrt(d1s);
       d2 = sqrt(d2s);
       distance = d1 + d2;

      % distance_in_time = distance/params.c;
       tbin = ((distance/(params.c*params.bin_size)));

       dot1 =  max(0,sum(scene_pixel_normal(sp,:).*lps./d1,2));
       dot2 =  max(0,sum(scene_pixel_normal(sp,:).*fovsp./d2,2));

       intensity = params.laser_intensity.*scene_pixel_area.*((dot1.*dot2)./(fourpi*d1s*d2s)); %hemiscpherical spreading
       
        for i = 1:length(intensity)
            frac = tbin(i) - floor(tbin(i)); %Interpolate and sum up
            measurement(floor(tbin(i)), lp) = measurement(floor(tbin(i)), lp) + (1-frac)*intensity(i);
            measurement(ceil(tbin(i)), lp) = measurement(ceil(tbin(i)), lp) + (frac)*intensity(i);
        end
        
       % Approximate SPAD FOV spreading with convolution
       FOV = (gausswin(floor((params.FOV_radius/params.c)/params.bin_size)));
       FOV = FOV/sum(FOV);
       measurement(:,lp) = conv(measurement(:,lp), FOV, 'same');

       % Laser pule shape convolution
        if floor(params.laser_pulse_width/params.bin_size)>0
           las = (gausswin(floor(params.laser_pulse_width/params.bin_size)));
           las=las/sum(las);
           measurement(:,lp) = conv(measurement(:,lp), las, 'same');
        end
   end
     
    


end

