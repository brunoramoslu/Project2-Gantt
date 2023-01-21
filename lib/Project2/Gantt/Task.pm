##########################################################################
#
#	File:	Project/Gantt/Task.pm
#
#	Author:	Alexander Westholm
#
#	Purpose: The Task class is the data representation of a task
#		within a Gantt chart. It communicates date information
#		up to its containing class, allowing the root object to
#		know the start and end dates of the chart.
#
#	Client:	CPAN
#
#	CVS: $Id: Task.pm,v 1.6 2004/08/03 06:08:24 awestholm Exp $
#
##########################################################################
package Project2::Gantt::Task;

use Mojo::Base -base,-signatures;

use Time::Piece;

has parent => undef;

#TODO: Review start/end conversion to date
has start => undef;
has end => undef;

has startDate => undef;
has endDate => undef;
has description => undef;
has color => undef;
has resources => sub { [] };

sub new {
	my $self = shift->SUPER::new(@_);
	if(not $self->description){
		die "Task must have description!";
	}
	if(not($self->start and $self->end)){
		die "Must provide task dates!";
	}
	$self->startDate(_makeDate($self->start));
	$self->endDate(_makeDate($self->end));
	return $self;
}

##########################################################################
#
#	Function: _makeDate(dateString)
#
#	Purpose: Appends hour/minute/second information (all zeroed) to
#		a Class::Date string that does not have it, and returns
#		the created Class::Date object.
#
#	NOTE:	Perhaps this should be moved to TextUtils?
#
##########################################################################
sub _makeDate($string) {
	print STDERR "#"x80,"\n";
	print STDERR "_makeDate string=$string\n";
	my $add		= "";
	$add =	" 00:00:00" if($string !~ /\:/);
	print STDERR "_makeDate add=$add\n";
	my $fulldate = $string.$add;
	print STDERR "_makeDate fulldate=$fulldate\n";
	my $t = Time::Piece->strptime($fulldate,'%Y-%m-%d %H:%M:%S');
	print STDERR "Time::Piece " . $t->strftime('%Y-%m-%d %H:%M:%S'), "\n";
	print STDERR "-"x80,"\n";
	return $t;
}

sub addResource($self,$resource) {
	push @{$self->resources}, $resource;
}

##########################################################################
#
#	Method:	_handleDates()
#
#	Purpose: Checks to see whether this object's starting date is
#		before its parent's, and if so, resets the parent date.
#		Does similar for end date.
#
##########################################################################
sub _handleDates($self) {
	my $parent  = $self->parent;
	my $oStrt	= $parent->startDate || -1;
	my $oEnd	= $parent->endDate || 0;
	if(($oStrt > $self->startDate) or ($oStrt == -1)){
		$parent->getStartDate($self->startDate);
	}

    # Peter Weatherdon added check for $oEnd == 0
	if(($oEnd < $self->endDate) or ($oEnd == 0)) {
		$parent->getEndDate($self->endDate);
	}
	$parent->_handleDates();
}

1;
