##########################################################################
#
#	File:	Project/Gantt/TimeSpan.pm
#
#	Author:	Alexander Westholm
#
#	Purpose: This class is a visual representation of a timespan on
#		a Gantt chart. It is used to display both sub-projects,
#		and the tasks they contain. 
#
#	Client:	CPAN
#
#	CVS: $Id: TimeSpan.pm,v 1.4 2004/08/03 17:56:52 awestholm Exp $
#
##########################################################################
package Project2::Gantt::TimeSpan;
use strict;
use warnings;
use Mojo::Base -base,-signatures;
use Project2::Gantt::Globals;

has task    => undef;
has canvas  => undef;
has skin    => undef;
has beginX  => 205;
has rootStr => undef;

sub new {
	my $self = shift->SUPER::new(@_);
	die "Must provide proper args to TimeSpan!" if not defined $self->task or not defined $self->rootStr;
	return $self;
}

##########################################################################
#
#	Method:	Display(mode, height)
#
#	Purpose: Calls _writeBar passing its parameters along. Simply a
#		placeholder at this point, but exists incase some
#		preprocessing is necessary at a later date.
#
##########################################################################
sub display($self, $mode, $height) {
	$self->_writeBar($mode, $height);
}

##########################################################################
#
#	Method:	_writeBar(mode, height)
#
#	Purpose: This method calculates the distance from the beginning of
#		the graph at which to begin drawing this TimeSpan, as well
#		as how many pixels in width it should be. It then calls
#		either _drawSubProj or _drawTask depending on whether
#		the task object passed to the constructor is a
#		Project::Gantt instance or a Project::Gantt::Task
#		instance.
#
##########################################################################
sub _writeBar($self, $mode, $height) {
	my $task      = $self->task;
	my $rootStart = $self->rootStr;
	my $taskStart = $task->startDate;
	my $taskEnd   = $task->endDate;
	my $startX    = $self->beginX;
	my $dif       = $taskStart-$rootStart;

	# calculate starting X coordinate based on number of units away from start it is
	if($mode eq 'hours'){
		$startX += $dif->hours * $DAYSIZE;
		$startX += (($rootStart->min / 59) * $DAYSIZE);
	}elsif($mode eq 'months'){
		$startX	+= $self->_getMonthPixels($rootStart->month_begin, $taskStart);
	}else{
		$startX += $dif->days * $DAYSIZE;
		$startX += (($rootStart->hour / 23) * $DAYSIZE);
	}
	my $endX	= $startX;
	my $edif	= $taskEnd-$taskStart;
	# range variable indicates whether or not space filled by this bar is less than 15 pixels or not
	# this is because 15 pixels are required for the diamond shape... if less than, a rectangle
	# is used
	my $range	= 0;

	# calculate ending X coordinate based on number of units within this bar
	if($mode eq 'hours'){
		$endX	+= $edif->hours * $DAYSIZE;
		$range	= $edif->hours;
	}elsif($mode eq 'months'){
		my $tmp	= $self->_getMonthPixels($taskStart, $taskEnd);
		$endX	+= $tmp;
		$range	= $tmp / $DAYSIZE;
	}else{
		$endX	+= $edif->days * $DAYSIZE;
		$range	= $edif->days;
	}
	if($startX == $endX){
		die "Incorrect date range!";
	}
	
	$self->_drawSubProj($startX, $height, $endX, $range) if $task->isa("Project2::Gantt");
	$self->_drawTask($startX, $height, $endX, $range, $task->color) if $task->isa("Project2::Gantt::Task");
}

##########################################################################
#
#	Method:	_getMonthPixels(start, end)
#
#	Purpose: Given the start and end of a TimeSpan, as passed in, this
#		method approximately calculates the number of pixels
#		that it should take up on the Gantt chart. There are some
#		minor errors occasionally, as this calculation is based on
#		the number of seconds in the task divided by the number of
#		seconds in the year. Since not every month has the same
#		number of seconds, minor miscalculations will occur.
#
##########################################################################
sub _getMonthPixels($self, $birth, $death) {
	my $pixelsPerYr	= 12 * 60;
	my $secsInYear	= (((60*60)*24)*365);
	my $secsInSpan	= ($death - $birth)->sec;
	my $percentage	= $secsInSpan / $secsInYear;
	return $percentage * $pixelsPerYr;
}

