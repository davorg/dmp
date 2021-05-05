my @sorted_IPs = map { substr($_, 4) } 
                 sort 
                 map { pack('C4', /(\d+)\.(\d+)\.(\d+)\.(\d+)/) . $_ } @IPs;
