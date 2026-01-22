#!/usr/bin/env bash
# gh-profile - Manage GitHub SSH profiles per repository

# # Save as ~/bin/gh-profile and make executable
# chmod +x ~/bin/gh-profile

# # Set profile for current repo
# gh-profile           # or: gh-profile select

# # Set global default profile
# gh-profile global

# # List available profiles and current settings
# gh-profile list

# # Show current settings
# gh-profile status

set -e

SSH_DIR="$HOME/.ssh"
SSH_CONFIG="$HOME/.ssh/config"
GIT_CONFIG_KEY="core.sshCommand"
PROFILE_CONFIG_KEY="github.profile"

get_github_user() {
    local key_path=$1
    local github_user=""
    
    # Try to get GitHub username via SSH test with timeout
    # Using bash built-in timeout mechanism since GNU timeout isn't available on macOS by default
    github_user=$(ssh -i "$key_path" -o IdentitiesOnly=yes -o ConnectTimeout=3 -o BatchMode=yes -T git@github.com 2>&1 | grep -oE 'Hi [^!]+' | cut -d' ' -f2 2>/dev/null || echo "")
    
    echo "$github_user"
}

get_github_user_by_host() {
    local ssh_host=$1
    local github_user=""
    
    github_user=$(ssh -o ConnectTimeout=3 -o BatchMode=yes -T "$ssh_host" 2>&1 | grep -oE 'Hi [^!]+' | cut -d' ' -f2 2>/dev/null || echo "")
    
    echo "$github_user"
}

parse_ssh_config_github_hosts() {
    if [[ ! -f "$SSH_CONFIG" ]]; then
        return
    fi
    
    local current_host=""
    local current_identity=""
    
    while IFS= read -r line; do
        # Remove leading/trailing whitespace
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Skip comments and empty lines
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        
        # Match Host directive
        if [[ "$line" =~ ^Host[[:space:]]+(.+)$ ]]; then
            # Save previous host if it was a GitHub host
            if [[ -n "$current_host" && -n "$current_identity" && "$current_host" =~ github\.com ]]; then
                echo "$current_host|$current_identity"
            fi
            current_host="${BASH_REMATCH[1]}"
            current_identity=""
        # Match IdentityFile directive
        elif [[ "$line" =~ ^IdentityFile[[:space:]]+(.+)$ ]]; then
            current_identity="${BASH_REMATCH[1]}"
            # Expand ~ to $HOME
            current_identity="${current_identity/#\~/$HOME}"
        fi
    done < "$SSH_CONFIG"
    
    # Don't forget the last host
    if [[ -n "$current_host" && -n "$current_identity" && "$current_host" =~ github\.com ]]; then
        echo "$current_host|$current_identity"
    fi
}

list_profiles() {
    local show_github=${1:-true}
    echo "Available GitHub profiles:"
    local idx=1
    
    # First, list profiles from SSH config
    while IFS='|' read -r host identity; do
        [[ -z "$host" ]] && continue
        
        local github_user=""
        if [[ "$show_github" == "true" ]]; then
            github_user=$(get_github_user_by_host "git@${host}")
        fi
        
        if [[ -n "$github_user" ]]; then
            echo "  $idx) @$github_user [${host}]"
        else
            echo "  $idx) ${host} ($(basename "$identity"))"
        fi
        ((idx++))
    done < <(parse_ssh_config_github_hosts)
    
    # Then list remaining keys not in SSH config
    local config_keys=()
    while IFS='|' read -r host identity; do
        config_keys+=("$identity")
    done < <(parse_ssh_config_github_hosts)
    
    for key in "$SSH_DIR"/id_*; do
        [[ -f "$key" && ! "$key" =~ \.pub$ ]] && {
            # Skip if already in SSH config
            local skip=false
            for config_key in "${config_keys[@]}"; do
                [[ "$key" == "$config_key" ]] && skip=true && break
            done
            [[ "$skip" == "true" ]] && continue
            
            local pubkey="${key}.pub"
            if [[ -f "$pubkey" ]]; then
                local github_user=""
                
                if [[ "$show_github" == "true" ]]; then
                    github_user=$(get_github_user "$key")
                fi
                
                if [[ -n "$github_user" ]]; then
                    echo "  $idx) @$github_user ($(basename "$key"))"
                else
                    local email=$(ssh-keygen -lf "$pubkey" 2>/dev/null | awk '{print $NF}' || echo "")
                    local display="$(basename "$key")"
                    [[ -n "$email" ]] && display="$display - $email"
                    echo "  $idx) $display"
                fi
                ((idx++))
            fi
        }
    done
    return 0
}

