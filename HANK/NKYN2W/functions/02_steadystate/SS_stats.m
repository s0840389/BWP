% Steady state statistics
%%

[mesh.k,mesh.m]=meshgrid(grid.k,grid.m);
clear targets
targets.ShareBorrower=sum((grid.m<0).*sum(sum(joint_distr,2),3)');
targets.A=sum(grid.k.*sum(sum(joint_distr,1),3));
targets.B=grid.m*sum(sum(joint_distr,2),3);
%grid.K=targets.K;
grid.B=targets.B;
targets.K=grid.K;
JDredux = sum(joint_distr,3);
targets.BoverK     = targets.B/targets.K;

parS.qs=qs;

targets.L=grid.N*sum(grid.h'.*squeeze(sum(sum(joint_distr,1),2)));
targets.KY=targets.K/Output;
targets.BY=targets.B/Output;
targets.Y=Output;
BCaux_M=sum(sum(joint_distr,2),3);
targets.m_bc=BCaux_M(1,:);
targets.m_0=BCaux_M(grid.m==0);
BCaux_K=sum(sum(joint_distr,1),3);
targets.k_bc=BCaux_K(:,1);
aux_MK=sum(joint_distr,3);
targets.WtH_b0=sum(aux_MK(mesh.m==0 & mesh.k>0));
targets.WtH_bnonpos=sum(aux_MK(mesh.m<=0 & mesh.k>0));

compen=(Wy_fc.*grid.ly*grid.Mg+grid.le*We_fc);


targets.T =(1-par.tau).*compen ;%+(1-par.tau).*Profits_fc;
par.G=targets.B*(1-par.RB/par.PI)+targets.T;
par.R=R_fc;
par.Wy=Wy_fc(1);
par.We=We_fc;
par.PROFITS=Profits_fc(1);
par.N=grid.N;

targets.GtoY=par.G/Output;

targets.C=sum(sum(sum(joint_distr.*c_a_guess)))*par.nu + sum(sum(sum(joint_distr.*c_n_guess)))*(1-par.nu); % Consumption


targets.LS=compen/Output; % labour share

targets.Inv=par.delta*grid.K;

par.ResWedge=Output-targets.C-par.G-targets.Inv+2* sum(sum(sum((meshes.m<0).*meshes.m.*joint_distr)))*par.borrwedge;



%%

moneydist=sum(sum(joint_distr,3),2);

capdist=sum(sum(joint_distr,3),1);

hdist=squeeze(sum(sum(joint_distr,2),1));

% labour income gini

dhIG=hdist;

yIG=cumsum([hdist(1); diff(cumsum(hdist))].*grid.h')/(sum(grid.h'.*hdist));

targets.Igini=1-sum(dhIG.*yIG)*2;

% wealth share

Wealth=meshes.k+meshes.m;

[distl]=[joint_distr(:), Wealth(:)];

distl=sortrows(distl,2);

targets.Top10=sum((cumsum(distl(:,1))>0.9).*distl(:,2).*distl(:,1))/(sum(distl(:,1).*distl(:,2)));

Income=meshes.k*par.R+meshes.m*(par.RB-1)+par.Wy*meshes.h*par.tau;

[Incdistl]=[joint_distr(:), Income(:)];

Incdistl=sortrows(Incdistl,2);

targets.Top1pct=sum((cumsum(Incdistl(:,1))>=0.99).*Incdistl(:,2).*Incdistl(:,1))/(sum(Incdistl(:,1).*Incdistl(:,2)));

targets.borrowers=sum(sum(sum((meshes.m<0).*joint_distr)));

% Income Gini
[income_sort, IX] = sort(Income(:));
income_pdf        = joint_distr(IX);
income_cdf        = cumsum(income_pdf);

S                   = cumsum(income_pdf.*income_sort)';
S                   = [0 S];
targets.GiniInc      = 1-(sum(income_pdf.*(S(1:end-1)+S(2:end))')/S(end));

%% Ginis
% Net worth Gini
mplusk=mesh.k(:)*par.Q+mesh.m(:);
[mplusk, IX]       = sort(mplusk);
moneycapital_pdf   = JDredux(IX);
moneycapital_cdf   = cumsum(moneycapital_pdf);
targets.NegNetWorth= sum((mplusk<0).*moneycapital_pdf);

S                  = cumsum(moneycapital_pdf.*mplusk)';
S                  = [0 S];
targets.GiniW      = 1-(sum(moneycapital_pdf.*(S(1:end-1)+S(2:end))')/S(end));

% Liquid Gini
[liquid_sort, IX]  = sort(mesh.m(:));
liquid_pdf         = JDredux(IX);
liquid_cdf         = cumsum(liquid_pdf);
targets.Negliquid  = sum((liquid_sort<0).*liquid_pdf);

S                  = cumsum(liquid_pdf.*liquid_sort)';
S                  = [0 S];
targets.GiniLI      = 1-(sum(liquid_pdf.*(S(1:end-1)+S(2:end))')/S(end));

% Illiquid Gini
[illiquid_sort, IX] = sort(mesh.k(:));
illiquid_pdf        = JDredux(IX);
illiquid_cdf        = cumsum(illiquid_pdf);
targets.Negliquid   = sum((illiquid_sort<0).*illiquid_pdf);

S                   = cumsum(illiquid_pdf.*illiquid_sort)';
S                   = [0 S];
targets.GiniIL      = 1-(sum(illiquid_pdf.*(S(1:end-1)+S(2:end))')/S(end));

% consumption gini
css=(1-par.nu)*c_n_guess+par.nu*c_a_guess;

[css_sort, IX] = sort(css(:));

css_pdf   = joint_distr(IX);

S                  = cumsum(css_pdf.*css_sort)';
S                  = [0 S];
targets.GiniC      = 1-(sum(css_pdf.*(S(1:end-1)+S(2:end))')/S(end));

targets.Cy=sum(joint_distr(1:mpar.nhy*mpar.nk*mpar.nm).*css(1:mpar.nhy*mpar.nk*mpar.nm))/mpar.MeasY;
targets.Ce=sum(joint_distr(mpar.nhy*mpar.nk*mpar.nm+1:end).*css(mpar.nhy*mpar.nk*mpar.nm+1:end))/mpar.MeasE;

%%

clear distl Wealth Income Incdistl dhIG yIG illiquid_cdf illiquid_pdf illiquid_sort liquid_cdf liquid_sort liquid_pdf moneycapital_cdf moneycapital_pdf S
clear css_pdf css_sort IX income_pdf income_sort income_cdf