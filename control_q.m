classdef control_q < handle
    % CONTROL_Q Central contoller class to make NW control decisions using Q-learning
    
    properties
        Q; % Q table : matrix of dimentsions |states + actions|
        state_size;
        action_size;
        prev_state;
        prev_action;
        cum_reward = 0;
        alpha = 0.9; % Learning rate
        gamma = 0.8; % Discount factor
        epsilon = 1; % Epsilon value for greedy decisions
        min_epsilon = 0.1; % Minimum upto which epsilon is decremented
        epsilon_step; % Epsilon step size
        r_stream; % Stream of random numbers
        learn = 1; % Flag for the state of the learner : 1-learning phase, 0-greedy phase
    end
    
    methods
        function obj = control_q(state_size, action_size, eps_step, seed)
            obj.Q = zeros([state_size+1, action_size]);
            obj.state_size = state_size;
            obj.action_size = action_size;
            obj.prev_state = ones(1, length(state_size));
            obj.prev_action = ones(1, length(action_size));
            obj.epsilon_step = eps_step;
            obj.r_stream = RandStream('mt19937ar', 'Seed', seed);
        end
        function obj = reward(obj, r, t)
            rew = reward(r, t) + .98 * obj.cum_reward(end);
            obj.cum_reward = [obj.cum_reward, rew];
        end
        function obj = control(obj, r)
            cur_state = ones(1, length(obj.state_size));
            for i = 1:length(obj.state_size)
                % State depends on only the first routers
                cur_state(i) = size(r{i}.q, 2)+1;
            end
            % Reward for the previous state & action
            reward = obj.cum_reward(end);
            
            % Compute the Q update using the previous reward
            if obj.learn == 1
                cur_index=num2cell(cur_state);
                prev_index=num2cell([obj.prev_state, obj.prev_action]);
                greedy_Q = max(max(obj.Q(cur_index{:}, :, :)));
                update = (1-obj.alpha) * obj.Q(prev_index{:}) + obj.alpha * (reward + obj.gamma*greedy_Q);
                obj.Q(prev_index{:}) = update;
            end
            
            % Choose a new action
            if rand(obj.r_stream) > obj.epsilon
                % Greedy step
                cur_index=num2cell(cur_state);
                current_Q = obj.Q(cur_index{:}, :, :);
                [~, greedy_ij] = max(current_Q(:));
                [control1, control2] = ind2sub(obj.action_size, greedy_ij);
            else
                % Random step
                control1 = randi(obj.action_size(1));
                control2 = randi(obj.action_size(2));
            end
            r{1}.next_hop = control1;
            r{2}.next_hop = control2;
                
            % State current state as previous for next round
            obj.prev_state = cur_state;
            obj.prev_action = [control1, control2];
			obj.epsilon = max(obj.min_epsilon, obj.epsilon - obj.epsilon_step);
        end
    end
end