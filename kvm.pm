#!/usr/bin/perl
package kvm;

# use Exporter qw(import);
# our @EXPORT_OK = qw(stripFlags);

sub stripFlags(){
    
    my @argv;
    my @flagv;
    foreach my $v (@ARGV){
	if (index( $v, "-") == 0) {
	    push @flagv, $v;
	} else {
	    push @argv, $v;
	}
    }
    @ARGV = @argv;
    
    return @flagv;
}

sub arplist() {
    my @arplist = split /\n/,`arp -e`;
    shift @arplist; #remove banner:  ipAddress HWtype macHWaddress Flags Mask Iface 
    my %arp;
    foreach my $v (@arplist){
	if ($v =~ /^(\d+\.\d+\.\d+\.\d+).*\s+([0-9A-Fa-f]+:[\dA-Fa-f]+:[\dA-Fa-f]+:[\dA-Fa-f]+:[\dA-Fa-f]+:[\dA-Fa-f]+).*/) {
	    my $ip = $1;
	    my $mac = $2;

	    my %addr = (
		"ip" => $ip,
		"mac" => $mac,
		);
	    $arp{$mac} = \%addr;
	}
    }
    return \%arp;
}


sub iflist() {
    my $vmname = shift;
    @iflist  = split /\n/,`virsh domiflist $vmname`;
    shift @iflist; #remove banner: Interface Type Source Model MAC
    shift @iflist; #remove HR: -----------------------------------
    my %ifs;
    foreach my $v (@iflist){
	($interface, $type, $source, $model, $mac) = split /\s+/, $v;
	my %interface = (
	    "interface" => $interface,
	    "type" => $type,
	    "source" => $source,
	    "model" => $model,
	    "mac" => $mac,
	    );
	$ifs{$interface}= \%interface;
    }

    return \%ifs;
}

sub blklist(){
    my $vmname = shift;
    my %blklist = ();

    @kvmblklist = split /\n/, `virsh domblklist $vmname`;
    shift @kvmblklist; #remove banner: Target Source
    shift @kvmblklist; #remove HR: ------------------------------

    foreach my $blk (@kvmblklist){
	($target, $source) = split /\s+/, $blk;
	$blklist{$target} = $source;
    }

    return \%blklist;
}


# returns 1 on succes 0 otherwise
sub shutdown(){
    my $vmname = shift;
    my $kvms = &list();

    my $state = $kvms->{$vmname}->{"state"};
    if ( $state ne "shut" ) {
	print "shutting down $vmname\n";
	if (system "virsh", "shutdown", $vmname){
	    return 0;
	} else {
	    return 1;
	}
    } else {
	return 1;
    }
    return 0;

}

sub list(){

    my @kvmlist = split /\n/, `virsh list --all`;

    shift @kvmlist; #remove banner: Id Name State
    shift @kvmlist; #remove HR: ------------------------------
    my %kvms;
    foreach my $v (@kvmlist){
	$v =~  s/^\s+|\s+$//g; #trim 

	($id, $name, $state) = split /\s+/, $v;
	my %kvm = (
	    "id" => $id,
	    "name" => $name,
	    "state" => $state,
	    );
	$kvms{$name} = \%kvm;
    }

    while ( ($vmname, $kvm) = each %kvms ){
	my $blklist = &blklist($vmname);
	$kvm->{"blklist"} = $blklist;
    }
    return \%kvms;
}

1;
