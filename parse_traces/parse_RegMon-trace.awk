#!/usr/bin/gawk
# USAGE: cat tracefile.txt | gawk --non-decimal-data -f parse_trace.awk
# Thomas Huehn 2012

BEGIN{
    #print header
	MHz = 44;
    print "ktime d_ktime d_tsf d_mac d_tx d_rx d_ed d_read e_mac_k e_mac_tsf reset tx_start tx_air rx_start rx_air ed_start ed_air";
}
{
#
if (NR == 1) {
	time = $1;
    time_old	= sprintf("%d", substr($1,10,10));
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
}
else if (NR > 1) {
    #time_diff
    k_time_diff  =  sprintf("%.0f", (sprintf("%d", substr($1,10,10)) - time_old) / 1000 );

	#tsf diff
	if (sprintf("%d", "0x" $2) > tsf_1_old)
		tsf_1_diff	= sprintf("%d", "0x" $2) - tsf_1_old;
	else
		tsf_1_diff	= 12345;
	
	# read duration of MIB register readings in usec
	read_duration	= sprintf("%d", "0x" $7) - sprintf("%d", "0x" substr($2,9,8));

    #mac_diff
    if (sprintf("%d", "0x" $3) > mac_old) {

		mac_diff		= sprintf("%d", "0x" $3) - mac_old;
	    tx_diff			= sprintf("%d", "0x" $4) - tx_old;
	    rx_diff			= sprintf("%d", "0x" $5) - rx_old;
	    ed_diff			= sprintf("%d", "0x" $6) - ed_old;
    }
    else {
	    pot_reset	= 1;
	    mac_diff	= sprintf("%d", "0x" $3);
	    tx_diff		= sprintf("%d", "0x" $4);
	    rx_diff		= sprintf("%d", "0x" $5);
	    ed_diff		= sprintf("%d", "0x" $6);
    }
	
	#potential tx packet borders
	if(tx_diff > 0 && tx_paket == 0){
		tx_start	= 1;
		tx_paket	= 1;
		tx_airtime	= tx_diff + (read_duration - 2) * MHz;
	}
	else if (tx_diff > 0 && tx_paket == 1){
		tx_start	= 0;
		tx_airtime	= tx_airtime + tx_diff + (read_duration -2) * MHz;
	}
	else if (tx_diff == 0 && tx_paket == 1){
		tx_start	= 0;
		tx_paket	= 0;
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
	else if (rx_diff > 0 && rx_paket == 1){
		rx_start	= 0;
		rx_airtime	= rx_airtime + rx_diff + (read_duration -2) * MHz;
	}
	else if (rx_diff == 0 && rx_paket == 1){
		rx_start	= 0;
		rx_paket	= 0;
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
	else if (ed_diff > 0 && ed_paket == 1){
		ed_start	= 0;
		ed_airtime	= ed_airtime + ed_diff + (read_duration -2) * MHz;
	}
	else if (ed_diff == 0 && ed_paket == 1){
		ed_start	= 0;
		ed_paket	= 0;
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
		
	#expected mac count
    k_exp_mac	= k_time_diff * MHz ;
	k_exp_mac	= sprintf("%.0f",($1 - time) * MHz / 1000);
    tsf_exp_mac = tsf_1_diff * MHz;

	#final print
    print $1 , ($1 - time), tsf_1_diff, mac_diff, tx_diff, rx_diff, ed_diff, noise, rssi, nav, read_duration, k_exp_mac, tsf_exp_mac, pot_reset, tx_start, tx_end, rx_start, rx_end, ed_start, ed_end

	#refresh lines
	time = $1;
    time_old	= sprintf("%d", substr($1,10,10));
	tsf_1_old	= sprintf("%d", "0x" $2);
    mac_old		= sprintf("%d", "0x" $3);
	tx_old		= sprintf("%d", "0x" $4);
	rx_old		= sprintf("%d", "0x" $5);
	ed_old		= sprintf("%d", "0x" $6);
	pot_reset	= 0;
}

}
END{

}
