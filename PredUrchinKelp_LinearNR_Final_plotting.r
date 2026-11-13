# PredUrchinKelp_LinearNR_v2_plotting.r
#
# Jess K Hopf
# Aug 2025

# This script accompanies the matlab bundle of code that has the leading script PredUrchinKelp_LinearNR_v2.m



library(tidyverse)

# load in data & set types
# Tab_readin <- read_csv('model outputs/PredUrchinKelp_LinearNR_v1_TabOut_DistProb0.25_20251120_500_redistF_F0.08b600000test.csv') %>%
  # Tab_readin <- read_csv('model outputs/PredUrchinKelp_LinearNR_v1_TabOut_DistProb0_20251124_500_redistF_F0.08b600000noDIST.csv') %>%
Tab_readin <- read_csv('model outputs/PredUrchinKelp_LinearNR_v1_TabOut_DistProb0_20260130_F0.08_RU1.5_estMPA_BEFORE.csv') %>%
  mutate(patchID = factor(patchID, levels = c("FB", "RB","RBO","RI", "RIO", "FI", "all"), ordered = T))

# add patch number
Tab_readin <- Tab_readin %>% mutate(patchIDn = rep(c(1:16),(dim(Tab_readin)[1])/16))

# add whole population to table
Tab_readin <- Tab_readin %>% 
  add_row(Tab_readin %>% group_by(sceNo, rep, distProb, distCover) %>%
            summarise(across(yrsBelowKmin:kbioCVT, ~mean(., na.rm = "TRUE"))) %>%
            mutate(patchID = "all", patchIDn = 17)) %>% 
  mutate(patchID = factor(patchID, levels = c("FB", "RB","RBO","RI", "RIO", "FI", "all"), ordered = T)) 






# get probability of disturbance
Prob_dist <- Tab_readin$distProb %>% unique 

# get means across replicates and patches by runs
Tab_mu <- Tab_readin %>% 
  group_by(sceNo, patchID, distProb) %>% 
  summarise(across(yrsBelowKmin:kbioCVT, list(mean = mean, cv = ~sd(.x)/mean(.x))))

# get means across patches by runs (not replicates) (i.e., mean of all FI, FB, etc)
Tab_mupt <- Tab_readin %>% 
  group_by(sceNo, patchID, distProb, rep) %>% 
  summarise(across(yrsBelowKmin:kbioCVT, list(meanpt = mean, cvpt = ~sd(.x)/mean(.x))))

# mean (and se) of means (across replicates)
Tab_mumu <- Tab_readin %>% group_by(sceNo,  patchID, distProb) %>% 
  summarise(across(yrsBelowKmin:kbioCVT, list(meanall = mean, cvall = ~sd(.x)/mean(.x), medall = median)))


              
# colours
p_colours = c("lightblue","darkolivegreen1","darkolivegreen3","darkolivegreen1","darkolivegreen3", "lightblue","grey90")
names(p_colours) = levels(Tab_readin$patchID)


### Individual sites----------------------

# # points are individual patches and runs
# ggplot(Tab_readin, aes(y = 1-yrsBelowKmin, x = patchIDn, group = patchIDn, fill = patchID)) +
#   geom_boxplot(alpha = 0.7) +
#   facet_wrap(~sceNo, ncol = 1) +
#   scale_fill_manual(values = p_colours) +
#   ylab('Proportion of years above kelp threshold') +
#   xlab('Patch') +
#   # ggtitle(paste("Prob of disturbance:",Prob_dist)) +
#   theme_bw() +
#   theme(strip.background = element_blank(),
#         strip.text.x = element_blank(),
#         legend.position = "none") +
#   scale_x_continuous(breaks = c(1:16))

ggplot(Tab_readin, aes(y = 1-yrsBelowKmin, x = patchIDn, group = patchIDn, fill = patchID)) +
  geom_violin(alpha = 0.7, aes(fill = patchID), scale = "width", draw_quantiles = c(0.25, 0.5, 0.75)) +
  # stat_summary(fun.data = "mean_cl_boot", geom = "pointrange", colour = "red") +
  stat_summary(fun = "median", geom = "point", size = 2, colour = "red") +
  stat_summary(fun = quantile, fun.args = list(probs = c(0.25,0.5,0.75)), width = 1, linewidth = 0.2, geom = "crossbar") +
  facet_wrap(~sceNo, ncol = 1) +
  ylab('Proportion of years above kelp threshold') +
  ggtitle(paste("Prob of disturbance:",Prob_dist)) + 
  scale_fill_manual(values = p_colours) +
  theme_bw() +
  theme(strip.background = element_blank(),
        strip.text.x = element_blank())


