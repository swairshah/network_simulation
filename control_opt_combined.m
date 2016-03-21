function [] = control_opt_combined(r0, r1, r2, r3)
    function ratio = occupancy(router)
        max_q = router.max_q;
        cur_q = size(router.q, 2);
        ratio = cur_q/max_q;
    end

    r2_oc = occupancy(r2);
    r3_oc = occupancy(r3);

    if ~isempty(r0.q) 
        if r2_oc <= r3_oc 
            r0.next_hop = r2;
            r2_oc = (size(r2.q, 2)+1)/r2.max_q;
        else
            r0.next_hop = r3;
            r3_oc = (size(r3.q, 2)+1)/r3.max_q;
        end
    end
    
    if ~isempty(r1.q)
        if r2_oc <= r3_oc
            r1.next_hop = r2;
        else
            r1.next_hop = r3;
        end
    end

end

        
