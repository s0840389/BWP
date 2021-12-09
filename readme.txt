

Author: Jamie lenney
Date: 03-Nov-2021


Software required

    MATLAB                                                Version 9.9         (R2020b)
    Econometrics Toolbox                                  Version 5.5         (R2020b)
    Optimization Toolbox                                  Version 9.0         (R2020b)
    Parallel Computing Toolbox                            Version 7.3         (R2020b)
    Statistics and Machine Learning Toolbox               Version 12.0        (R2020b)
    R + selected packages

Folder structure

    1) charts 

    Contains matlab and R codes to generate figures in text

        charts.m - creates the charts in section 4

        decomp_charts.m - Does the partial eq consumption decomp of the HANK IRF's (figure 7)

        charts.r - creates consumption decomp chart (figure 7)

        VAR/main.m - Estimates the VAR in figure 1. [Data included] 

        ls_y_correlation.r - correlation between output and labour share, and standard deviations
               

    2) HANK 

    Contains 3 HANK models solved using the peturbation algorithms Bayer, Born & Luetticke

    NK - medium scale new keynesian model
    NKYN - model augmented with expansionary labour but flexible labour markets Wy=We
    NKYN2W - model augmented with expansionary labour but inflexible labour markets Wy~=We

steady states are saved in directory '../steadystates' new users need to resolve the steady state and save in a chosen directory. 

mainskript.m is the main file to run all the code
definess_pars.m - is the file where parameter value and grid sizes are set.


    3) RANK

     main.m solves 4 models and produces IRF's for those models using a first order peturbation

        NK -  a text book medium scale model

        NKYN - model augmented with expansionary labour

        NKcap - two agent baby hank model with workers and capatalists

        NKYNcap - two agent baby hank model with workers and capatalists augmented with expansionary labour


