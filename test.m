% =======================================================
%                   Script to test
% =======================================================
%
% Config Parameters
%var_blis  = 'B3A2C0';
clear all

n_kernel  = 6;  % # kernels
graphs    = 1;  % generate graphs
save_data = 1;  % save data

%
% Matrix size 
m = 1024;
n = 1024;
k = 1024;

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

            % kernels 
            
            l = l+1;
            kernel_name(l,:) = {[num2str(mm),'x',num2str(nn),'x',num2str(kk)]};
            
            if save_data == 1 
                fname_all_time    = ['data/time_',num2str(MR),'x',num2str(NR),'x',num2str(KR),'.txt'];
                fname_B3A2C0_time = 'data/B3A2C0/time_B3A2C0.txt';
                fname_B3C2A0_time = 'data/B3C2A0/time_B3C2A0.txt';
                fname_C3B2A0_time = 'data/C3B2A0/time_C3B2A0.txt';
                
                dlmwrite(fname_all_time,    time_all);
                if( KR == 4 )
                    l1 = l1 + 1;
                    kernel_name_B3A2C0(l1,:) = {[num2str(mm),'x',num2str(nn),'x',num2str(kk)]};
                    dlmwrite(fname_B3A2C0_time, round(time_B3A2C0), '-append');
                end
                if ( NR == 4 )
                    l2 = l2 + 1;
                    kernel_name_B3C2A0(l2,:) = {[num2str(mm),'x',num2str(nn),'x',num2str(kk)]};
                    dlmwrite(fname_B3C2A0_time, round(time_B3C2A0), '-append');
                    dlmwrite(fname_C3B2A0_time, round(time_C3B2A0), '-append');
                end
            end
        end
    end
end

    % Generate graphs
if graphs == 1
   generate_graphs(kernel_name_B3A2C0, kernel_name_B3C2A0);
end