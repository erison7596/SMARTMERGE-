#!/usr/bin/env bash
# -----------------------------------------------------------------------------------
# smartmerge.sh – Linguagem-aware textual merge (C#, Go) com indentação final
# -----------------------------------------------------------------------------------
# Uso:
#   smartmerge.sh --csharp BASE LEFT RIGHT   # para arquivos .cs
#   smartmerge.sh --go     BASE LEFT RIGHT   # para arquivos .go
#
# Saída: merge de BASE, LEFT e RIGHT (stdout), sem marcadores internos de token,
#        sem sequências de linhas em branco repetidas, e com:
#         • cada declaração ou instrução reconstruída em sua própria linha;
#         • indentação de 4 espaços por nível de chaves (“{” / “}”).
#
# Requisitos:
#   • bash 4+
#   • diff3 (GNU diffutils)
#   • awk, sed, mktemp
# -----------------------------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

MARK=">>>>SMARTMERGE_SEP_MARK<<<<<"

print_usage() {
  echo "Usage: $0 --csharp|--go BASE LEFT RIGHT" >&2
  exit 1
}

[[ $# -ne 4 ]] && print_usage

LANG_FLAG=$1; shift
BASE_FILE=$1; LEFT_FILE=$2; RIGHT_FILE=$3

if [[ ! -f "$BASE_FILE" ]] || [[ ! -f "$LEFT_FILE" ]] || [[ ! -f "$RIGHT_FILE" ]]; then
  echo "Error: Arquivo BASE, LEFT ou RIGHT inválido." >&2
  exit 1
fi

case "$LANG_FLAG" in
  --csharp)
    SEPS='{}()[];,.?'
    COMMENT_LINE_REGEX='//.*$'
    ;;
  --go)
    SEPS='{}()[];,.'
    COMMENT_LINE_REGEX='//.*$'
    ;;
  *)
    print_usage
    ;;
esac

preprocess() {
  local infile="$1"
  local outfile="$2"
  local tmp="${outfile}.tmp"

  awk -v cregex="$COMMENT_LINE_REGEX" \
      -v mark="$MARK" \
      -v seps="$SEPS" '
    BEGIN {
      escaped = ""
      for (i = 1; i <= length(seps); i++) {
        c = substr(seps, i, 1)
        if (c ~ /[\\^$.*+?|\[\]{}()]/) {
          escaped = escaped "\\" c
        } else {
          escaped = escaped c
        }
      }
      sep_class = "[" escaped "]"
    }
    {
      comment = ""
      line = $0
      if (match(line, cregex)) {
        comment = substr(line, RSTART, RLENGTH)
        line = substr(line, 1, RSTART - 1)
      }
      gsub(sep_class, "\n" mark "\n&\n" mark "\n", line)
      print line comment
    }
  ' "$infile" > "$tmp"

  mv "$tmp" "$outfile"
}

TMPDIR=$(mktemp -d smartmerge.XXXXXX)
trap "rm -rf '$TMPDIR'" EXIT INT TERM

preprocess "$BASE_FILE"  "$TMPDIR/base"
preprocess "$LEFT_FILE"  "$TMPDIR/left"
preprocess "$RIGHT_FILE" "$TMPDIR/right"

diff3 -m "$TMPDIR/left" "$TMPDIR/base" "$TMPDIR/right" 2>"$TMPDIR/diff3.stderr" \
  | sed "/${MARK//\//\\/}/d" \
  | awk '
      NF {
        print
        prev_blank = 0
        next
      }
      {
        if (prev_blank == 0) {
          print
          prev_blank = 1
        }
      }
    ' \
  | awk -v lang="$LANG_FLAG" '
      BEGIN {
        indent = 0
        current = ""
      }
      {
        token = $0
        gsub(/^[ \t]+|[ \t]+$/, "", token)
        if (token == "") next

        if (token ~ /^\/\//) {
          if (current != "") {
            printf("%*s%s\n", indent*4, "", current)
            current = ""
          }
          printf("%*s%s\n", indent*4, "", token)
          next
        }

        if (lang == "--go" && token ~ /^package[[:space:]]/) {
          if (current != "") {
            printf("%*s%s\n", indent*4, "", current)
            current = ""
          }
          printf("%*s%s\n", indent*4, "", token)
          next
        }

        if (token == "{") {
          if (current != "") {
            current = current " {"
          } else {
            current = "{"
          }
          printf("%*s%s\n", indent*4, "", current)
          indent++
          current = ""
          next
        }

        if (token == "}") {
          if (current != "") {
            printf("%*s%s\n", indent*4, "", current)
            current = ""
          }
          indent--
          if (indent < 0) indent = 0
          printf("%*s}\n", indent*4, "")
          next
        }

        if (token == ";") {
          current = current ";"
          printf("%*s%s\n", indent*4, "", current)
          current = ""
          next
        }

        if (token ~ /^[\.,\?:]$/) {
          current = current token
          next
        }

        if (token == "(") {
          current = current "("
          next
        }

        if (token == ")") {
          current = current ")"
          next
        }

        if (current == "") {
          current = token
        } else {
          current = current " " token
        }
      }
      END {
        if (current != "") {
          printf("%*s%s\n", indent*4, "", current)
        }
      }
    '
