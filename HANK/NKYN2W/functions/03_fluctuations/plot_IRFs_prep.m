
IRF_distr=Gamma_state*IRF_state_sparse(1:mpar.numstates-mpar.os,1:mpar.maxlag);
% preparation
%IRF_H=100*grid.h(1:end-1)*IRF_distr(mpar.nm+mpar.nk+(1:mpar.nh-1),2:end)/par.H;
K=grid.k*IRF_distr(mpar.nm+(1:mpar.nk),:)+grid.K;
%I=(K(2:end)-(1-par.delta)*K(1:end-1));
%IRF_I=100*(I/(par.delta*grid.K)-1);


IRF_tau=100*IRF_state_sparse(mpar.numstates-8,2:end);
IRF_K=100*IRF_state_sparse(mpar.numstates-7,1:end-1);
IRF_qs=100*IRF_state_sparse(mpar.numstates-5,2:end);
IRF_qk=100*IRF_state_sparse(mpar.numstates-6,2:end);
IRF_Wy=100*IRF_state_sparse(mpar.numstates-3,2:end);
IRF_We=100*IRF_state_sparse(mpar.numstates-2,2:end);
RB=par.RB+(IRF_state_sparse(mpar.numstates-1,2:end));
IRF_RB=100*100*(RB-par.RB);
IRF_S=100*IRF_state_sparse(end,1:end-1);

%Yss=[invmutil(mutil_c(:)); invmutil(Vk(:)); log(par.Q); log(par.PI); log(Output);...
 %   log(par.G); log(par.W)*0 ; log(par.R); log(par.PROFITS); log(par.N); log(targets.T);...
  %  log(targets.B) ;log(targets.Inv); log(par.R); log(targets.C) ];

IRF_Eq=100*IRF_state_sparse(end-mpar.oc+1,1:end-1);
IRF_PI=100*100*IRF_state_sparse(end-mpar.oc+2,1:end-1);
IRF_Y=100*IRF_state_sparse(end-mpar.oc+3,1:end-1);
IRF_G=100*IRF_state_sparse(end-mpar.oc+4,1:end-1);
IRF_PIwy=100*IRF_state_sparse(end-mpar.oc+5,1:end-1);
IRF_R=100*IRF_state_sparse(end-mpar.oc+6,1:end-1);
IRF_PId=100*IRF_state_sparse(end-mpar.oc+7,1:end-1);
IRF_N=100*IRF_state_sparse(end-mpar.oc+8,1:end-1);
IRF_B=100*IRF_state_sparse(end-mpar.oc+9,1:end-1);
IRF_I=100*IRF_state_sparse(end-mpar.oc+10,1:end-1);
IRF_ra=100*IRF_state_sparse(end-mpar.oc+11,1:end-1);
IRF_C=100*IRF_state_sparse(end-mpar.oc+12,1:end-1);

IRF_ly=100*IRF_state_sparse(end-mpar.oc+13,1:end-1);
IRF_le=100*IRF_state_sparse(end-mpar.oc+14,1:end-1);
IRF_Mg=100*IRF_state_sparse(end-mpar.oc+15,1:end-1);
IRF_PIWe=100*IRF_state_sparse(end-mpar.oc+16,1:end-1);

IRF_Cy=100*IRF_state_sparse(end-mpar.oc+17,1:end-1);
IRF_Ce=100*IRF_state_sparse(end-mpar.oc+18,1:end-1);

IRF_giniC=100*IRF_state_sparse(end-mpar.oc+19,1:end-1);


IRF_M=100*grid.m*IRF_distr((1:mpar.nm),2:end)./(targets.B+par.ABS*grid.K);
M=grid.m*IRF_distr((1:mpar.nm),1:end)+targets.B-par.ABS*(K(1:end)-grid.K);

%IRF_C=100*((Y-G-I)./(Output-par.G-par.delta*grid.K)-1);


Y=Output*(1+IRF_state_sparse(end-mpar.oc+3,1:end-1));
G=par.G*(1+IRF_state_sparse(end-mpar.oc+4,1:end-1));
I=exp(IRF_state_sparse(end-mpar.oc+10,1:end-1))*targets.Inv;
C=exp(IRF_state_sparse(end-mpar.oc+12,1:end-1))*targets.C;

PI=1+IRF_state_sparse(end-mpar.oc+2,1:end-1);
Q=par.Q*(1+IRF_state_sparse(end-mpar.oc+1,1:end-1));
R=par.R*(1+IRF_state_sparse(end-mpar.oc+6,1:end-1));

