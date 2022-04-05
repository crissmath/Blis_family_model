% this function load data for model and create graphs
function generate_graphs(m, n, k, kernel_name_B3A2C0, kernel_name_B3C2A0)

%Need add this function how to generate data locally


    % Load data 
    %data_B3A2C0 = readmatrix('data/B3A2C0/time_B3A2C0.txt');
    %data_B3C2A0 = readmatrix('data/B3C2A0/time_B3C2A0.txt');
    %data_C3B2A0 = readmatrix('data/C3B2A0/time_C3B2A0.txt');
   
    %Total times
    total_time_B3A2C0 = (sum(data_B3A2C0,2));
    total_time_B3C2A0 = (sum(data_B3C2A0,2));
    total_time_C3B2A0 = (sum(data_C3B2A0,2));

    %best times
    [val1, ind1] = min(total_time_B3A2C0);
    [val2, ind2] = min(round(total_time_B3C2A0));
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


    %colors_gnu = 
    	%		 'PackBc' 		    black
    	%		 'PackCc'		    red
    	%	     'UnpackCc'		    blue dark
    	%		 'CopyBr/CopyCr'	yellow 
    	%        'StreamAr/Ac'		orange
	    %      	 'StreamBr/Bc',		blue ligth		
	    %	 	 'StreamC/Cc/Cr'	green
	    %	 	 'Arithmetic'		violet

    % Color palette GNU plot
    color_black      = [0 0 0];
    color_red        = [0.6350 0.0780 0.1840];
    color_blue_d     = [0 0.4470 0.7410];
    color_yellow     = [0.9290 0.6940 0.1250];
    color_orange     = [0.8500 0.3250 0.0980];
    color_blue_light = [0.3010 0.7450 0.9330];
    color_green      = [0.4660 0.6740 0.1880];
    color_violet     = [0.4940 0.1840 0.5560];

    color_map = [color_black; color_red; color_blue_d; color_yellow; color_orange; ...
                 color_blue_light; color_green; color_violet];


    lw   = 0.0001;
    x_width= 30 ; y_width= 15;
    y_limit = 30;
    Titles = ['Time kernel perfomance of GEMM with $m=$',num2str(m),' $n=$',num2str(n),' $k=$',num2str(k)]; 
    
    disp_name =  flip({'PackBc', 'PackCc', 'UnpackCc', 'CopyBr/CopyCr', ...
                  'StreamA/Ac','StreamBr/Bc','StreamC/Cc/Cr', 'Arithmetic'}');

    f = figure('Units','centimeters', 'Position', [20,20, x_width, y_width]);
    %subplot(3,1,1)
    time_B3A2C0_variant = bar( X, flip(data_B3A2C0,2), "stacked", 'LineWidth', lw);
    set(time_B3A2C0_variant, {'DisplayName'}, disp_name);
                            time_B3A2C0_variant(1).FaceColor = color_map(8,:) ;
                            time_B3A2C0_variant(2).FaceColor = color_map(7,:) ;
                            time_B3A2C0_variant(3).FaceColor = color_map(6,:) ;
                            time_B3A2C0_variant(4).FaceColor = color_map(5,:) ;
                            time_B3A2C0_variant(5).FaceColor = color_map(4,:) ;
                            time_B3A2C0_variant(6).FaceColor = color_map(3,:) ;
                            time_B3A2C0_variant(7).FaceColor = color_map(2,:) ;
                            time_B3A2C0_variant(8).FaceColor = color_map(1,:) ;
                            leg = legend();
                            set(leg, 'FontSize', 8)
                            title(Titles,'interpreter', 'latex')
                            ylim([0 y_limit])
                            text(1:length(total_time_B3A2C0), total_time_B3A2C0, num2str(total_time_B3A2C0), ...
                            'Fontsize', 5,'vert','bottom','horiz','center');
                            
                            xlabel('Microkernel dimensions${ (m_r \times n_r \times k_r)}$','interpreter','latex', ...
                            'FontWeight','bold', 'FontSize', 15)
                            ylabel('$Time(s)$','interpreter','latex', ...
                            'FontWeight','bold', 'FontSize', 15)  

     
    f_1 = figure('Units','centimeters', 'Position', [20,20, x_width, y_width]);
    %subplot(3,1,2)
    time_B3C2A0_variant = bar( X1, flip(data_B3C2A0,2), "stacked", 'LineWidth', lw);
    set(time_B3C2A0_variant, {'DisplayName'}, disp_name);
                            time_B3C2A0_variant(1).FaceColor = color_map(8,:) ;
                            time_B3C2A0_variant(2).FaceColor = color_map(7,:) ;
                            time_B3C2A0_variant(3).FaceColor = color_map(6,:) ;
                            time_B3C2A0_variant(4).FaceColor = color_map(5,:) ;
                            time_B3C2A0_variant(5).FaceColor = color_map(4,:) ;
                            time_B3C2A0_variant(6).FaceColor = color_map(3,:) ;
                            time_B3C2A0_variant(7).FaceColor = color_map(2,:) ;
                            time_B3C2A0_variant(8).FaceColor = color_map(1,:) ;
                            leg = legend();
                            set(leg, 'FontSize', 8)
                            title(Titles, 'interpreter', 'latex')
                            ylim([0 y_limit])
                            text(1:length(total_time_B3C2A0), total_time_B3C2A0, num2str(total_time_B3C2A0), ...
                            'Fontsize', 5,'vert','bottom','horiz','center');
                            
                            xlabel('Microkernel dimensions${ (m_r \times n_r \times k_r)}$','interpreter','latex', ...
                                   'FontWeight','bold', 'FontSize', 15)
                            ylabel('$Time(s)$','interpreter','latex', ...
                            'FontWeight','bold', 'FontSize', 15)  

    f_2 = figure('Units','centimeters', 'Position', [20,20, x_width, y_width]);
    %subplot(3,1,3)
    time_C3B2A0_variant = bar( X1, flip(data_C3B2A0,2), "stacked", 'LineWidth', lw);
    set(time_C3B2A0_variant, {'DisplayName'}, disp_name);
                            time_C3B2A0_variant(1).FaceColor = color_map(8,:) ;
                            time_C3B2A0_variant(2).FaceColor = color_map(7,:) ;
                            time_C3B2A0_variant(3).FaceColor = color_map(6,:) ;
                            time_C3B2A0_variant(4).FaceColor = color_map(5,:) ;
                            time_C3B2A0_variant(5).FaceColor = color_map(4,:) ;
                            time_C3B2A0_variant(6).FaceColor = color_map(3,:) ;
                            time_C3B2A0_variant(7).FaceColor = color_map(2,:) ;
                            time_C3B2A0_variant(8).FaceColor = color_map(1,:) ;
                            leg = legend();
                            set(leg, 'FontSize', 8)
                            title(Titles, 'interpreter', 'latex')
                            ylim([0 y_limit])
                            text(1:length(total_time_C3B2A0), total_time_C3B2A0, num2str(total_time_C3B2A0), ...
                            'Fontsize', 5,'vert','bottom','horiz','center');

                            xlabel('Microkernel dimensions${ (m_r \times n_r \times k_r)}$', ...
                                   'interpreter','latex', 'FontWeight','bold', 'FontSize', 15);
                            ylabel('$Time(s)$','interpreter','latex','FontWeight','bold', 'FontSize', 15); 
    

    f_3 = figure('Units','centimeters', 'Position', [20,20, x_width, y_width]);
    bests_times = [data_B3A2C0(ind1,:); data_B3C2A0(ind2,:); data_C3B2A0(ind3,:)];
    total_time_best = sum(bests_times,2);
    best_time_variants = bar( X2, flip(bests_times,2), "stacked");
    set(best_time_variants, {'DisplayName'}, disp_name);
                            best_time_variants(1).FaceColor = color_map(8,:) ;
                            best_time_variants(2).FaceColor = color_map(7,:) ;
                            best_time_variants(3).FaceColor = color_map(6,:) ;
                            best_time_variants(4).FaceColor = color_map(5,:) ;
                            best_time_variants(5).FaceColor = color_map(4,:) ;
                            best_time_variants(6).FaceColor = color_map(3,:) ;
                            best_time_variants(7).FaceColor = color_map(2,:) ;
                            best_time_variants(8).FaceColor = color_map(1,:) ;
                            leg = legend();
                            set(leg, 'FontSize', 8)
                            title(Titles, 'interpreter', 'latex')
                            ylim([0 y_limit])
                            text(1:length(total_time_best), total_time_best, ...
                                 num2str(total_time_best),'vert','bottom','horiz','center');

                            xlabel('Microkernel dimensions${ (m_r \times n_r \times k_r)}$','interpreter','latex', ...
                                    'FontWeight','bold', 'FontSize', 15)
                            ylabel('$Time(s)$','interpreter','latex', ...
                            'FontWeight','bold', 'FontSize', 15) 

    v = ver('MATLAB');
    if (v.Release == '(R2019b)')
        %saveas(f,   'time_all_B3A2C0.pdf');
        f.Units       = 'centimeters';
        f.PaperUnits  = 'centimeters';
        f.PaperSize   = f.Position(3:4);
        print(f,'time_all_B3A2C0.pdf', '-dpdf');

        %saveas(f_1, 'time_all_B3C2A0.pdf');
        f_1.Units       = 'centimeters';
        f_1.PaperUnits  = 'centimeters';
        f_1.PaperSize   = f_1.Position(3:4);
        print(f_1,'time_all_B3C2A0.pdf','-dpdf')

        %saveas(f_2, 'time_all_C3B2A0.pdf');
        f_2.Units       = 'centimeters';
        f_2.PaperUnits  = 'centimeters';
        f_2.PaperSize   = f_2.Position(3:4);
        print(f_2,'time_all_C3B2A0.pdf','-dpdf')

        %saveas(f_3, 'time_all_best.pdf');
        f_3.Units       = 'centimeters';
        f_3.PaperUnits  = 'centimeters';
        f_3.PaperSize   = f_3.Position(3:4);
        print(f_3,'time_all_best.pdf','-dpdf')

    else
        exportgraphics(f,   'time_all_B3A2C0.pdf');
        exportgraphics(f_1, 'time_all_B3C2A0.pdf');
        exportgraphics(f_2, 'time_all_C3B2A0.pdf');
        exportgraphics(f_3, 'time_all_best.pdf'  );
    end
end
