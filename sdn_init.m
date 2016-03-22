function [s, t, r] = sdn_init(buffers)
% Source nodes
s = {node(1, 0), node(2, 0)};
% Destination nodes
t = {node(5, 0), node(6, 0)};
% Router nodes
r = {router(1,buffers(1),0), router(2,buffers(2),0), router(3,buffers(3),0), router(4,buffers(4),0), router(5,buffers(5),0), router(6,buffers(6),0)};

% Connection between the nodes
st = [1 1; 1 2; 2 1; 2 2]';
sr = [1 1; 2 2]';
rr = [1 3; 1 4; 2 3; 2 4; 3 5; 3 6; 4 5; 4 6]';
rt = [5 1; 6 2]';
for ij = st
    s{ij(1)}.connect_node(t{ij(2)});
end
for ij = sr
    s{ij(1)}.connect_router(r{ij(2)});
end
for ij = rr
    r{ij(1)}.connect_router(r{ij(2)});
end
for ij = rt
    r{ij(1)}.connect_node(t{ij(2)});
end
end