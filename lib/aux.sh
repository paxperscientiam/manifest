#!/usr/bin/env bash

###################################
# SECTION:  Auxilary Functions.
###################################

saveFile() {
  FN="${1}"
  shift
  echo "${@}" &> "${_BASE}${_NS}.${FN}"
}

errorHandle() {
  osascript -e 'display notification "Someone setup us the bomb!" with title "Sorry, a system error occurred."'
}

# FUNCTION:
timeStamp() {
  date +%Y.%m.%d.%H.%M.%S
}

