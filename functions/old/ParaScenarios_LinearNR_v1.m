% ParaScenarios_LinearNR_v0.m
% April 2025
% 
% Jess Hopf
% jess.k.hopf@gmail.com 
  
% runs wtih PredUrchinKelp_LinearNR_v1.m

% % increasing size of area protected in reserve (50% impacted)
% % areas = 0% 12.5%, 25%, 50%
% pAs_vec = [repmat("FB",1,8), repmat("RB",1,0), repmat("RI",1,0), repmat("FI",1,8);...
%     repmat("FB",1,7), repmat("RB",1,1), repmat("RI",1,1), repmat("FI",1,7);...
%     repmat("FB",1,6), repmat("RB",1,2), repmat("RI",1,2), repmat("FI",1,6);...
%     repmat("FB",1,4), repmat("RB",1,4), repmat("RI",1,4), repmat("FI",1,4);...
%     repmat("FB",1,2), repmat("RB",1,6), repmat("RI",1,6), repmat("FI",1,2);...
%     repmat("FB",1,0), repmat("RB",1,8), repmat("RI",1,8), repmat("FI",1,0)];



% % changing location of reserve (50% impacted / 12.5% reserve)
% % area of reserve impacted: 0%, 50%, 100%
% pAs_vec = [repmat("FB",1,6), repmat("RB",1,2), repmat("RI",1,0), repmat("FI",1,8);...
%     repmat("FB",1,7), repmat("RB",1,1), repmat("RI",1,1), repmat("FI",1,7);...
%     repmat("FB",1,8), repmat("RB",1,0), repmat("RI",1,2), repmat("FI",1,6);];


% All scenarios 
    pAs_vec = [repmat("FB",9,8),repmat("FI",9,8)];

    % Baseline
    pAs_vec(1,5) = "RB"; pAs_vec(1,13) = "RI";
    % Add
    pAs_vec(2,[2,6]) = "RB"; pAs_vec(2,[10,14]) = "RI";
    pAs_vec(3,[4,5]) = "RB"; pAs_vec(3,[12,13]) = "RI";
    pAs_vec(4,[3,4,5]) = "RB"; pAs_vec(4,13) = "RI";
    pAs_vec(5,5) = "RB"; pAs_vec(5,[11,12,13]) = "RI";
    % Move
    pAs_vec(6,[4,5]) = "RB";
    pAs_vec(7,[3,6]) = "RB";
    pAs_vec(8,[12,13]) = "RI";
    pAs_vec(9,[11,14]) = "RI";




% Others/play arounds ---------------------

    % pAs_vec = [repmat("FB",1,7), repmat("RB",1,1), repmat("RI",1,1), repmat("FI",1,7)];
    % pAs_vec = [repmat("FB",1,4), repmat("RB",1,4), repmat("RI",1,4), repmat("FI",1,4)];
    

    % pAs_vec = [repmat("FB",1,7), repmat("FI",1,7), repmat("RI",1,1), repmat("RB",1,1);
    %              repmat("FB",1,6), repmat("FI",1,6), repmat("RI",1,2), repmat("RB",1,2)];


% pAs_vec = [repmat("FB",1,7), repmat("FI",1,7), repmat("RI",1,1), repmat("RB",1,1);
    %              repmat("FB",1,6), repmat("FI",1,6), repmat("RI",1,2), repmat("RB",1,2)];

    % testing the layout of the coastline
    % pAs_vec = [repmat("FB",1,7), repmat("RB",1,1), repmat("RI",1,1), repmat("FI",1,7);...
    %         repmat("FB",1,7), repmat("FI",1,7), repmat("RI",1,1), repmat("RB",1,1);...
    %         repmat("RB",1,1), repmat("FB",1,7), repmat("FI",1,7), repmat("RI",1,1)];




% % All scenarios OLD
%     pAs_vec = [repmat("FB",17,8),repmat("FI",17,8)];
% 
%     % MPAs close
%         % no impacted MPAs
%         pAs_vec(1,4:5) = "RB";
%         pAs_vec(2,3:6) = "RB";
%         pAs_vec(3,1:8) = "RB";
% 
%         % mix impact
%         pAs_vec(4,8) = "RB"; pAs_vec(4,9) = "RI";
%         pAs_vec(5,7:8) = "RB"; pAs_vec(5,9:10) = "RI";
%         pAs_vec(6,5:8) = "RB"; pAs_vec(6,9:12) = "RI";
% 
%         % all MPAs impacted
%         pAs_vec(7,12:13) = "RI";
%         pAs_vec(8,11:14) = "RI";
%         pAs_vec(9,9:16) = "RI";
% 
%     % MPAs far
%         % no impacted MPAs
%         pAs_vec(10,[2,7]) = "RB";
%         pAs_vec(11,1:2:7) = "RB";
% 
%         % mix impact
%         pAs_vec(12,5) = "RB"; pAs_vec(12,13) = "RI";
%         pAs_vec(13,[3,7]) = "RB"; pAs_vec(13,[11,15]) = "RI";
%         pAs_vec(14,2:2:8) = "RB"; pAs_vec(14,10:2:16) = "RI";
% 
%         % all MPAs impacted
%         pAs_vec(15,[10,15]) = "RI";
%         pAs_vec(16,9:2:15) = "RI";



%%

% % number of patches
% n = 16;
% 
% % number of MPAs
% k = 2;
% 
% 
% % get combinations of the elements in binomical coefficients
% ops = nchoosek(1:n,k)
% 
% % find only combinations that dont have adjacent pairs (including edge pairs)
% % ops1 = [ops(:,k) ops(:,1:(k-1))];
% % check = sum(ismember((ops-ops1),[1,1-n]),2)==0;
% % valid = ops.*check;
% % 
% % valid( ~any(valid,2), : ) = []
% % size(valid,1)
% 
% valid = ops;
% 
% 
% % remove symetrical duplicates
% 
% nvec = 1:n;
% nvecr = flip(nvec);
% ns = [nvec; nvecr((n/2+1):n) nvecr(1:(n/2))]';
% sortns = sort([prod(valid,2), prod(changem(valid,ns(:,1),ns(:,2)),2)],2);
% [~,uniis,~] = unique(sortns,'rows');
% 
% univalid = valid(sort(uniis),:)
% size(univalid,1)
% 
% 
% % assign MPAs to places
% 
%     % empty fished vector + impacted
%     pAs_vec = repmat("F",size(univalid,1),n);
% 
%     % add reserves
%     for m = 1:size(univalid,1)
%         pAs_vec(m,univalid(m,:)) = "R";
%     end
% 
%     % add baseline/impact
%     pAs_vec(:,:,2) = [repmat("B",size(univalid,1),n/2),repmat("I",size(univalid,1),n/2),];
%     pAs_vec = join(pAs_vec,"",3);
% 




    % 
    % % plot
    % pAs_plot = str2double(changem(pAs_vec,[1,2,3,4],["FB","RB","RI","FI"]));
    % figure
    % heatmap(pAs_plot,'CellLabelColor', 'None')


