function [] = main()

s0 = node(); s0.id = 0;
s1 = node(); s1.id = 1;

r0 = router(); r0.init(0,5,0);
r1 = router(); r1.init(1,5,0);

s0.connect(r0);
s1.connect(r1);

r2 = router(); r2.init(2,2,0);
r3 = router(); r3.init(3,2,0);


r4 = router(); r4.init(4,1,0);
r5 = router(); r5.init(5,1,0);


r0.connect(r2);
r1.connect(r2);

r1.connect(r3);
r0.connect(r3);

r2.connect(r4);
r2.connect(r5);

r3.connect(r4);
r3.connect(r5);


t0 = node(); t0.id = 4;
t1 = node(); t1.id = 5;

r4.connect_node(t0);
r5.connect_node(t1);

stream = RandStream('mlfg6331_64');
for time = 1:10
    if rand(stream) < 0
        s0.pkt_generate(t0, time);
    else
        s0.pkt_generate(t1, time);  
    end
    
    if rand(stream) < 0
        s1.pkt_generate(t0, time);
    else
        s1.pkt_generate(t1, time);
    end

    control_opt(r0);
    control_opt(r1);

    r0.process();
    r1.process();
    r2.fwd_to_dst();
    r3.fwd_to_dst();
    r4.send_to_node();
    r5.send_to_node();
    disp(t1.received_pkt);
end

end

