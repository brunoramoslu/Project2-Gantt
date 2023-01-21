##########################################################################
#
#	File:	Project/Gantt/GanttHeader.pm
#
#	Author:	Alexander Westholm
#
#	Purpose: This object paints a calendar header on the canvas. It is
#		also responsible for drawing the 'swim lanes' used to
#		visually locate each task on the calendar.
#
#	Client:	CPAN
#
#	CVS: $Id: GanttHeader.pm,v 1.6 2004/08/03 17:56:52 awestholm Exp $
#
##########################################################################
package Project2::Gantt::GanttHeader;

use Mojo::Base -base,-signatures;

use Project2::Gantt::DateUtils qw[:round];
use Project2::Gantt::TextUtils;
use Project2::Gantt::Globals;

use Time::Seconds;

has canvas    => undef;
has title     => undef;
has startDate => undef;
has endDate   => undef;
has skin      => undef;
has beginX    => 205;
has beginY    => 30;
has root      => undef;

use constant TITLE_SIZE => 200;

sub new {
	my $self = shift->SUPER::new(@_);
	$self->title($self->root->description);
	$self->startDate(Time::Piece->new($self->root->startDate)) if not defined $self->startDate;
	$self->endDate(Time::Piece->new($self->root->endDate)) if not defined $self->endDate;
	return $self;
}

##########################################################################
#
#	Method:	display(mode)
#
#	Purpose: Selects and calls the apropriate header painting method,
#		and if the skin wishes to display the title, the method
#		responsible for doing that is called.
#
##########################################################################
sub display($self, $mode= 'days') {
	if($mode eq 'hours'){
		$self->_writeHeaderHours();
	}elsif($mode eq 'months'){
		$self->_writeHeaderMonths();
	}else{
		$self->_writeHeaderDays();
	}
	if($self->skin->doTitle){
		$self->_writeTitle();
	}
}

##########################################################################
#
#	Method:	_writeHeaderDays()
#
#	Purpose: Iterates over the the span from start to end of the chart
#		by increments of one day. For each day, a square is
#		written to the top of the chart containing the day's
#		number within the month, and the name of the month is
#		written above these squares. Also, swimlanes are put in
#		after each square if the skin calls for it.
#
##########################################################################
sub _writeHeaderDays($self) {
	my $start	= $self->startDate;
	my $end		= $self->endDate;
	my $yval	= $self->beginY;
	my $xval	= $self->beginX;
	$start		= dayBegin($start);

	say STDERR "xval=$xval yval=$yval";

	my @monthsWritn	= ();

	while($start <= $end){
		print STDERR "_writeHeaderDays start=$start\n";
		print STDERR "_writeHeaderDays end=$end\n";
		print STDERR "_writeHeaderDays mon=" . $start->fullmonth,"\n";
		# if haven't already written the name of this month out
		if(not $monthsWritn[$start->mon]){
			print STDERR "_writeHeaderDays Checking with we need to write the month name\n";
			# if more than 15 days left in month, write name of month above day listings
			print STDERR "_writeHeaderDays \$start->month_last_day " .$start->month_last_day, "\n";
			print STDERR "_writeHeaderDays \$start->mday " .$start->mday, "\n";
			if((($start->month_last_day - $start->mday) >= 15) and (($end-$start)>=15)) {
				print STDERR "Write fullmonth ... $xval 12\n";
				$self->_writeText(
					$start->fullmonth . " " . $start->year,
					$xval,
					12);
				$monthsWritn[$start->mon] = 1;
			}
		}
		# write each day
		$self->_writeRectangle(
			$DAYSIZE,
			$start->mday,
			$xval,
			$yval
		);
		$self->_writeSwimLane($xval, $yval) if $self->skin->doSwimLanes();
		$start	+= ONE_DAY;
		$xval	+= $DAYSIZE;
	}
	$self->_writeSwimLane($xval, $yval) if $self->skin->doSwimLanes();
}

##########################################################################
#
#	Method:	_writeHeaderMonths()
#
#	Purpose: For each month between the start and end of the chart,
#		inclusively, a rectangle featuing that month's name is
#		drawn at the top of the chart. Also, swimlanes are
#		installed after each month if the skin dictates.
#
##########################################################################
sub _writeHeaderMonths($self) {
	my $start	= $self->startDate;
	my $end		= $self->endDate;
	my @yearsWritn	= ();
	my $yval	= $self->beginY;
	my $xval	= $self->beginX;
	# transform start date to absolute beginning of month,
	# so that $start+"1M" won't ever be bigger than $end
	# before it should be
	$start		= monthBegin($start);

	while($start <= $end){
		# if haven't written this year
		if((not $yearsWritn[$start->year]) and (($end->month-$start->month)>1)){
			# if year has more than one month on chart, display year above months
			if((getMonth($start->month) ne 'December') and (getMonth($end->month) ne 'January')){
				$self->_writeText(
					$start->year,
					$xval,
					12);
				$yearsWritn[$start->year] = 1;
			}
		}
		# write each month
		$self->_writeRectangle(
			$MONTHSIZE,
			getMonth($start->month),
			$xval,
			$yval);
		$self->_writeSwimLane($xval, $yval) if $self->skin->doSwimLanes();
		$start	+= "1M";
		$xval	+= $MONTHSIZE;
	}
}

