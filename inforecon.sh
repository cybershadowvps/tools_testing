#!/bin/bash

# Initialize variables
domain=""
domain_list=""
api_key="982680b1787fa59701919aa22515a025e00df1e3bb2bc4f186b8e919558d576c"

# Display usage information
usage() {
    echo "Usage: $0 [-u <domain>] [-d <domain_list.txt>] [-h]"
    echo "  -u <domain>         Perform recon on a single domain"
    echo "  -d <domain_list.txt> Perform recon on multiple domains from a file"
    echo "  -h                  Display this help message"
    exit 0
}

# Parse command-line arguments
while getopts "u:d:h" opt; do
  case ${opt} in
    u ) domain=$OPTARG ;;
    d ) domain_list=$OPTARG ;;
    h ) usage ;;
    * ) usage ;;
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
