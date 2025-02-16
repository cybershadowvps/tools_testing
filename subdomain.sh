while true;
do subfinder -silent -dL domains.txt -all | anew subdomains2.txt | notify -pc ./config.yaml;
sleep 10800;
done
