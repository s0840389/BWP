function [Difference,LHS,RHS,JD_new,c_a_star,m_a_star,k_a_star,c_n_star,m_n_star,P]  = Fsys(State,Stateminus,...
    Control_sparse,Controlminus_sparse,StateSS,...
    ControlSS,Gamma_state,indexMUdct,indexVKdct,DC1,DC2,DC3,...
    par,mpar,grid,targets,Copula,P,aggrshock)
% System of equations written in Schmitt-Grohé-Uribe generic form with states and controls
% STATE: Vector of state variables t+1 (only marginal distributions for histogram)
% STATEMINUS: Vector of state variables t (only marginal distributions for histogram)
% CONTROL: Vector of state variables t+1 (only coefficients of sparse polynomial)
% CONTROLMINUS: Vector of state variables t (only coefficients of sparse polynomial)
% STATESS and CONTROLSS: Value of the state and control variables in steady
% state. For the Value functions these are at full grids.
% GAMMA_STATE: Mapping such that perturbationof marginals are still
% distributions (sum to 1).
% PAR, MPAR: Model and numerical parameters (structure)
% GRID: Liquid, illiquid and productivity grid
% TARGETS: Stores targets for government policy
% COPULA: Interpolant that allows to map marginals back to full-grid
% distribuitions
% P: steady state transition matrix
% aggrshock: sets whether the Aggregate shock is TFP or uncertainty
%
% =========================================================================
% Part of the Matlab code to accompany the paper
% 'Solving heterogeneous agent models in discrete time with
% many idiosyncratic states by perturbation methods', CEPR Discussion Paper
% DP13071
% by Christian Bayer and Ralph Luetticke
% http://www.erc-hump-uni-bonn.net/
% =========================================================================


%% Initializations
mutil = @(c)(1./(c.^par.xi));
invmutil = @(mu)((1./mu).^(1/par.xi));

% Number of states, controls
nx   = mpar.numstates; % Number of states
ny   = mpar.numcontrols; % number of Controls
NxNx = nx-mpar.os; % Number of states without aggregate
Ny = length(indexMUdct)+length(indexVKdct);
NN   = mpar.nm*mpar.nk*mpar.nh; % Number of points in the full grid

% Initialize LHS and RHS
LHS  = zeros(nx+Ny+mpar.oc,1);
RHS  = zeros(nx+Ny+mpar.oc,1);

%% Indexes for LHS/RHS
% Indexes for Controls
mutil_cind = 1:length(indexMUdct);
Vkind = length(indexMUdct)+(1:length(indexVKdct));

Eqind  = Ny+1;
PIind = Ny+2;
Yind  = Ny+3;
Gind  = Ny+4;
PIwyind  = Ny+5;
Rind  = Ny+6;
Profitind  = Ny+7;
Nind  = Ny+8;
Bind  = Ny+9;
Invind= Ny+10;
raind= Ny+11;
Cind= Ny+12;
lyind= Ny+13;
leind= Ny+14;
Mgind= Ny+15;
PIweind= Ny+16;
Cyind= Ny+17;
Ceind= Ny+18;
giniCind= Ny+19;

%Yss=[invmutil(mutil_c(:)); invmutil(Vk(:)); log(par.Q); log(par.PI); log(Output);...
 %   log(par.G); log(par.W) ; log(par.R); log(par.PROFITS); log(par.N); log(targets.T);...
  %  log(targets.B); log(targets.Inv); log(par.R) ];

 
%Xss=[squeeze(sum(sum(joint_distr,2),3)); ... % marginal distribution liquid
 %   squeeze(sum(sum(joint_distr,1),3))'; ... % marginal distribution illiquid
  %  squeeze(sum(sum(joint_distr,2),1)); ... % marginal distribution productivity
   % log(grid.K); log(par.Q); log(par.qs);
   % log(targets.Inv); log(par.w);
   % log(par.RB); 0];
  
% Indexes for States
marginal_mind = (1:mpar.nm-1);
marginal_kind = (mpar.nm-1+(1:mpar.nk-1));
marginal_hind = (mpar.nm+mpar.nk-2 + (1:(mpar.nh-1)));

