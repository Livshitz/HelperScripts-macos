sudo spindump -notarget 5  -timelimit 60 -stdout -noFile  -noProcessingWhileSampling   -aggregateStacksByProcess | grep -B 15 "Unresponsive for" | perl -n -e'/Process:.*\[(\d+)\]/ && print "$1\n"'

# then pipe on results like that: " | xargs kill -9"