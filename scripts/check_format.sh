#!/usr/bin/env bash

readonly BASEDIR=$(readlink -f $(dirname $0))/..
cd $BASEDIR

# exit on errors
set -e

if ! hash nproc 2>/dev/null; then

function nproc() {
	echo 8
}

fi

function version_lt() {
	[ $( echo -e "$1\n$2" | sort -V | head -1 ) != "$1" ]
}

rc=0

echo -n "Checking file permissions..."

while read -r perm _res0 _res1 path; do
	if [ ! -f "$path" ]; then
		continue
	fi

	fname=$(basename -- "$path")

	case ${fname##*.} in
		c|h|cpp|cc|cxx|hh|hpp|md|html|js|json|svg|Doxyfile|yml|LICENSE|README|conf|in|Makefile|mk|gitignore|go|txt)
			# These file types should never be executable
			if [ "$perm" -eq 100755 ]; then
				echo "ERROR: $path is marked executable but is a code file."
				rc=1
			fi
		;;
		*)
			shebang=$(head -n 1 $path | cut -c1-3)

			# git only tracks the execute bit, so will only ever return 755 or 644 as the permission.
			if [ "$perm" -eq 100755 ]; then
				# If the file has execute permission, it should start with a shebang.
				if [ "$shebang" != "#!/" ]; then
					echo "ERROR: $path is marked executable but does not start with a shebang."
					rc=1
				fi
			else
				# If the file doesnot have execute permissions, it should not start with a shebang.
				if [ "$shebang" = "#!/" ]; then
					echo "ERROR: $path is not marked executable but starts with a shebang."
					rc=1
				fi
			fi
		;;
	esac

done <<< "$(git grep -I --name-only --untracked -e . | git ls-files -s)"

if [ $rc -eq 0 ]; then
	echo " OK"
fi

if hash astyle; then
	echo -n "Checking coding style..."
	if [ "$(astyle -V)" \< "Artistic Style Version 3" ]
	then
		echo -n " Your astyle version is too old so skipping coding style checks. Please update astyle to at least 3.0.1 version..."
	else
		rm -f astyle.log
		touch astyle.log
		# Exclude rte_vhost code imported from DPDK - we want to keep the original code
		#  as-is to enable ongoing work to synch with a generic upstream DPDK vhost library,
		#  rather than making diffs more complicated by a lot of changes to follow SPDK
		#  coding standards.
		git ls-files '*.[ch]' '*.cpp' '*.cc' '*.cxx' '*.hh' '*.hpp' | \
			grep -v rte_vhost | grep -v cpp_headers | \
			xargs -P$(nproc) -n10 astyle --options=.astylerc >> astyle.log
		if grep -q "^Formatted" astyle.log; then
			echo " errors detected"
			git diff
			sed -i -e 's/  / /g' astyle.log
			grep --color=auto "^Formatted.*" astyle.log
			echo "Incorrect code style detected in one or more files."
			echo "The files have been automatically formatted."
			echo "Remember to add the files to your commit."
			rc=1
		else
			echo " OK"
		fi
		rm -f astyle.log
	fi
else
	echo "You do not have astyle installed so your code style is not being checked!"
fi

GIT_VERSION=$( git --version | cut -d' ' -f3 )

if version_lt "1.9.5" "${GIT_VERSION}"; then
	# git <1.9.5 doesn't support pathspec magic exclude
	echo " Your git version is too old to perform all tests. Please update git to at least 1.9.5 version..."
	exit 0
fi

echo -n "Checking comment style..."

git grep --line-number -e '/[*][^ *-]' -- '*.[ch]' > comment.log || true
git grep --line-number -e '[^ ][*]/' -- '*.[ch]' ':!lib/rte_vhost*/*' >> comment.log || true
git grep --line-number -e '^[*]' -- '*.[ch]' >> comment.log || true
git grep --line-number -e '\s//' -- '*.[ch]' >> comment.log || true
git grep --line-number -e '^//' -- '*.[ch]' >> comment.log || true

if [ -s comment.log ]; then
	echo " Incorrect comment formatting detected"
	cat comment.log
	rc=1
