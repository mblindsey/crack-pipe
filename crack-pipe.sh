#!/bin/bash
#
###############################################################################
#
# Name:  crackPipe.sh
# Authors: Michael Lindsey, Matt Burch
# Date: 10/31/2015
# Version: ALPHA V1.1
# Description: This script automates three non-optimized brute-forcing commands
# for cracking a file of hashes with oclHashcat.  It can run all rules in a 
# directory against all wordlist in another, all rules in a directory against
# a single wordlist in another, or simply all worldlists in a directory with no
# rules specified.  It also uses the oclHashcat switches 'remove', 'session',
# and file output format 3. The script comes with a CSV file of hashtypes
# from 'http://hashcat.net/wiki/doku.php?id=example_hashes' as a convenience
# for looking up hashtypes.  Some common hashtypes are may be set from the 
# command line via keyword.
#
###############################################################################

# Just hit the wordlists, no rules.  Try this first.
do_wordlists ()
{
echo "do_wordlists"
 for WORDLIST in $(find ${WORDLISTDIR} -type f)
 do
    ${OCL} --session ${SESSION} -m ${HASHTYPE} -o ${CRACKED} --outfile-format=3 ${USERNAME} --remove ${HASH_IN} ${WORDLIST}
 done
}

# Run specific directory of rules on a single user specified wordlist
do_rulesonwords ()
{
echo "do_rulesonwords"
echo ${WORDLIST}
 for RULE in $(find ${RULEDIR} -type f)
 do
    ${OCL} --session ${SESSION} -m ${HASHTYPE} -o ${CRACKED} --outfile-format=3 ${USERNAME} --remove ${HASH_IN} -r ${RULE} ${WORDLIST}
 done
}

# Hammer crack. Apply all rules to all worlists.  Takes a long time.
do_allrules_allwords ()
{
echo "do_allrules_allwords"
 for WORDLIST in $(find ${WORDLISTDIR} -type f)
 do
    for RULE in $(find ${RULEDIR} -type f)
    do
       ${OCL} --session ${SESSION} -m ${HASHTYPE} -o ${CRACKED} --outfile-format=3 ${USERNAME} --remove ${HASH_IN} -r ${RULE} ${WORDLIST}
    done
done
}

# Usage Function
usage() {
  echo "Usage: $0 [-w|-a] [-r wordlist ] [-s session_name] [-m hashtype|ntlmv1|ntlmv2|ipmi] [-i inputfile] [-o outputfile]"
  echo "This script requires wordlist and rules directories set as vars.  Change them as required."
  echo "Srcipt requires:
	-w : Runs wordlists in a directory only.
	-r : Runs rules in a directory agains a single wordlist. Provide path the wordlist.
	-a : Runs all rules in a directory against all wordlists in directory. No args.
	-s : A distinctive name for the oclHashcat session.  
	-m : The hash type for oclHashcat to crack.  Needs Arg. A number or one of the following convenience args:
             'ntlmv1','ntlmv2','ipmi'. 
	-i : Input filename of hashes to be cracked. 
	-o : Output filename for results.
         "
  exit 1
}


##### Variables

RETVAL=0
# Path to oclHashcat
OCL=<set>
# Path to wordlist directory
WORDLISTDIR=<set>
# Path to rules directory
RULEDIR=<set>
# Input hash file 
HASH_IN=
# Output file 
CRACKED= 
# OCL Session Name. Getting some ranoom number to append
SESSION=
# The oclHashcat hastype
HASHTYPE=
# The '--username' oclhashcat arg to ignore usernames in a file. Used for 'ipmi' cracking.
USERNAME=
WORDS="false"
WORDLISTS=
RULES="false"
ALL="false"

##### Main

if [ $# -lt 1 ]; then
    echo "I don't have anything to do!" > /dev/stderr
    usage
fi

while getopts “hwar:m:s:i:o:” OPT
do
     case $OPT in
         h)
             usage
             exit 1
             ;;
         w)
             WORDS="true"
            ;; 
         r)
             RULES="true"
             WORDLIST="${OPTARG}"
             ;;
         a)
             ALL="true"
             ;;
	 s)
	     #add some dumb random digits to the end of the session name
	     SESSION=oclSession.${OPTARG}.`head -200 /dev/urandom |cksum | cut -f2 -d" "`
	     ;;
         m)
             if [ ${OPTARG} == "ntlmv1" ]
	     then
               HASHTYPE=5500
	     elif [ ${OPTARG} == "ntlmv2" ]
	     then
               HASHTYPE=5600
             elif [ ${OPTARG} == "ipmi" ]
             then
               HASHTYPE=7300
               # The '--username' oclhashcat arg to ignore usernames in a file. Used for 'ipmi' cracking.
               USERNAME="--username"

	     else  
               HASHTYPE=${OPTARG}
	     fi
             ;;
         i)
             HASH_IN=${OPTARG}
             ;;
         o)
             CRACKED=${OPTARG}
             ;;
         ?) 
	     usage
             exit
             ;;
     esac
done

if [[ -z ${HASHTYPE} ]] || [[ -z ${HASH_IN} ]] || [[ -z ${CRACKED} ]]
then
     usage
     exit 1
fi

if [ "${WORDS}" == "true" ]; then
  do_wordlists
fi

if [ "${RULES}" == "true" ]; then
  do_rulesonwords
fi

if [ "${ALL}" == "true" ]; then
  do_allrules_allwords
fi

exit $RETVAL
