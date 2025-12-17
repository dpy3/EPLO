function [Taguchi_option]=Get_Taguchi_option(i)
switch i
    case 'EXP1'
        Taguchi_option = struct('SearchAgents_no',16,'Max_iteration',80,'Groups',2,'Comminicate',3);
    case 'EXP2'
        Taguchi_option = struct('SearchAgents_no',32,'Max_iteration',40,'Groups',2,'Comminicate',6);
    case 'EXP3'
        Taguchi_option = struct('SearchAgents_no',64,'Max_iteration',20,'Groups',2,'Comminicate',5);
    case 'EXP4'
        Taguchi_option = struct('SearchAgents_no',16,'Max_iteration',80,'Groups',4,'Comminicate',5);
    case 'EXP5'
        Taguchi_option = struct('SearchAgents_no',32,'Max_iteration',40,'Groups',4,'Comminicate',3);
    case 'EXP6'
        Taguchi_option = struct('SearchAgents_no',64,'Max_iteration',20,'Groups',4,'Comminicate',6);
    case 'EXP7'
        Taguchi_option = struct('SearchAgents_no',16,'Max_iteration',80,'Groups',8,'Comminicate',3);
    case 'EXP8'
        Taguchi_option = struct('SearchAgents_no',32,'Max_iteration',40,'Groups',8,'Comminicate',6);
    case 'EXP9'
        Taguchi_option = struct('SearchAgents_no',64,'Max_iteration',20,'Groups',8,'Comminicate',5);        
end
end