tauind=NxNx+1;
Kind=NxNx+2;
qkind=NxNx+3;
qsind=NxNx+4;
Invstind=NxNx+5;
Wyind=NxNx+6;
Weind=NxNx+7;
RBind = NxNx+8;
Sind  = NxNx+9;

%% Control Variables (Change Value functions according to sparse polynomial)
Control      = Control_sparse;
Controlminus = Controlminus_sparse;

Control(end-mpar.oc+1:end)       = ControlSS(end-mpar.oc+1:end) + Control_sparse(end-mpar.oc+1:end,:);
Controlminus(end-mpar.oc+1:end)  = ControlSS(end-mpar.oc+1:end) + (Controlminus_sparse(end-mpar.oc+1:end,:));

%% State Variables
% read out marginal histogramm in t+1, t
Distribution      = StateSS(1:end-9) + Gamma_state * State(1:NxNx);
Distributionminus = StateSS(1:end-9) + Gamma_state * Stateminus(1:NxNx);

% Aggregate Endogenous States

tau      = StateSS(end-8) + (State(end-8));
tauminus = StateSS(end-8) + (Stateminus(end-8));

K      = exp(StateSS(end-7) + (State(end-7)));
Kminus = exp(StateSS(end-7) + (Stateminus(end-7)));

qk      = exp(StateSS(end-6) + (State(end-6)));
qkminus = exp(StateSS(end-6) + (Stateminus(end-6)));

qs      = exp(StateSS(end-5) + (State(end-5)));
qsminus = exp(StateSS(end-5) + (Stateminus(end-5)));

Invst      = exp(StateSS(end-4) + (State(end-4)));
Invstminus = exp(StateSS(end-4) + (Stateminus(end-4)));

Wy      = exp(StateSS(end-3) + (State(end-3)));
Wyminus = exp(StateSS(end-3) + (Stateminus(end-3)));

We      = exp(StateSS(end-2) + (State(end-2)));
Weminus = exp(StateSS(end-2) + (Stateminus(end-2)));

RB      = StateSS(end-1) + (State(end-1));
RBminus = StateSS(end-1) + (Stateminus(end-1));

% Aggregate Exogenous States
S       = StateSS(end) + (State(end));
Sminus  = StateSS(end) + (Stateminus(end));

%% Split the Control vector into items with names
% Controls
XX             = zeros(NN,1);
XX(indexMUdct) = Control(mutil_cind);
aux = reshape(XX,[mpar.nm, mpar.nk, mpar.nh]);
aux = myidct(aux,1,DC1); % do dct-transformation
aux = myidct(aux,2,DC2); % do dct-transformation
mutil_c_dev = myidct(aux,3,DC3); % do dct-transformation
mutil_c        = (mutil(mutil_c_dev(:)+ControlSS((1:NN))));

XX             = zeros(NN,1);
XX(indexVKdct) = Control(Vkind);
aux = reshape(XX,[mpar.nm, mpar.nk, mpar.nh]);
aux = myidct(aux,1,DC1); % do dct-transformation
aux = myidct(aux,2,DC2); % do dct-transformation
Vk_dev = myidct(aux,3,DC3); % do dct-transformation
Vk             = (mutil(Vk_dev(:)+ControlSS((1:NN)+NN)));


% Aggregate Controls (t+1)
PI = exp(Control(PIind));
Y  = exp(Control(Yind ));
B  = exp(Control(Bind ));
PIwy=Control(PIwyind);
R  = exp(Control(Rind ));
ra=exp(Control(raind));
Eq=exp(Control(Eqind));
Inv=exp(Control(Invind));
PIwe=Control(PIweind);

% Aggregate Controls (t)
PIminus = exp(Controlminus(PIind));
Eqminus  = exp(Controlminus(Eqind ));
Yminus  = exp(Controlminus(Yind ));
Gminus  = exp(Controlminus(Gind ));
Rminus  = exp(Controlminus(Rind ));
Profitminus  = exp(Controlminus(Profitind ));
Nminus  = exp(Controlminus(Nind ));
Bminus  = exp(Controlminus(Bind ));
PIwyminus=Controlminus(PIwyind);
raminus=exp(Controlminus(raind));
Invminus=exp(Controlminus(Invind));
Cminus=exp(Controlminus(Cind));
lyminus=exp(Controlminus(lyind));
leminus=exp(Controlminus(leind));
Mgminus=exp(Controlminus(Mgind));
PIweminus=Controlminus(PIweind);
Cyminus=exp(Controlminus(Cyind));
Ceminus=exp(Controlminus(Ceind));
giniCminus=Controlminus(giniCind);

