% PredUrchinKelp_LinearNR_v1_Plotting
% Dec 2024
% 
% Jess Hopf
% jess.k.hopf@gmail.com 

% goes with PredUrchinKelp_LinearNR_v2.m



%% Initial conditions biomasses

NbioF = squeeze(mean(NBP1(:,:,contains(pAs,"F")),2)).*0.00006;
NbioR = squeeze(mean(NBP1(:,:,~contains(pAs,"F")),2)).*0.00006;
Nbio = [reshape(NbioF,1,[]), reshape(NbioR,1,[])];
NbioGrp = [repmat("Fished",1,2254),repmat("MPA",1,322)];

UbioF = squeeze(sum(UBP1(2:3,(T1-40):end,:,contains(pAs,"F")),1)).*0.00006;
UbioR = squeeze(sum(UBP1(2:3,(T1-40):end,:,~contains(pAs,"F")),1)).*0.00006;

KbioF = squeeze(sum(KBP1(1:2,(T1-40):end,:,contains(pAs,"F")),1)).*0.00006;
KbioR = squeeze(sum(KBP1(1:2,(T1-40):end,:,~contains(pAs,"F")),1)).*0.00006;



figure
tiledlayout(2,2)

nexttile([2,1]);
hold on
boxplot(Nbio,NbioGrp)
yline(2.2,':g')    % last 10 yrs (2008-2018)
yline(1.91,'--g')  % 10yrs before heatwave (2004-2014)
yline(1.3,':b')
yline(1.46,'--b')
ylabel('Sheephead biomass densities (kg.60m^2)')
ylim([0,2.5])
title("pred.BHb = " + pred.BHb + "  F " + pred.F*4 + "  Pred " + urchin.PE + "   urchin.RU " + urchin.RU)


