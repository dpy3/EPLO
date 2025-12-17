% This function initialize the first population of search agents
function Positions=ninitialization(SearchAgents_no,dim,ub,lb)

Boundary_no= size(ub,2); % numnber of boundaries

% If the boundaries of all variables are equal and user enter a signle
% number for both ub and lb
if Boundary_no==1
    Positions=rand(SearchAgents_no,dim).*(ub-lb)+lb;
end

% If each variable has a different lb and ub
if Boundary_no>1
    XPositions = zeros(SearchAgents_no, dim);
    for i=1:dim
        ub_i=ub(i);
        lb_i=lb(i);
        k=(1+(t/T)^0.5)^10;
        Positions(:,i)=rand(SearchAgents_no,1).*(ub_i-lb_i)+lb_i;
        %XPositions(:,i) = lb_i + ub_i - Positions(:,i);
        XPositions(:,i) = (ub+lb)/2+(ub+lb)/(2*k)-Positions(:,i)/k;
        XPositions(:,i) = max(XPositions(:,i), lb_i);
        XPositions(:,i) = min(XPositions(:,i), ub_i);
        fitnessValues_Positions = fitnessFunction(Positions);%计算positions的适应度并存储起来
        fitnessValues_XPositions = fitnessFunction(XPositions);%Xpositions
        populationCells = cell(2*SearchAgents_no, 2);%初始化了一个 2*SearchAgents_no 行、2 列的 cell 数组，用于存储合并后的种群及其适应度值。
        for j = 1:SearchAgents_no
            populationCells{j, 1} = Positions(j, :);
            populationCells{j, 2} = fitnessValues_Positions(j);
            populationCells{j + SearchAgents_no, 1} = XPositions(j, :);
            populationCells{j + SearchAgents_no, 2} = fitnessValues_XPositions(j);
        end
        [~, sortIdx] = sort([populationCells{:, 2}]); % 这里假设适应度值越小越好（如果是越大越好，则需要加上'descend'）
        sortedPopulationCells = populationCells(sortIdx, :);% 根据适应度值对合并后的种群进行排序
                             
        newPositions = zeros(SearchAgents_no, dim);
        for k = 1:SearchAgents_no
        newPositions(k, :) = sortedPopulationCells{k, 1};
        end
    
    % 更新Positions为新的种群
        Positions = newPositions;
    end
end