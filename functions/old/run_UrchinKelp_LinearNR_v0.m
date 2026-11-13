function [kt,ut,GC,RK_noise] = run_UrchinKelp_LinearNR_v0(kelp, urchin, patch, disp, tmax, RR, kt1, ut1, nt, dist)
% function running single populations kelp <> urchins model
% see parent file for parameter values

% Runs with
% PredUrchinKelp_LinearNR_v0.m

% see Hunter and Caswell (2005, ecological modelling) for more information
% on vecpermutation approach

% -----------------------
% unpack structures 
% note, some parts of structure are not unpacked until later
ps = patch.ps;
pAs = patch.pAs;

Deye = disp.Deye;
Dkj = disp.Dkj;
Dkd = disp.Dkd;
Duj = disp.Duj;

RKstdv = kelp.RKstdv;
mu = kelp.mu;
muvar = kelp.muvar;
ddD = kelp.ddD;
RTk = kelp.RTk;
reproWeight = kelp.reproWeight;  
lag = kelp.lag; 
g = kelp.g;
rS = kelp.rS;
c = kelp.c;
d = kelp.d;
rD = kelp.rD;
rJ = kelp.rJ;
aij = cell2mat(kelp.aij);

RU = urchin.RU;
RUstdv = urchin.RUstdv;
RTu = urchin.RTu;
gJ = urchin.gJ;
MJ = urchin.MJ;
alpha = urchin.alpha;
alphavar = urchin.alphavar;
MH = urchin.MH;
ME = urchin.ME;
PH = urchin.PH;
PE = urchin.PE;
H = urchin.H;
F = urchin.F;
PLD = urchin.PLD;
tau = urchin.tau;
w1 = urchin.w1;
w2 = urchin.w2;
kmin = urchin.kmin;

