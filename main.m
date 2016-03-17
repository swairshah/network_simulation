function [] = main()

s0 = node(); s0.id = 0;
s1 = node(); s1.id = 1;

r0 = router(); r0.init(0,5,0);
r1 = router(); r1.init(1,5,0);

s0.connect(r0);
s1.connect(r1);

r2 = router(); r2.init(2,1,0);
r3 = router(); r3.init(3,1,0);

r0.connect(r2);
r1.connect(r2);

r1.connect(r3);
r0.connect(r3);

t0 = router(); t0.init(4, 1, 0);
t1 = router(); t1.init(5, 1, 0);

r2.connect(t0);
r2.connect(t1);

r3.connect(t0);
r3.connect(t1);

for time = 1:10
    if rand < 0
        s0.pkt_generate(t0, time);
    else
        s0.pkt_generate(t1, time);  
    end
    
    if rand < 0
        s1.pkt_generate(t0, time);
    else
        s1.pkt_generate(t1, time);
    end

    r0.process();
    r1.process();
    r2.fwd_to_dst();
    r3.fwd_to_dst();
    
    disp(t1.drop_count);
end

end

