function main()
N = 3; % Number of candidates
B = 10; % Number of batches
D = 1000; % Duration per batch
buffers = [1, 1, 2, 1, 1, 1]; % Buffer sizes of Routers
p = 0.75; % Packet generation load
epsilon_step = 1/D; % Epsilon step size
replay_size = 1000; % Size of the replay set
sample_size = 50; % Number of samples to train on

hiddenLayerSize = [4, 4];
action_size = [2, 2];
best_q = sdn_best_q(D, 1, B, p, buffers, action_size, epsilon_step);
best_nn = sdn_best_nn(D, N, B, p, hiddenLayerSize, buffers, action_size, epsilon_step, replay_size, sample_size);
save(sprintf('[%s]', sprintf('%d,', buffers)), 'best_q');
save(sprintf('[%s], [%s], %d-%d', sprintf('%d,', buffers), sprintf('%d,', hiddenLayerSize), sample_size, replay_size), 'best_nn');

p = [0.5, 0.9, 0.75, 1, 0.6];
sdn_compare(D, B, p, buffers, control_opt(), best_q, best_nn);
end