##########################################################################
#
#	Method:	_drawTask(startX, startY, endX, range)
#
#	Purpose: Given the starting coordinates, and ending X coordinate
#		of a TimeSpan, uses Image::Magick to draw the span on the
#		chart using whatever Skin scheme is in effect. Range is
#		an indication of whether the span takes up more than
#		15 pixels or not. If so, the span is drawn as a diamond,
#		if not, as a rectangle.
#
##########################################################################
sub _drawTask($self, $startX, $startY, $endX, $range, $color = undef) {

	$color = $self->{skin}->itemFill if not defined $color;

	print STDERR "_drawTask $startX, $startY, $endX, $range, $color\n";

	my $canvas	= $self->{canvas};
	my $leadY	= $startY + 8.5;
	my $bottom	= $startY + 13.5;
	$startY		+= 3.5;
	my $leadX	= $startX + 7.5;
	my $trailX	= $endX - 7.5;
	# if has space for full diamond
	if($range >= 1){
		# $canvas->Draw(
		# 	fill		=>	$me->{skin}->itemFill(),
		# 	stroke		=>	$me->{skin}->itemFill(),
		# 	primitive	=>	'polygon',
		# 	points		=>	"${startX}, $leadY ${leadX}, $bottom ${leadX}, $startY");
		print STDERR "_drawTask polygon 1 [$startX,$leadX],[$leadX,$bottom],[$leadX,$startY]\n";
		$canvas->polygon(
			points =>[[$startX,$leadY],[$leadX,$bottom],[$leadX,$startY]],
			fill => { solid=> $color, combine => 'normal'});
		# $canvas->Draw(
		# 	fill		=>	$me->{skin}->itemFill(),
		# 	stroke		=>	$me->{skin}->itemFill(),
		# 	primitive	=>	'polygon',
		# 	points		=>	"${trailX}, $bottom ${trailX}, $startY ${endX}, $leadY");
		print STDERR "_drawTask polygon 2 [$trailX,$bottom],[$trailX,$startY],[$endX,$leadY]\n";

		$canvas->polygon(
			points =>[[$trailX,$bottom],[$trailX,$startY],[$endX,$leadY]],
			fill => { solid => $color, combine => 'normal' }
		);
		# if space between diamond edges, fill in
		if($leadX != $trailX){
			# $canvas->Draw(
			# 	fill		=>	$me->{skin}->itemFill(),
			# 	stroke		=>	$me->{skin}->itemFill(),
			# 	primitive	=>	'rectangle',
			# 	points		=>	"${leadX}, $startY ${trailX}, $bottom");
			$canvas->box(
				color  => $color,
				xmin   => $leadX,
				ymin   => $startY,
				xmax   => $trailX,
				ymax   => $bottom,
				filled => 1
			);
		}
	# not enough space for full diamond, use rectangle
	}else{
		# $canvas->Draw(
		# 	fill		=>	$me->{skin}->itemFill(),
		# 	stroke		=>	$me->{skin}->itemFill(),
		# 	primitive	=>	'rectangle',
		# 	points		=>	"${startX}, $startY ${endX}, $bottom");
		$canvas->box(
			color  => $color,
			xmin   => $startX,
			ymin   => $startY,
			xmax   => $endX,
			ymax   => $bottom,
			filled => 1
		);
	}
}

##########################################################################
#
#	Method:	_drawSubProj(startX, startY, endX, range)
#
#	Purpose: Same as above, except draws a bracket instead of a
#		diamond, indicating a containment relationship.
#
##########################################################################
sub _drawSubProj($self, $startX, $startY, $endX, $range) {
	my $canvas   = $self->{canvas};
	my $edgeTop  = $startY + 7;
	my $edgeBot  = $startY + 17;
	my $innerBot = $startY + 10;
	my $polyX    = $startX + 7.5;
	my $endPolyX = $endX   - 7.5;

	say STDERR "_drawSubProj";

	#if enough space for full bracket
	if($range >= 1){
		# $canvas->Draw(
		# 	fill		=>	$self->{skin}->containerFill(),
		# 	stroke		=>	$self->{skin}->containerStroke(),
		# 	primitive	=>	'polygon',
		# 	points		=>	"${startX}, $edgeBot ${startX}, $edgeTop ${polyX}, $startY ${polyX}, $innerBot");
		print STDERR "_drawSubProj polygon 1 [$startX,$edgeBot],[$startX,$edgeTop],[$polyX,$startY],[$polyX,$innerBot]\n";
		$canvas->polygon(
			points =>[[$startX,$edgeBot],[$startX,$edgeTop],[$polyX,$startY],[$polyX,$innerBot]],
			color => 'grey',
			fill => { solid=>'grey', combine => 'normal'});
		# $canvas->Draw(
		# 	fill		=>	$self->{skin}->containerFill(),
		# 	stroke		=>	$self->{skin}->containerStroke(),
		# 	primitive	=>	'polygon',
		# 	points		=>	"${endPolyX}, $innerBot ${endPolyX}, $startY ${endX}, $edgeTop ${endX}, $edgeBot");
		print STDERR "_drawSubProj polygon 2 [$endPolyX,$innerBot],[$endPolyX,$startY],[$endX,$edgeTop],[$endX,$edgeBot]\n";
		$canvas->polygon(
			points =>[[$endPolyX,$innerBot],[$endPolyX,$startY],[$endX,$edgeTop],[$endX,$edgeBot]],
			color => 'red',
			fill => { solid=>'grey', combine => 'normal'});
		# if space between bracket ends, fill in
		if($polyX != $endPolyX){
			# $canvas->Draw(
			# 	fill		=>	$self->{skin}->containerFill(),
			# 	stroke		=>	$self->{skin}->containerStroke(),
			# 	primitive	=>	'rectangle',
			# 	points		=>	"${polyX}, $startY ${endPolyX}, $innerBot");
			$canvas->box(
				color  => 'grey',
				xmin   => $polyX,
				ymin   => $startY,
				xmax   => $endPolyX,
				ymax   => $innerBot,
				filled => 1,
			);
		}
	# not enough space for full bracket, use rectangle
	}else{
		# $canvas->Draw(
		# 	fill		=>	$self->{skin}->containerFill(),
		# 	stroke		=>	$self->{skin}->containerStroke(),
		# 	primitive	=>	'rectangle',
		# 	points		=>	"${startX}, $startY ${endX}, $edgeBot");
		$canvas->box(
			color => 'red',
			xmin =>$startX,
			ymin =>$startY,
			xmax =>$endX,
			ymax =>$edgeBot
		);
	}
}

1;
