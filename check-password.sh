# Check if an argument was actually provided
is_consecutive() {
    local input="$1"
    local len=${#input}

    if [ "$len" -lt 2 ]; then
        return 1
    fi

    # 2. Loop to check sequence
    for (( i=0; i<len-1; i++ )); do
        local current
        local next

        # Get ASCII values of characters
        printf -v current "%d" "'${input:i:1}"
        printf -v next "%d" "'${input:i+1:1}"

        if [ "$((current + 1))" -ne "$next" ]; then
            return 1 # Not consecutive
        fi
    done

    return 0 # Success! It is consecutive
}

is_repetitive() {
    local input="$1"
    local len=${#input}

    # Loop to check sequence
    for (( i=0; i<len-1; i++ )); do
        local current="${input:i:1}"
        local next="${input:i+1:1}"

        if [ "$current" != "$next" ]; then
            return 1 # Not repetitive
        fi
    done

    return 0 # Success! It is not repetitive
}

is_dictionary_word() {
    local word="$1"
    local dict_file="/usr/share/dict/words"
    local dict_found=0
    local aspell_found=0

    # 1. Check Dictionary File
    if [ ! -f "$dict_file" ]; then
        dict_file="/usr/dict/words"
    fi

    if [ -f "$dict_file" ]; then
        dict_found=1
        # -F: Fixed string (not regex)
        # -x: Match whole line
        # -q: Quiet (exit 0 if match, 1 if not)
        # -i: Case insensitive
        if grep -Fxqi "$word" "$dict_file"; then
            return 0 # Found in dictionary file
        fi
    fi

    # 2. Check Aspell
    if command -v aspell >/dev/null 2>&1; then
        aspell_found=1
        # aspell list outputs the word if it is NOT in the dictionary (misspelled)
        # So if output is empty, it IS in the dictionary (correctly spelled)
        if [ -z "$(echo "$word" | aspell list)" ]; then
            return 0 # Found in aspell
        fi
    fi

    # 3. Check availability
    if [ "$dict_found" -eq 1 ] && [ "$aspell_found" -eq 1 ]; then
        return 1 # Checked both, found in neither -> Not a dictionary word
    else
        return 2 # One or both checks were unavailable
    fi
}

if [ -z "$1" ]; then
    echo "Usage: $0 <password>"
    exit 1
fi
password=$1
printf "\n\nEvaluating the password: \"%s\"\n\n" $1
length=${#password}
echo "The password length is: $length"
if [ "$length" -ge 16 ]; then
      printf "✅ Good password length. \n\n"
elif [ "$length" -lt 8 ]; then
    printf "❌ Error: Password is too short (minimum 8 characters).\n\n"
    exit 1
else
    printf "⚠️  Warning: Password meets minimum length (8) but is short (aim for 16+).\n\n"
fi

if is_repetitive "$password"; then
    echo "❌ Quality Alert: Password is a simple repetitive sequence."
    exit 1
else

  if is_consecutive "$password"; then
      echo "❌ Quality Alert: Password is a simple consecutive sequence."
      exit 1
  else
      echo "✅ Password is neither a simple repetitive sequence nor a simple consecutive sequence."
  fi
fi

is_dictionary_word "$password"
dict_check_result=$?

if [ $dict_check_result -eq 0 ]; then
    echo "❌ Quality Alert: Password is a common dictionary word."
    exit 1
elif [ $dict_check_result -eq 1 ]; then
    echo "✅ Password is not a common dictionary word."
else
    echo "⚠️  Warning: Could not perform all dictionary checks (Dictionary file and/or aspell missing)."
fi