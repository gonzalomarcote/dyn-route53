# dyn-route53
Route53 dynamic dns script

Author: Gonzalo Marcote - gonzalomarcote_at_gmail.com

License: GNU General Public License V3.0

Disclaimer: For my own use. Use on your own (GNU GPL License).

### Sscript to configure you home our office dynamic IP in one AWS Route53 domain

#### Usage
Required packages: awscli, jq, moreutils

Configure your aws account with `aws configure`

Create one dynroute53.json file like specified in the script. First IP value can be whatever.

Just edit it and fill the following variables:

	record -> your hosted zone or record. Last dot is important
	zoneId -> your AWS Hosted zone Id
	mail -> your email if you want notifications when IP has changed. Require one mail server configured
	json -> the path where you have your json file

Run it with one cronjob every 5 minutes for example:
	`*/5 * * * * /usr/local/bin/dynroute53`