dist_yrs = dist.yrs;

    
% vectors for state variables ---
    % predators
    % nt = reshape(nt,4,[],1,RR);
    
    % kelp
    kt = NaN(3*ps,tmax,RR);
    kt(:,1,:) = repmat(kt1',1,1,RR);
    
    % urchins
    ut = kt;
    ut(:,1,:) =  repmat(ut1',1,1,RR);  

% set noise vectors for recruits (timeseries of noise)
% this needs to be done outside the loop becasue we set the same variance for
% the whole year (= 4 time steps), which is what the repelem() does

    % kelp (sptial and temporal noise)
    % RK_noise = repelem(max(zeros(tmax/4,1,RR),normrnd(1,RKstdv,tmax/4,1,RR)),4,1,1);
    RK_noise = repelem(max(zeros(tmax/4,ps,RR),normrnd(1,RKstdv,tmax/4,ps,RR)),4,1,1);

    % urchins (temporal noise only)
    RU_noise = repelem(max(zeros(tmax/4,1,RR),normrnd(1,RUstdv,tmax/4,1,RR)),4,1,1);

% Dispersal matricies 
% these come from the function/script Dispersal_LinearNR_v0.m
    % Urchins
    % join into block and repeat
    Du = repmat(blkdiag(Duj, Deye, Deye),1,1,RR); 

    % Kelp
    % join into block and repeat
    % note that this does not include movement for juveniles as this is
    % treated as an addition of juvs at the end (+RKnew) due to the
    % time-lag needed for bull-kelp
    Dk = repmat(blkdiag(Deye, Deye, Dkd),1,1,RR);  

% pre-set stuff
    % vecpermutation matrix, repeated for reps
    P = repmat(Func_vecperm(ps,3),1,1,RR);
    % set Psi (switching function) to 1 (predation on) as intial condition
    Psi = ones(1,1,RR);

% run over time ----
    for t = 1:tmax

        % Values for impacted (I) patches
        % add disturbance effects if it is a heatwave year
        if ismember(t, dist_yrs)
            % kelp recruitment
            RKI = dist.RK;
            % change in standing kelp growth
            lambdaI = dist.lambda(t);
            % urchin grazing rates
            hijI = dist.hij(:,:,t); 
        else 
            RKI = kelp.RK;
            lambdaI = kelp.lambda(t);
            hijI = cell2mat(kelp.hij);
            hijI = hijI(:,:,t);  
        end

        % values for non-heatwave impacted patches
        RK = kelp.RK;
        lambda = kelp.lambda(t);
        hij = cell2mat(kelp.hij);
        hij = hij(:,:,t);    

    % 🟣 URCHINS ---
    % runs per patch, since depends on local densities for everything
    Mu = zeros(3*ps, 3*ps, RR);

    for p = 1:ps
        % index
        i1 = 3*p-2;
        i2 = 3*p-1;
        i3 = 3*p;

        if contains(pAs(p),'I')  % impacted patches
            Hij = hijI;
        else
            Hij = hij;   % non-impacted patches
        end

        % if for the last 6 months (>3months) of kelp biomass are less than 
        % thethreshold (each year), then urchins no longer reproduce and 
        % are not predated on
        % Psi is 1 until  k < kmin for consecutive time periods, then it is 0 (predation off)
        % it can switch back to 1 (predation on) if there is enough kelp
        if t>2 
            ktdelay = sum(kt(i1:i2,(t-2:t-1),:));        
            Psi = sum(ktdelay < kmin) ~= 2;
        end
       
        % 1. Demography
        % incoming recruits per kg adult w/ timing + noise (temporal, not spatial)
        RUin = RU .* RTu(t) .* RU_noise(t,:,:);

        % survival
            % juvs
                % density-independent survival
                sJ = exp(-MJ);

                % get denisty of prey/predators at relevant scale (1ha)
                % pred-prey dynamics (1 km2 = 100ha)
                utden = sum(ut(i2:i3,t,:))./100;
                ntden = nt(p,t,:,:)./100;

                % inc DD survival (more adults = more survival)
                % sJ = sJ.*(1-exp(-alpha*(ut(i2,t)+ut(i3,t))));

                % with scaling transition
                % sJ = sJ.*(1-exp(-alpha*(ut(i2,t)+ut(i3,t))) - 0.5*alpha^2 * exp(-alpha*(ut(i2,t)+ut(i3,t))) * alphavar);
                % give error if neg survival and set sJ to zero if that is
                % the case (this means that for high variances, such as
                % what we see, the landscape-scale survival will rapidly
                % drop off at moderate-low urchins densities
                % if sJ<0; warning('Urchin survival < 0'); end
                % if sJ<0; sJ = 0; end

            % % linear predation (surviving predation)
            % % hiding adults 
            % sH = exp(-MH -PH.*ntden -F);
            % % exposed adults
            % sE = exp(-ME -Psi .* (PE.*ntden + F));

            % % type II predation
            % % hiding adults 
            % sH = exp(-MH -F -Func_TypeII(PH,H,utden).*ntden);
            % % exposed adults
            % sE = exp(-ME -Psi .* (F + Func_TypeII(PE,H,utden).*ntden));

            % type III predation
            % assumes hollings original Type III where k = 2
            % hiding adults 
            sH = exp(-MH -F -Func_TypeIII(PH,H,2,utden).*ntden);
            % exposed adults
            sE = exp(-ME -Psi .* (F + Func_TypeIII(PE,H,2,utden).*ntden));


            % proportion urchins exposed / behavioural swtiching (phi)
                % grazing capacity 
                % (ratio of drift kelp to total urchin feeding rate, in local patch)
                % use max so that NaN (no drift state) becomes 0
                GC = max(kt(i3,t,:)./(sum(ut(i2:i3,t,:)).*Hij(3,1)),0);

                % Phi = Func_Switch(w1, w2, kt(i3,t));
                Phi = reshape(Func_Switch(w1, w2, GC),1,1,RR);
                % Phi = zeros(1,1,RR);

            % demography matrices 
            Mu(i1:i3,i1:i3,:) = [repmat((1-gJ)*sJ,1,1,RR),  RUin,  Psi.*RUin;
                                 gJ.*(1-Phi).*sH,    (1-Phi).*sH,  (1-Phi).*sH;
                                 gJ.*Phi.*sE,        Phi.*sE,      Phi.*sE];
    end

        % 2. Projection matrix (demography then dispersal)
        % dispersal matricies are pulled from outside the forloop
        Pu = pagemtimes(pagemtimes(pagetranspose(P),Du),pagemtimes(P,Mu));

        % next yrs numbers
        ut(:,t+1,:) = pagemtimes(Pu,ut(:,t,:));


        % mass mortality events (urchin culling) need to check if works for linear if using
        % if urchin.culling == "Y"
        %     if ismember(t, dist_yrs(1) + urchin.culltime + (0:urchin.culllgth-1))
        %         % ut(2:3,t+1,:) = max(ut(2:3,t+1,:) - [urchin.culln*0.5; urchin.culln*0.5],[0;0]);
        %         % cull all exposed first, then the hiding urchins
        %             % which reps have more exposed than the cull number
        %             exp_reps = find(ut(3,t+1,:) > urchin.culln)';
        %             % ...and which dont
        %             both_reps = find(ut(3,t+1,:) <= urchin.culln)';
        %             % for exp_reps, just cull from exposed
        %             ut(3,t+1,exp_reps) = ut(3,t+1,exp_reps) - urchin.culln;
        %             % for both_reps, cull all from exposed and rest from hiding
        %             ut(3,t+1,both_reps) = 0;
        %             ut(2,t+1,both_reps) = max(ut(2,t+1,both_reps)-ut(3,t+1,both_reps),0);
        %     end
        % end

        
    % 🌿 KELP ----
       
      % kelp restoration 
      % NEED TO FIX FOR LINEAR! if using
        % % adding juveile kelp biomass 
        RKr = 0;
        % if kelp.restore == "Y"
        %     if ismember(t, dist_yrs(1) + kelp.resttime + (0:kelp.restlgth-1))
        %         RKr = kelp.restn;
        %     end
        % end
        
        % 1. Demography
        % for each patch
        RKnew = zeros(3*ps, 1, RR);
        Mk = zeros(3*ps, 3*ps, RR);
        for p = 1:ps
            % index
            i1 = 3*p-2;
            i2 = 3*p-1;
            i3 = 3*p;

            if contains(pAs(p),'I')  % impacted patches
                rk = RKI;
                lamb = lambdaI;
                Hij = hijI;
            else
                rk = RK;            % non-impacted patches
                lamb = lambda;
                Hij = hij;   
            end


            % Juvenile kelp 
            % settlment -> DD survival -> grazing & other

                % per capita settling spores + timing + noise from adults
                RKset = rk .* RTk(t) .* RK_noise(t,p,:);
    
                % Total standing adult contribution to patch p
                ksporeT = sum(reproWeight .* kt((1:3:ps*3)+1,max(1,t-lag),:) .* Dkj(p,:)', 1:2);
    
                % total incoming setted sporophyte biomass (before density dependence)
                % spores from all adults x patch area + [restored juvs]<---- (this needs fixing if using)
                ksetT = RKset .* ksporeT + RKr;
    
                % DD survival of young
                     % to be used for intra-cohort part of DD
                % if ksetn = 0 & k2n = 0 then the DD function is NaN, and if <1 we get wierd survival rates, 
                % so we will set 1 instead. This wont affect dynamics, since it is then x 0. 
                % NOTE TO SELF: need to make proportional density in 4+ popmodel
                ksetn = max(ksetT, 1);
            
                % Adult densities to be used for inter-cohort part of DD
                % NOTE TO SELF: need to make proportional density in 4+ popmodel
                k2n = max(kt(i2,t,:), 1);
    
                % DD functions
    
                % for Beverton-Holt DD function 
                % (which doesnt use scale transitions, since only settlers)
                % note this basic form assumes that the slope at the orgin = 1
                if ddD == 1
                    sY = 1/(1+ksetn.*mu);
    
                else % for mixed and ricker DD functions
                    DD = ( (ddD-1).*k2n.*exp(mu.*ddD.*k2n) ) ./ (ddD.*ksetn.*exp(mu.*ddD.*k2n) + exp(mu.*k2n) .* ((ddD-1).*k2n-ddD.*ksetn)  );
    
                    % second derivative of mixed DD function
                    % this has been calculted using the matlab solver, see ExploringMixedDD_v0.m 
                    DD2 = (2.*k2n.*exp(ddD.*mu.*k2n).*(ddD - 1).*(exp(mu.*k2n).*(ddD - 1) + mu.*exp(mu.*k2n).*(k2n.*(ddD - 1) - ddD.*ksetn) + ddD^2.*ksetn.*mu.*exp(ddD.*mu.*k2n)).^2)./(exp(mu.*k2n).*(k2n.*(ddD - 1) - ddD.*ksetn) + ddD.*ksetn.*exp(ddD.*mu.*k2n)).^3 - (k2n.*exp(ddD.*mu.*k2n).*(ddD - 1).*(2.*mu.*exp(mu.*k2n).*(ddD - 1) + mu.^2.*exp(mu.*k2n).*(k2n.*(ddD - 1) - ddD.*ksetn) + ddD.^3.*ksetn.*mu.^2.*exp(ddD.*mu.*k2n)))./(exp(mu.*k2n).*(k2n.*(ddD - 1) - ddD.*ksetn) + ddD.*ksetn.*exp(ddD.*mu.*k2n)).^2 - (2.*exp(ddD.*mu.*k2n).*(ddD - 1).*(exp(mu.*k2n).*(ddD - 1) + mu.*exp(mu.*k2n).*(k2n.*(ddD - 1) - ddD.*ksetn) + ddD.^2.*ksetn.*mu.*exp(ddD.*mu.*k2n)))./(exp(mu.*k2n).*(k2n.*(ddD - 1) - ddD.*ksetn) + ddD.*ksetn.*exp(ddD.*mu.*k2n)).^2 + (2.*ddD.*mu.*exp(ddD.*mu.*k2n).*(ddD - 1))./(exp(mu.*k2n).*(k2n.*(ddD - 1) - ddD.*ksetn) + ddD.*ksetn.*exp(ddD.*mu.*k2n)) + (ddD.^2.*mu.^2.*k2n.*exp(ddD.*mu.*k2n).*(ddD - 1))./(exp(mu.*k2n).*(k2n.*(ddD - 1) - ddD.*ksetn) + ddD.*ksetn.*exp(ddD.*mu.*k2n)) - (2.*ddD.*mu.*k2n.*exp(ddD.*mu.*k2n).*(ddD - 1).*(exp(mu.*k2n).*(ddD - 1) + mu.*exp(mu.*k2n).*(k2n.*(ddD - 1) - ddD.*ksetn) + ddD^2.*ksetn.*mu.*exp(ddD.*mu.*k2n)))./(exp(mu.*k2n).*(k2n.*(ddD - 1) - ddD.*ksetn) + ddD.*ksetn.*exp(ddD.*mu.*k2n)).^2;
    
                    % per capita survival of settlers including scale transition
                    sY = DD + 0.5.*DD2.*muvar;
                end 
    
                % total new biomass of juveniles
                % = total incoming * DD surv * retension * predation * growth
                RKnew(i1,:,:) = ksetT .* sY .* rS .* exp(-Func_TypeII(aij(1,2),Hij(1,2),sum(kt(i1:i2,t,:))).*ut(i3,t+1,:)) .* lamb;

        % projection matrix
        Mk(i1:i3,i1:i3,:) = [zeros(1,1,RR), zeros(1,1,RR), zeros(1,1,RR);
            
              rS .* g .* (1-c) .* exp(-Func_TypeII(aij(2,2),Hij(2,2),sum(kt(i1:i2,t,:))).*ut(i3,t+1,:)) .* lamb,...
              rS .* g .* (1-c) .* exp(-Func_TypeII(aij(2,2),Hij(2,2),sum(kt(i1:i2,t,:))).*ut(i3,t+1,:)) .* lamb,...
              zeros(1,1,RR);

              c .* exp(-Func_TypeII(aij(3,1),Hij(3,1),kt(i3,t,:)).*ut(i2,t+1,:)),...
              c .* exp(-Func_TypeII(aij(3,1),Hij(3,1),kt(i3,t,:)).*ut(i2,t+1,:)),...
              (1-d) .* exp(-Func_TypeII(aij(3,1),Hij(3,1),kt(i3,t,:)).*ut(i2,t+1,:))];

        end
       
        
        % 2. Projection matrix (demography then dispersal)
        Pk = pagemtimes(pagemtimes(pagetranspose(P),Dk),pagemtimes(P,Mk));

        % next yrs numbers + recruits
        kt(:,t+1,:) = pagemtimes(Pk,kt(:,t,:)) + RKnew;

    
    end

end
