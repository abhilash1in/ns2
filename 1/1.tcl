# set variable_name


#create a new simulator object:
set ns [new Simulator]

#open a file called prog1.nam in write mode
set nf [open prog1.nam w]

#tells simulator to record simulation traces in NAM input format, written to $nf when 'flush-trace' is caled
$ns namtrace-all $nf

#open a file called prog1.nam in write mode
set nd [open prog1.tr w]

#trace-all is for recording the simulation trace in a general format
$ns trace-all $nd


#procedure/function
proc finish { } {
	global ns nf nd

	#writes the trace records to the corresponding files
	$ns flush-trace

	#close the opened files
	close $nf
	close $nd

	#awk "event = $1"
	exec nam prog1.nam &
	exec awk -f 1.awk prog1.tr &
	exit 0
}

#create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

#to decide when to drop packets, each packet is treated identically. 
# when the queue is filled to the maximum capacity, it drops the newly arriving packets until the queue has enough room to accept incoming traffic
#duplex link with 1Mbps bandwidth, 10ms delay and uses DropTail queue management protocol
$ns duplex-link $n0 $n1 0.4Mb 10ms DropTail  
#change this for xgraph vs no. of packets recieved
$ns duplex-link $n1 $n2 0.4Mb 10ms DropTail

#orientation of nodess
$ns duplex-link-op $n0 $n1 orient right-up
$ns duplex-link-op $n1 $n2 orient right-down


#limit for DropTail queue
$ns queue-limit $n1 $n2 5

# User Datagram Protocol
# UDP is a transport layer protocol
# UDP agent accepts data of variable size and segments it if needed
set udp0 [new Agent/UDP]

#attaches an agent object created to a node object
$ns attach-agent $n0 $udp0

# CBR-Constant Bit Rate
# CBR traffic generator, generates packets of size 500 bytes after every interval of 0.005 seconds
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0


#null agent acts as a sink and also frees the received pakets
set sink [new Agent/Null]
#attaches an agent object created to a node object
$ns attach-agent $n2 $sink

#to establish a logical network connection between them
#establishes a network connection by setting the destination address to each others' network and port address pair.
$ns connect $udp0 $sink

#schedule events for CBR to start and stop
$ns at 0.2 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"

#call procedure 'finish'
$ns at 5.0 "finish"

#run the simulation
$ns run