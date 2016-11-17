function phaseData = getPhase(Proj, whichPair)
%% Getting the phases
    numConds = length(Proj);
    d1 = 1 + 2*(whichPair-1);
    d2 = d1+1;
    
    for c=1:numConds
        data = Proj(c).proj(:,[d1,d2]);
        phase = atan2(data(:,2), data(:,1));  % Y comes first for atan2
        
        deltaData = diff(data);
        phaseOfDelta = atan2(deltaData(:,2), deltaData(:,1));  % Y comes first for atan2
        phaseOfDelta = [phaseOfDelta(1); phaseOfDelta];  %#ok<AGROW> % so same length as phase
        radius = sum(data.^2,2).^0.5;
        
        % collect and format
        % make things run horizontally so they can be easily concatenated.
        phaseData(c).phase = phase'; %#ok<AGROW>
        phaseData(c).phaseOfDelta = phaseOfDelta'; %#ok<AGROW>
        phaseData(c).radius = radius'; %#ok<AGROW>
        
        % angle between state vector and Dstate vector
        % between -pi and pi
        phaseData(c).phaseDiff = minusPi2Pi(phaseData(c).phaseOfDelta - phaseData(c).phase); %#ok<AGROW>
    end
    
end
