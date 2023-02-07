

%Read Bond Price Data
pf_list=["CA135087A610CAN 1.5Jun23";
        "CA135087M763CAN 0.5Nov23";
        "CA135087B451CAN 2.5Jun24";
        "CA135087P402CAN 3.0Nov24";
        "CA135087D507CAN 2.25Jun25";
        "CA135087P246CAN 3.0Oct25";
        "CA135087E679CAN 1.5Jun26";
        "CA135087L930CAN 1.0Sep26";
        "CA135087F825CAN 1.0Jun27";
        "CA135087N837CAN 2.75Sep27";
        "CA135087H235CAN 2.0Jun28";];
%Input Coupon Rate
CouponRate_list = [0.015;
                    0.005;
                    0.025;
                    0.030;
                    0.0225;
                    0.030;
                    0.015;
                    0.01;
                    0.01;
                    0.0275;
                    0.02;];
%Input Settle Date
setl_list=['30-Jan-2023';
           '27-Jan-2023';
           '26-Jan-2023';
           '25-Jan-2023';
           '24-Jan-2023';
           '23-Jan-2023';
           '20-Jan-2023';
           '19-Jan-2023';
           '18-Jan-2023';
           '17-Jan-2023';
           '16-Jan-2023';];

%Input Maturity Date
Matu_list=['30-Jun-2023';
           '30-Nov-2023';
           '30-Jun-2024';
           '30-Nov-2024';
           '30-Jun-2025';
           '30-Oct-2025';
           '30-Jun-2026';
           '30-Sep-2026';
           '30-Jun-2027';
           '30-Sep-2027';
           '30-Jun-2028';];



% Introduce Do loop for the Bond return calculation
for a= 1:length(pf_list)
   bond_tp=pf_list(a);
  
   % Reading CSV file of Bond Price input
   table=readtable(bond_tp+".csv",'PreserveVariableNames',true);
   % Select  Closing PRice
   Close_P(:,a)=table(:,2);
   Matu_dt= datetime(Matu_list(a,:));
   c_rate=CouponRate_list(a,:);
   Period = 2; 
   Basis = 0; 
   % Calculat Month return
    for b=1:11
        setl_dt= datetime(setl_list(b,:));
        P_at_D=table2array(Close_P(b,a));
        Yield_list(b,a) = bndyield(P_at_D, c_rate, setl_dt, Matu_dt,'Period',2, 'Basis',0);
        Time_2_M(b,a)=Matu_dt-setl_dt;
    end

end

figure
%color_tp=['r';'b';'g';'c';'m';'y';'k';'-w'];
hold on
for c=1:11
    x=years(Time_2_M(c,:))';
    v=Yield_list(c,:);
    xq=years(hours(2000:720:46000))';
   % color_a=color_tp(c,1);
    vq1 = interp1(x,v,xq)*100;
    plot(xq,vq1);  
end
legend(setl_list);
ytickformat('percentage')
title('Yield Curve by Settle Date (Linear Interpolation)');
xlabel('Maturity (Year)') 
ylabel('Yield (%)')



%Calculating Spot Rate
stprc=[100 100 100 100 100 100 100 100 100 100 100]';
for d=1:11
    list_BD=datenum(Matu_list); 
    Bond_SP=[list_BD CouponRate_list stprc];
    Yields_SP=Yield_list(d,:);
    Settle_SP=datenum(setl_list(d,:));
    [ZeroRates, CurveDates] = zbtyield(Bond_SP, Yields_SP, Settle_SP);
    [ForwardRates, CurveDates] = zero2fwd(ZeroRates, CurveDates, Settle_SP)
    Spot_rate(d,:)=ZeroRates';
    Forwar_rate(d,:)=ForwardRates';
    CV_Date(d,:)=CurveDates';
end


figure
%color_tp=['r';'b';'g';'c';'m';'y';'k';'-w'];
hold on
for e=1:11
    x=years(Time_2_M(e,:))';
    v=Spot_rate(e,:);
    xq=years(hours(2000:720:46000))';
   % color_a=color_tp(c,1);
    vq1 = interp1(x,v,xq)*100;
    plot(xq,vq1);  
end
legend(setl_list);
ytickformat('percentage')
title('Spot Curve by Maturity Date');
xlabel('Maturity (Year)') 
ylabel('Yield (%)')



figure
%color_tp=['r';'b';'g';'c';'m';'y';'k';'-w'];
hold on
for f=1:11
    x=years(Time_2_M(f,:))';
    v=Forwar_rate(f,:);
    xq=years(hours(2000:720:46000))';
   % color_a=color_tp(c,1);
    vq1 = interp1(x,v,xq,'spline')*100;
    plot(xq,vq1);  
end
legend(setl_list);
ytickformat('percentage')
title('Forward Curve by Maturity Date');
xlabel('Maturity (Year)') 
ylabel('Yield (%)')


sqq=cov(Forwar_rate*100,Spot_rate*100);



[vs,dp]=eig(sqq);



