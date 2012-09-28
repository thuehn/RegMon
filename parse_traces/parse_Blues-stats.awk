#!/usr/bin/gawk
# parse Minstrel-Blues Stats
# Thomas Huehn 2012

BEGIN{
		#adapt fieldseperator to table
	FS = ","
	start_seq = 0;
	i = 1;
}
{
#
if (start_seq == 0 && substr($0,0,4) == "time"){
	print "start found"
	start_seq = 1;
	next;
}
else if (start_seq == 0){
	next;
		print "nest ";
}

#DATA
else if (start_seq == 1 && substr($0,0,4) != "time" && substr($0,0,4) != "neig"){

#current rate
if (match($2,"x") !=0 )
	print "current rate"


sub(/x/, "", $2)
sub(/^[[:blank:]]*/, "", $2)
sub(/[[:blank:]]*$/, "", $2)
print "stats line= " $2"ende";
#stats[i] = $1;
#i = i +1;
#print "stats[i]= " stats[i];
}




#MAC and we need to print
else if (start_seq == 1 && substr($0,0,4) == "neig"){
	print "neigbor line";
#	mac=substr($0,11,28);

#	for (k = 1; k<i; k++) {
#		print mac, stats[k]



	i = 0;
	start_seq = 0;
	}

}