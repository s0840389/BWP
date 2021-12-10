setwd('/home/jamie/OneDrive/Documents/university/ucl/msc/dissertation/FES/')

require(tidyr)
require(data.table)
require(reldist)
require(ggplot2)
require(mFilter)
require(readxl)

dt=data.table(read.csv('fes.csv'))

censor=dt[,.(Minc=max(ginc)),by=year]

#cut(texp15,wtd.quantile(texp15,q = c(0,0.1,0.25,0.5,0.80,0.90,0.95,0.99,1),na.rm=TRUE,weight=dt$wgt),labels = c(0.1,0.25,0.5,0.80,0.90,0.95,0.99,1))

dt2=dt

dt2=merge(dt2,censor,by='year',all.x=TRUE)

dt2[,'inc.cense':=(ginc==Minc)*1]


dt2=dt2[,.(year,wgt,texp15,ginc15,agecat,inc.cense,
          q=cut(ginc15,wtd.quantile(ginc15,q = c(0.02,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1),na.rm=TRUE,weight=wgt),
                labels = c(10,20,30,40,50,60,70,80,90,100))
),by=year]


#dt2$q=ifelse(dt2$inc.cense==1,'censor',as.character(dt2$q))

#dt3=dt2[,.(y=wtd.quantile(ginc15,q=0.5,w=wgt),c=wtd.quantile(texp15,q=0.5,w=wgt),nw=sum(wgt),n=sum(wgt/wgt)),by=.(year,q)]

dt3=dt2[,.(y=weighted.mean(ginc15,w=wgt),c=weighted.mean(texp15,w=wgt),nw=sum(wgt),n=sum(wgt/wgt)),by=.(year,q)]


dt3=dt3[is.na(q)==FALSE&q!='censor']

fg.check=ggplot(data=dt3)+geom_line(aes(x=year,y=c,color=q))

dt4=dt3[,.(year,
           c.hp=hpfilter(log(c),freq=108,type='lambda')$cycle,
           y.hp=hpfilter(log(y),freq=108,type='lambda')$cycle),by=q]


dt5=dt4[,.(c.sd=sd(c.hp),y.sd=sd(y.hp)),by=q]

#dt5$q=as.numeric(as.character(dt5$q))

fg=ggplot(data=dt5)+geom_point(aes(x=q,y=c.sd),size=5)+
 theme_classic(base_size=16)+labs(x='Income percentile',y='Log HP filter standard deviation',colour='')+
  scale_y_continuous(limits=c(0,0.05))


dt100=data.table(read_excel('../../../../../research/HANK/BWP/charts/consumptionincome.xlsx'))
dt100=melt(dt100,id.vars='year')  

colnames(dt100)=c('year','q','texp')

cpi=read.csv('cpi.csv')

dt101=merge(dt100,cpi,by='year',all.x=TRUE)

dt101$c=dt101$texp/dt101$cpi*100

dt101=dt101[,.(year,q,c)]
dt101.old=dt3[year<2001,.(year,q,c)]

dt102=rbind(dt101.old,dt101)

dt102=dt102[q!='total']

dt103=dt102[,.(year,c.hp=hpfilter(log(c),freq=108,type='lambda')$cycle),by=q]

dt104=dt103[,.(c.sd=sd(c.hp)),by=q]

#dt5$q=as.numeric(as.character(dt5$q))

fg2=ggplot(data=dt104)+geom_point(aes(x=q,y=c.sd),size=5)+
  theme_classic(base_size=16)+labs(x='Income percentile',y='Log HP filter standard deviation',colour='')+
  scale_y_continuous(limits=c(0,0.08))
#ggplot(data=dt102)+geom_line(aes(x=year,y=c,color=q))


