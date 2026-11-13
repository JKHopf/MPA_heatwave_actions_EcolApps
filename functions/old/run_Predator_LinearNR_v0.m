function [N_t,B_t] = run_Predator_LinearNR_v0(pred, T, RR, patch, nt1)

% runs IMP model for predators
% Linear non-realistic model

% Runs with
% PredUrchinKelp_LinearNR_v0.m

% unpack 'patch' structure
ps = patch.ps;
pAs = patch.pAs;

% Model run set-up --------------------
    % repilcated rho vector (pdf of recruits)
    Ro = repmat(pred.Ro',1,1,RR);

    % set noise vectors for recruits (timeseries of noise)
    % this needs to be done outside the loop becasue we set the same variance for
    % the whole year (= 4 time steps)
    % (assumes TEMPORAL, but not spatial variation)
    R_noise = repelem(max(zeros(T/4,1,RR),normrnd(1,pred.Rstdv,T/4,1,RR)),4,1,1);

    % set up matrix to hold model runs 
    % size = y(size classes)*number of patches,t(time),RR(reps)
    N_t = nan(length(pred.x).*ps,T,RR);

    % set baseline predator parameters 
    % (these get changed in the years that fishery closures happen - see below)
        % fished
        predTempF = pred;
        % reserve (and set F to 0)
        predTempR = pred;
        predTempR.F = 0;

    % set intial conditions (size distributions)
    if size(nt1,2) == 1
        N_t(:,1,:) = repmat(nt1,1,RR);
    else
        N_t(:,1,:) = nt1;
    end

% Model run ---------------
    for t = 1:T %loop over time steps  

    % Temporarily change fishing pressure
        % if ismember('fish', pred.Properties.VariableNames) && pred.fish == "Y"
        %     if ismember(t, dist.yrs(1) + pred.fishtime + (0:pred.fishlgth-1))
        %         predTempF.F = pred.fishF;
        %     else
        %         predTempF.F = pred.F;
        %     end
        % end

    % GROWTH & SURVIVAL
        % Create the kernels that caculates the probability of 
        % growing and moving from size x to y.
        % This is where fishing is included, so we need one for reserves
        % and one for fished areas. 
        % size = mesh size x mesh size x reps
        % This is determinisic 
        % (if need to add variability to adult survival it happens here, 
        % using vectorised version, it just takes A LOT longer to run)
        kmatF = Func_mkkern(predTempF);
        kmatR = Func_mkkern(predTempR);
              
        % weight by midpoint rule (even weighting)
        kmatF = pred.dx .* kmatF;
        kmatR = pred.dx .* kmatR;

        % replicate        
        kmatF = repmat(kmatF,1,1,RR);
        kmatR = repmat(kmatR,1,1,RR);

        % assign to each patch to the bloack diagonal depending on patch status
            % empty matrix  
            kmat = zeros(size(N_t,1), size(N_t,1), RR);
        for p = 1:ps
            if contains(pAs(p),'R')  % reserves
                kmat((pred.meshno*(p-1)+1):(pred.meshno*p), (pred.meshno*(p-1)+1):(pred.meshno*p), :) = kmatR;
            else % fished
                kmat((pred.meshno*(p-1)+1):(pred.meshno*p), (pred.meshno*(p-1)+1):(pred.meshno*p), :) = kmatF;
            end
        end 
        

    % RECRUITMENT
    % closed population with DD, well-mixed between patches
        
        % total larval production in population
        L = sum(repmat(pred.Fun',ps,1).* N_t(:,t,:));  
                  
        % number that survive DD
        % DD survival - Beverton-Holt function (recruits affect each other)
        % This is the same for all pops under a well mixed assumption
        R = (pred.BHa./(1+(pred.BHa.*L)./(pred.BHb))).*L;
        
        % recrtuiment variability after DD 
        % (assumes TEMPORAL, but not spatial variation)
        R = max([zeros(1,1,RR),normrnd(R,pred.Rstdv)]); 
    
        % multiple by prob density function
        Radd = R.*Ro.* pred.RoT(t).*R_noise(t,:,:);

        % distribute into patches
        Raddps = repmat(Radd./ps, ps,1);
              
    % CALC NEXT TIME STEP
        % keep >= 0 (issue from + var recruits)
        N_t(:,t+1,:) = pagemtimes(kmat,N_t(:,t,:)) + Raddps;
        N_t(:,t+1,:) = max(0,N_t(:,t+1,:)); 

    end

        % biomass (kg)
        B_t = N_t.*repmat(Func_Length2Weight(pred.x',pred.y,pred.z),ps,T+1,RR);

end








    
    