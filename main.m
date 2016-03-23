function main()
N = 3; % Number of candidates
B = 10; % Number of batches
D = 100; % Duration per batch
buffers = [1, 1, 2, 1, 5, 5]; % Buffer sizes of Routers
p = 0.75; % Packet generation load
epsilon_step = 1/D; % Epsilon step size
replay_size = 1000; % Size of the replay set
sample_size = 50; % Number of samples to train on

hiddenLayerSize = [4, 4];
action_size = [2, 2];
best_nn = sdn_best_nn(D, N, B, p, hiddenLayerSize, buffers, action_size, epsilon_step, replay_size, sample_size);
best_q = sdn_best_q(D, N, B, p, buffers, action_size, epsilon_step);

p = 0.5:0.05:1;
sdn_compare(D, B, p, buffers, control_opt(), best_q, best_nn);
end