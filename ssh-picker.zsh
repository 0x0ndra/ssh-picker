# SSH Picker for Zsh
# Replaces the default 'ssh' command with an interactive fzf-based server picker.
# Run 'ssh' with no arguments to open the picker.
# Servers are managed via ~/.ssh/config

ssh() {
  if [ $# -eq 0 ]; then
    local host key result
    while true; do
      result=$(awk '
        /^Host [^*]/ {
          if (host) print host (ip && ip!=host ? "\t(" ip ")" : "")
          host=$2; ip=""
        }
        /^[[:space:]]+HostName / { ip=$2 }
        END { if (host) print host (ip && ip!=host ? "\t(" ip ")" : "") }
      ' ~/.ssh/config | fzf \
        --prompt="ssh> " \
        --header="[enter] connect  [ctrl-a] add  [ctrl-d] delete  [ctrl-e] edit  [ctrl-y] copy" \
        --expect=ctrl-a,ctrl-d,ctrl-e,ctrl-y)

      key=$(printf '%s' "$result" | head -1)
      host=$(printf '%s' "$result" | tail -1 | awk '{print $1}')

      if [ "$key" = "ctrl-a" ]; then
        local name ip_addr ssh_user
        read "name?Host name: "
        read "ip_addr?IP / hostname: "
        read "ssh_user?User [$USER]: "
        ssh_user=${ssh_user:-$USER}
        if [[ -n "$name" && -n "$ip_addr" ]]; then
          printf '\nHost %s\n  HostName %s\n  User %s\n' "$name" "$ip_addr" "$ssh_user" >> ~/.ssh/config
          echo "Added: $name ($ip_addr)"
        fi

      elif [ "$key" = "ctrl-e" ] && [ -n "$host" ]; then
        local lnum
        lnum=$(awk -v h="$host" '/^Host / && $2==h{print NR; exit}' ~/.ssh/config)
        ${EDITOR:-nano} ${lnum:++$lnum} ~/.ssh/config

      elif [ "$key" = "ctrl-y" ] && [ -n "$host" ]; then
        local copy_ip copy_user
        copy_ip=$(awk -v h="$host" '/^Host /{f=($2==h)} f && /HostName/{print $2; exit}' ~/.ssh/config)
        copy_user=$(awk -v h="$host" '/^Host /{f=($2==h)} f && /[[:space:]]User /{print $2; exit}' ~/.ssh/config)
        local cmd="ssh ${copy_user:+${copy_user}@}${copy_ip:-$host}"
        echo "$cmd" | pbcopy
        echo "Copied: $cmd"

      elif [ "$key" = "ctrl-d" ] && [ -n "$host" ]; then
        local confirm
        read "confirm?Delete '$host'? [y/N] "
        if [[ "$confirm" =~ ^[yY]$ ]]; then
          local tmp=$(mktemp)
          awk -v del="$host" '/^Host /{skip=($2==del)} !skip{print}' ~/.ssh/config > "$tmp" && mv "$tmp" ~/.ssh/config
          echo "Deleted: $host"
        fi

      else
        [ -n "$host" ] && command ssh "$host"
        break
      fi
    done
  else
    command ssh "$@"
  fi
}
