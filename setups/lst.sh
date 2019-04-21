
echo "" >> ~/.bash_profile
echo "# LST:" >> ~/.bash_profile
echo "lst()" >> ~/.bash_profile
echo "{" >> ~/.bash_profile
echo "	ls -R \$1 | grep \":$\" | sed -e  's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'" >> ~/.bash_profile
echo "}" >> ~/.bash_profile