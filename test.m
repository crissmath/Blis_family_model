% =======================================================
%                   Script to test
% =======================================================
%
% Config Parameters
%var_blis  = 'B3A2C0';
visual    = 0;  % generate graphs
save_data = 1;  % save data
n_kernel  = 6;  % # kernels multiples of 4
%
% Matrix size 
m = 1792;
n = 1536;
k = 1024;

%
% micro-panels size 
% MR = 4;
% NR = 4; %  4,8,12,16,24 --> second dimension variation 
% KR = 4; %  4,8,12,16,24 --> first variation 
for m=4:4:(n_kernel*4)
    for n=4:4:(n_kernel*4)
        for k=4:4:(n_kernel*4)

            MR = m;
            NR = n;
            KR = k; 
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

            if visual == 1
                X = categorical({'B3A2C0', 'B3C2A0', 'C3B2A0'});
                X = reordercats(X,{'B3A2C0', 'B3C2A0', 'C3B2A0'});

                time_bar = bar( X, time_all, "stacked");
                set(time_bar, {'DisplayName'}, {'PackBc', 'PackCc', 'UnpackCc', 'CopyBr/CopyCr', ...
                                            'StreamA/Ac','StreamBr/Bc','StreamC/Cc/Cr', 'Arithmetic'}');
                %Color configuration
                time_bar(1).FaceColor = [0 0.4470 0.7410];
                time_bar(2).FaceColor = [0.8500 0.3250 0.0980];
                time_bar(3).FaceColor = [0.9290 0.6940 0.1250];
                time_bar(4).FaceColor = [0.4660 0.6740 0.1880];
                time_bar(5).FaceColor = [0 0 0];
                time_bar(6).FaceColor = [0.3010 0.7450 0.9330];
                time_bar(7).FaceColor = [0.6350 0.0780 0.1840];
                time_bar(8).FaceColor = [0.4940 0.1840 0.5560];
                legend()
                %exportgraphics(gca, 'time_all_stacked.pdf');
            end

            if save_data == 1 
                fname_all_time    = ['data/time_',num2str(MR),'x',num2str(NR),'x',num2str(KR),'.txt'];
                fname_B3A2C0_time = 'data/B3A2C0/time_B3A2C0.txt';
                fname_B3C2A0_time = 'data/B3C2A0/time_B3C2A0.txt';
                fname_C3B2A0_time = 'data/C3B2A0/time_C3B2A0.txt';
                
                dlmwrite(fname_all_time,    time_all);
                dlmwrite(fname_B3A2C0_time, time_B3A2C0, '-append');
                dlmwrite(fname_B3C2A0_time, time_B3C2A0, '-append');
                dlmwrite(fname_C3B2A0_time, time_C3B2A0, '-append');

            end
        end
    end
end