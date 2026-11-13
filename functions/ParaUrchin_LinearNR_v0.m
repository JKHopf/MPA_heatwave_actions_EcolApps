function urchin = ParaUrchin_LinearNR_v0(tmax)

% Sets para values for urchin portion of the model.
% Relevant to PredUrchinKelp_LinearNR_v1.m & PredUrchinKelp_LinearNR_v2.m


% Recruitment
    % kg incoming settlers per kg adult (mean value; inc fecundity & dispersal) 
    % - set to 0 to turn off urchins in model
    % - threshold urchin biomass value = 2.64x10^4 kg.ha, above which urchins dominate) get this in non-MPA scenario with RU = 3.605*10^5  
    % - 1*10^6 gives urchin values seen at Anacapa East, with sheephead present (6.7x10^3 kg.ha), but urchins dominate when sheephead are
    %   under fishing pressure
    % Set so that kg.60m^2 is within the range seen in the Channel Islands
    % (~60 kg.60m2 outside MPAs, ~24 kg.60m2 in MPAs)
    urchin.RU = 1.5; % 1.75; % 1.25; % baseline = 1.5

    % temporal stdv of recruitment (noise)
    urchin.RUstdv = 0.621; % 0;%       

    % Reproduction timing
    % vector that decitates if reproduction occurs in that time step
    % urchins reproduce 90% March-July (March-May = spring)
    % urchin.RTu = repmat([0.25 0.25 0.25 0.25],1,tmax/4);
    urchin.RTu = repmat([0.05 0.54 0.36 0.05],1,tmax/4);

% Growth    
    % proportion maturing from juvenile to adults
    % 4 seasons in a year * 2 = 2 yrs maturation
    urchin.gJ = 1/(4*2);

% Mortlaity rates (instantaneous natural mortality, per 3months)
    % natural mortality
        % juveniles
        urchin.MJ = 0.1/4;
            % strength of DD 
            % smaller = stronger DD effects (survival increases slower with
            % inc adult biomass)
            urchin.alpha = 0.00001;
            % variance in adult urchin densitites 
            % (for use in scale transition to landscape)
            % value from PISCO_kelp-urchin-sheephead_data.Rmd
            urchin.alphavar = 16113; % 

        % hiding adults
        urchin.MH = 0.1/4;
        % exposed adults
        urchin.ME = 0.1/4;

    % predation (attack) rate on urchins by predators (lower = less mortality)
        % exposed
        urchin.PE = 0.0017472; % 0.0001; %    0.001; %    
        % hiding   0.0065
        urchin.PH = urchin.PE*0.5; % *0.5;

        % handling time (time(in sesasons)/kg prey) 
        % will be <<<1 since it wont take a season for a fish to handle an urchin
        % ( = 1/asymptotic (max) kg of prey consumed per predator in a time step)
        % higher (slower) handling time = lower mortality (higher survival)
        % ballpark one every hour (2184 hours per season = 1/2184th of a season /2 to account for day/night)
        % 1 urchin = 0.21kg, so its 1 kg every 5 hours
        % 1 sheephead = ~2.7 kg (PISCO data), so /2.7 to get per kg predator
        urchin.H = 1/(2184/(2*5))/2.7; % 1/(2184/2); %   0.0001;


    % fishing rate
        urchin.F = 0;   

    % discount rate for juv survival
    % PLD in days
    urchin.PLD = 65;
    urchin.tau = 1-urchin.PLD/91;


% **behavioural switching function (hiding <> exposed)
    % inflection point (drift density at which urchin hiding:exposed = 1:1)
    urchin.w1 = 0.5; %   1; %
    % slope around inflection point 
    % (larger values = steeper inflection = sharper transition)
    % (smaller values = flatter line = urchins out all the time)
    urchin.w2 = 0.5; % 

% **step function (turns predation/fishing of exposed on/off) 
% min density of all standing kelp (juvs + adults) per unit area
% 0 = events never off (predation/reproduction on)
% large number = events always off (predation/reproduction off)
    urchin.kmin = 1*10^4; % 1170*100;% 1170;% 10^10; %  0;%  

end