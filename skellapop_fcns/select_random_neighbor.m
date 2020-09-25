function pixel=select_random_neighbor(N,center_pixel)

    Nrow=sqrt(N);
    Ncol=Nrow;
    
    n_col = ceil(center_pixel/Ncol);
    n_row= center_pixel-(n_col-1)*Ncol;
    
    r=0;
    c=0;
    while(r==0 && c==0)
        r=randi(3)-2;
        c=randi(3)-2;
    end
    
    n_col=n_col+c;
    n_row=n_row+r;
    
    n_col=min(max([1,n_col]),Ncol);
    n_row=min(max([1,n_row]),Nrow);
    
%     if n_col>Ncol
%         n_col=1;
%     elseif n_col<1
%         n_col=Ncol;
%     end
%         
%     if n_row>Nrow
%         n_row=1;
%     elseif n_row<1
%         n_row=Nrow;
%     end
    
    
    pixel = n_row+(n_col-1)*Ncol;
    
end