%% Write LHS values
% Controls
LHS(nx+Vkind)      = Controlminus(Vkind);
LHS(nx+mutil_cind) = Controlminus(mutil_cind);



% States
% Marginal Distributions (Marginal histograms)
LHS(marginal_mind) = Distribution(1:mpar.nm-1);
ba=mpar.nm;
LHS(marginal_kind) = Distribution(ba+(1:mpar.nk-1));
ba=mpar.nm+mpar.nk;
LHS(marginal_hind) = Distribution(ba+(1:mpar.nh-1));



% take into account that RB is in logs
RB=exp(RB); RBminus=exp(RBminus);


%% Set of Differences for exogenous process

% shock (1)
LHS(Sind)          = (S);
RHS(Sind) = (par.rhoS * (Sminus));

switch(aggrshock)
    case('MP')
        EPS_TAYLOR=Sminus;
        TFP=1;
    case('TFP')
        TFP=exp(Sminus);
        EPS_TAYLOR=0;
    case('Uncertainty')
        TFP=1;
        EPS_TAYLOR=0;
        % Tauchen style for Probability distribution next period
        [P,~,~] = ExTransitions(exp(Sminus),grid,mpar,par);
end

% Calculate aggregate Capital, Bonds and Human Capital Supply in t
marginal_mminus = Distributionminus(1:mpar.nm)';
marginal_kminus = Distributionminus((1:mpar.nk)+mpar.nm)';
marginal_hminus = Distributionminus(mpar.nm+mpar.nk+(1:mpar.nh))';

Hminus  = sum(grid.h(1:end-1).*marginal_hminus(1:end-1)); %Last column is entrepreneurs.
Lminus  = sum(grid.m.*marginal_mminus);

% (2) government bonds

LHS(nx+Bind)       = (Bminus);
RHS(nx+Bind) = Lminus ;


Aminus = (sum(grid.k.*marginal_kminus));

