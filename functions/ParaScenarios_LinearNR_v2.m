% ParaScenarios_LinearNR_v2.m
% April 2025
% 
% Jess Hopf
% jess.k.hopf@gmail.com 
  
% runs wtih  PredUrchinKelp_LinearNR_Final.m
% comment in/out required scenario

% Establishing new MPAs
    % % no reserves
        % pAs_vec = [repmat("FB",1,8),repmat("FI",1,8)];


% % All scenarios 
%     pAs_vec = [repmat("FB",17,8),repmat("FI",17,8)];
% 
%     % MPAs close
%         % no impacted MPAs
%         pAs_vec(2,4:5) = "RB";
%         pAs_vec(3,3:6) = "RB";
%         pAs_vec(4,1:8) = "RB";
% 
%         % mix impact
%         pAs_vec(5,8) = "RB"; pAs_vec(5,9) = "RI";
%         pAs_vec(6,7:8) = "RB"; pAs_vec(6,9:10) = "RI";
%         pAs_vec(7,5:8) = "RB"; pAs_vec(7,9:12) = "RI";
% 
%         % all MPAs impacted
%         pAs_vec(8,12:13) = "RI";
%         pAs_vec(9,11:14) = "RI";
%         pAs_vec(10,9:16) = "RI";
% 
%     % MPAs far
%         % no impacted MPAs
%         pAs_vec(11,[2,7]) = "RB";
%         pAs_vec(12,1:2:7) = "RB";
% 
%         % mix impact
%         pAs_vec(13,5) = "RB"; pAs_vec(13,13) = "RI";
%         pAs_vec(14,[3,7]) = "RB"; pAs_vec(14,[11,15]) = "RI";
%         pAs_vec(15,2:2:8) = "RB"; pAs_vec(15,10:2:16) = "RI";
% 
%         % all MPAs impacted
%         pAs_vec(16,[10,15]) = "RI";
%         pAs_vec(17,9:2:15) = "RI";


% % Adding to established MPA network
%     % just baseline
%         pAs_vec = [repmat("FB",1,8),repmat("FI",1,8)];
%         pAs_vec(1,6) = "RB"; pAs_vec(1,14) = "RI";
% 
%     % All scenarios 
%         pAs_vec = [repmat("FB",9,8),repmat("FI",9,8)];
%         % Baseline
%         pAs_vec(1:7,6) = "RBO"; pAs_vec([1:5,8,9],14) = "RIO";
%         % Add
%         pAs_vec(2,2) = "RB"; pAs_vec(2,10) = "RI";
%         pAs_vec(3,5) = "RB"; pAs_vec(3,13) = "RI";
%         pAs_vec(4,[5,7]) = "RB"; 
%         pAs_vec(5,[13,15]) = "RI";
%         % Move
%         pAs_vec(6,5) = "RB";
%         pAs_vec(7,2) = "RB";
%         pAs_vec(8,13) = "RI";
%         pAs_vec(9,10) = "RI";

