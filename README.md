# TOP DOMAINS

## About 
The repo caontains the top ranked top level domains (TLD) and websites tracked via [Cisco's Umbrella Popularity List](https://s3-us-west-1.amazonaws.com/umbrella-static/index.html). Potential future enhancements may include additional source of records for merging (ex: Alexa 1Million).

The repo's goal is to provide a simple, static comma separate files available for easy ingestion and use.

## Usage
The files can be downloaded directly via the directory top-recs in the repo, or can generated locally via running of the script.

If you choose to run the script yourself, locally, the following commands will execute it:

```bash
# Downloads and splits records accordingly
wget -qO- https://gitlab.com/cjbarker/top-domains/raw/master/create-lists.sh | sh

# Available files separated by TLD and websites
# Format <rank>,<value>
ls top-recs/
top-TLD-100.csv       top-TLD-5828.csv      top-sites-1000.csv    top-sites-100000.csv
top-TLD-1000.csv      top-sites-100.csv     top-sites-10000.csv   top-sites-1000000.csv

# Example Output of ranked Top Level Domains (TLD) 
head top-recs/top-TLD-100.csv
1,com
2,net
3,org
4,googleapis.com
5,io
6,co
7,s3.amazonaws.com
8,tv
9,elb.amazonaws.com
10,goog

# Example Output of ranked Top Websites 
head top-recs/top-sites-100.csv
1,google.com
2,netflix.com
3,api-global.netflix.com
4,www.google.com
5,microsoft.com
6,facebook.com
7,doubleclick.net
8,g.doubleclick.net
9,google-analytics.com
10,googleads.g.doubleclick.net
```