# change in median
patch_med <- Tab_readin %>% group_by(sceNo, patchIDn, patchID, distProb) %>%
  summarise(across(yrsBelowKmin, list(med = ~median(.x))))
patch_med1 <- patch_med %>% filter(sceNo == 1) %>%
  pull(yrsBelowKmin_med) %>% rep(((dim(patch_med)[1])/17))
patch_med <- patch_med %>% ungroup %>% 
  mutate(scen1 = patch_med1, yrsBelowKmin_diff = yrsBelowKmin_med - patch_med1)

# average change in median by status (excluding old reserves)
patch_med_avg <- patch_med %>% mutate(status = str_extract(patchID, "F|R|all")) %>% 
  group_by(sceNo, status) %>% filter(patchID != "RBO") %>% filter(patchID != "RIO") %>% 
  summarise(across(yrsBelowKmin_diff, list(mean = ~mean(.x))))

patch_med_avg_all <- patch_med %>% mutate(status = str_extract(patchID, "F|R|all")) %>% 
  group_by(sceNo) %>% filter(patchID != "all") %>% 
  summarise(across(yrsBelowKmin_diff, list(mean = ~mean(.x))))


# # change in 75-percentile
# patch_75th <- Tab_readin %>% group_by(sceNo, patchIDn, patchID, distProb) %>%
#   summarise(across(yrsBelowKmin, list(quant75 = ~quantile(.x, 0.75))))
# patch_75th1 <- patch_75th %>% filter(sceNo == 1) %>%
#   pull(yrsBelowKmin_quant75) %>% rep(((dim(patch_75th)[1])/17))
# patch_75th <- patch_75th %>% ungroup %>% 
#   mutate(scen1 = patch_75th1, yrsBelowKmin_diff = yrsBelowKmin_quant75 - patch_75th1)
# 
# # change in 25-percentile
# patch_25th <- Tab_readin %>% group_by(sceNo, patchIDn, patchID, distProb) %>%
#   summarise(across(yrsBelowKmin, list(quant25 = ~quantile(.x, 0.25))))
# patch_25th1 <- patch_25th %>% filter(sceNo == 1) %>%
#   pull(yrsBelowKmin_quant25) %>% rep(((dim(patch_25th)[1])/17))
# patch_25th <- patch_25th %>% ungroup %>% 
#   mutate(scen1 = patch_25th1, yrsBelowKmin_diff = yrsBelowKmin_quant25 - patch_25th1)




ggplot() +
  geom_hline(yintercept = 0) + 
  geom_col(data = patch_med, aes(y = -yrsBelowKmin_diff, x = patchIDn,
                          group = patchIDn, fill = patchID), color = 'grey30') +
  geom_text(data = patch_med %>% filter(patchID == 'all'), 
            aes(y = -yrsBelowKmin_diff, x = patchIDn,
                                  label = round(-yrsBelowKmin_diff,3)), vjust = -0.5) + 
  # geom_point(data = patch_75th, aes(y = -yrsBelowKmin_diff, x = patchIDn, 
  #                                 group = patchIDn), colour = 'black') +
  # geom_point(data = patch_25th, aes(y = -yrsBelowKmin_diff, x = patchIDn, 
  #                                   group = patchIDn), colour = 'red') +
  geom_hline(data = patch_med_avg %>% filter(status != 'all'),
             aes(yintercept = -yrsBelowKmin_diff_mean, 
                                       colour = status)) +
  geom_hline(data = patch_med_avg_all,
             aes(yintercept = -yrsBelowKmin_diff_mean), colour = "grey80") +
  facet_wrap(~sceNo, ncol = 1) +
  ylab('Absoulte change in proportion of years above kelp threshold') +
  ggtitle(paste("Prob of disturbance:",Prob_dist)) + 
  scale_fill_manual(values = p_colours) +
  theme_bw() +
  theme(strip.background = element_blank(),
        strip.text.x = element_blank())
  



### Combined

## Years below min kelp biomass -------------------


  # # points are individual patches and runs
  ggplot(Tab_readin, aes(y = 1-yrsBelowKmin, x = patchID)) +
    geom_boxplot(alpha = 0.7, aes(fill = patchID)) +
    facet_wrap(~sceNo, ncol = 1) +
    ylab('Proportion of years above kelp threshold') +
    ggtitle(paste("Prob of disturbance:",Prob_dist)) + 
    scale_fill_manual(values = p_colours) +
    theme_bw() +
    theme(strip.background = element_blank(),
          strip.text.x = element_blank())


