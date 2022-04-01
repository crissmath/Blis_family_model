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
    X2 = categorical(var3_names');
    X2 = reordercats(X2,var3_names');


    disp_name =  {'PackBc', 'PackCc', 'UnpackCc', 'CopyBr/CopyCr', ...
                  'StreamA/Ac','StreamBr/Bc','StreamC/Cc/Cr', 'Arithmetic'}';

    f = figure;
    %subplot(3,1,1)
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
                            legend()
                            title('B3A2C0')
                            ylim([0 120])
                            text(1:length(total_time_B3A2C0), total_time_B3A2C0, num2str(total_time_B3A2C0), ...
                            'Fontsize', 5,'vert','bottom','horiz','center');
                            
                            xlabel('Microkernel dimensions${ (m_r \times n_r \times k_r)}$','interpreter','latex', ...
                            'FontWeight','bold', 'FontSize', 15)
                            ylabel('$Time(s)$','interpreter','latex', ...
                            'FontWeight','bold', 'FontSize', 15)  

     
    f_1 = figure;
    %subplot(3,1,2)
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
                            leg = legend();
                            set(leg, 'FontSize', 8)
                            title('B3C2A0')
                            ylim([0 120])
                            text(1:length(total_time_B3C2A0), total_time_B3C2A0, num2str(total_time_B3C2A0), ...
                            'Fontsize', 5,'vert','bottom','horiz','center');
                            
                            xlabel('Microkernel dimensions${ (m_r \times n_r \times k_r)}$','interpreter','latex', ...
                                   'FontWeight','bold', 'FontSize', 15)
                            ylabel('$Time(s)$','interpreter','latex', ...
                            'FontWeight','bold', 'FontSize', 15)  
    f_2 = figure;
    %subplot(3,1,3)
    time_C3B2A0_variant = bar( X1, data_C3B2A0, "stacked");
    set(time_C3B2A0_variant, {'DisplayName'}, disp_name);
                            time_C3B2A0_variant(1).FaceColor = [0 0.4470 0.7410];
                            time_C3B2A0_variant(2).FaceColor = [0.8500 0.3250 0.0980];
                            time_C3B2A0_variant(3).FaceColor = [0.9290 0.6940 0.1250];
                            time_C3B2A0_variant(4).FaceColor = [0 0 0];
                            time_C3B2A0_variant(5).FaceColor = [0.4660 0.6740 0.1880];
                            time_C3B2A0_variant(6).FaceColor = [0.3010 0.7450 0.9330];
                            time_C3B2A0_variant(7).FaceColor = [0.6350 0.0780 0.1840];
                            time_C3B2A0_variant(8).FaceColor = [0.4940 0.1840 0.5560];
                            leg = legend();
                            set(leg, 'FontSize', 8)
                            title('C3B2A0')
                            ylim([0 120])
                            text(1:length(total_time_C3B2A0), total_time_C3B2A0, num2str(total_time_C3B2A0), ...
                            'Fontsize', 5,'vert','bottom','horiz','center');

                            xlabel('Microkernel dimensions${ (m_r \times n_r \times k_r)}$', ...
                                   'interpreter','latex', 'FontWeight','bold', 'FontSize', 15);
                            ylabel('$Time(s)$','interpreter','latex','FontWeight','bold', 'FontSize', 15); 
    

    f_3 = figure;
    bests_times = [data_B3A2C0(ind1,:); data_B3C2A0(ind2,:); data_C3B2A0(ind3,:)];
    total_time_best = sum(bests_times,2);
    best_time_variants = bar( X2, bests_times, "stacked");
    set(best_time_variants, {'DisplayName'}, disp_name);
                            best_time_variants(1).FaceColor = [0 0.4470 0.7410];
                            best_time_variants(2).FaceColor = [0.8500 0.3250 0.0980];
                            best_time_variants(3).FaceColor = [0.9290 0.6940 0.1250];
                            best_time_variants(4).FaceColor = [0 0 0];
                            best_time_variants(5).FaceColor = [0.4660 0.6740 0.1880];
                            best_time_variants(6).FaceColor = [0.3010 0.7450 0.9330];
                            best_time_variants(7).FaceColor = [0.6350 0.0780 0.1840];
                            best_time_variants(8).FaceColor = [0.4940 0.1840 0.5560];
                            leg = legend();
                            set(leg, 'FontSize', 8)
                            title('Best kernels')
                            ylim([0 60])
                            text(1:length(total_time_best), total_time_best, ...
                                 num2str(total_time_best),'vert','bottom','horiz','center');

                            xlabel('Microkernel dimensions${ (m_r \times n_r \times k_r)}$','interpreter','latex', ...
                                    'FontWeight','bold', 'FontSize', 15)
                            ylabel('$Time(s)$','interpreter','latex', ...
                            'FontWeight','bold', 'FontSize', 15) 

    v = ver('MATLAB');
    if (v.Release == '(R2019b)')
        %saveas(f,   'time_all_B3A2C0.pdf');
        f.PaperPositionMode = 'manual';
        orient(f,'landscape')
        print(f,'time_all_B3A2C0.pdf','-dpdf')

        %saveas(f_1, 'time_all_B3C2A0.pdf');
        f_1.PaperPositionMode = 'manual';
        orient(f_1,'landscape')
        print(f_1,'time_all_B3C2A0.pdf','-dpdf')

        %saveas(f_2, 'time_all_C3B2A0.pdf');
        f_2.PaperPositionMode = 'manual';
        orient(f_2,'landscape')
        print(f_2,'time_all_C3B2A0.pdf','-dpdf')

        %saveas(f_3, 'time_all_best.pdf');
        f_3.PaperPositionMode = 'manual';
        orient(f_3,'landscape')
        print(f_3,'time_all_best.pdf','-dpdf')

    else
        exportgraphics(f,   'time_all_B3A2C0.pdf');
        exportgraphics(f_1, 'time_all_B3C2A0.pdf');
        exportgraphics(f_2, 'time_all_C3B2A0.pdf');
        exportgraphics(f_3, 'time_all_best.pdf'  );
    end
end
