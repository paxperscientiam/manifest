#!/usr/bin/env bash
# shellcheck disable=1090
# shellcheck disable=2154
###################################
# Disclaimer: THIS IS AN ACTIVE EXPERIMENT. EXECUTE AT YOUR OWN PERIL.
###################################
# SECTION: News.

###################################
# Manifest -- a project dedicated to the paranoid.
# Manifest is written for and tested on Bash on OSX.
# Purpose: To generate and maintain 'manifests' of applications/gems/modules/packages/ports/etc.
## To mirror a user's environment.
# Execution: To be run either as a cron job or from a shell.
###################################
# SECTION: Requirements.
###################################
# Bash 4.2
# Pallet and Cask for Emacs 24
###################################
# SECTION: Variables.
###################################
checkRC () {
  SOURCE="${BASH_SOURCE[-1]}"
  while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  done
  _CWD="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  #
  [[ $BUILD == 'GO' ]] && return
  if [[ -f "${_CWD}/${1}" ]]; then
    printf '%s\n' "RC file found in current working directory."
    . "${_CWD}/${1}"
    return
  elif [[ -f "${HOME}/${1}" ]]; then
    printf '%s\n' "RC file found in home directory."
    . "${HOME}/${1}"
    return
  else
    printf '%s' 'Configuration file is required!'
  fi
}
checkRC ".manifestrc"

source "${_CWD}/src/env"
source "${_CWD}/src/check-version"
source "${_CWD}/src/verify-path"
source "${_CWD}/src/aux"




#
#
notify () {
  if ((messageStatus & verbosity)); then
    msg="${1}${2}"
  else
    msg="${1}"
  fi

  if ((messageStatus & notify)); then
    osascript -e "display notification \"$msg\" with title \"manifest \""
  fi
  if ((messageStatus & stdout)); then
    printf '%s.\n' "${1}"
  fi
  if ((messageStatus & log)); then
    echo "LOOOOL"
  fi
}
notify=$((1<<0))
stdout=$((1<<1))
log=$((1<<2))


messageHandler() {
  n=$(($1*notify))
  s=$(($2*stdout))
  l=$(($3*log))
  #
  return $((n|s|l))
}

if ! checkVersion 42
then
  printf '%s\n' "Your version of \`bash\` is too old :("
fi

messageHandler "${osxNote}" "${ttyNote}" "${logNote}"
messageStatus=$?

###############################
missing () {
  printf "I require %s, but it was not found. Aborting.\\n" "${1}" && exit 1;
  exit 1
}
########
init () {
  ## terminal check
  if [[ -t 0  || -t 1 ]]; then
    notify "Running in Terminal."
    _isTerm=1
  else
    notify 'Not-a-terminal.\n'
    _isTerm=0
  fi
  ##
  ##
  [[ $BUILD == 'GO' ]] && return
  verifyBase "${_BASE}"
}
# Reset log file. (user should have a choice in the matter)
#>"${_LOG}" # create/reset log, might be causing trouble with readline

###################################
# SECTION: Primary Functions.
###################################
# FUNCTION: Main
__manifest() {
  notify "manifest core is running."
  notify "That is all, ${_OWNER}! (^.^)"
}
#


# FUNCTION manifest of background services
__lunchy () {
  type lunchy &>/dev/null && missing "lunchy (a ruby gem)"

  saveFile "${USER}.background-services.txt" "`lunchy list`"

  notify "Generating ${FUNCNAME[0]#__} manifest of ${_OWNER}..."
  notify "${FUNCNAME[0]} is complete."
}
#
# composer global
__composer() {
  #  progress-bar 5
  if ! type composer &>/dev/null
  then
    missing "${FUNCNAME[0]#__}"
  fi
  #
  if [[ -z "${COMPOSER_HOME}" ]];then
    COMPOSER_HOME="${HOME}/composer.json"
  fi
  if [[ -r "${COMPOSER_HOME}/composer.json" ]]; then
    /bin/cp "${COMPOSER_HOME}/composer.json" "${_BASE}"
  fi
}

# FUNCTION: Generate 'Gemfile' to use for reinstalling 'local' gems.
__gem() {
  if [[ $1 == 'help' ]]; then
    printf 'Create an execute-ready manifest of ruby gems.\n'
    exit 0
  fi
  #
  if ! type gem &>/dev/null
  then
    missing "${FUNCNAME[0]#__}"
  fi

  gemv=$(gem --version)
  # need to properly parse output so that it can used on the command line
  notify "Generating ${FUNCNAME[0]#__} manifest..."
  #thanks to arturkomarov @ disqus

  saveFile "local.gems.${gemv}.txt" \
           "`gem list | sed 's/(//'|sed 's/)//'|awk '{print "gem install " $1 " --version=" $2}'`"

  #
  notify "${FUNCNAME[0]#__} is complete."
}

#
# FUNCTION: Generate a 'package.json' for NPM global modules.
__npm() {
  if [[ $1 == 'help' ]]; then
    printf 'Create a manifest of global npm modules.\n'
    exit 0
  fi
  type npm &>/dev/null || { echo >&2 "I require npm but it's not installed. Aborting."; exit 1;}
  #npmv=$(npm --version)
  nodev=$(node --version)

  notify "Generating ${FUNCNAME[0]#__} manifest..."

  saveFile "npm-global.${nodev}.json" "`npm -g ls --json true --parseable true --depth=0`"

  #
  # continue
  notify "${FUNCNAME[0]#__} is complete."
}
#
# FUNCTION: Emacs stuff.
__emacs() {

  if [[ $1 == 'help' ]]; then
    printf 'Emacs is the One True Editor.\n'
    exit 0
  fi
  #test
  type emacs &>/dev/null || { echo >&2 "I require emacs but it's not installed. Aborting."; exit 1;}
  #
  # generate cask file
  emacs --batch --eval "(progn (package-initialize)
(if (bound-and-true-p pallet-mode)
(pallet-init)
(progn
(pallet-mode)
(pallet-init))))"

  #
  notify "Generating ${FUNCNAME[0]#__} (cask) manifest..."
  cp -p "${HOME}/.emacs.d/Cask" "${_BASE}/cask.txt"
  #
  notify "${FUNCNAME[0]#__} is complete."

}
#


