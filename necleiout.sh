
while true;
do nuclei -l httpsub.txt -severity medium | anew fuzzresultnuclei9.txt | notify -pc ./config.yaml;
sleep 3600;
done