##########################################################################
#
#	Method:	_writeHeaderHours()
#
#	Purpose: Draws a box for each hour between the beginning and end
#		of the chart, and optionally, a swimlane for each hour.
#
##########################################################################
sub _writeHeaderHours($self) {
	my $start	  = $self->startDate;
	my $end		  = $self->endDate;
	my @daysWritn = ();
	my $yval	  = $self->beginY;
	my $xval	  = $self->beginX;
	$start		  = hourBegin($start);

	while($start <= $end){
		print STDERR "_writeHeaderHours start=$start\n";
		print STDERR "_writeHeaderHours end=$end\n";
		# if day not already written
		if((not $daysWritn[$start->mday.$start->mon]) and (($end->hour-$start->hour)>5)){
			# if day has more than 6 hours on chart, list day of week
			if(($start->hour <= 18) and ($end->hour >= 6)){
				$self->_writeText(
					$start->fullday,
					$xval,
					12);
				$daysWritn[$start->mday.$start->mon] = 1;
			}
		}
		# write each hour
		$self->_writeRectangle(
			$DAYSIZE,
			$start->hour,
			$xval,
			$yval);
		$self->_writeSwimLane($xval, $yval) if $self->skin->doSwimLanes();
		$start	+= ONE_HOUR;
		$xval	+= $DAYSIZE;
	}
}

##########################################################################
#
#	Method:	_wrietRectangle(width, text, xval, yval)
#
#	Purpose: Method used by the _writeHeader* methods to paint the
#		square/rectangle representing each interval of time.
#
##########################################################################
sub _writeRectangle($self, $width, $text, $xval, $yval) {
	my $height	= 17;
	my $oxval	= $xval + $width;
	my $oyval	= $yval - $height;
	my $canvas	= $self->canvas;
	# draw box and inscribe text for a time unit above chart

	print STDERR "_writeRectangle $xval $yval $oxval $oyval\n";

	$canvas->box(
		color => $self->skin->secondaryFill,
		xmin  => $xval,
		ymin  => $yval,
		xmax  => $oxval,
		ymax  => $oyval
	) or print STDERR "ERROR: " . $canvas->errstr;

	$canvas->string(
		x      => $xval + 2,
		y      => $yval - 5,
		string => $text,
		font   => $self->skin->font,
		size   => 10,
		aa     => 1,
		color  => 'black'
	);
}

##########################################################################
#
#	Method:	_writeText(text, xval, yval)
#
#	Purpose: Method used to write month name/ year number/ day name
#		above calendar header.
#
##########################################################################
sub _writeText($self, $text, $xval, $yval) {
	print STDERR "_writeText $text, $xval, $yval\n";
	$self->canvas->string(
		x => $xval,
		y => $yval,
		string => $text,
		font => $self->skin->font,
		size => 10,
		aa => 1,
		color => $self->skin->primaryText,
	) or die "ERROR: " . $self->canvas->errstr;
}

##########################################################################
#
#	Method:	_writeTitle()
#
#	Purpose: Truncates the title if necesary and draws it to the
#		canvas.
#
##########################################################################
sub _writeTitle($self) {
	my $xval = 1;
	my $yval =  12;
	my $title = truncate($self->title,TITLE_SIZE);
	$self->_writeText($title, $xval, $yval);
}

##########################################################################
#
#	Method: _writeSwimLane(xval, yval)
#
#	Purpose: Draws a vertical line on the chart seperating the units
#		of time.
#
##########################################################################
sub _writeSwimLane($self, $xval, $yval) {
	my $canvas	= $self->canvas;
	my $endY	= $canvas->getheight - 3;
	# $canvas->Draw(
	# 	primitive	=>	'line',
	# 	stroke		=>	$self->{skin}->secondaryFill(),
	# 	points		=>	"${xval}, ".($yval+1)." ${xval}, $endY");
	$canvas->line(
		color =>$self->skin->secondaryFill,
		x1    => $xval,
		x2    => $xval,
		y1    => $yval+1,
		y2    => $endY,
		aa    => 1,
		endp  => 1
	);
}

1;
