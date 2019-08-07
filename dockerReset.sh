# set -e && set -o pipefail && cd `pwd`

osascript -e 'quit app "Docker"'
open -a Docker
# while [ -z "$(docker info 2> /dev/null )" ]; 
# while [ $? -ne 0 ]
until docker info > /dev/null 2>&1
do
	printf "."; 
	sleep 1; 
done;

echo "Done!"