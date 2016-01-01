# crack-pipe

crack-pipe.sh
This script automates three non-optimized brute-forcing commands for cracking a file of hashes with oclHashcat. It can run all rules in a directory against all wordlist in another, all rules in a directory against a single wordlist in another, or simply all worldlists in a directory with no rules specified. It also uses the oclHashcat switches 'remove', 'session', and file output format 3. The script also comes with a CSV file of hashtypes from 'http://hashcat.net/wiki/doku.php?id=example_hashes' as a convenience for looking up hashtypes. Some common hashtypes are may be set from the command line via keyword.

hashtypes.csv
A CSV file, for CLI searching, from the table of hashtypes at: http://hashcat.net/wiki/doku.php?id=example_hashes
