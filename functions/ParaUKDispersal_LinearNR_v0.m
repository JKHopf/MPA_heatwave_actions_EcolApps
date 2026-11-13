function disp = ParaUKDispersal_LinearNR_v0(kelp, ps)

% Sets the dispersal type and values for the linear coastline urchin-kelp model.
% Relevant to PredUrchinKelp_LinearNR_v1.m & PredUrchinKelp_LinearNR_v2.m

% unpack
rJ = kelp.rJ;
rD = kelp.rD;

% generic

% no dispersal/move
disp.Deye = eye(ps);


% Kelp -------

% juveniles/spores 
    % % none
    % disp.Dkj = disp.Deye;

    % even redistribution (well mixed)
    % disp.Dkj = repmat(1/ps, ps, ps); 

    % % nearest neighbour
    % disp.Dkj = diag(repmat(rJ,ps,1)) + diag(repmat((1-rJ)/2,ps-1,1),1) +...
    %       diag(repmat((1-rJ)/2,ps-1,1),-1) + diag((1-rJ)/2,ps-1) + diag((1-rJ)/2,-ps+1); 

    % using data from Gaylord 2002 (Fig 7 - cumulative probabilities)
    % here we have fitted a negative expoential curve to the cum prob data
    % (see Gaylord_macro_dispersal.rmd)
        % shape parameter from fit
        para = 1.059;

        % distances between patches 
        % assume each patch is 1km x 1km
        % makes long enough for dispersal not to be lost into the ether
        % dists = 0.5:1:19.5;
        dists = 1:40;

        % the probability of travelling within the given distances 
        % (i.e. up to 1km, up to 2km etc)
        dispprob = [1,exp(-para.*dists(1:end-1))] - exp(-para.*dists);

        % drop out every second patch 
        % (which is a sand patch where spores go to die ☠️)
        dispprob = dispprob(1:2:end);

        % loop the extra back around
        % first pads out array with 0, then reshape to the 1/2 number of
        % patches + 1, and finally sum up extra for each patch
        pss = ps/2+1;
        dispprob = sum(reshape(padarray(dispprob,[0,pss-rem(length(dispprob),pss)],'post')',pss,[]),2);

        % get the first column of the dispersal matrix (for patch 1)
        % [prob of dispersing with own patch; prob of going to other patchs
        % downstream; prob to furthest patch; prob of going upstream]
        D1 = [dispprob(1); dispprob(2:end-1)/2; dispprob(end); flip(dispprob(2:end-1))/2];

        % cycle through the patches, offseting the dispersal matrix each
        % time
        disp.Dkj = NaN(ps);
        disp.Dkj(:,1) = D1;
        for p = 2:ps
            disp.Dkj(:,p) = [D1(end-(p-2):end); D1(1:end-p+1)];
        end 


% drift
    % % none
    % disp.Dkd = disp.Deye.*rD;

    % even redistribution 
    % Dkd = repmat(1/ps, ps, ps); 
     
    % nearest neighbour
    disp.Dkd = diag(repmat(rD,ps,1)) + diag(repmat((1-rD)/2,ps-1,1),1) +...
          diag(repmat((1-rD)/2,ps-1,1),-1) + diag((1-rD)/2,ps-1) + diag((1-rD)/2,-ps+1); 


 % Urchins ---------------------
    % % none
    % disp.Duj = disp.Deye;

    % juveniles (even redistribution among even sized patches)
    disp.Duj = repmat(1/ps, ps, ps);    




end