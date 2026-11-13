% PredUrchinKelp_LinearNR_Final.m
% Nov 2026
% 
% Jess Hopf
% jess.k.hopf@gmail.com 

% Toolboxes requried:
%   - Statistics and Machine Learning Toolbox
%   - Optimization Toolbox
%   - Image processing toolbox
%   - Mapping toolbox

% Pred-urchin-kelp linear, non-sptial model in discrete time 

% An infinite linear coastline with p patches of equal size.
%  - The last and first patch are connected.
%  - This is a non-realistic coastline. 
%  - Patches are 1 x 1km = 1 km2, with 1km of sand between each
%  - Some patches are protected in a reserve, some are fished (varies)
%  - Some patches are affected by heatwaves, some are not (varies)
%  - all other variance (e.g. recruitment) is temporal but not spatial
%  - kelp: adults are assumed homogenous within a patch, larval dispersal is only between neighboring patches and only a small portion of the larval disperse, drift dispersal is...a gaussian function??
%  - urchins: adults are sedentary within the patch. Larval are well mixed across the whole coastline
%  - sheephead: adults are sedentary within a patch, larval are well mixed across the whole coastline

% Patch types:
%   - Fished & Baseline (FB)
%   - Fished & Impacted by heatwaves (FI)
%   - Protected & Baseline (RB)
%   - Protected & Impacted by heatwaves (RI)


