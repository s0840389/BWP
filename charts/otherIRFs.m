clear all


IRFposNK=[0 4 3 2 12 11 13];
sh=[0.0026 -0.02 -0.005 -0.022 0.002 0.059 0.0167];
IRFname={'MP','G','TFP','IST','RP','W','MK'};
IRFname2={'Monetary Policy','Gov. spending','TFP','Investment-specific','Risk premium','Wage markup','Markup'};


%% NK model
load('../HANK/steadystates/NKfund_60_15.mat','hx','gx','mpar')

mparNK=mpar;
hxNK=hx;
gxNK=gx;
    
maxlag=40; % Quarters

figure(8)
    clf
    subplot(1,2,1)

    for i=1:7

    x0=zeros(mpar.numstates,1);
%    x0(end-IRFposNK(i))=-0.01/gxNK(end-mparNK.oc+3,end-IRFposNK(i));
    x0(end-IRFposNK(i))=sh(i);

    MX=[eye(length(x0));gxNK];
    IRF_state_sparse=[];
    x=x0;

    % y=ybar+gx*(x-xbar)
    % x'=xbar+hx(x-xbar)

    for t=1:maxlag
        IRF_state_sparse(:,t)=(MX*x)';
        x=hxNK*x;
    end

    IRF_Y=100*IRF_state_sparse(end-mpar.oc+3,1:end-1);
    IRF_W=100*IRF_state_sparse(mpar.numstates-5,2:end);
    IRF_N=100*IRF_state_sparse(end-mpar.oc+7,1:end-1);
    IRF_LS=0.62*(IRF_W+IRF_N-IRF_Y);

    if i == 1 | i== 2 | i==5 % demand shocks
        plot(IRF_LS,'LineWidth',1.8)
        hold on
    else 
        plot(IRF_LS,'LineWidth',1.8,'LineStyle','--')
        hold on  
    end  

    if i==1
        title('HANK')
    end
end


text(15,0.5,'Counter-cyclical')
    text(15,-0.5,'Pro-cyclical')

    hline=refline(0,0);
    hline.Color='black';
    
  %% HANK YN
    
load('../HANK/steadystates/YNfund_60_15.mat','hx','gx','mpar')

mparYN=mpar;
hxYN=hx;
gxYN=gx;
    

    subplot(1,2,2)

    for i=1:7

    x0=zeros(mpar.numstates,1);
%    x0(end-IRFposNK(i))=-0.01/gxYN(end-mpar.oc+3,end-IRFposNK(i));

    x0(end-IRFposNK(i))=sh(i);

    MX=[eye(length(x0));gxYN];
    IRF_state_sparse=[];
    x=x0;

    % y=ybar+gx*(x-xbar)
    % x'=xbar+hx(x-xbar)

    for t=1:maxlag
        IRF_state_sparse(:,t)=(MX*x)';
        x=hxYN*x;
    end

    IRF_Y=100*IRF_state_sparse(end-mpar.oc+3,1:end-1);
    IRF_W=100*IRF_state_sparse(mpar.numstates-5,2:end);
    IRF_N=100*IRF_state_sparse(end-mpar.oc+7,1:end-1);
    IRF_LS=0.62*(IRF_W+IRF_N-IRF_Y);

    if i == 1 | i== 2 | i==5 % demand shocks
        plot(IRF_LS,'LineWidth',1.8)
        hold on
    else 
        plot(IRF_LS,'LineWidth',1.8,'LineStyle','--')
        hold on  
    end  

    if i==1
        title('HANK-YN')
    end
    end

    hline=refline(0,0);
    hline.Color='black';
    legend(IRFname2)
        
    figure(8)

    h = gcf;
    set(h,'Units','centimeters');
    pos = get(h,'Position');
    h.Position(1) =0;
    h.Position(2) =0;
    h.Position(3) =20;
    h.Position(4) =10;
    set(h,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
    print(h,'IRF_OtherShocks','-dpdf','-r0')
