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