get_all_profiles() {
    local profiles=()
    
    # Add SSH config hosts first
    while IFS='|' read -r host identity; do
        [[ -n "$host" ]] && profiles+=("host:$host")
    done < <(parse_ssh_config_github_hosts)
    
    # Add remaining keys not in SSH config
    local config_keys=()
    while IFS='|' read -r host identity; do
        config_keys+=("$identity")
    done < <(parse_ssh_config_github_hosts)
    
    for key in "$SSH_DIR"/id_*; do
        [[ -f "$key" && ! "$key" =~ \.pub$ && -f "${key}.pub" ]] && {
            local skip=false
            for config_key in "${config_keys[@]}"; do
                [[ "$key" == "$config_key" ]] && skip=true && break
            done
            [[ "$skip" == "false" ]] && profiles+=("key:$key")
        }
    done
    
    printf '%s\n' "${profiles[@]}"
}

get_current_profile() {
    local scope=${1:-local}
    local flag=""
    [[ "$scope" == "global" ]] && flag="--global"
    
    local cmd=$(git config $flag $GIT_CONFIG_KEY 2>/dev/null || echo "")
    if [[ -n "$cmd" ]]; then
        # macOS-compatible extraction (no -P flag)
        local extracted=$(echo "$cmd" | sed -n 's/.*-i \([^ ]*\).*/\1/p')
        if [[ -n "$extracted" ]]; then
            echo "$extracted"
        else
            echo "default"
        fi
    else
        echo "default"
    fi
}

set_profile() {
    local profile=$1
    local scope=${2:-local}
    local flag=""
    [[ "$scope" == "global" ]] && flag="--global"
    
    if [[ "$profile" == "default" ]]; then
        git config $flag --unset $GIT_CONFIG_KEY 2>/dev/null || true
        git config $flag --unset $PROFILE_CONFIG_KEY 2>/dev/null || true
        
        # Reset remote URL to github.com if it's a github.com-* host
        if [[ "$scope" == "local" ]]; then
            local remote_url=$(git remote get-url origin 2>/dev/null || echo "")
            if [[ "$remote_url" =~ git@github\.com-[^:]+:(.+)$ ]]; then
                local repo_path="${BASH_REMATCH[1]}"
                git remote set-url origin "git@github.com:${repo_path}"
                echo "✓ Reset remote URL to github.com"
            fi
        fi
        echo "✓ Reset to default SSH behavior ($scope)"
    elif [[ "$profile" =~ ^host:(.+)$ ]]; then
        local ssh_host="${BASH_REMATCH[1]}"
        
        # For SSH config hosts, update the remote URL
        if [[ "$scope" == "local" ]]; then
            local remote_url=$(git remote get-url origin 2>/dev/null || echo "")
            if [[ "$remote_url" =~ git@[^:]+:(.+)$ ]]; then
                local repo_path="${BASH_REMATCH[1]}"
                git remote set-url origin "git@${ssh_host}:${repo_path}"
                echo "✓ Set remote to use ${ssh_host}"
            else
                echo "⚠ Warning: Could not parse remote URL"
            fi
        else
            echo "⚠ SSH config hosts only work for local repo settings"
        fi
        
        # Also unset sshCommand in case it was previously set
        git config $flag --unset $GIT_CONFIG_KEY 2>/dev/null || true
        git config $flag $PROFILE_CONFIG_KEY "$ssh_host"
        echo "✓ Set profile to ${ssh_host} ($scope)"
    elif [[ "$profile" =~ ^key:(.+)$ ]]; then
        local key_path="${BASH_REMATCH[1]}"
        git config $flag $GIT_CONFIG_KEY "ssh -i $key_path -o IdentitiesOnly=yes"
        git config $flag $PROFILE_CONFIG_KEY "$(basename "$key_path")"
        echo "✓ Set profile to $(basename "$key_path") ($scope)"
    fi
}

