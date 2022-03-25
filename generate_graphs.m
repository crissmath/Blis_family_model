% this function load data for model and create graphs
function generate_graphs(kernel_name)

    % Load data 
    data_B3A2C0 = readmatrix('data/B3A2C0/time_B3A2C0.txt');
    data_B3C2A0 = readmatrix('data/B3C2A0/time_B3C2A0.txt');
    data_C3B2A0 = readmatrix('data/C3B2A0/time_C3B2A0.txt');

    % plot data 
    kr_names = kernel_name;
    X = categorical(kr_names');
    X = reordercats(X,kr_names');

    disp_name =  {'PackBc', 'PackCc', 'UnpackCc', 'CopyBr/CopyCr', ...
    'StreamA/Ac','StreamBr/Bc','StreamC/Cc/Cr', 'Arithmetic'}';

    f = figure;
    subplot(3,1,1)
    time_B3A2C0_variant = bar(X, data_B3A2C0, "stacked");
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
    subplot(3,1,2)
    time_B3C2A0_variant = bar(X, data_B3C2A0, "stacked");
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
    subplot(3,1,3)
    time_C3B2A0_variant = bar(X, data_C3B2A0, "stacked");
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
    %exportgraphics(f, 'time_all_kernel.pdf');
end