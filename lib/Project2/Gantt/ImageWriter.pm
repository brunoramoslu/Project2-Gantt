##########################################################################
#
#	File:	Project/Gantt/ImageWriter.pm
#
#	Author:	Alexander Westholm
#
#	Purpose: The ImageWriter object coordinates the visualization
#		of scheduling data. It creates the canvas, and all
#		supporting objects that write different aspects of the
#		chart to the screen.
#
#	Client:	CPAN
#
#	CVS: $Id: ImageWriter.pm,v 1.14 2004/08/03 17:56:52 awestholm Exp $
#
##########################################################################
package Project2::Gantt::ImageWriter;

use Mojo::Base -base,-signatures;

use Imager;
use Project2::Gantt::DateUtils qw[:round :lookup];
use Project2::Gantt::Globals;
use Project2::Gantt::GanttHeader;
use Project2::Gantt::TimeSpan;
use Project2::Gantt::SpanInfo;

##########################################################################
#
#	Method:	new(%opts)
#
#	Purpose: Constructor. Takes as parameters the mode of drawing
#		(hours, days, or months), the root Project::Gantt object,
#		and the skin in use.
#
##########################################################################
sub new {
	my $cls	= shift;
	my %opts= @_;
	if(not $opts{root}){
		die "Must supply root node to ImageWriter!";
	}
	$opts{mode} = 'days' if not $opts{mode};
	my $me 	= bless \%opts, $cls;
	$me->_getCanvas();
	return $me;
}

##########################################################################
#
#	Method:	_getCanvas()
#
#	Purpose: This method examines the root node, and sets the width
#		of the canvas based on the timespan covered by the chart,
#		and sets the height based on how many schedule items
#		constitute the chart.
#
##########################################################################
sub _getCanvas {
	my $me = shift;
	my $skin = $me->{skin};
	my ($height, $width) = (0,0);
	$height = 40;
	# add height for each row
	$height += 20 for (1..$me->{root}->getNodeCount());
	$width	= 205;
	my $incr = $DAYSIZE;
	$incr = $MONTHSIZE if($me->{mode} eq 'months');
	# add width for each time unit
	$width += $incr for (1..$me->{root}->timeSpan());

	my $canvas = Imager->new(xsize=>$width,ysize=>$height);
	$canvas->box(filled => 1, color => $skin->background);
	#$canvas->Read('xc:'.$me->{skin}->background());
	$me->{canvas} = $canvas;
}

##########################################################################
#
#	Method:	display(filename)
#
#	Purpose: Creates the Calendar header and draws it, then calls
#		writeBars to draw in all tasks/subprojects. Finally,
#		writes the image to a file.
#
##########################################################################
sub display {
	my $me	= shift;
	my $img	= shift;
	my $hdr	= Project2::Gantt::GanttHeader->new(
		canvas	=>	$me->{canvas},
		skin	=>	$me->{skin},
		root	=>	$me->{root});
	$hdr->display($me->{mode});

    # PW added parameters, required by new writeBars with recursive support
    $me->writeBars($me->{'root'}, 40);  
	$me->{canvas}->write(file=>$img) or die $me->{canvas}->errstr;
}

##########################################################################
#
#	Method:	writeBars()
#
#	Purpose: Iterates over all tasks/subprojects contained by the root
#		object, and creates SpanInfo and TimeSpan objects for each
#		item, then draws them.
#       
#       Peter Weatherdon: Jan 19, 2005
#           Modified this method to allow recursion for support of nested
#           projects (more than 1 level deep)
#
##########################################################################
sub writeBars {
	my $me		= shift;
    my $project = shift;
    my $height  = shift;
	my $stDate	= $me->{root}->getStartDate();
    my @tasks   = $project->getTasks();
    my @projs   = $project->getSubProjs();

	# write tasks before sub-projects.. adjust height as we go
	for my $tsk (@tasks,@projs){
		my $info= Project2::Gantt::SpanInfo->new(
			canvas	=>	$me->{canvas},
			skin	=>	$me->{skin},
			task	=>	$tsk);
		$info->display($height);
		my $bar	= Project2::Gantt::TimeSpan->new(
			canvas	=>	$me->{canvas},
			skin	=>	$me->{skin},
			task	=>	$tsk,
			rootStr	=>	$stDate);
		$bar->display($me->{mode},$height);
		$height	+= 20;

        # if the task is a sub-project then draw recursively
		if($tsk->isa("Project2::Gantt")){
            $me->writeBars ($tsk, $height);
		}
	}
}


1;