else
	echo " OK"
fi
rm -f comment.log

echo -n "Checking for spaces before tabs..."
git grep --line-number $' \t' -- './*' ':!*.patch' > whitespace.log || true
if [ -s whitespace.log ]; then
	echo " Spaces before tabs detected"
	cat whitespace.log
	rc=1
else
	echo " OK"
fi
rm -f whitespace.log

echo -n "Checking trailing whitespace in output strings..."

git grep --line-number -e ' \\n"' -- '*.[ch]' > whitespace.log || true

if [ -s whitespace.log ]; then
	echo " Incorrect trailing whitespace detected"
	cat whitespace.log
	rc=1
else
	echo " OK"
fi
rm -f whitespace.log

echo -n "Checking for use of forbidden library functions..."

git grep --line-number -w '\(atoi\|atol\|atoll\|strncpy\|strcpy\|strcat\|sprintf\|vsprintf\)' -- './*.c' ':!lib/rte_vhost*/**' > badfunc.log || true
if [ -s badfunc.log ]; then
	echo " Forbidden library functions detected"
	cat badfunc.log
	rc=1
else
	echo " OK"
fi
rm -f badfunc.log

echo -n "Checking for use of forbidden CUnit macros..."

git grep --line-number -w 'CU_ASSERT_FATAL' -- 'test/*' ':!test/spdk_cunit.h' > badcunit.log || true
if [ -s badcunit.log ]; then
	echo " Forbidden CU_ASSERT_FATAL usage detected - use SPDK_CU_ASSERT_FATAL instead"
	cat badcunit.log
	rc=1
else
	echo " OK"
fi
rm -f badcunit.log

echo -n "Checking blank lines at end of file..."

if ! git grep -I -l -e . -z  './*' ':!*.patch' | \
	xargs -0 -P$(nproc) -n1 scripts/eofnl > eofnl.log; then
	echo " Incorrect end-of-file formatting detected"
	cat eofnl.log
	rc=1
else
	echo " OK"
fi
rm -f eofnl.log

echo -n "Checking for POSIX includes..."
git grep -I -i -f scripts/posix.txt -- './*' ':!include/spdk/stdinc.h' ':!include/linux/**' ':!lib/rte_vhost*/**' ':!scripts/posix.txt' ':!*.patch' > scripts/posix.log || true
if [ -s scripts/posix.log ]; then
	echo "POSIX includes detected. Please include spdk/stdinc.h instead."
	cat scripts/posix.log
	rc=1
else
	echo " OK"
fi
rm -f scripts/posix.log

echo -n "Checking #include style..."
git grep -I -i --line-number "#include <spdk/" -- '*.[ch]' > scripts/includes.log || true
if [ -s scripts/includes.log ]; then
	echo "Incorrect #include syntax. #includes of spdk/ files should use quotes."
	cat scripts/includes.log
	rc=1
else
	echo " OK"
fi
rm -f scripts/includes.log

if hash pycodestyle 2>/dev/null; then
	PEP8=pycodestyle
elif hash pep8 2>/dev/null; then
	PEP8=pep8
fi

if [ -n "${PEP8}" ]; then
	echo -n "Checking Python style..."

	PEP8_ARGS+=" --max-line-length=140"

	error=0
	git ls-files '*.py' | xargs -P$(nproc) -n1 $PEP8 $PEP8_ARGS > pep8.log || error=1
	if [ $error -ne 0 ]; then
		echo " Python formatting errors detected"
		cat pep8.log
		rc=1
	else
		echo " OK"
	fi
	rm -f pep8.log
else
	echo "You do not have pycodestyle or pep8 installed so your Python style is not being checked!"
fi

