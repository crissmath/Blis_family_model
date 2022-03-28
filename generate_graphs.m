% this function load data for model and create graphs
function generate_graphs(kernel_name_B3A2C0, kernel_name_B3C2A0)

    % Load data 
    data_B3A2C0 = readmatrix('data/B3A2C0/time_B3A2C0.txt');
    data_B3C2A0 = readmatrix('data/B3C2A0/time_B3C2A0.txt');
    data_C3B2A0 = readmatrix('data/C3B2A0/time_C3B2A0.txt');
   
    %Total times
    total_time_B3A2C0 = round(sum(data_B3A2C0,2));
    total_time_B3C2A0 = round(sum(data_B3C2A0,2));
    total_time_C3B2A0 = round(sum(data_C3B2A0,2));

    %best times
    [val1, ind1] = min(total_time_B3A2C0);
    [val2, ind2] = min(total_time_B3C2A0);
    [val3, ind3] = min(total_time_C3B2A0);

    fprintf("best time B3A2C0 : val:%d  index :%d \n", val1, ind1);
    fprintf("best time B3C2A0 : val:%d  index :%d \n", val2, ind2);
    fprintf("best time C3B2A0 : val:%d  index :%d \n", val3, ind3);

    % plot data 
    var1_names = kernel_name_B3A2C0;
    X = categorical(var1_names');
    X = reordercats(X,var1_names');

    var2_names = kernel_name_B3C2A0;
    X1 = categorical(var2_names');
    X1 = reordercats(X1,var2_names');

    best_names = [kernel_name_B3A2C0(ind1); kernel_name_B3C2A0(ind2); kernel_name_B3C2A0(ind3)]
    var3_names = best_names;
    %X2 = categorical(var3_names');
    %X2 = reordercats(X2,var3_names');


    disp_name =  {'PackBc', 'PackCc', 'UnpackCc', 'CopyBr/CopyCr', ...
    'StreamA/Ac','StreamBr/Bc','StreamC/Cc/Cr', 'Arithmetic'}';

    f = figure;
    subplot(3,1,1)
    time_B3A2C0_variant = bar( X, data_B3A2C0, "stacked");
    set(time_B3A2C0_variant, {'DisplayName'}, disp_name);
                            time_B3A2C0_variant(1).FaceColor = [0 0.4470 0.7410];
                            time_B3A2C0_variant(2).FaceColor = [0.8500 0.3250 0.0980];
                            time_B3A2C0_variant(3).FaceColor = [0.9290 0.6940 0.1250];
                            time_B3A2C0_variant(4).FaceColor = [0.4660 0.6740 0.1880];
                            time_B3A2C0_variant(5).FaceColor = [0 0 0];
                            time_B3A2C0_variant(6).FaceColor = [0.3010 0.7450 0.9330];
                            time_B3A2C0_variant(7).FaceColor = [0.6350 0.0780 0.1840];
                            time_B3A2C0_variant(8).FaceColor = [0.4940 0.1840 0.5560];
                            %legend()
                            title('B3A2C0')
                            text(1:length(total_time_B3A2C0), total_time_B3A2C0, ...
                                 num2str(total_time_B3A2C0),'vert','bottom','horiz','center'); 
    
                            
    subplot(3,1,2)
    time_B3C2A0_variant = bar( X1, data_B3C2A0, "stacked");
    set(time_B3C2A0_variant, {'DisplayName'}, disp_name);
                            time_B3C2A0_variant(1).FaceColor = [0 0.4470 0.7410];
                            time_B3C2A0_variant(2).FaceColor = [0.8500 0.3250 0.0980];
                            time_B3C2A0_variant(3).FaceColor = [0.9290 0.6940 0.1250];
                            time_B3C2A0_variant(4).FaceColor = [0 0 0];
                            time_B3C2A0_variant(5).FaceColor = [0.4660 0.6740 0.1880];
                            time_B3C2A0_variant(6).FaceColor = [0.3010 0.7450 0.9330];
                            time_B3C2A0_variant(7).FaceColor = [0.6350 0.0780 0.1840];
                            time_B3C2A0_variant(8).FaceColor = [0.4940 0.1840 0.5560];
                            %legend()
                            title('B3C2A0')
                            text(1:length(total_time_B3C2A0), total_time_B3C2A0, ...
                                 num2str(total_time_B3C2A0),'vert','bottom','horiz','center'); 
    
    subplot(3,1,3)
    time_C3B2A0_variant = bar( X1, data_C3B2A0, "stacked");
    set(time_C3B2A0_variant, {'DisplayName'}, disp_name);
                            time_C3B20_variant(1).FaceColor = [0 0.4470 0.7410];
                            time_C3B20_variant(2).FaceColor = [0.8500 0.3250 0.0980];
                            time_C3B20_variant(3).FaceColor = [0.9290 0.6940 0.1250];
                            time_C3B20_variant(4).FaceColor = [0 0 0];
                            time_C3B20_variant(5).FaceColor = [0.4660 0.6740 0.1880];
                            time_C3B20_variant(6).FaceColor = [0.3010 0.7450 0.9330];
                            time_C3B20_variant(7).FaceColor = [0.6350 0.0780 0.1840];
                            time_C3B20_variant(8).FaceColor = [0.4940 0.1840 0.5560];
                            %legend()
                            title('C3B2A0')
                            text(1:length(total_time_C3B2A0), total_time_C3B2A0, ...
                                 num2str(total_time_C3B2A0),'vert','bottom','horiz','center'); 
    

    f2 = figure;
    bests_times = [data_B3A2C0(ind1,:); data_B3C2A0(ind2,:); data_C3B2A0(ind3,:)];
    best_time_variants = bar(bests_times, "stacked");
    set(best_time_variants, {'DisplayName'}, disp_name);
                            time_B3A2C0_variant(1).FaceColor = [0 0.4470 0.7410];
                            time_B3A2C0_variant(2).FaceColor = [0.8500 0.3250 0.0980];
                            time_B3A2C0_variant(3).FaceColor = [0.9290 0.6940 0.1250];
                            time_B3A2C0_variant(4).FaceColor = [0.4660 0.6740 0.1880];
                            time_B3A2C0_variant(5).FaceColor = [0 0 0];
                            time_B3A2C0_variant(6).FaceColor = [0.3010 0.7450 0.9330];
                            time_B3A2C0_variant(7).FaceColor = [0.6350 0.0780 0.1840];
                            time_B3A2C0_variant(8).FaceColor = [0.4940 0.1840 0.5560];
                            %legend()
                            title('Best kernels')

    v = ver('MATLAB');
    if (v.Release == '(R2019b)')
        saveas(f, 'time_all_kernel.pdf');
    else
        exportgraphics(f, 'time_all_kernel.pdf');
    end
end
