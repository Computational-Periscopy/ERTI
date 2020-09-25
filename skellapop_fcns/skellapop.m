function skellapop(filename,iterations,plot_debug)

    disp('---------------- Skellapop algorithm ----------------')
    disp(['Reconstructing dataset ' filename])
    scales = 1; % number of coarse scales
    init = cputime;
    %% coarsest scale
    downsampling = [2^scales,4];
    data = load_dataset(filename,downsampling);
    [point_cloud,data,inference] = backprojection(data);
    inference.plot_debug = plot_debug;
    inference.iterations = iterations;
    hyperpriors = get_hyperparam(data);
    point_cloud = PointProcess_RJMCMC(data,point_cloud,hyperpriors,inference);
    
    %% finer scales
    for s=scales-1:-1:0
        downsampling = [2^s,4];
        ref_scale = data.scale;
        data = load_dataset(filename,downsampling);
        data.scale = ref_scale/2;
        [point_cloud,inference] = upsample_pointcloud(point_cloud,inference,hyperpriors,data);
        hyperpriors = get_hyperparam(data);
        point_cloud = PointProcess_RJMCMC(data,point_cloud,hyperpriors,inference);
    end
    elapsed_time = cputime-init;
    
    disp(['Finished reconstruction, elapsed time: ' num2str(elapsed_time)])
    %% save results
    save(['results\out_' filename],'point_cloud','elapsed_time','data','hyperpriors','inference')
    
    %% plot 3D reconstruction
    plot_results(point_cloud,data,hyperpriors);

end