show_status() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Current settings:"
    
    # Check remote URL for SSH host
    local remote_url=$(git remote get-url origin 2>/dev/null || echo "")
    local remote_host=""
    if [[ "$remote_url" =~ git@([^:]+): ]]; then
        remote_host="${BASH_REMATCH[1]}"
    fi
    
    local local_profile=$(get_current_profile local)
    local global_profile=$(get_current_profile global)
    
    if [[ -n "$remote_host" && "$remote_host" != "github.com" ]]; then
        local github_user=$(get_github_user_by_host "git@${remote_host}" 2>/dev/null || echo "")
        if [[ -n "$github_user" ]]; then
            echo "  📍 Local (this repo): @${github_user} [${remote_host}]"
        else
            echo "  📍 Local (this repo): ${remote_host}"
        fi
    elif [[ "$local_profile" != "default" ]]; then
        echo "  📍 Local (this repo): $(basename "$local_profile")"
    else
        echo "  📍 Local (this repo): using global/default"
    fi
    
    if [[ "$global_profile" != "default" ]]; then
        echo "  🌐 Global default:    $(basename "$global_profile")"
    else
        echo "  🌐 Global default:    system SSH config"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

main() {
    local cmd=${1:-select}
    local show_github="true"
    
    # Check for --fast flag to skip GitHub username lookup
    if [[ "$2" == "--fast" ]] || [[ "$cmd" == "--fast" ]]; then
        show_github="false"
        [[ "$cmd" == "--fast" ]] && cmd="select"
    fi
    
    case "$cmd" in
        list|ls)
            list_profiles "$show_github"
            show_status
            ;;
        global)
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Set GLOBAL default profile (for all repos):"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            list_profiles "$show_github"
            echo "  0) default (system SSH config)"
            echo ""
            
            local profiles=()
            while IFS= read -r profile; do
                profiles+=("$profile")
            done < <(get_all_profiles)
            
            read -p "Choose [0-${#profiles[@]}]: " choice
            
            if [[ "$choice" == "0" ]]; then
                set_profile "default" "global"
            elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#profiles[@]} ]]; then
                set_profile "${profiles[$((choice-1))]}" "global"
            else
                echo "❌ Invalid choice"
                exit 1
            fi
            show_status
            ;;
        select|local|"")
            if ! git rev-parse --git-dir &> /dev/null; then
                echo "❌ Error: Not in a git repository"
                exit 1
            fi
            
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Set profile for THIS repository:"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            list_profiles "$show_github"
            echo "  0) default (use global or system SSH config)"
            echo ""
            
            local profiles=()
            while IFS= read -r profile; do
                profiles+=("$profile")
            done < <(get_all_profiles)
            
            read -p "Choose [0-${#profiles[@]}]: " choice
            
            if [[ "$choice" == "0" ]]; then
                set_profile "default" "local"
            elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#profiles[@]} ]]; then
                set_profile "${profiles[$((choice-1))]}" "local"
            else
                echo "❌ Invalid choice"
                exit 1
            fi
            show_status
            ;;
        status)
            show_status
            ;;
        *)
            echo "Usage: gh-profile [select|global|list|status] [--fast]"
            echo ""
            echo "Commands:"
            echo "  select (default) - Set SSH profile for current repo"
            echo "  global          - Set global default SSH profile"
            echo "  list            - List available SSH keys"
            echo "  status          - Show current profile settings"
            echo ""
            echo "Options:"
            echo "  --fast          - Skip GitHub username lookup (faster)"
            exit 1
            ;;
    esac
}

main "$@"