% Calculate joint distributions
cumdist = zeros(mpar.nm+1,mpar.nk+1,mpar.nh+1);
cumdist(2:end,2:end,2:end) = Copula({cumsum(marginal_mminus),cumsum(marginal_kminus)',cumsum(marginal_hminus)});
JDminus = diff(diff(diff(cumdist,1,1),1,2),1,3);

% Generate meshes for b,k,h
[meshes.m,meshes.k,meshes.h] = ndgrid(grid.m,grid.k,grid.h);

% Marginal cost
mc              =  par.mu- (par.beta * log(PI) - log(PIminus))/par.kappa;

% (3a) wage philips curve production
LHS(nx+PIwyind)       = PIwyminus;
muhaty=par.gamma*log(lyminus/(grid.ly))-log(Wy/par.Wy);
RHS(nx+PIwyind)    =  par.beta*PIwy + par.kappa_w*muhaty;

%LHS(nx+PIwyind)       = log(Wy/Wyminus);
%RHS(nx+PIwyind)    = log(We/Weminus);

% (3b) wage philips curve expansioanry

LHS(nx+PIweind)       = PIweminus;
muhate=par.gamma*log(leminus/(grid.le))-log(We/par.We);
RHS(nx+PIweind)    =  par.beta*PIwe + par.kappa_w*muhate;

%LHS(nx+PIweind)       = PIweminus;
%muhate=par.gamma*log(Nminus/(grid.N))-log(We/par.We);
%RHS(nx+PIweind)    =  par.beta*PIwe + par.kappa_w*muhate;

% (4) wage lom production

LHS(Wyind)=PIwyminus;
RHS(Wyind)=log(PIminus)+log(Wy/Wyminus);
%RHS(Wyind)=PIweminus;

% (4b) wage lom epansioanry

LHS(Weind)=PIweminus;
RHS(Weind)=log(PIminus)+log(We/Weminus);


lyi=lyminus/Mgminus;
ki=Kminus/Mgminus;

% (5) Profits for Entrepreneurs
piy=mc*Yminus-Wy*lyminus-(Rminus+par.delta)*Kminus; % dividends of production
pin=Yminus*(1-mc)-We*leminus;

LHS(nx+Profitind)  = (Profitminus);
RHS(nx+Profitind) = piy+pin;

% (6) output
LHS(nx+Yind)       = (Yminus/Mgminus);
RHS(nx+Yind)    = ((TFP*(lyi).^(1-par.alphay).*ki.^(par.alphay)))^par.thetay;


%% Prices that are not part of Control Vector

% (7) Wage Rate

  LHS(nx+lyind)       = Wy;
  RHS(nx+lyind) = TFP*(1-par.alphay)*mc*ki^(par.thetay*par.alphay)*lyi^((1-par.alphay)*par.thetay-1); % wages
    
% (21) total labour

LHS(nx+Nind)=Nminus;

RHS(nx+Nind)=lyminus+leminus;

% (22) measure of goods

LHS(nx+Mgind)=Mgminus;
RHS(nx+Mgind)=par.zn*leminus^par.thetan;

%(23) demand for expansinoary labour

LHS(nx+leind)=We;
RHS(nx+leind)=(Yminus/Mgminus)*(1-mc)*par.thetan*Mgminus/leminus;


% (8) Return on Capital
  
  LHS(nx+Rind)       = (Rminus);
  RHS(nx+Rind)=TFP*mc*(par.alphay)*ki^(par.thetay*(par.alphay)-1)*lyi^((1-par.alphay)*par.thetay)- par.delta;
  

% household Wages

  Htoty=lyminus/(par.Hy*mpar.MeasY);
  Htote=leminus/(par.He*mpar.MeasE);
  
  %Htoty=Nminus/(par.Hy);
  %Htote=Nminus/(par.He);
  
  
  NWy=Htoty*Wy; % little adjustment because in egm update procedure household picks x=c-G(h,n)
  NWe=Htote*We;
  
  WW=ones(mpar.nm,mpar.nk,mpar.nh); %Wages
  WW(:,:,1:mpar.nhy)=NWy;
  WW(:,:,mpar.nhy+1:end)=NWe;
  
  %WW(:,:,end)=Profitminus*par.profitshare*(1-par.lumpshare);

  % (9) return on assets
  
  LHS(nx+raind)=raminus*Aminus;
  RHS(nx+raind)=(Rminus+par.delta)*Kminus + Profitminus + (1-par.delta)*qk*Kminus - Kminus*qkminus +qs-qsminus -par.phi/2*log(Invminus/Invstminus)^2*Invminus; 
  
  

%% Incomes (grids)
inc.labor   = tau*WW.*(meshes.h);%+Profitminus*par.lumpshare*par.tau;
inc.rent    = meshes.k*raminus;%+(1-par.lumpshare)*meshes.k/Kminus*par.tau*Profitminus;
inc.capital = meshes.k;
inc.money   = (RBminus/PIminus).*meshes.m...
    + (meshes.m<0).*(par.borrwedge/PIminus).*meshes.m;

%% First Set: Value Functions, Marginal Values
%% Update policies

EVk = reshape(reshape(Vk,[mpar.nm*mpar.nk mpar.nh])*P',[mpar.nm,mpar.nk mpar.nh]);
RBaux = RB/PI + (meshes.m<0).*(par.borrwedge/PI);
EVm = reshape(reshape(RBaux(:).*mutil_c,[mpar.nm*mpar.nk mpar.nh])*P',[mpar.nm,mpar.nk mpar.nh]);

[c_a_star,m_a_star,k_a_star,c_n_star,m_n_star] = EGM_policyupdate(EVm,EVk,1,PIminus,RBminus,inc,meshes,grid,par,mpar);

meshaux=meshes;
meshaux.h(:,:,end)=1000;

%% Update Marginal Value Bonds
mutil_c_n = mutil(c_n_star); % marginal utility at consumption policy no adjustment
mutil_c_a = mutil(c_a_star); % marginal utility at consumption policy adjustment
mutil_c_aux    = par.nu.*mutil_c_a + (1-par.nu).*mutil_c_n; % Expected marginal utility at consumption policy (w &w/o adjustment)
aux=((invmutil(mutil_c_aux(:)))-ControlSS((1:NN)));
aux = reshape(aux,[mpar.nm, mpar.nk, mpar.nh]);
aux = mydct(aux,1,DC1); % do dct-transformation
aux = mydct(aux,2,DC2); % do dct-transformation
aux = mydct(aux,3,DC3); % do dct-transformation
DC=aux(:);

RHS(nx+mutil_cind) = (DC(indexMUdct)); % Write Marginal Utility to RHS of F

%% Update marginal Value of Capital
%EVk     = reshape(Vk,[mpar.nm*mpar.nk, mpar.nh])*P';
%Vk_next = griddedInterpolant(meshaux.m,meshaux.k,meshaux.h,reshape(EVk,[mpar.nm mpar.nk mpar.nh]));
%Vk_aux  = par.nu.*(raminus+1).*mutil_c_a + (1-par.nu).*raminus.*mutil_c_n+ par.beta.*(1-par.nu).*Vk_next(m_n_star,meshaux.k,meshaux.h); % Expected marginal utility at consumption policy (w &w/o adjustment)

EVk     = reshape(Vk,[mpar.nm*mpar.nk, mpar.nh])*P';
EVkl=reshape(EVk,[mpar.nm mpar.nk mpar.nh]);

Vk_next=zeros(mpar.nm,mpar.nk,mpar.nh);


for i=1:mpar.nh
    
Vk_nextInt = griddedInterpolant(meshaux.m(:,:,i),meshaux.k(:,:,i),EVkl(:,:,i));

Vk_next(:,:,i)=Vk_nextInt(m_n_star(:,:,i),meshaux.k(:,:,i));

end

Vk_aux  = par.nu.*(raminus+1).*mutil_c_a + (1-par.nu).*raminus.*mutil_c_n+ par.beta.*(1-par.nu).*Vk_next; % Expected marginal utility at consumption policy (w &w/o adjustment)

aux=((invmutil(Vk_aux(:)))-ControlSS((1:NN)+NN));
aux = reshape(aux,[mpar.nm, mpar.nk, mpar.nh]);
aux = mydct(aux,1,DC1); % do dct-transformation
aux = mydct(aux,2,DC2); % do dct-transformation
aux = mydct(aux,3,DC3); % do dct-transformation
DC=aux(:);

RHS(nx+Vkind) = (DC(indexVKdct));  % Write Marginal Value of K to RHS of F

%% Differences for distributions

% Initialize matrices
weight11  = zeros(mpar.nm*mpar.nk, mpar.nh,mpar.nh);
weight12  = zeros(mpar.nm*mpar.nk, mpar.nh,mpar.nh);
weight21  = zeros(mpar.nm*mpar.nk, mpar.nh,mpar.nh);
weight22  = zeros(mpar.nm*mpar.nk, mpar.nh,mpar.nh);

% find next smallest on-grid value for money and capital choices
[Dist_m_a,idm_a] = genweight(m_a_star,grid.m);
[Dist_m_n,idm_n] = genweight(m_n_star,grid.m);
[Dist_k,idk_a]   = genweight(k_a_star,grid.k);
idk_n = repmat(ones(mpar.nm,1)*(1:mpar.nk),[1 1 mpar.nh]); %This is the actual point on grid


% Transition matrix adjustment case
idm_a=repmat(idm_a(:),[1 mpar.nh]);
idk_a=repmat(idk_a(:),[1 mpar.nh]);
idh=kron(1:mpar.nh,ones(1,mpar.nm*mpar.nk*mpar.nh));

index11 = sub2ind([mpar.nm mpar.nk mpar.nh],idm_a(:),idk_a(:),idh(:));
index12 = sub2ind([mpar.nm mpar.nk mpar.nh],idm_a(:),idk_a(:)+1,idh(:));
index21 = sub2ind([mpar.nm mpar.nk mpar.nh],idm_a(:)+1,idk_a(:),idh(:));
index22 = sub2ind([mpar.nm mpar.nk mpar.nh],idm_a(:)+1,idk_a(:)+1,idh(:));


for hh=1:mpar.nh
    
    %Corresponding weights
    weight21_aux =  Dist_m_a(:,:,hh).*(1-Dist_k(:,:,hh));
    weight11_aux = (1-Dist_m_a(:,:,hh)).*(1-Dist_k(:,:,hh));
    weight22_aux =  (Dist_m_a(:,:,hh)).*(Dist_k(:,:,hh));
    weight12_aux =  (1-Dist_m_a(:,:,hh)).*(Dist_k(:,:,hh));
    
    % Dimensions (mxk,h',h)
    weight11(:,:,hh)=weight11_aux(:)*P(hh,:);
    weight12(:,:,hh)=weight12_aux(:)*P(hh,:);
    weight21(:,:,hh)=weight21_aux(:)*P(hh,:);
    weight22(:,:,hh)=weight22_aux(:)*P(hh,:);
end
%Dimensions (mxk,h,h')
weight11=permute(weight11,[1 3 2]);
weight22=permute(weight22,[1 3 2]);
weight12=permute(weight12,[1 3 2]);
weight21=permute(weight21,[1 3 2]);
rowindex=repmat(1:mpar.nm*mpar.nk*mpar.nh,[1 4*mpar.nh]);

H_a=sparse(rowindex(:),[index11(:); index21(:); index12(:); index22(:)],...
    [weight11(:); weight21(:); weight12(:); weight22(:)],mpar.nm*mpar.nk*mpar.nh,mpar.nm*mpar.nk*mpar.nh); % mu'(h',k'), a without interest

% Policy Transition Matrix for no-adjustment case
weight11  = zeros(mpar.nm*mpar.nk, mpar.nh,mpar.nh);
weight21  = zeros(mpar.nm*mpar.nk, mpar.nh,mpar.nh);
idm_n=repmat(idm_n(:),[1 mpar.nh]);
idk_n=repmat(idk_n(:),[1 mpar.nh]);
index11 = sub2ind([mpar.nm mpar.nk mpar.nh],idm_n(:),idk_n(:),idh(:));
index21 = sub2ind([mpar.nm mpar.nk mpar.nh],idm_n(:)+1,idk_n(:),idh(:));


for hh=1:mpar.nh
    
    %Corresponding weights
    weight21_aux =  Dist_m_n(:,:,hh);
    weight11_aux = (1-Dist_m_n(:,:,hh));
    
    weight21(:,:,hh)=weight21_aux(:)*P(hh,:);
    weight11(:,:,hh)=weight11_aux(:)*P(hh,:);
    
end
weight11=permute(weight11,[1 3 2]);
weight21=permute(weight21,[1 3 2]);

rowindex=repmat(1:mpar.nm*mpar.nk*mpar.nh,[1 2*mpar.nh]);

H_n=sparse(rowindex,[index11(:); index21(:)],...
    [weight11(:); weight21(:)],mpar.nm*mpar.nk*mpar.nh,mpar.nm*mpar.nk*mpar.nh); % mu'(h',k'), a without interest

% Joint transition matrix and transitions
H=par.nu*H_a + (1-par.nu)*H_n;

JD_new=JDminus(:)'*H;
JD_new = reshape(JD_new(:),[mpar.nm,mpar.nk,mpar.nh]);

% Next period marginal histograms
% liquid assets
aux_m = squeeze(sum(sum(JD_new,2),3));
RHS(marginal_mind) = aux_m(1:end-1); %Leave out last state
% illiquid assets
aux_k =  squeeze(sum(sum(JD_new,1),3))' ;
RHS(marginal_kind) = aux_k(1:end-1); %Leave out last state
% human capital
aux_h = squeeze(sum(sum(JD_new,1),2));
RHS(marginal_hind) = aux_h(1:end-1); %Leave out last state & entrepreneurs

%% Third Set: Government Budget constraint

% (10) Return on bonds (Taylor Rule)

LHS(RBind)         = log(RB);
RHS(RBind) = log(par.RB) + par.rho_R* log(RBminus/par.RB)  + log(PIminus/par.PI).*((1-par.rho_R)*par.theta_pi)+ log(Yminus/targets.Y).*((1-par.rho_R)*par.theta_y)+EPS_TAYLOR;

taxrevenue =(1-tau)*(We*leminus+Wy*lyminus);

 %(11) Inflation jumps to equilibrate real bond supply and demand

%RHS(nx+PIind)=(B/Bminus);
%LHS(nx+PIind)=(Bminus/targets.B)^(-par.gamma_B)*(PIminus/par.PI)^par.gamma_pi*(Yminus/targets.Y)^par.gamma_Y;

RHS(nx+PIind)=par.G;
LHS(nx+PIind)=Gminus;


% (12) Government expenditures
LHS(nx+Gind)       = (Gminus);

RHS(nx+Gind) =  B - Bminus*RBminus/PIminus + taxrevenue;

% (13) taxes


LHS(tauind)       = (1-tau)/(1-par.tau);

RHS(tauind) = ((1-tauminus)/(1-par.tau))^par.rho_tax *((Bminus/targets.B)^par.gamma_taxB*(Yminus/targets.Y)^par.gamma_taxY)^(1-par.rho_tax) ;



% (14) Resulting Price of Capital
LHS(qkind)       = qk;
RHS(qkind)=1+par.phi*log(Invminus/Invstminus)+par.phi/2*log(Invminus/Invstminus)^2- par.phi/(1+ra)*Inv/Invminus*log(Inv/Invminus);

% (15) expected price of capital def

LHS(nx+Eqind)=Eqminus;
RHS(nx+Eqind)=qk;

% (16) expected price of capital

 LHS(nx+Invind)=Eqminus;
 RHS(nx+Invind)=1/(1+ra)*((R+par.delta)+(1-par.delta)*Eq);

% (17) capital lom

%LHS(Kind)       = K;
%RHS(Kind)       =(1-par.delta)*Kminus+Invminus-par.phi/2*log(Invminus/Invstminus)^2*Invminus;

LHS(Kind)=Yminus;
RHS(Kind)=Cminus+Gminus+Invminus+par.phi/2*log(Invminus/Invstminus)^2*Invminus - sum(marginal_mminus.*(grid.m<0).*grid.m.*par.borrwedge/PIminus)*2 +par.ResWedge;

% (18) investment idendity

LHS(Invstind)=Invst;
RHS(Invstind)=Invminus;
%RHS(Invstind)=K-(1-par.delta)*Kminus;

% (19) stock price

A = sum(sum(sum(grid.k.*JD_new)));

%LHS(qsind)=qs;
%RHS(qsind)=A-qk*K;

LHS(qsind)       = K;
RHS(qsind)       =(1-par.delta)*Kminus+Invminus-par.phi/2*log(Invminus/Invstminus)^2*Invminus;



% (20) Consumption

LHS(nx+Cind)=Cminus;
RHS(nx+Cind)=sum(sum(sum(par.nu*c_a_star.*JDminus+(1-par.nu)*c_n_star.*JDminus)));

c_star=par.nu*c_a_star+(1-par.nu)*c_n_star;

LHS(nx+Cyind)=Cyminus;
RHS(nx+Cyind)=sum(JDminus(1:mpar.nhy*mpar.nk*mpar.nm).*c_star(1:mpar.nhy*mpar.nk*mpar.nm))/mpar.MeasY;

LHS(nx+Ceind)=Ceminus;
RHS(nx+Ceind)=sum(JDminus(mpar.nhy*mpar.nk*mpar.nm+1:end).*c_star(mpar.nhy*mpar.nk*mpar.nm+1:end))/mpar.MeasE;


% consumption gini
 
 LHS(nx+giniCind)=giniCminus;
 
 [cstar_sort, IX] = sort(c_star(:));
 
 cstar_pdf   = JDminus(IX);
 
 S                  = cumsum(cstar_pdf.*cstar_sort)';
 S                  = [0 S];
 RHS(nx+giniCind)      = 1-(sum(cstar_pdf.*(S(1:end-1)+S(2:end))')/S(end));

%% Difference
Difference=((LHS-RHS));

end
function [ weight,index ] = genweight( x,xgrid )
% function: GENWEIGHT generates weights and indexes used for linear interpolation
%
% X: Points at which function is to be interpolated.
% xgrid: grid points at which function is measured
% no extrapolation allowed
[~,index] = histc(x,xgrid);
index(x<=xgrid(1))=1;
index(x>=xgrid(end))=length(xgrid)-1;

weight = (x-xgrid(index))./(xgrid(index+1)-xgrid(index)); % weight xm of higher gridpoint
weight(weight<=0) = 1.e-16; % no extrapolation
weight(weight>=1) = 1-1.e-16; % no extrapolation

end  % function