IRF_RBREAL=100*100*(RB./PI-par.RB);
IRF_Q=100*100*(Q-par.Q);
IRF_D=100*100*((1+IRF_R/100)*par.R-par.R);
Deficit=100*(M(2:end) - M(1:end-1)./PI)./Y;
IRF_LP=100*100*(((Q(2:end)+R(2:end))./Q(1:end-1)-RB(1:end-1)./PI(2:end))-((1+par.R/par.Q)-par.RB));

compen_t=grid.ly*Wy_fc*exp(IRF_Wy/100).*exp(IRF_ly/100)+grid.le*We_fc*exp(IRF_We/100).*exp(IRF_le/100);

IRF_LS=compen_t./(Output*exp(IRF_Y/100));

W=compen/grid.N;
W_fc=(Wy_fc*grid.ly+We_fc*grid.le)/grid.N;

IRF_W=((compen_t./(grid.N*exp(IRF_N/100)))/W -1)*100;

IRF_A=100*((qs*exp(IRF_qs/100)+par.Q*grid.K*exp(IRF_qk/100).*exp(IRF_state_sparse(mpar.numstates-7,2:end)))/targets.A - 1);




%% income irf's
NN=mpar.nh*mpar.nk*mpar.nm;

tirf=length(IRF_Y);
y_irf=zeros(mpar.nm,mpar.nk,mpar.nh,tirf);


incss=par.Wy*par.tau/par.Hy*meshes.h+meshes.m(:,:,:)*(par.RB-1) +meshes.k(:,:,:)*(par.R) +meshes.m(:,:,:).*(meshes.m(:,:,:)<0)*par.borrwedge;
  
incss=incss(:);

for t=1:tirf


  WWy=par.Wy*exp(IRF_Wy(t)/100)*par.tau.*exp(IRF_tau(t)/100).*exp(IRF_ly(t)/100)/par.Hy;
  
  WWe=par.We*exp(IRF_We(t)/100)*par.tau.*exp(IRF_tau(t)/100).*exp(IRF_le(t)/100)/par.He;
  
  
  y_irf(:,:,1:mpar.nhy,t)= WWy*meshes.h(:,:,1:mpar.nhy) +meshes.m(:,:,1:mpar.nhy)*(par.RB-1 + IRF_state_sparse(mpar.numstates-1,t))/(1+IRF_PI(:,t)/10000) +meshes.k(:,:,1:mpar.nhy)*(par.R*exp(IRF_ra(t)/100)) +meshes.m(:,:,1:mpar.nhy).*(meshes.m(:,:,1:mpar.nhy)<0)*par.borrwedge;
  

  y_irf(:,:,mpar.nhy+1:end,t)= WWe*meshes.h(:,:,mpar.nhy+1:end) +meshes.m(:,:,mpar.nhy+1:end)*(par.RB-1 + IRF_state_sparse(mpar.numstates-1,t))/(1+IRF_PI(:,t)/10000) +meshes.k(:,:,mpar.nhy+1:end)*(par.R*exp(IRF_ra(t)/100)) +meshes.m(:,:,mpar.nhy+1:end).*(meshes.m(:,:,mpar.nhy+1:end)<0)*par.borrwedge;
  
end





%IRF_C2=100*IRF_state_sparse(end-mpar.oc+13,1:end-1);
% wealth distribution IRFS

for i=1:mpar.maxlag-1
gini_IRF(i)=networthgini(IRF_distr(:,i)+Xss(1:mpar.nm+mpar.nk+mpar.nh),Q(i),mesh,mpar,Copula,joint_distr,cum_dist);

end

%% Ginis

% Net worth Gini
function [g]=networthgini(distr,Q,mesh,mpar,Copula,joint_distr,cum_dist)

mplusk=mesh.k(:)*Q+mesh.m(:);

[mplusk, IX]       = sort(mplusk);

distr2= zeros(mpar.nm+1,mpar.nk+1,mpar.nh+1);
distr2(2:end,2:end,2:end)=Copula({cumsum(distr(1:mpar.nm)),cumsum(distr(mpar.nm+1:mpar.nm+mpar.nk)),cumsum(distr(mpar.nk+mpar.nm+1:mpar.nk+mpar.nm+mpar.nh))});

distr3=diff(diff(diff(distr2,1,1),1,2),1,3);

JDredux=sum(distr3,3);

moneycapital_pdf   = JDredux(IX);

S                  = cumsum(moneycapital_pdf.*mplusk)';
S                  = [0 S];
g      = 1-(sum(moneycapital_pdf.*(S(1:end-1)+S(2:end))')/S(end));

end

