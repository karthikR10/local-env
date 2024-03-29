# Add Homebrew's executable directory to the front of the PATH
export PATH=/usr/local/bin:$PATH

export GOPATH=$HOME/Documents/go
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin
export PATH="$GOPATH/bin:$PATH"

# RUST
source "$HOME/.cargo/env"

alias wekube="~/Documents/go/src/weguard/wekube/bin/wekube_macos"

alias wecloud="~/Documents/go/src/weguard/weguard-eks-cluster/run.sh"
alias "update-kubeconfig"="aws eks --region us-west-2 update-kubeconfig --name dev-weguard-eks-cluster"

alias ll="ls -lah"

alias glo="git log --oneline --decorate"
alias gst="git status"
alias gco="git checkout"
alias gcm="git commit -m"
alias gplo="git pull origin"
alias gpso="git push origin"

# lazygit alias
alias lg="lazygit"

alias k="kubectl"
alias kgp="k get pods -o wide"
alias kgn="k get nodes -o wide"
alias kga="k get all -o wide"
alias kgs="k get service"
alias kgpv="k get pv"
alias kgpvc="k get pvc"
alias kd="k describe"
alias kns="kubie ns"
alias kcx="kubie ctx"
alias pod-check="kgp -A -o wide | grep -v Running | grep -v Comp"
alias pod-count="kgp -A | wc -l"


function awsprofile() {
  if [[ -z "$1" ]]; then
    unset AWS_PROFILE
    echo "AWS_PROFILE cleared"
  else
    export AWS_PROFILE=$1
    echo "AWS_PROFILE set to $AWS_PROFILE"
  fi
}

function helm_encrypt_dev_uswest2() {
  helm secrets encrypt ./helm-charts/environment/secrets/dev/values.yaml > ./helm-charts/environment/secrets/dev/values-enc.yaml
}

function helm_decrypt_dev_uswest2() {
  helm secrets decrypt ./helm-charts/environment/secrets/dev/values-enc.yaml > ./helm-charts/environment/secrets/dev/values.yaml
}

function helm_encrypt_dev_apsouth2() {
  helm secrets encrypt ./helm-charts/environment/secrets/dev-ap-south-2/values.yaml > ./helm-charts/environment/secrets/dev-ap-south-2/values-enc.yaml
}

function helm_decrypt_dev_apsouth2() {
  helm secrets decrypt ./helm-charts/environment/secrets/dev-ap-south-2/values-enc.yaml > ./helm-charts/environment/secrets/dev-ap-south-2/values.yaml
}

function helm_encrypt_qa_uswest2() {
  helm secrets encrypt ./helm-charts/environment/secrets/qa/values.yaml > ./helm-charts/environment/secrets/qa/values-enc.yaml
}

function helm_decrypt_qa_uswest2() {
  helm secrets decrypt ./helm-charts/environment/secrets/qa/values-enc.yaml > ./helm-charts/environment/secrets/qa/values.yaml
}

function helm_encrypt_qa_apsouth2() {
  helm secrets encrypt ./helm-charts/environment/secrets/qa-ap-south-2/values.yaml > ./helm-charts/environment/secrets/qa-ap-south-2/values-enc.yaml
}

function helm_decrypt_qa_apsouth2() {
  helm secrets decrypt ./helm-charts/environment/secrets/qa-ap-south-2/values-enc.yaml > ./helm-charts/environment/secrets/qa-ap-south-2/values.yaml
}

complete -C /usr/local/bin/terraform terraform


# Copilot CLI
eval "$(github-copilot-cli alias -- "$0")"



# source "/usr/local/opt/kube-ps1/share/kube-ps1.sh"
# PS1='$(kube_ps1)'$PS1

validateYaml() {
    python3 -c 'import yaml,sys;yaml.safe_load(sys.stdin)' < $1
}


## zoxide setup
#  =============================================================================
#
# Utility functions for zoxide.
#

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd() {
    \builtin pwd -L
}

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd() {
    # shellcheck disable=SC2164
    \builtin cd -- "$@"
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
function __zoxide_hook() {
    # shellcheck disable=SC2312
    \command zoxide add -- "$(__zoxide_pwd)"
}

# Initialize hook.
# shellcheck disable=SC2154
if [[ ${precmd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]] && [[ ${chpwd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]]; then
    chpwd_functions+=(__zoxide_hook)
fi

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

__zoxide_z_prefix='z#'

# Jump to a directory using only keywords.
function __zoxide_z() {
    # shellcheck disable=SC2199
    if [[ "$#" -eq 0 ]]; then
        __zoxide_cd ~
    elif [[ "$#" -eq 1 ]] && { [[ -d "$1" ]] || [[ "$1" = '-' ]] || [[ "$1" =~ ^[-+][0-9]$ ]]; }; then
        __zoxide_cd "$1"
    elif [[ "$@[-1]" == "${__zoxide_z_prefix}"* ]]; then
        # shellcheck disable=SC2124
        \builtin local result="${@[-1]}"
        __zoxide_cd "${result:${#__zoxide_z_prefix}}"
    else
        \builtin local result
        # shellcheck disable=SC2312
        result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -- "$@")" &&
            __zoxide_cd "${result}"
    fi
}

# Jump to a directory using interactive search.
function __zoxide_zi() {
    \builtin local result
    result="$(\command zoxide query -i -- "$@")" && __zoxide_cd "${result}"
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

\builtin unalias z &>/dev/null || \builtin true
function z() {
    __zoxide_z "$@"
}

\builtin unalias zi &>/dev/null || \builtin true
function zi() {
    __zoxide_zi "$@"
}

if [[ -o zle ]]; then
    function __zoxide_z_complete() {
        # Only show completions when the cursor is at the end of the line.
        # shellcheck disable=SC2154
        [[ "${#words[@]}" -eq "${CURRENT}" ]] || return 0

        if [[ "${#words[@]}" -eq 2 ]]; then
            _files -/
        elif [[ "${words[-1]}" == '' ]]; then
            \builtin local result
            # shellcheck disable=SC2086,SC2312
            if result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -i -- ${words[2,-1]})"; then
                result="${__zoxide_z_prefix}${result}"
                # shellcheck disable=SC2296
                compadd -Q "${(q-)result}"
            fi
            \builtin printf '\e[5n'
        fi
        return 0
    }

    \builtin bindkey '\e[0n' 'reset-prompt'
    if [[ "${+functions[compdef]}" -ne 0 ]]; then
        \compdef -d z
        \compdef -d zi
        \compdef __zoxide_z_complete z
    fi
fi

# =============================================================================
#
# To initialize zoxide, add this to your configuration (usually ~/.zshrc):
#
eval "$(zoxide init zsh)"
# ~/.zshrc

eval "$(starship init zsh)"

. "$HOME/.cargo/env"