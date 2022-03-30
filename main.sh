#!/bin/sh

set -e
set -o pipefail

ver="v0.5"
printf "using version: $ver"

cd $GITHUB_WORKSPACE

# This script should always run as if it were being called from
# the directory it lives in.
script_directory="$(perl -e 'use File::Basename;
  use Cwd "abs_path";
  print dirname(abs_path(@ARGV[0]));' -- "$0")"

printf "running from: $script_directory"
echo $INPUT_CHECK_TYPE >> check_type.txt

if [ "${INPUT_CHECK_TYPE}" == "spelling" ];then
  error_name='Spelling errors'
  report_path='resources/spell_check_results.tsv'
elif [ "${INPUT_CHECK_TYPE}" == "urls" ];then
  error_name='Broken URLs'
  report_path='resources/url_checks.tsv'
elif [ "${INPUT_CHECK_TYPE}" == "quiz_format" ];then
  error_name='Quiz format errors'
  report_path='question_error_report.tsv'
fi

# Copy the scripts from this version
curl -o $script_directory/check_type.R https://raw.githubusercontent.com/jhudsl/ottr-reports/v0.6/scripts/check_type.R
curl -o $script_directory/spell-check.R https://raw.githubusercontent.com/jhudsl/ottr-reports/v0.6/scripts/spell-check.R
curl -o $script_directory/url-check.R https://raw.githubusercontent.com/jhudsl/ottr-reports/v0.6/scripts/url-check.R
curl -o $script_directory/quiz-check.R https://raw.githubusercontent.com/jhudsl/ottr-reports/v0.6/scripts/quiz-check.R

# Run the check
chk_results=$(Rscript $script_directory/check_type.R)

# Print out the output
printf $error_name
printf $report_path
printf $chk_results

rm -rf $script_directory/ottr_report_scripts

# Save output
echo ::set-output name=error_name::$error_name
echo ::set-output name=report_path::$report_path
echo ::set-output chk_results=$chk_results
