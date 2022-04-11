% =======================================================
%                   Script to test
% =======================================================
%
% Config Parameters
%var_blis  = 'B3A2C0';
clear all

n_kernel    = 6;  % # kernels
g_graphs    = 0;  % generate graphs   Matlab/gnuplot
save_data   = 1;  % save data

%
% Matrix size layer 14  mobilnet v1.
m = 1024;
n = 1000;
k = 1;

%
% micro-panels size 
% MR = 4;
% NR = 4; %  4,8,12,16,24 --> second dimension variation 
% KR = 4; %  4,8,12,16,24 --> first variation
%kernel_name = zeros(n_kernel*n_kernel*n_kernel, 4);
%size(kernel_name)
l  = 0;
l1 = 0;
l2 = 0;
p  = 0;

if(save_data == 1)
    %delete the last generate data
    [status, cmdout] = system(['find . -type f -name',' *.txt',' -delete']);
    if(status == 0)
        fprintf(" data has been cleaned...\n");
    else 
        fprintf(" ERROR:\n");
    end
end


for mm = 4:4:(n_kernel*4)
    for nn = 4:4:(n_kernel*4)
        for kk = 4:4:(n_kernel*4)

            MR = mm;
            NR = nn;
            KR = kk; 
            fprintf("===============================================================\n");
            fprintf("                   MR=%d, NR=%d KR=%d                          \n",MR, NR, KR);
            fprintf("===============================================================\n");

            % mc nc kc values 
            


            %%if var_blis == 'B3A2C0'
                % get parameters : mc, nc, kc
                [MC, NC, KC, Mem_L1, Mem_L2, Mem_L3, Mem_L1_use, Mem_L2_use, ...
                Mem_L3_use] = mem_model_gap8('B3A2C0', m, n, k, MR, NR, KR);
                
                p=p+1;
                tiles_data(p,:) = [MC NC KC];

                % model
                [PackBc, PackAc, CopyBr, StreamAc, StreamBr, StreamCr, ...
                BrmemL1, BcmemL3, AcmemL2, time_B3A2C0] = gemm_blis_B3A2C0(m, n, k, MC, NC, KC, MR, NR);
            %elseif var_blis == 'B3C2A0'
                % get parameters : mc, nc, kc
                [MC, NC, KC, Mem_L1, Mem_L2, Mem_L3, Mem_L1_use, Mem_L2_use, ...
                Mem_L3_use] = mem_model_gap8('B3C2A0', m, n, k, MR, NR, KR);

                p=p+1;
                tiles_data(p,:) = [MC NC KC];

                %model
                [PackBc, PackCc, UnpackCc, CopyBr, StreamAr, StreamBr, StreamCr, ...
                BrmemL1, BcmemL3, CcmemL2, time_B3C2A0] = gemm_blis_B3C2A0( m, n, k, MC, NC, KC, MR, KR);

            %elseif var_blis == 'C3B2A0'
                % Get parameters : mc, nc, kc
                [MC, NC, KC, Mem_L1, Mem_L2, Mem_L3, Mem_L1_use, Mem_L2_use, ...
                Mem_L3_use] = mem_model_gap8('C3B2A0', m, n, k, MR, NR, KR);
                    

                p=p+1;
                tiles_data(p,:) = [MC NC KC];
                % model  
                [PackBc, PackCc, UnpackCc, CopyCr, StreamAr, StreamBc, StreamCc, ...
                CrmemL1, CcmemL3, BcmemL2, time_C3B2A0] = gemm_blis_C3B2A0( m, n, k, MC, NC, KC, MR, KR );
            %%end
            
            %All data time 
            time_all =[ time_B3A2C0;
                        time_B3C2A0;
                        time_C3B2A0];
            

            % generate names 
            l = l+1;
            kernel_name(l,:) = {[num2str(mm),'x',num2str(nn),'x',num2str(kk)]};
            label_names =   ["PackBc", "PackCc", "UnpackCc", "CopyBr/CopyCr","StreamA/Ac", ...
                             "StreamBr/Bc","StreamC/Cc/Cr", "Arithmetic"];
            
            if save_data == 1 
                fname_all_time    = ['data/time_',num2str(MR),'x',num2str(NR),'x',num2str(KR),'.txt'];
                %dlmwrite(fname_all_time,    time_all);
                if( KR == 4 )
                    l1 = l1 + 1;
                    %kernel_name_B3A2C0(l1,:) = {[num2str(mm),'x',num2str(nn),'x',num2str(kk)]};
                    kernel_name_B3A2C0(l1,:) = {[num2str(mm),'x',num2str(nn)]};
                    time_B3A2C0_t(l1,:) = time_B3A2C0;
                    %dlmwrite(fname_B3A2C0_time, (time_B3A2C0), '-append');

                end
                if ( NR == 4 )
                    l2 = l2 + 1;
                    %kernel_name_B3C2A0(l2,:) = {[num2str(mm),'x',num2str(nn),'x',num2str(kk)]};
                    kernel_name_B3C2A0(l2,:) = {[num2str(mm),'x',num2str(kk)]};
                    time_B3C2A0_t(l2,:) = time_B3C2A0;
                    time_C3B2A0_t(l2,:) = time_C3B2A0;
                    %dlmwrite(fname_B3C2A0_time, (time_B3C2A0), '-append');
                    %dlmwrite(fname_C3B2A0_time, (time_C3B2A0), '-append');
                end
            end
        end
    end
