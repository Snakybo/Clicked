#!/usr/bin/env bash
# Usage: lint-report.sh [diagnostics-file|-] [base-diagnostics-file]
#
# When a base diagnostics file is given, diagnostics are compared against it to report new and resolved ones.
# Set BASE_SHA to the commit the base diagnostics were generated from, to link to resolved diagnostics.

set -euo pipefail

input="${1:--}"
base_input="${2:-}"
summary="${GITHUB_STEP_SUMMARY:-/dev/stdout}"
repo_url="${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-Snakybo/Clicked}"
blob_url="$repo_url/blob/${GITHUB_SHA:-HEAD}"
base_sha="${BASE_SHA:-HEAD}"
base_blob_url="$repo_url/blob/$base_sha"
max_rows=500

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

tsv="$tmp/current.tsv"
base_tsv="$tmp/base.tsv"
new_tsv="$tmp/new.tsv"
resolved_tsv="$tmp/resolved.tsv"

parse() {
	sed -nE 's/^([^:]+):([0-9]+):([0-9]+): ([a-z]+)\[([^]]+)\] (.*)$/\1\t\2\t\3\t\4\t\5\t\6/p' "$1" \
		| sort -t $'\t' -k1,1 -k2,2n -k3,3n
}

parse "$input" > "$tsv"

has_base=false
if [[ -n "$base_input" && -f "$base_input" ]]; then
	has_base=true
	parse "$base_input" > "$base_tsv"

	# Match on file, severity, code, and message so shifted line numbers don't count as changes. Each base diagnostic
	# can only match a single current one, so duplicates are counted.
	: > "$new_tsv"
	awk -F '\t' -v new="$new_tsv" -v resolved="$resolved_tsv.unsorted" '
	{ key = $1 FS $4 FS $5 FS $6 }
	FILENAME == ARGV[1] { rows[key, ++base[key]] = $0; next }
	used[key] < base[key] { used[key]++; next }
	{ print > new }
	END {
		printf "" > resolved
		for (key in base) {
			for (i = used[key] + 1; i <= base[key]; i++) {
				print rows[key, i] > resolved
			}
		}
	}
	' "$base_tsv" "$tsv"
	sort -t $'\t' -k1,1 -k2,2n -k3,3n "$resolved_tsv.unsorted" > "$resolved_tsv"
fi

awk_lib='
function replace(s, from, to, out, i) {
	out = ""
	while ((i = index(s, from)) > 0) {
		out = out substr(s, 1, i - 1) to
		s = substr(s, i + length(from))
	}
	return out s
}
'

count() {
	awk -F '\t' -v sev="$2" '$4 ~ sev { n++ } END { print n + 0 }' "$1"
}

# Usage: table <tsv-file> <severity-regex> <blob-url> [show-severity]
table() {
	awk -F '\t' -v sev="$2" -v max="$max_rows" -v url="$3" -v show_sev="${4:-}" "$awk_lib"'
	function cell(s, parts, n, i, out) {
		n = split(s, parts, "`")
		out = ""
		for (i = 1; i <= n; i++) {
			if (i % 2 == 1) {
				parts[i] = replace(parts[i], "&", "&amp;")
				parts[i] = replace(parts[i], "<", "&lt;")
				parts[i] = replace(parts[i], ">", "&gt;")
			}
			out = out (i > 1 ? "`" : "") parts[i]
		}
		return replace(out, "|", "\\|")
	}
	BEGIN {
		if (show_sev) {
			print "| Severity | Location | Diagnostic | Message |"
			print "|----------|----------|------------|---------|"
		} else {
			print "| Location | Diagnostic | Message |"
			print "|----------|------------|---------|"
		}
	}
	$4 ~ sev {
		n++
		if (n <= max) {
			b = $4 == "error" ? "**" : ""
			if (show_sev) {
				printf "| %s%s%s ", b, $4, b
			}
			printf "| %s[%s:%s](%s/%s#L%s)%s | %s`%s`%s | %s%s%s |\n", b, $1, $2, url, $1, $2, b, b, $5, b, b, cell($6), b
		}
	}
	END {
		if (n > max) {
			printf "\n_...and %d more, see the job log._\n", n - max
		}
	}
	' "$1"
}

# Usage: delta <current> <base>
delta() {
	local d=$(($1 - $2))
	if [[ $d -gt 0 ]]; then
		echo "+$d"
	elif [[ $d -lt 0 ]]; then
		echo "$d"
	fi
}

# Only annotate new diagnostics when comparing, so the per-step annotation limit isn't spent on existing ones
annotate_tsv="$tsv"
if $has_base; then
	annotate_tsv="$new_tsv"
fi

awk -F '\t' "$awk_lib"'
function message(s) { return replace(replace(replace(s, "%", "%25"), "\r", "%0D"), "\n", "%0A") }
function property(s) { return replace(replace(message(s), ":", "%3A"), ",", "%2C") }
$4 == "error" || $4 == "warning" {
	printf "::%s file=%s,line=%s,col=%s,title=%s::%s\n", $4, property($1), $2, $3, property("wowlua-ls " $5), message($6)
}
' "$annotate_tsv"

errors=$(count "$tsv" '^error$')
warnings=$(count "$tsv" '^warning$')
hints=$(count "$tsv" '^hint$')

{
	if $has_base; then
		base_errors=$(count "$base_tsv" '^error$')
		base_warnings=$(count "$base_tsv" '^warning$')
		base_hints=$(count "$base_tsv" '^hint$')
		new=$(count "$new_tsv" '.')
		resolved=$(count "$resolved_tsv" '.')

		echo "Compared to [\`${base_sha:0:7}\`]($repo_url/commit/$base_sha)"
		echo
		echo "| Severity   | Count       | Change |"
		echo "| -----------|------------:|-------:|"
		echo "| **Errors** | **$errors** | $(delta "$errors" "$base_errors") |"
		echo "| Warnings   | $warnings   | $(delta "$warnings" "$base_warnings") |"
		echo "| Hints      | $hints      | $(delta "$hints" "$base_hints") |"
		echo

		if [[ $new -gt 0 ]]; then
			echo "### New ($new)"
			echo
			table "$new_tsv" '.' "$blob_url" true
			echo
		fi

		if [[ $resolved -gt 0 ]]; then
			echo "<details><summary>Resolved ($resolved)</summary>"
			echo
			table "$resolved_tsv" '.' "$base_blob_url" true
			echo
			echo "</details>"
			echo
		fi

		if [[ $((new + resolved)) -eq 0 ]]; then
			echo "No new or resolved diagnostics"
			echo
		fi
	elif [[ $((errors + warnings + hints)) -gt 0 ]]; then
		echo "| Severity   | Count       |"
		echo "| -----------|------------:|"
		echo "| **Errors** | **$errors** |"
		echo "| Warnings   | $warnings   |"
		echo "| Hints      | $hints      |"
		echo
	fi

	if [[ $((errors + warnings + hints)) -eq 0 ]]; then
		echo "No diagnostics"
		exit 0
	fi

	if [[ $((errors + warnings)) -gt 0 ]]; then
		echo "### Errors and warnings ($((errors + warnings)))"
		echo
		table "$tsv" '^(error|warning)$' "$blob_url"
		echo
	fi

	if [[ $hints -gt 0 ]]; then
		echo "<details><summary>Hints ($hints)</summary>"
		echo
		table "$tsv" '^hint$' "$blob_url"
		echo
		echo "</details>"
	fi
} >> "$summary"