ggplot(Tab_readin, aes(y = 1-yrsBelowKmin, x = patchID)) +
  geom_violin(alpha = 0.7, aes(fill = patchID), scale = "width") +
  stat_summary(fun = "median", geom = "point", size = 2, colour = "red") +
  stat_summary(fun = quantile, fun.args = list(probs = c(0.25,0.5,0.75)), width = 1, linewidth = 0.2, geom = "crossbar") +
  # stat_summary(fun.data = "mean_cl_boot", geom = "pointrange", colour = "red") +
  facet_wrap(~sceNo, ncol = 1) +
  ylab('Proportion of years above kelp threshold') +
  ggtitle(paste("Prob of disturbance:",Prob_dist)) + 
  scale_fill_manual(values = p_colours) +
  theme_bw() +
  theme(strip.background = element_blank(),
        strip.text.x = element_blank())


ggplot(Tab_readin %>% filter(sceNo %in% seq(1,5)), 
       aes(y = 1-yrsBelowKmin, x = patchID)) +
  geom_boxplot(alpha = 0.7, aes(fill = patchID)) +
  facet_wrap(~sceNo, ncol = 1) +
  ylab('Proportion of years above kelp threshold') +
  scale_fill_manual(values = p_colours) +
  theme_bw() +
  theme(strip.background = element_blank(),
        strip.text.x = element_blank(),
        legend.position = "none")

ggplot(Tab_readin %>% filter(sceNo %in% c(1,seq(6,9))), 
       aes(y = 1-yrsBelowKmin, x = patchID)) +
  geom_boxplot(alpha = 0.7, aes(fill = patchID)) +
  facet_wrap(~sceNo, ncol = 1) +
  ylab('Proportion of years above kelp threshold') +
  scale_fill_manual(values = p_colours) +
  theme_bw() +
  theme(strip.background = element_blank(),
        strip.text.x = element_blank(),
        legend.position = "none")
  
  # points are patch means within a replicate
  ggplot(Tab_mupt, aes(y = 1-yrsBelowKmin_meanpt, x = patchID)) +
    geom_boxplot(alpha = 0.5, aes(fill = patchID)) +
    facet_wrap(~sceNo, ncol = 1) +
    scale_fill_manual(values = p_colours) +
    ylab('Mean proportion of years above kelp threshold') +
    ggtitle(paste("Prob of disturbance:",Prob_dist))

  # # mean all
  # ggplot(Tab_mumu, aes(y = 1-yrsBelowKmin_meanall, x = patchID)) +
  #   geom_col() +
  #   facet_wrap(~propRes, ncol = 1) +
  #   ylab('Mean proportion of years below kelp threshold') +
  #   ylim(c(0,0.6)) + 
    # ggtitle(paste("Prob of disturbance:",Prob_dist))

  
