function sdn_compare(duration, batch, loads, buffers, opt, q, nn)
% Use the same seed for all packet generation
seed = randseed;

load = loads;
if size(loads, 2) == 1
	load = ones(1, batch) * loads;
end
% Run the simulations
q.learn = 0;
nn.learn = 0;
[drop_o, delay_o] = sdn_simulate(duration, load, opt, buffers, seed);
[drop_q, delay_q] = sdn_simulate(duration, load, q, buffers, seed);
[drop_n, delay_n] = sdn_simulate(duration, load, nn, buffers, seed);

% Negelect the initial zero reward
total_duration = size(opt.cum_reward, 2);

figure('name', 'Best Of All');
subplot(2, 2, 1);
plot(0:total_duration, opt.cum_reward, 0:total_duration, q.cum_reward, 0:total_duration, nn.cum_reward);
title(strcat('Buffers-', num2str(buffers)));
xlabel('Time(i)');
ylabel('Reward(points)');
legend('Baseline', 'Q-learner', 'NN-learner');

x_value = loads;
x_label = 'Load(p)';
if size(loads, 2) == 1
	x_value = 1:batch;
	x_label = 'Time(batch)';
end

subplot(2, 2, 2);
title('Baseline');
xlabel(x_label);
yyaxis left;
plot(x_value, drop_o);
ylabel('Drop(count)');
yyaxis right;
plot(x_value, delay_o);
ylabel('Delay(ms)');

subplot(2, 2, 3);
title('Q-learner');
xlabel(x_label);
yyaxis left;
plot(x_value, drop_q);
ylabel('Drop(count)');
yyaxis right;
plot(x_value, delay_q);
ylabel('Delay(ms)');

subplot(2, 2, 4);
title('NN-learner');
yyaxis left;
plot(x_value, drop_n);
ylabel('Drop(count)');
yyaxis right;
plot(x_value, delay_n);
ylabel('Delay(ms)');
end