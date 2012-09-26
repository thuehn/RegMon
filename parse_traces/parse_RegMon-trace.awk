#!/usr/bin/gawk
# USAGE: cat tracefile.txt | gawk --non-decimal-data -f parse_trace.awk
# Thomas Huehn 2012

BEGIN{
    #print header
	MHz = 40;
    #print "ktime d_ktime d_tsf d_mac d_tx d_rx d_ed noise rssi nav d_read e_mac_k e_mac_tsf reset tx_start tx_air rx_start rx_air ed_start ed_air";
}
{
#
if (NR == 1) {
	time 		= $1;
	tsf_1_old	= sprintf("%d", "0x" substr($2,7,10));
    mac_old		= sprintf("%d", "0x" $3);
	tx_old		= sprintf("%d", "0x" $4);
	rx_old		= sprintf("%d", "0x" $5);
	ed_old		= sprintf("%d", "0x" $6);
	#noise
	noise_raw	= sprintf("%d", "0x" $8);
	noise		= -1 - xor(rshift(noise_raw, 19), 0x1ff);
    pot_reset	= 0;
	tx_start	= 0;
	tx_paket	= 0;
	tx_end		= 0;
	rx_start	= 0;
	rx_paket	= 0;
	rx_end		= 0;
	ed_start	= 0;
	ed_paket	= 0;
	ed_end		= 0;
	prev_error  = 0;
}
else if (NR > 1) {
    #time_diff
	if(prev_error == 0){
		if(strtonum($1) - strtonum(time) < 0){
			k_time_diff	= "NA";
			prev_error	= 1;
		}
		else 
			k_time_diff  =  strtonum($1) - strtonum(time);
	}
	else {
		k_time_diff	= "NA";
		prev_error	= 0;
	}

	#tsf diff
	if (sprintf("%d", "0x" $2) + 0 > tsf_1_old + 0)
		tsf_1_diff	= sprintf("%d", "0x" $2) - tsf_1_old;
	else
		tsf_1_diff	= "NA";
	
	# read duration of MIB register readings in usec
	read_duration	= sprintf("%d", "0x" $7) - sprintf("%d", "0x" substr($2,9,8));

    #mac_diff
    if (sprintf("%d", "0x" $3) + 0 > mac_old + 0) {
		mac_diff		= sprintf("%d", "0x" $3) - mac_old;
		if (sprintf("%d", "0x" $4) - tx_old  <= mac_diff +0)
	    	tx_diff			= sprintf("%d", "0x" $4) - tx_old;
		else
			tx_diff = 0;
			
		if (sprintf("%d", "0x" $5) - rx_old <= mac_diff)
			rx_diff			= sprintf("%d", "0x" $5) - rx_old;
		else
			rx_diff = o;
			
		if (sprintf("%d", "0x" $6) - ed_old <= mac_diff)
			ed_diff			= sprintf("%d", "0x" $6) - ed_old;
		else
			ed_diff = o;
    }
    else {
	    pot_reset	= 1;
	    mac_diff	= sprintf("%d", "0x" $3);
	    tx_diff		= sprintf("%d", "0x" $4);
	    rx_diff		= sprintf("%d", "0x" $5);
	    ed_diff		= sprintf("%d", "0x" $6);
    }
	
	#expected mac counts
	if (k_time_diff != "NA")
		k_exp_mac	= sprintf("%.0f", k_time_diff * MHz / 1000);
	else
		k_exp_mac 	= "NA";

	if (tsf_1_diff  != "NA")
	    	tsf_exp_mac = tsf_1_diff * MHz;
	else
		tsf_exp_mac = "NA";
	
	#potential tx packet borders
	if(tx_diff > 0 && tx_paket == 0){
		tx_start	= 1;
		tx_paket	= 1;
		tx_airtime	= tx_diff + (read_duration - 2) * MHz;
	}
	else if (tx_diff == mac_diff && tx_paket == 1){
		tx_start	= 0;
		#check if MIB reset
		if (pot_reset == 1)
			tx_airtime	= tx_airtime + tsf_exp_mac;
		else
			tx_airtime	= tx_airtime + tx_diff + (read_duration -2) * MHz;
	}
	else if (tx_diff < mac_diff && tx_paket == 1){
		tx_start	= 0;
		tx_paket	= 0;
		tx_airtime	= tx_airtime + tx_diff + (read_duration -2) * MHz;
		tx_end		= sprintf("%.0f",tx_airtime / MHz);
		tx_airtime	= 0;
	}
	else if (tx_diff == 0 && tx_paket == 0){
		tx_start	= 0;
		tx_paket	= 0;
		tx_end		= 0;
		tx_airtime	= 0;
	}
	
	#potential rx packet borders
	if(rx_diff > 0 && rx_paket == 0){
		rx_start	= 1;
		rx_paket	= 1;
		rx_airtime	= rx_diff + (read_duration - 2) * MHz;
	}
	else if (rx_diff == mac_diff && rx_paket == 1){
		rx_start	= 0;
		#check if MIB reset
		if (pot_reset == 1)
			rx_airtime	= rx_airtime + tsf_exp_mac;
		else
			rx_airtime	= rx_airtime + rx_diff + (read_duration -2) * MHz;
	}
	else if (rx_diff < mac_diff && rx_paket == 1){
		rx_start	= 0;
		rx_paket	= 0;
		rx_airtime	= rx_airtime + rx_diff + (read_duration -2) * MHz;		
		rx_end		= sprintf("%.0f",rx_airtime / MHz);
		rx_airtime	= 0;
	}
	else if (rx_diff == 0 && rx_paket == 0){
		rx_start	= 0;
		rx_paket	= 0;
		rx_end		= 0;
		rx_airtime	= 0;
	}

	#potential ed borders
	if(ed_diff > 0 && ed_paket == 0){
		ed_start	= 1;
		ed_paket	= 1;
		ed_airtime	= ed_diff + (read_duration - 2) * MHz;
	}
	else if (ed_diff == mac_diff && ed_paket == 1){
		ed_start	= 0;
		#check if MIB reset
		if (pot_reset == 1)
			ed_airtime	= ed_airtime + tsf_exp_mac;
		else
			ed_airtime	= ed_airtime + ed_diff + (read_duration -2) * MHz;
	}
	else if (ed_diff < mac_diff && ed_paket == 1){
		ed_start	= 0;
		ed_paket	= 0;
		ed_airtime	= ed_airtime + ed_diff + (read_duration -2) * MHz;
		ed_end		= sprintf("%.0f",ed_airtime / MHz);
		ed_airtime	= 0;
	}
	else if (ed_diff == 0 && ed_paket == 0){
		ed_start	= 0;
		ed_paket	= 0;
		ed_end		= 0;
		ed_airtime	= 0;
	}

    #noise calculation
    if (noise_raw != $8) {
		noise		= -1 - xor(rshift(noise_raw, 19), 0x1ff);
		noise_raw	= $8;
    }
	
	#rssi calculation
	rssi = sprintf("%d", "0x" $9);

	#nav
	nav = sprintf("%d", "0x" $10);

	#final print
	print $1 , k_time_diff, tsf_1_diff, mac_diff, tx_diff, rx_diff, ed_diff, noise, rssi, nav, read_duration, k_exp_mac, tsf_exp_mac, pot_reset, tx_start, tx_end, rx_start, rx_end, ed_start, ed_end

	#refresh lines
	time_old	=time;
	time 		= $1;
	tsf_1_old	= sprintf("%d", "0x" $2);
    mac_old		= sprintf("%d", "0x" $3);
	tx_old		= sprintf("%d", "0x" $4);
	rx_old		= sprintf("%d", "0x" $5);
	ed_old		= sprintf("%d", "0x" $6);
	pot_reset	= 0;
	tx_end		= 0;
	rx_end		= 0;
	ed_end		= 0;
}

}
END{

}
