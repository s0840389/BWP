function [ N,R_fc,W_fc,Profits_fc,WW,RR,RBRB,Y,qs,par,ly,le,Mg ] = factor_returns(meshes,grid,par,mpar)
%factor_returns
  
    mc =  par.mu - (par.beta * log(par.PI) - log(par.PI))/par.kappa;
    
  Mg=1; % measure of goods

  le=0.2; % expansionary labour
  ly=0.8; % production labour

  N=ly+le;

  par.zn=Mg/le^par.thetan;
  
    ki=grid.K/Mg;
    lyi=ly/Mg;

  R_fc=mc*par.alphay*ki^(par.thetay*par.alphay-1)*lyi^((1-par.alphay)*par.thetay)-par.delta;
  
  W_fc = (1-par.alphay)*mc*ki^(par.thetay*par.alphay)*lyi^((1-par.alphay)*par.thetay-1); % wages
    
  yi = Mg*((lyi)^(1-par.alphay)*ki^(par.alphay))^par.thetay; % firm output
   
  Y=yi*Mg;

  piy=Mg*(mc*yi-W_fc*lyi-(R_fc+par.delta)*ki); % dividends of production
  pin=Mg*yi*(1-mc)-le*W_fc;
  
  Profits_fc=piy+pin;
  
  Htot=N/par.H;
  
  par.kappaH=W_fc*par.H*par.tau/Htot^par.gamma; % work out kappa in utilty fn such that H=H
  
  NW=Htot*W_fc; % little adjustment because in egm update procedure household picks x=c-G(h,n)
  
  WW=NW*ones(mpar.nm,mpar.nk,mpar.nh);%;-par.kappaH/(par.tau*(1+par.gamma))*1./meshes.h*Htot.^(1+par.gamma); %Wages with GHH adjustment
  
 % WW(:,:,end)=Profits_fc*par.profitshare*(1-par.lumpshare);
  
  RR = R_fc; %Rental rates
  
  RBRB = par.RB/par.PI + (meshes.m<0).*(par.borrwedge/par.PI);

  qs=Profits_fc/R_fc; % stock price
  
end

