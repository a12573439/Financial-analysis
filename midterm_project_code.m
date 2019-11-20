[T,TXT,RAW]=xlsread('ISE599_Midterm','WTI_FuturesCurve');
data=T;
data_info=TXT;
 price=data(3:end,[3,9,15,21,27,33,39,45,51,57,63,69]);
 term_return=nan(4959,11);

 date_num=data(3:end,1)+693960;
 date_str=datestr(date_num);
 
 contract_name=data_info(3:end,2);
 m=datestr(date_str,'mm');
 m=str2num(m);
 m_end=[];
 m_end(1)=1;
 expire_date=[];
 for i=3:4959
     if(m(i-1)~=m(i))
         m_end(end+1)=i-1;
     end
     if(~strcmp(contract_name(i-1),contract_name(i)))
         expire_date(end+1)=i-1;
     end
     
 end
 
 m_end(end+1)=4959;
 
 for i=1:11
     term_return(:,i)=price(:,i)./price(:,i+1);
 end
 
 port_num=length(m_end);
 trade_monthly=nan(port_num,2);
 
 % We need to create a 4959*2 array to store the price of long and short
 daily_price=nan(4959,2);
 daily_return=nan(4959,2);

 long_position=1;
 short_position=2;
 for t=1:(port_num-1)
      
      [maxVal maxInd] = max(term_return(m_end(t),:));
      [minVal minInd] = min(term_return(m_end(t),:));     
      daily_price(m_end(t):expire_date(t),long_position)=price(m_end(t):expire_date(t),maxInd+1);
      daily_price(expire_date(t)+1:m_end(t+1),long_position)=price(expire_date(t)+1:m_end(t+1),maxInd);
      daily_price(m_end(t):expire_date(t),short_position)=price(m_end(t):expire_date(t),minInd+1);
      daily_price(expire_date(t)+1:m_end(t+1),short_position)=price(expire_date(t)+1:m_end(t+1),minInd);
      
      for j=m_end(t)+1:m_end(t+1)
          daily_return(j,1)=daily_price(j,1)/daily_price(j-1,1);
          daily_return(j,2)=daily_price(j,2)/daily_price(j-1,2);
      end
      
 end
 
 port_value=nan(4959,1);
 port_value(1)=1;
 daily_total_return=(daily_return(:,1)-daily_return(:,2))*100;
 
 for i=2:4959
     port_value(i)=port_value(i-1)*(1+daily_total_return(i)/100);
 end
figure(1);
plot(date_num,port_value);
datetick('x','dd-mm-yyyy','keepticks');
grid on;

cumulative_return=nan(20,1);
target_date=[2,242,503,764,1025,1287,1547,1807,2068,2330,2591,2852,3112,3373,3634,3895,4156,4417,4677,4938,4961]-2;


for i=1:20
    year=1999+i;
    fprintf('the cumulative return of %4.f is %6.4f%%\n',year,100*port_value(target_date(i+1))/port_value(target_date(i)+1)-100);
end



variance=nanvar(daily_total_return);
variance_total=variance*4959;
volatility_total=sqrt(variance_total);

volatility_annually=sqrt(variance*252);
return_annually=100*((port_value(end))/port_value(1))^(1/19)-100;
fprintf('the annualized return of the portfolio is %6.4f%%\n',return_annually);
fprintf('the annualized risk(annualized volitality) of the portfolio is %6.4f\n',volatility_annually);

sharpe_ratio=(100*port_value(4959)/port_value(1)-100)/volatility_total;
fprintf('the sharpe ratio of the portfolio is %6.4f\n',sharpe_ratio);

figure(2)
portval_vec=[1;cumprod(1+0.01*daily_total_return(2:end))];
yyaxis left 


plot(date_num,portval_vec);
datetick('x','dd-mm-yyyy','keepticks');
ylabel('Portfolio Value');

%   calculate drawdown at each time point
drawdown_vec=nan(length(portval_vec),1);
for i=1:length(portval_vec)
    drawdown_vec(i)=portval_vec(i)/max(portval_vec(1:i))-1;
end
yyaxis right
plot(date_num,drawdown_vec);
ylabel('Drawdowns');

%   locate the maximum drawdown
[max_drawdown,pos_right]=min(drawdown_vec);
[blah,pos_left]=max(portval_vec(1:pos_right));
date_left=date_num(pos_left);
date_right=date_num(pos_right);
hold on
yyaxis left
plot([date_left,date_right],portval_vec([pos_left,pos_right]),'r*')

fprintf('Max Drawdown = %.1f%%.\n',max_drawdown*100);
fprintf('The Max Drowdown period is from %s to %s\n',datestr(date_num(pos_left)),datestr(date_num(pos_right)));
 