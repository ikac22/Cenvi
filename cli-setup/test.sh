T="a,b,c,d,e"
A=(${T//,/ })
echo "$A"
for k in ${A[@]}; do
	echo $k
done
