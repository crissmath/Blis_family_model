% =======================================================
%                   Script to test
% =======================================================
%
% Config Parameters
%var_blis  = 'B3A2C0';
clear all

n_kernel    = 6;  % # kernels
g_graphs    = 1;  % generate graphs   Matlab/gnuplot
save_data   = 1;  % save data

%
% Matrix size layer 14  mobilnet v1.
m = 512;
n = 196;
k = 4608;

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

            %%if var_blis == 'B3A2C0'
                % get parameters : mc, nc, kc
                [MC, NC, KC, Mem_L1, Mem_L2, Mem_L3, Mem_L1_use, Mem_L2_use, ...
                Mem_L3_use] = mem_model_gap8('B3A2C0', m, n, k, MR, NR, KR);

                % model
                [PackBc, PackAc, CopyBr, StreamAc, StreamBr, StreamCr, ...
                BrmemL1, BcmemL3, AcmemL2, time_B3A2C0] = gemm_blis_B3A2C0(m, n, k, MC, NC, KC, MR, NR);
            %elseif var_blis == 'B3C2A0'
                % get parameters : mc, nc, kc
                [MC, NC, KC, Mem_L1, Mem_L2, Mem_L3, Mem_L1_use, Mem_L2_use, ...
                Mem_L3_use] = mem_model_gap8('B3C2A0', m, n, k, MR, NR, KR);

                %model
                [PackBc, PackCc, UnpackCc, CopyBr, StreamAr, StreamBr, StreamCr, ...
                BrmemL1, BcmemL3, CcmemL2, time_B3C2A0] = gemm_blis_B3C2A0( m, n, k, MC, NC, KC, MR, KR);

            %elseif var_blis == 'C3B2A0'
                % Get parameters : mc, nc, kc
                [MC, NC, KC, Mem_L1, Mem_L2, Mem_L3, Mem_L1_use, Mem_L2_use, ...
                Mem_L3_use] = mem_model_gap8('C3B2A0', m, n, k, MR, NR, KR);
                    
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
    data_B3A2C0 = array2table(time_B3A2C0_t, 'Rownames', kernel_name_B3A2C0,'VariableNames', label_names)
    fprintf(" ==============================\n"); 
    fprintf("             B3C2A0            \n"); 
    fprintf(" ==============================\n"); 
    data_B3C2A0 = array2table(time_B3C2A0_t, 'Rownames', kernel_name_B3C2A0,'VariableNames', label_names)
    fprintf(" ==============================\n"); 
    fprintf("            C3B2A0             \n"); 
    fprintf(" ==============================\n"); 
    data_C3B2A0 = array2table(time_C3B2A0_t, 'Rownames', kernel_name_B3C2A0,'VariableNames', label_names)

    writetable(data_B3A2C0, fname_B3A2C0_time, 'WriteRowNames', true, 'Delimiter',' ') ;
    writetable(data_B3C2A0, fname_B3C2A0_time, 'WriteRowNames', true, 'Delimiter',' ') ;
    writetable(data_C3B2A0, fname_C3B2A0_time, 'WriteRowNames', true, 'Delimiter',' ') ;  
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