nexttile
hold on
scatter(reshape(UbioF,1,[]), reshape(KbioF,1,[]), 'b', 'filled', 'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2)
xline(mean(UbioF, 'all'), '--m')
yline(mean(KbioF, 'all'), '--g')
title("Fished: urchins = " + mean(UbioF, 'all') + " kelp = " + mean(KbioF, 'all'))
% ylim([0,1000])
% xlim([0,600])
xlabel('Urchin biomass (kg.60m^2)')
ylabel('Kelp biomass (kg.60m^2)')

nexttile
hold on
scatter(reshape(UbioR,1,[]), reshape(KbioR,1,[]), 'g', 'filled', 'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2)
xline(mean(UbioR, 'all'), '--m')
yline(mean(KbioR, 'all'), '--g')
title("Fished: urchins = " + mean(UbioR, 'all') + " kelp = " + mean(KbioR, 'all'))
% ylim([0,1000])
% xlim([0,600])
xlabel('Urchin biomass (kg.60m^2)')
ylabel('Kelp biomass (kg.60m^2)')
%%

% nexttile
% hold on
% histogram(UbioF, 'FaceAlpha',0.6)
% xline(mean(UbioF, 'all'), '--b')
% histogram(UbioR, 'FaceAlpha',0.6, 'FaceColor','g')
% xline(mean(UbioR, 'all'), '--g')
% title("Fished: " + mean(UbioF, 'all') + "  MPA: " + mean(UbioR, 'all'))
% 
% xlabel('Urchin biomass (kg.60m^2)')
% ylabel('Frequency')
% 
% nexttile
% hold on
% histogram(KbioF, 'FaceAlpha',0.6)
% xline(mean(KbioF, 'all'), '--b')
% histogram(KbioR, 'FaceAlpha',0.6, 'FaceColor','g')
% xline(mean(KbioR, 'all'), '--g')
% xlabel('Kelp biomass (kg.60m^2)')
% ylabel('Frequency')
% title("Fished: " + mean(KbioF, 'all') + "  MPA: " + mean(KbioR, 'all'))







%% Predator biomass over time (single scenario)

% Pre-disturbance time period
    T = T0+T1+1;

    % sum up populations
    NBps = zeros(T,ps,RR);
    for i = 1:ps
        ind1 = pred.meshno*(i-1)+1;
        ind2 = pred.meshno*(i);
        NBps(:,i,:) = pagetranspose(sum(nb1(ind1:ind2,:,:),1));
    end

    figure
    for i = 1:ps
        subplot(ps, 1, i)
        plot((1:T),squeeze(NBps(:,i,:)),'k')
        xline(T0+1,'--r')
        title(pAs(i))
        xlim([0,T+1])
    end
    xlabel('time (seasons)')
    ylabel('Pred biomass (kg.km^2)')



% % post disturbance
%     % sum up populations
%     NBps = zeros(T2,ps,RR);
%     for i = 1:ps
%         ind1 = pred.meshno*(i-1)+1;
%         ind2 = pred.meshno*(i);
%         NBps(:,i,:) = pagetranspose(sum(nb(ind1:ind2,(end-T2+1):end,:),1));
%     end
% 
%     ylims = [0,5000];
% 
%     figure
%     for i = 1:ps
%         subplot(ps, 1, i)
%         plot((1:T2),squeeze(NBps(:,i,:)),'k')
%         title(pAs(i))
%         % ylim(ylims)
%     end
%     xlabel('time (seasons)')
%     ylabel('Pred biomass (kg.km^2)')



%% Urchin-kelp biomass over time figure and outputs (single rep & scenario)
    
% which rep? 
R = 1;

% pre or post?
P = 'pre'; % 'post'; %      
switch P
    case 'pre'
        KBP = KBP1;
        UBP = UBP1;
        T = T1+1;
    case 'post'
        KBP = KBP2;
        UBP = UBP2;
        T = T2+1;
end


figure
hold on

subs = ps; %1; % 

for p = 1:subs
    
    subplot(2,subs,p)
    plot((1:T)'./4, KBP(:,:,R,p))
    % xlim([10,T/4])
    ylim([0,ceil(max(KBP(:,:,R,:),[],'all')*1.01)])
    ylabel('Kelp density (kg.km2)')

    if p == ps
    legend('Juv Kelp','Adult kelp','Drift kelp')
    end
    if strcmp(P,'pre')
        title(pAs_vec(1,p))
    else 
        title(pAs(p))
    end

    subplot(2,subs,subs+p)
    hold on
    plot((1:T)'./4, UBP(2:3,:,R,p))
    % xlim([10,T/4])
    ylim([0,ceil(max(UBP(2:3,:,R,:),[],'all')*1.01)])
    
    % text((T-40)/4, UBP(2,T,R,p),num2str(urchin.H))

    if p == ps
    legend('Hiding adults','Exposed adult')
    end
    ylabel('Urchin density (kg.km2)')
    xlabel('Time (seasons)')

end

annotation('textbox',[.1 .9 .1 .1], ...
    'String',[P," rep:",R],'EdgeColor','none')



%% Prop yrs below x kg kelp (single scenario)
% each dot is a replicate run

% scenario #
ss = 1;

% target level
tkg = urchin.kmin;


% yrs standing kelp below target
% removing first 10 yrs & normalised to length of run
yrbl = squeeze(sum(KBP2(1:2,41:end,:,:),1));
yrbl = squeeze(sum((yrbl<tkg),1)./(T2+1-40));
yrblmu = squeeze(mean(yrbl,2));

figure
hold on
scatter(categorical(pAs), yrbl, 'filled')
% scatter(categorical(["FB", "FI", "RB", "RI"]), mean(yrbl).*100, 'filled','k')
% xlim([10,(T2+1)/4])
ylim([0,0.1])
ylabel("Prop years below min (" + urchin.kmin + ")")
xlabel('Population')


%% Prop yrs below x kg kelp (multiple scenarios)

% scatter plot of all reps
figure
hold on

for j = 1:size(pAs_vec,1)
    subplot(size(pAs_vec,1),1,j)
    scatter(categorical(pAs_vec(j,:)), yrbl(:,:,j), 'filled')
end

% mean across 




%% Mean and CV kelp (multiple scenarios, 4pops)
% rep & time-averaged

% sum standing kelp
% removing first 10 yrs & normalise to area 
% & scale to 1km2 (total area is 10km2)
KS4 = sum(KB4(1:2,41:end,:,:,:))./reshape(areas_vec,[1,1,1,size(areas_vec)])./10;

% mean across time
KS4meant = squeeze(mean(KS4,2));

% CV across time
KS4CVt = squeeze(std(KS4,0,2))./KS4meant;

% mean of mean and CV across reps
KS4meanm = squeeze(mean(KS4meant,1,"omitmissing"));
KS4meancv = squeeze(mean(KS4CVt,1,"omitmissing"));


% add the mean across the 4 patches 
% (ignore zeros as this is when there is no MPA)
KS4meanm(:,5) = mean(KS4meanm, 2, 'omitmissing');
KS4meancv(:,5) = mean(KS4meancv, 2, 'omitmissing');


% set colours
mycolors = viridis(length(areaR_vec));

figure
hold on

subplot(2,1,1)
scatter(categorical(["FB", "FI", "RB", "RI","All"]), KS4meanm, 'filled')
% xlim([10,(T2+1)/4])
% ylim([0,1.1])
ylabel("Mean time-average kelp biomass (kg.km^2)")
title("Heatwave probability (yr): " + dist.prob + ". Prop area affected by HW: "+areaH)
ax = gca; 
ax.ColorOrder = mycolors;

subplot(2,1,2)
scatter(categorical(["FB", "FI", "RB", "RI","All"]), KS4meancv, 'filled')
% xlim([10,(T2+1)/4])
% ylim([0,1.1])
ylabel("Mean CV kelp biomass")
xlabel('Population')
ldg = legend(string(areaR_vec));
title(ldg,'Prop area reserve')
ax = gca; 
ax.ColorOrder = mycolors;


% % Urchins
% % removing first 10 yrs & normalise to area
% U4 = sum(UB4(2:3,41:end,:,:,:))./reshape(areas_vec,[1,1,1,size(areas_vec)]);
% 
% % mean across time
% U4meant = squeeze(mean(U4,2));
% 
% % mean of mean
% U4meanm = squeeze(mean(U4meant,1,"omitmissing"))
% 
% sum(KS4meanm)
% mean(KS4meanm)
% sum(U4meanm)
% mean(U4meanm)

%% plot persistence over time (multiple reps, single scenario)

figure(25240)
hold on

for i = 1:4  
    i2 = (3*i-1);

    subplot(1,4,i)
    hold on
    plot((1:T2+1)./4,sum(kt2(i2,:,:)>1,3),'--r','LineWidth',1)
    % xline(dist.yrs,'--r')
    % xline(dist.yrs(end)+8*4+1,'--k')
    % xline(dist.yrs(1)+mngt.time+(1:mngt.length),':k')
    xlabel('Time (years)')
    ylabel('Number of sims persisting')
    ylim([0,RR])

    if i == 1
        title("Fished & Baseline (FB)")
    elseif i == 2
        title("Fished & Impacted by heatwaves (FI)")
    elseif i == 3
        title("Protected & Baseline (RB)")
    else
        title("Protected & Impacted by heatwaves (RI)")
    end
end





%% persistence over time

figure
hold on 

plot(PropSurvPS2')


%% Testing replicate numbers

% proportion of patches in the population that are surviving after 20 yrs
psurv_perpatch = mean(psurv);
psurv_all = mean(psurv,'all');

figure(1342)
hold on

% subplot(2,1,1)
% hold on
% scatter(1:16,psurv_perpatch,'filled')

subplot(2,1,2)
hold on
scatter(RR,psurv_all,'filled')