% Top-level stuff --------------------

    % clear all
    clear
    
    % add paths
    addpath('functions\')
    addpath('model outputs\')
    addpath('sandbox\')

    % set random number
    % rng(1)

    tic
        
% ------- Model parameters -------------

% runtimes
% runs winter, spring, summer, autmum
% disturbance happens in yr 20-23
T0 = 40*4; % pre timing for predator
T1 = 40*4; % initial, no disturbance scenario
T2 = 20*4; % disturbance/MPA adaptation scenario

% number of replicates
RR = 5000;%  


% patch assignment
    % (min 4 patches, must be even number)
    % F = fished, R = reserve, B = baseline, I = impacted by heatwaves

    % call patches from scenario script
    ParaScenarios_LinearNR_v2

    % number of patches 
    ps = size(pAs_vec,2);

% load in parameter values
tmax = 1000;
kelp = ParaKelp_LinearNR_v0(1000);
urchin = ParaUrchin_LinearNR_v0(1000);
pred = ParaPred_LinearNR_v0(1000);
disp = ParaUKDispersal_LinearNR_v0(kelp, ps);

% --- Disturbance -------

% How do vital rates change during the disturbance 
% kelp recruitment
dist.RK =  kelp.RK / 7; %  kelp.RK; % 0; %  
% change in kelp biomass
dist.lambda = kelp.lambda .* repmat([1 1 0.5 0.5],1,tmax/4); %   .* 0; %
% urchin grazing rates
dist.hij = repmat(cell2mat(kelp.bhij) .* reshape([1.15 1.05 1.2 2.3],1,1,4), 1, 1, tmax/4); %  repmat(cell2mat(kelp.bhij), 1, 1, 1, tmax/4); %  

% ---------- Run models -----------------

% 1. Run model without disturbance & with baseline MPA configuration

    % prob of disturbance in a given year
    % use dist-prob = 0 for never having diturbance, and 1 for always
    % having a disturbance
    dist.prob = 0;
   
        % set years with disturbance and then rep for each season in that year
        indD = repelem(rand((T1+4)/4,1)<dist.prob,4,1); 
    
        % set vector with years 
        dist.yrs = 1:(T1+4); 
        dist.yrs = dist.yrs(indD); 
 
    % set MPA configuration to baseline
    pAs = pAs_vec(1,:);

    % Intial conditions
    % KELP
    kt0 = repmat([1.2*10^6,1.2*10^6,1.2*10^6],1,ps); %  [0,1,0]; %  [0,0,0]; %    
    % URCHINS
    ut0 = repmat([100000,100000,0],1,ps);%  [urchin.RU,urchin.RU,0]; % repmat([0 0 0],1,ps);% 
    
    % run pred model over time
    % runs a bit longer to get a stable state for preds
    [nt1,nb1] = run_Predator_LinearNR_v1(pred, T0+T1, RR, ps, pAs, repmat(50,pred.meshno*ps,1));
    nb1_re = reshape(nb1,pred.meshno,ps,T0+T1+1,[]);

   % biomass predating on urchins, proportional to area
    PBE1 = squeeze(sum(nb1_re(pred.Lgraze_ind:end,:,(T0+1):end,:),1));
    % PBE1 = zeros(ps,T2,1,1,1,RR);
    % PBE1 = repmat(5000,ps,T2,1,1,1,RR);

    % urchin-kelp section
    % note that input predator biomass needs to be size T2 x RR)
    [kt1,ut1,~,~] = run_UrchinKelp_LinearNR_v2(kelp, urchin, ps, pAs, disp,...
                                  T1, RR, kt0, ut0, squeeze(PBE1), dist);

        % split out populations
        NBP1 = zeros(T1+1,RR,ps);
        KBP1 = zeros(3,T1+1,RR,ps); 
        UBP1 = zeros(3,T1+1,RR,ps); 
        for p = 1:ps
            i1 = 3*p-2; 
            i3 = 3*p;
            KBP1(:,:,:,p) = kt1(i1:i3,:,:);
            UBP1(:,:,:,p) = ut1(i1:i3,:,:);

            ind1 = pred.meshno*(p-1)+1;
            ind2 = pred.meshno*(p);
            NBP1(:,:,p) = squeeze(sum(nb1(ind1:ind2,(end-T1):end,:),1));
        end

    % outputs
    % the runs in which the population (all patches) persist to the end
    PerstReps = find(squeeze(prod(sum(KBP1(1:2,end,:,:),1) > 1,4)));

    % proportion replicates w/persisting kelp forest over time
    % (broken down by patch)
    PropSurvPS1 = squeeze(sum(sum(KBP1(1:2,:,:,:),1) > 1, 3)./RR)';

    % mean (across replicates) standing kelp/adult urchins/all pred biomass over time 
    % (broken down by population)
    % patch x time x scenario
    KBPmean = squeeze(mean(sum(KBP1(1:2,:,:,:),1),3))';
    UBPmean = squeeze(mean(sum(UBP1(2:3,:,:,:),1),3))';
    NBPmean = squeeze(mean(NBP1(:,:,:),2))';


%% 2. Run next section with disturbance and alternative MPA configs

    % Reset prob of disturbance in a given year
    dist.prob =  0.25; % 

     % set years with disturbance and then rep for each season in that year
        indD = repelem(rand((T1+4)/4,1)<dist.prob,4,1); 
    
        % set vector with years 
        dist.yrs = 1:(T1+4); 
        dist.yrs = dist.yrs(indD); 
 

% pre-assign variables
yrbl  = NaN(RR,ps,size(pAs_vec,1));
Kmeant  = NaN(RR,ps,size(pAs_vec,1));
Kcvt  = NaN(RR,ps,size(pAs_vec,1));
psurv = NaN(RR,ps,size(pAs_vec,1));

% Run over timing of mngt action
% note: run as parfor when doing large number of reps or when running over
% scenarions, otherwise (checking single reps/runs) runs as for
for i = 1:size(pAs_vec,1)

    pAs = pAs_vec(i,:);

    % run pred model over time
    % note T1 is to get stable state and T2 is the same as the
    % urchin-kelp run
    [~,nb2] = run_Predator_LinearNR_v1(pred, T2, RR, ps, pAs, nt1(:,end));
    nb2_re = reshape(nb2,pred.meshno,ps,T2+1,[]);

    % biomass predating on urchins, proportional to area
    PBE2 = squeeze(sum(nb2_re(pred.Lgraze_ind:end,:,:,:),1));
    % PBE2 = zeros(ps,T2,1,1,1,RR);
    % PBE2 = repmat(5000,ps,T2,1,1,1,RR);

    % urchin-kelp section
    % note that input predator biomass needs to be size T2 x RR)
    [kt2,ut2,~,~] = run_UrchinKelp_LinearNR_v2(kelp, urchin, ps, pAs, disp,...
                                  T2, RR, kt1(:,end,:), ut1(:,end,:), squeeze(PBE2), dist);

    % split out populations
    NBP2 = zeros(T2+1,RR,ps);
    KBP2 = zeros(3,T2+1,RR,ps); 
    UBP2 = zeros(3,T2+1,RR,ps); 
    for p = 1:ps
        i1 = 3*p-2; 
        i3 = 3*p;
        KBP2(:,:,:,p) = kt2(i1:i3,:,:);
        UBP2(:,:,:,p) = ut2(i1:i3,:,:);

        ind1 = pred.meshno*(p-1)+1;
        ind2 = pred.meshno*(p);
        NBP2(:,:,p) = squeeze(sum(nb2(ind1:ind2,(end-T2):end,:),1));
    end


    % get stats

    % FOR SINGLE RUNS (looking at persisting forests)
        % the runs in which the population (all patches) persist to the end
        PerstReps = find(squeeze(prod(sum(KBP2(1:2,end,:,:),1) > 1,4)));

        % proportion replicates w/persisting kelp forest over time
        % (broken down by patch)
        PropSurvPS2 = squeeze(sum(sum(KBP2(1:2,:,:,:),1) > 1, 3)./RR)';

        % mean (across replicates) standing kelp/adult urchins/all pred biomass over time 
        % (broken down by population, omitting populations that go to extinction)
        % patch x time x scenario
        KBPmean = squeeze(mean(sum(KBP2(1:2,:,PerstReps,:),1),3))';
        UBPmean = squeeze(mean(sum(UBP2(2:3,:,PerstReps,:),1),3))';
        NBPmean = squeeze(mean(NBP2(:,:,:),2))';

    % the following calculations are at the patch level
    % PROP YRS BELOW xkg KELP
        % dvide by length of run
        yrbl1 = squeeze(sum(KBP2(1:2,:,:,:),1));
        % for each rep, each patch
        yrbl(:,:,i) = squeeze(sum((yrbl1<urchin.kmin),1)./(T2+1)); 

   % does patch extist after T2
   % above 0.01% 
        psurv(:,:,i) = squeeze(sum(KBP2(1:2,end,:,:),1) > 100);
   
   % MEAN & CV of kelp biomass
        % sum kelp
        Kmean = squeeze(sum(KBP2(1:2,:,:,:,:),1));
        % mean across time (each rep, each patch)
        Kmeant(:,:,i) = squeeze(mean(Kmean,1)); 
        % CV across time (each rep, each patch)
        Kcvt(:,:,i) = squeeze(std(Kmean,0,1))./Kmeant(:,:,i);





end
toc

%% Set up tables to export to R

% table set up
% scenario | replicate | patch | value
%     s1   |     r1    |  p1   |  ...   
%     s1   |     r1    |  ...  |  ...   
%     s1   |     r1    |  p16  |  ... 

%     s1   |     r2    |  p1   |  ...   
%     s1   |     r2    |  ...  |  ...   
%     s1   |     r2    |  p16  |  ...
  
%     s1   |     ...   |  ...  |  ...   
%     s1   |     RR    |  p16  |  ...  

%     S    |     RR    |  p16  |  ...  



% repeat each scenario set RR times and put into a vector
patchID = reshape(repelem(pAs_vec,RR,1)',1,[])';
sceNo = repelem(1:size(pAs_vec,1), RR * ps)';
% propRes = repelem([0,0.125,0.25,0.5,0.75,1], RR * ps)';
% propRes = repelem([0, 0.5, 1], RR * ps)';

% replicate number
rep = repmat(repelem(1:RR,1,ps),1,size(pAs_vec,1))';

% scenario info
distProb = repmat(dist.prob, length(patchID),1);
distCover = repmat(0.5, length(patchID),1);

% variables
yrsBelowKmin = reshape(pagetranspose(yrbl),[],1,1);
patchSurv = reshape(pagetranspose(psurv),[],1,1);
kbioMeanT = reshape(pagetranspose(Kmeant),[],1,1);
kbioCVT = reshape(pagetranspose(Kcvt),[],1,1);

Tab_out = table(sceNo, rep, patchID, distProb, distCover, yrsBelowKmin, patchSurv, kbioMeanT, kbioCVT);


% save table
writetable(Tab_out,['PredUrchinKelp_LinearNR_v1_TabOut_DistProb',num2str(dist.prob),'_',datestr(now, 'yyyymmdd'),'_F',num2str(pred.F*4),'_RU',num2str(urchin.RU),'_estMPA.csv'])



%% single scenario calcualtions
% PREDATORS
    % mean over time for fished (left) and reserve (right) 
    [mean(NBPmean(contains(pAs,"F"),:,:),1:2),mean(NBPmean(~contains(pAs,"F"),:,:),1:2)]

% URCHINS
    % mean over time for fished (left) and reserve (right) 
    [mean(UBPmean(contains(pAs,"F"),:,:),1:2),mean(UBPmean(~contains(pAs,"F"),:,:),1:2)]
    [mean(UBPmean(contains(pAs,"F"),:,:),1:2),mean(UBPmean(~contains(pAs,"F"),:,:),1:2)]

% KELP
    % mean over time for fished (left) and reserve (right) 
    [mean(KBPmean(contains(pAs,"F"),:,:),1:2), mean(KBPmean(~contains(pAs,"F"),:,:),1:2)]
    % proprotion surviving (last 2 years) fished (top), reserve (mid), and both (bottom)
    [mean(PropSurvPS(contains(pAs,"F"),(end-8):end));...
     mean(PropSurvPS(~contains(pAs,"F"),(end-8):end));...
     mean(PropSurvPS(:,(end-8):end))]


