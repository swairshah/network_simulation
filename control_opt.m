classdef control_opt < handle
    %CONTROL_OPT Baseline controller
    
    properties
        cum_reward = 0;
    end
    
    methods
        function obj = reward(obj, r, t)
            rew = reward(r, t) + .98 * obj.cum_reward(end);
            obj.cum_reward = [obj.cum_reward, rew];
        end
        function obj = control(obj, r)
            r3_oc = r{3}.occupancy();
            r4_oc = r{4}.occupancy();
            
            if ~isempty(r{1}.q)
                if r3_oc <= r4_oc
                    r{1}.next_hop = 1;
                    r3_oc = (size(r{3}.q, 2)+1)/r{3}.max_q;
                else
                    r{1}.next_hop = 2;
                    r4_oc = (size(r{4}.q, 2)+1)/r{4}.max_q;
                end
            end
            
            if ~isempty(r{2}.q)
                if r3_oc <= r4_oc
                    r{2}.next_hop = 1;
                else
                    r{2}.next_hop = 2;
                end
            end
        end
    end
end