function Mort = Func_TypeIII(a,h,k,prey)

% Type III 
% Prey switching behavior
% Refugia effects at low prey densities

% Characteristic features:
    % - Low predation pressure when prey is rare (providing refugia)
    % - Accelerating predation at intermediate densities
    % - Saturation at high prey densities due to handling time limits

    % Mort = p.c. mortlaity of resource due to grazing
    % h = handling time (time/prey per kg predator) = 1/asymptotic (max) kg of prey consumed per predator 
    % a = attack rate (prey/time per kg predator)
    % prey = density of prey
    % k = Hill coefficient or cooperativity parameter(use k = 2 for orginal
    % hollings type III)
    % note its k-1 in the numerator since this is per capita rates 


    Mort = (a.*prey.^(k-1))./(1+a.*h.*prey.^k);

end    



% Plotting
    % per predator
    % figure(1)
    % hold on
    % plot(1:1000, Func_TypeIII(urchin.PH,10^3,2,1:1000), LineWidth=1)
    % xlabel('Density of resource/prey')
    % ylabel('p.c. mortality due to predation')
 


    % pred_n = 1:10^6;
    % H = [1,0.1,0.01,0.001,0.0001,0.00001];
    % 
    % T3 = NaN(length(h), length(pred_n));
    % 
    % for h = 1:length(H)
    %     T3(h,:) = Func_TypeIII(urchin.PH,H(h),2,pred_n);
    %     xlim([0,10^5])
    % end
    % 
    % 
    % figure
    % subplot(2,1,1)
    % hold on
    % plot(pred_n, T3, LineWidth=1)
    % ylabel('p.c. mortality due to predation')
    % subplot(2,1,2)
    % hold on
    % plot(pred_n, exp(-T3), LineWidth=1)
    % xlabel('Density of resource/prey')
    % ylabel('p.c. survival due to predation')


