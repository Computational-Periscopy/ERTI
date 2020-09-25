function occupied_volume=modify_neighbors(type,occupied_volume,n,t0_new,t0_death,NEIGH)

% type: indicator of RJ move
% 0 -> birth
% 1 -> death
% 2 -> shift

Nrow=size(occupied_volume,1);

n_col = ceil(n/Nrow);
n_row = n-(n_col-1)*Nrow;


if type==0 % birth

    b=max([n_col-Npix2,1]):min([n_col+Npix2,Nrow]);
    a=max([n_row-Npix2,1]):min([n_row+Npix2,Nrow]);
    c=t0_new-Nbin2:t0_new+Nbin2 ;
    occupied_volume(a,b,c)=occupied_volume(a,b,c)+1;   

elseif type==1 % death
    
    b=max([n_col-Npix2,1]):min([n_col+Npix2,Nrow]);
    a=max([n_row-Npix2,1]):min([n_row+Npix2,Nrow]);
    c=t0_death-Nbin2:t0_death+Nbin2 ;
    occupied_volume(a,b,c)=occupied_volume(a,b,c)-1;
    
else % shift

    b=max([n_col-Npix2,1]):min([n_col+Npix2,Nrow]);
    a=max([n_row-Npix2,1]):min([n_row+Npix2,Nrow]);
    c=t0_death-Nbin2:t0_death+Nbin2;
    occupied_volume(a,b,c)=occupied_volume(a,b,c)-1;

    c=t0_new-Nbin2:t0_new+Nbin2 ;
    
    occupied_volume(a,b,c)=occupied_volume(a,b,c)+1;
    
end