## Time-averaged mean of kelp biomass ----------------
  
  # # points are individual patches and runs 
  ggplot(Tab_readin, 
         aes(y = kbioMeanT/100, x = patchID)) +
    geom_boxplot(alpha = 0.7, aes(fill = patchID)) +
    scale_fill_manual(values = p_colours) +
    facet_wrap(~sceNo, ncol = 1) +
    ylab('Time average mean of kelp biomass (tonne/ha)') +
    ggtitle(paste("Prob of disturbance:",Prob_dist)) 

   
  # # points are patch means within a replicate
  # ggplot(Tab_mupt, aes(y = kbioMeanT_meanpt, x = patchID)) +
  #   geom_boxplot() +
  #   facet_wrap(~propRes, ncol = 1) +
  #   ylab('Time average mean of kelp biomass') +
  #   ggtitle(paste("Prob of disturbance:",Prob_dist))
  
  
  
  ## Time-averaged CV of kelp biomass ------------------------
  
  # # points are individual patches and runs 
  ggplot(Tab_readin, aes(y = kbioCVT, x = patchID)) +
    geom_boxplot(alpha = 0.7) +
    facet_wrap(~sceNo, ncol = 1) +
    ylab('Time-averaged CV of kelp biomass') +
    ggtitle(paste("Prob of disturbance:",Prob_dist))


  # # points are patch means within a replicate
  # ggplot(Tab_mupt, aes(y = kbioCVT_meanpt, x = patchID)) +
  #   geom_boxplot() +
  #   facet_wrap(~propRes, ncol = 1) +
  #   ylab('Mean time-averaged CV of kelp biomass') +
  #   ggtitle(paste("Prob of disturbance:",Prob_dist))
  
  
  
 # proportion of patches in the population that are surviving after 20 yrs
  # baseline value
  BL_val <- Tab_mupt %>% ungroup %>% 
    filter(patchID == 'all' & sceNo == 1) %>%
    summarise(median(patchSurv_meanpt)) %>% pull

  ggplot(Tab_mupt %>% filter(patchID == 'all'),
         aes(x = patchSurv_meanpt, y = sceNo, group = sceNo)) +
    geom_boxplot(alpha = 0.7, fill = "grey90") +
    geom_vline(xintercept = BL_val, colour = 'darkred', linetype = 2) + 
    # coord_flip() + 
    scale_y_reverse(name = "") +
    xlab('Proportion of patches surviving (after 20yrs)') +
    # ggtitle(paste("Prob of disturbance:",Prob_dist)) +
    theme_classic() + 
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank(),
          axis.line.y = element_blank())
  
  
  mean_prop <- Tab_readin %>% filter(patchID != 'all') %>% 
    group_by(sceNo, rep) %>% 
    summarise(patchSurv_meanRep = mean(patchSurv))
  
  
  ggplot(mean_prop,
         aes(x = patchSurv_meanRep, y = sceNo, group = sceNo)) +
    geom_boxplot(alpha = 0.7, fill = "grey90") +
    geom_vline(xintercept = BL_val, colour = 'darkred', linetype = 2) + 
    scale_y_reverse(name = "") +
    xlab('Proportion of patches surviving (after 20yrs)') +
    # ggtitle(paste("Prob of disturbance:",Prob_dist)) +
    theme_classic() + 
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank(),
          axis.line.y = element_blank())
  
  
  ggplot(mean_prop,
         aes(x = patchSurv_meanRep, y = sceNo, group = sceNo)) +
    geom_point() +
    scale_y_reverse(name = "") +
    xlab('Proportion of patches surviving (after 20yrs)') +
    # ggtitle(paste("Prob of disturbance:",Prob_dist)) +
    theme_classic() + 
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank(),
          axis.line.y = element_blank())
  
  
  
  
  
  
  ggplot(Tab_readin %>% filter(patchID != 'all'),
         aes(x = patchSurv, y = sceNo, group = sceNo)) +
    geom_boxplot(alpha = 0.7, fill = "grey90") +
    geom_vline(xintercept = BL_val, colour = 'darkred', linetype = 2) + 
    # coord_flip() + 
    scale_y_reverse(name = "") +
    xlab('Proportion of patches surviving (after 20yrs)') +
    # ggtitle(paste("Prob of disturbance:",Prob_dist)) +
    theme_classic() + 
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank(),
          axis.line.y = element_blank())
  
  
  
  
  
  # Proportion of simulations/replicates with kelp (above threshold) >75% and 50% of the time
  Tab_readin <- Tab_readin %>% 
    mutate(yrsAboveKmin = 1-yrsBelowKmin)
  
  Freq_above <- Tab_readin %>% group_by(sceNo, patchID, patchIDn) %>% 
                  summarise(freq50 = mean(yrsAboveKmin>=0.5),
                            freq75 = mean(yrsAboveKmin>=0.75),
                            freq100 = mean(yrsAboveKmin==1))
  
  Freq_above_all <- Freq_above %>% filter(patchIDn != 17) %>% 
                      group_by(sceNo) %>% 
                      summarise(across(freq50:freq100, mean)) %>% 
                      pivot_longer(cols = freq50:freq100, 
                                   names_to = "frequency",
                                   values_to = "proportion")
  
  ggplot(Freq_above, aes(x = patchIDn, y = freq100)) +
    geom_line() +
    facet_wrap(~sceNo, ncol = 1) +
    ylim(c(0,1)) +
    scale_fill_manual(values = p_colours) +
    theme_bw() +
    theme(strip.background = element_blank(),
          strip.text.x = element_blank(),
          legend.position = "none")
      
  ggplot(Freq_above_all) +
    geom_col(aes(y = proportion, x = sceNo, fill = frequency),
            position = "dodge")
  
  
  Freq_above_all %>% group_by(frequency) %>% 
    summarise
  
  
  
  
  
  
  
  
  
  
  
  
  
  