if hash shellcheck 2>/dev/null; then
	echo -n "Checking Bash style..."

	shellcheck_v=$(shellcheck --version | grep -P "version: [0-9\.]+" | cut -d " " -f2)

	# Exclude list currently holds all of reported errors. Errors will be fixed and list
	# reduced over time. If you find any new error which is not on the list and you think
	# that it should be excluded - please create a GitHub issue.
	# For more information about the topic and a list of human-friendly error descripions
	# go to: https://trello.com/c/29Z90j1W
	# Error descriptions can also be found at: https://github.com/koalaman/shellcheck/wiki
	SHCK_EXCLUDE="SC1001,SC1003,SC1004,SC1010,\
SC1083,SC1090,SC1091,SC1113,SC2001,SC2002,SC2003,SC2004,SC2005,\
SC2009,SC2010,SC2012,SC2013,SC2015,SC2016,SC2018,SC2019,SC2022,SC2026,\
SC2027,SC2030,SC2031,SC2034,SC2035,SC2039,SC2043,SC2044,SC2045,SC2046,SC2048,\
SC2059,SC2068,SC2074,SC2086,SC2088,SC2089,SC2090,SC2091,SC2094,\
SC2097,SC2098,SC2103,SC2115,SC2116,SC2119,SC2120,SC2121,SC2124,SC2126,SC2128,\
SC2129,SC2140,SC2142,SC2143,SC2145,SC2146,SC2148,SC2152,SC2153,SC2154,SC2155,\
SC2162,SC2164,SC2165,SC2166,SC2167,SC2174,SC2178,SC2181,SC2191,SC2192,SC2195,\
SC2199,SC2206,SC2207,SC2214,SC2223,SC2230,SC2231,SC2235"
	# SPDK fails some error checks which have been deprecated in later versions of shellcheck.
	# We will not try to fix these error checks, but instead just leave the error types here
	# so that we can still run with older versions of shellcheck.
	SHCK_EXCLUDE="$SHCK_EXCLUDE,SC1117"

	SHCK_FORMAT="diff"
	SHCK_APPLY=true
	if [ "$shellcheck_v" \< "0.7.0" ]; then
		SHCK_FORMAT="tty"
		SHCK_APPLY=false
	fi
	SHCH_ARGS=" -e $SHCK_EXCLUDE -f $SHCK_FORMAT"

	error=0
	git ls-files '*.sh' | xargs -P$(nproc) -n1 shellcheck $SHCH_ARGS &> shellcheck.log || error=1
	if [ $error -ne 0 ]; then
		echo " Bash formatting errors detected!"

		# Some errors are not auto-fixable. Fall back to tty output.
		if grep -q "Use another format to see them." shellcheck.log; then
			SHCK_FORMAT="tty"
			SHCK_APPLY=false
			SHCH_ARGS=" -e $SHCK_EXCLUDE -f $SHCK_FORMAT"
			git ls-files '*.sh' | xargs -P$(nproc) -n1 shellcheck $SHCH_ARGS > shellcheck.log || error=1
		fi

		cat shellcheck.log
		if $SHCK_APPLY; then
			git apply shellcheck.log
			echo "Bash errors were automatically corrected."
			echo "Please remember to add the changes to your commit."
		fi
		rc=1
	else
		echo " OK"
	fi
	rm -f shellcheck.log
else
	echo "You do not have shellcheck installed so your Bash style is not being checked!"
fi

# Check if any of the public interfaces were modified by this patch.
# Warn the user to consider updating the changelog any changes
# are detected.
echo -n "Checking whether CHANGELOG.md should be updated..."
staged=$(git diff --name-only --cached .)
working=$(git status -s --porcelain --ignore-submodules | grep -iv "??" | awk '{print $2}')
files="$staged $working"
if [[ "$files" = " " ]]; then
	files=$(git diff-tree --no-commit-id --name-only -r HEAD)
fi

has_changelog=0
for f in $files; do
	if [[ $f == CHANGELOG.md ]]; then
		# The user has a changelog entry, so exit.
		has_changelog=1
		break
	fi
done

needs_changelog=0
if [ $has_changelog -eq 0 ]; then
	for f in $files; do
		if [[ $f == include/spdk/* ]] || [[ $f == scripts/rpc.py ]] || [[ $f == etc/* ]]; then
			echo ""
			echo -n "$f was modified. Consider updating CHANGELOG.md."
			needs_changelog=1
		fi
	done
fi

if [ $needs_changelog -eq 0 ]; then
	echo " OK"
else
	echo ""
fi

exit $rc
