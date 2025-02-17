#!/bin/bash

# Initialize variables
domain=""
domain_list=""
api_key="0221c8a3e655673bbc49d7fe876d3645f5a2dad2c3c1fe3cd2fad5e1ee1bf5f9"

# Parse command-line arguments
while getopts "u:d:" opt; do
  case ${opt} in
    u ) domain=$OPTARG ;;
    d ) domain_list=$OPTARG ;;
    * ) echo "Usage: $0 -u <domain> OR -d <domain_list.txt>"; exit 1 ;;
  esac
done

# Create output directory
mkdir -p recon_results

# Function to process a single domain
process_domain() {
    local domain=$1
    echo "Processing domain: $domain"
    output_file="recon_results/${domain}_out.txt"

    # Fetch Wayback Machine data
    echo "Fetching Wayback Machine URLs for $domain..."
    curl -sG "https://web.archive.org/cdx/search/cdx" \
        --data-urlencode "url=*.$domain/*" \
        --data-urlencode "collapse=urlkey" \
        --data-urlencode "output=text" \
        --data-urlencode "fl=original" > "$output_file"

    echo "Filtering sensitive file types..."
    cat "$output_file" | sort -u | grep -E '\\.xls|\\.xml|\\.xlsx|\\.json|\\.pdf|\\.sql|\\.doc|\\.docx|\\.pptx|\\.txt|\\.zip|\\.tar\\.gz|\\.tgz|\\.bak|\\.7z|\\.rar|\\.log|\\.cache|\\.secret|\\.db|\\.backup|\\.yml|\\.gz|\\.config|\\.csv|\\.yaml|\\.md|\\.md5|\\.exe|\\.dll|\\.bin|\\.ini|\\.bat|\\.sh|\\.tar|\\.deb|\\.rpm|\\.iso|\\.img|\\.apk|\\.msi|\\.dmg|\\.tmp|\\.crt|\\.pem|\\.key|\\.pub|\\.asc' > "recon_results/${domain}_sensitive_files.txt"

    echo "Fetching VirusTotal domain report for $domain..."
    curl -s "https://www.virustotal.com/vtapi/v2/domain/report?apikey=$api_key&domain=$domain" > "recon_results/${domain}_virustotal_report.json"

    echo "Fetching AlienVault OTX data for $domain..."
    curl -s "https://otx.alienvault.com/api/v1/indicators/hostname/$domain/url_list?limit=500&page=1" > "recon_results/${domain}_alienvault_urls.json"
}

# Process a single domain if provided
if [ -n "$domain" ]; then
    process_domain "$domain"
fi

# Process multiple domains from a file if provided
if [ -n "$domain_list" ]; then
    while IFS= read -r line; do
        process_domain "$line"
    done < "$domain_list"
fi

echo "Recon complete. Results saved in the 'recon_results' directory."
