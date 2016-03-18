function next_hop = control_opt(router) 
    function ratio = occupancy(router)
        max_q = router.max_q;
        cur_q = size(router.q, 2);
        ratio = cur_q/max_q;
    end

    min_ratio = 1;
    next_hop = router.neighbors(1); % by default next_hop is the first neighbor
    for r = router.neighbors
        occupancy_ratio = occupancy(r);
        if occupancy_ratio < min_ratio
            min_ratio = occupancy_ratio;
            next_hop = r;
        end
    end

    router.next_hop = next_hop;
end


        