# Function: create system apps manifest.
__sysApps() {
  if [[ $1 == 'help' ]]; then
    printf 'Create a manifest of Applications.\n'
    exit 0
  fi
  #
  notify "Generating $(sw_vers -productVersion) manifest..."

  saveFile "system.apps.txt" "`mdfind -onlyin /Applications/ kMDItemKind == Application | tee >(wc -l) | sort -f`"

  notify "${FUNCNAME[0]} is complete."
}
#

getPYVersion() {
  python << EOF
import sys
print "%s%s" % (sys.version_info[0] , sys.version_info[1])
EOF
}
pyv=$(getPYVersion)


__pip() {
  if ! type pip &>/dev/null
  then
    missing "${FUNCNAME[0]#__}"
  fi

  notify "Generating ${FUNCNAME[0]#__} manifest..."
  saveFile "pip.py${pyv}.txt" "`pip --isolated freeze`"
  notify "done."
}


# # manifest of all installed macports ports
__port() {
  if [[ $1 == 'help' ]]; then
    printf 'Create a manifest of installed and requested Macports ports.\n'
    exit 0
  fi

  if ! type port &>/dev/null
  then
    missing "${FUNCNAME[0]#__}"
  fi
  #
  # Credit: Macports
  notify "Generating ${FUNCNAME[0]#__} manifest..."

  saveFile "system.macports.txt" "`port -qv installed`"

  notify "done."

  notify "Creating manifest of requested ports..."

  #saveFile "system.macports-requested.txt" `port echo requested | cut -d ' ' -f 1"`

  port echo requested | cut -d ' ' -f 1 > "${_BASE}/MANIFEST.system.macports-requested.txt"
  #
  notify "${FUNCNAME[0]#__} is complete."
}
#
__cron() {
  # crontabs
  notify "Replicating crontab of user ${_OWNER}"
  crontab -l > "${_BASE}${USER}.crontab.txt"
  #
  notify "${FUNCNAME[0]#__} is complete."
}
#
#
getUser() {
  /usr/bin/stat -f %Su "${BASH_SOURCE[0]}"
}
#
###################################
# SECTION: Auxilary Functions.
###################################
#
###################################
# SECTION: Execute.
###################################
# Menu functions
func_menu_help() {
  BOLD=$(tput bold)
  NORM=$(tput sgr0)
  cat <<EOM
${BOLD}
manifest -- execute, in case of Doomsday.
A Bash program that generates parseable package manifests using the
syntax of respective package managers. All designed with love for the paranoid.${NORM}

-c: show config (RC) file
-f: list functions; takes optional argument
-i: interactively create a .manifestrc file
-q: quiet mode
-v: print version
-h: get help, seriously
EOM
}
#
#
#
init
#
#

while getopts acfinq:tvh FLAG; do
  case $FLAG in
    a) #set a
      shift $((OPTIND-1))
	    echo win
	    exit 0
	    ;;
    c) #--config
      shift $((OPTIND-1))
      printf "%b" "This option is not ready. Stay tuned!"
      exit 0
	    ;;
    f)  #set option "f"
	    shift $((OPTIND-1))
	    if [[ -z "${1}" ]]; then
	      arr=(`compgen -A function | grep '__' | sed 's/__//g'`)
        printf '%-14s STATUS\n' "COMMAND"
        printf '%.0s-' {1..30}; echo
        for tttt in "${arr[@]}"
        do
          if type -p "${tttt}" &>/dev/null
          then
            printf '%-14s found\n' "${tttt}"
          else
            printf '%-14s not found\n' "${tttt}"
          fi
        done
	    else
	      if ( compgen -A function "__${1}"); then
	        eval "__${1}" 'help'
	      else
	        printf 'Function %s not found.\n' "${1}"
	      fi
	    fi
	    exit 0
	    ;;
    i) #--init
	    printf '%s\n' "Initialize configuration file?"
	    exit 0
	    ;;
    n) # use osx notifications
	    shift $((OPTIND-1))
	    break
	    ;;
    q) # set 'q'
	    __manifest &> /dev/null &
	    exit 0
	    ;;
    t) # set 't'
	    # shift $((OPTIND-1))
	    #system=1
	    #__manifest
	    ;;
    v) #set option "v"
	    printf 'β\n'
	    exit 0
	    ;;
    h)  #show help
	    func_menu_help
	    exit 0
	    ;;
    \?) #unrecognized option - show help
	    printf 'Unknown option.\n'
	    printf 'Use -h for helpful info.\n'
	    exit 2
	    ;;
  esac
done
#
if [[ $BUILD == 'GO' ]]
then
  _CWD="${_CWD}"
  install -b -m 755 /dev/null "${_CWD}/dist/manifest"; while read -ra words; do if [[ ${words[0]} == source ]]; then eval cat "${words[1]}"; else printf '%s\n' "${words[*]}"; fi; done < "${0}" >| "${_CWD}/dist/manifest"
fi