end

%save data for export
if save_data == 1

    fname_B3A2C0_time = 'data/plots/time_B3A2C0.dat';
    fname_B3C2A0_time = 'data/plots/time_B3C2A0.dat';
    fname_C3B2A0_time = 'data/plots/time_C3B2A0.dat';

    % save data gnuplot
    fprintf(" ==============================\n"); 
    fprintf("              B3A2C0           \n");
    fprintf(" ==============================\n"); 
    data_B3A2C0 = array2table(time_B3A2C0_t, 'Rownames', kernel_name_B3A2C0,'VariableNames', label_names);
    %data_B3A2C0.total = sum(data_B3A2C0{:,1:end},2)
    fprintf(" ==============================\n"); 
    fprintf("             B3C2A0            \n"); 
    fprintf(" ==============================\n"); 
    data_B3C2A0 = array2table(time_B3C2A0_t, 'Rownames', kernel_name_B3C2A0,'VariableNames', label_names);
    %data_B3C2A0.total = sum(data_B3C2A0{:,1:end},2)
    fprintf(" ==============================\n"); 
    fprintf("            C3B2A0             \n"); 
    fprintf(" ==============================\n"); 
    data_C3B2A0 = array2table(time_C3B2A0_t, 'Rownames', kernel_name_B3C2A0,'VariableNames', label_names);
    %data_C3B2A0.total = sum(data_C3B2A0{:,1:end},2)

    %% All kernels data 
    writetable(data_B3A2C0, fname_B3A2C0_time, 'WriteRowNames', true, 'Delimiter',' ') ;
    writetable(data_B3C2A0, fname_B3C2A0_time, 'WriteRowNames', true, 'Delimiter',' ') ;
    writetable(data_C3B2A0, fname_C3B2A0_time, 'WriteRowNames', true, 'Delimiter',' ') ;
    

    %subtable kernels 

                    sub_names_krs   = [ {data_B3A2C0.Properties.RowNames{1 :9 ,:}}'; ...
                                        {data_B3A2C0.Properties.RowNames{13:14,:}}';
                                        {data_B3A2C0.Properties.RowNames{19   ,:}}';   
                                        {data_B3A2C0.Properties.RowNames{25   ,:}}';
                                        {data_B3A2C0.Properties.RowNames{31   ,:}}';];

                    sub_data_B3A2C0 = [ data_B3A2C0{1 :9 ,:};
                                        data_B3A2C0{13:14,:};
                                        data_B3A2C0{19   ,:};   
                                        data_B3A2C0{25   ,:};
                                        data_B3A2C0{31   ,:}];

                    sub_data_B3C2A0 = [ data_B3C2A0{1 :9 ,:};
                                        data_B3C2A0{13:14,:};
                                        data_B3C2A0{19   ,:};
                                        data_B3C2A0{25   ,:};
                                        data_B3C2A0{31   ,:}];

                    sub_data_C3B2A0 = [ data_C3B2A0{1 :9 ,:};
                                        data_C3B2A0{13:14,:};
                                        data_C3B2A0{19   ,:};
                                        data_C3B2A0{25   ,:};
                                        data_C3B2A0{31   ,:}];


    %best kernel for every variant
        %Total times
        total_time_B3A2C0 = (sum(sub_data_B3A2C0,2));
        total_time_B3C2A0 = (sum(sub_data_B3C2A0,2));
        total_time_C3B2A0 = (sum(sub_data_C3B2A0,2));
    
        %best times
        [val1, ind1] = min(total_time_B3A2C0);
        [val2, ind2] = min(total_time_B3C2A0);
        [val3, ind3] = min(total_time_C3B2A0);

        fprintf('B3A2C0  B3C2A0  C3B2A0\n');
        fprintf("%d,%d,%d,%s,%s,%s\n",  val1, val2, val3,...
                sub_names_krs{ind1}, sub_names_krs{ind2}, sub_names_krs{ind3});
end


% Generate graphs this function is replace for gnuplot
if g_graphs == 'matlab_'
    generate_graphs(m, n, k, kernel_name_B3A2C0, kernel_name_B3C2A0);
end
if g_graphs == 1
    %[status, cmdout] = system('gnuplot ~/Blis_family_model/data/plots/plots.gp')
    %[status, cmdout] = system('epstopdf data/plots/time_all_B3A2C0.eps && epstopdf data/plots/time_all_B3C2A0.eps && epstopdf data/plots/time_all_C3B2A0.eps');
    [status, cmdout] = system('~/Blis_family_model/./plot.sh');
    cmdout
    if(status == 0)
        fprintf("gnuplot generate graphs in : /data/plot \n");
    else
        fprintf("Error...\n");

    end
end
