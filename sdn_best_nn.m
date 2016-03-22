function best_nn = sdn_best_nn(duration, N, batch, loads, hiddenLayerSize, buffers, action_size, epsilon_step, replay_size, sample_size)
% Use the same seed for all packet generation
pkt_seed = randseed;
% Use the same seed for all random decisions
dec_seed = randseed;

switch 1
	case N <= 3
		rows = 1;
	case N <= 9
		rows = 2;
	case N <= 17
		rows = 3;
	otherwise
		rows = 4;
end
cols = ceil((N+1)/rows);

load = loads;
if size(loads, 2) == 1
	load = ones(1, batch) * loads;
end
best_mean = -Inf;
best_nn = [];
drops = [];
delays = [];
figure('name', 'NN Candidates');
for n = 1:N
	% Create a new NN-controller
    nn = control_nn(hiddenLayerSize, buffers(1:4), action_size, epsilon_step, dec_seed, replay_size, sample_size);

	% Run the simulations
	[drop, delay] = sdn_simulate(duration, load, nn, buffers, pkt_seed);
	drops = [drops, drop];
	delays = [delays, delay];

	if mean(q.cum_reward) > best_mean
		best_nn = nn;
	end

	subplot(rows, cols, n);
	plot(q.cum_reward);
	title(strcat('Candidate-', n));
	xlabel('Time(i)');
	ylabel('Reward(points)');
	if n == 1
		title_layers = strcat('Layers-', num2str(hiddenLayerSize));
		title_epsilon = strcat(', Epsilon-1/', epsilon_step);
		title_replay = strcat(', Replay-', replay_size);
		title_sample = strcat(', Samples-', sample_size);
		title(strcat('Same packets', title_layers, title_epsilon, title_replay, title_sample));
	end
end

x_value = loads;
x_label = 'Load(p)';
if size(loads, 2) == 1
	x_value = 1:batch;
	x_label = 'Time(batch)';
end

subplot(rows, cols, N+1);
title('NN-learner');
xlabel(x_label);
yyaxis left;
plot(x_value, drops);
ylabel('Drop(count)');
yyaxis right;
plot(x_value, delays);
ylabel('Delay(ms)');
end