function [fit]=fun_w(Distance,pop_node,i,BeaconAmount,Beacon,hop1)
    fit =0;
    for j=1:BeaconAmount
        %w = (1/hop1(j,i)); 
        w = (1/hop1(j,i))^2; 
        
        fit =fit+ w* (((((pop_node(1,1)-Beacon(1,j))^2+(pop_node(1,2)-Beacon(2,j))^2)^0.5) - Distance(j,i) ))^2;%所有节点间相互距离
       % fit =fit+abs(((((pop_node(1,1)-Beacon(1,j))^2+(pop_node(1,2)-Beacon(2,j))^2)^0.5) - Distance(j,i) ));%所有节点间相互距离
       
    end
    %fit=fit/BeaconAmount;