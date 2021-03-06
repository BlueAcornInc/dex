#
# lib.d/helpers/cli.sh for dex -*- shell-script -*-
#

# normalize_flags - normalize POSIX short and long flags for easier parsing
# usage: normalize_flags <fargs> [<flags>...]
#   <fargs>: string of short flags requiring an argument.
#   <flags>: flag string(s) to normalize, typically passed as "$@"
# examples:
#   normalize_flags "" "-abc"
#     => -a -b -c
#   normalize_flags "om" "-abcooutput.txt" "--def=jam" "-mz"
#     => -a -b -c -o output.txt --def jam -m z"
normalize_flags(){
  local fargs="$1"
  shift
  for arg in $@; do
    if [ "--" = ${arg:0:2} ]; then
      echo ${arg%=*}
      [[ "$arg" == *"="* ]] && echo ${arg#*=}
    elif [ "-" = ${arg:0:1} ]; then
      local i=1
      while read -n1 flag; do
        ((i++))
        [ -z "$flag" ] || echo "-$flag"
        if [[ "$fargs" == *"$flag"* ]]; then
          echo ${arg:$i}
          break
        fi
      done < <(echo -n "${arg:1}")
    else
      echo $arg
    fi
  done
}

# normalize_flags_first - like normalize_flags, but outputs flags first.
# usage: normalize_flags <fargs> [<flags>...]
#   <fargs>: string of short flags requiring an argument.
#   <flags>: flag string(s) to normalize, typically passed as "$@"
# examples:
#   normalize_flags_first "" "-abc command -xyz otro"
#     => -a -b -c -x -y -z command otro

normalize_flags_first(){
  local fargs="$1"
  local args=()
  shift
  args=()
  for arg in $(normalize_flags "$fargs" "$@"); do
    if [ "-" = ${arg:0:1} ]; then
      echo $arg
    else
      args+=( "$arg" )
    fi
  done

  for arg in ${args[@]}; do
    echo $arg
  done
}

runfunc(){
  [ "$(type -t $1)" = "function" ] || error \
    "$1 is not a valid runfunc target"

  eval "$@"
}

unrecognized_flag(){
  printf "\n\n$1 is an unrecognized flag\n\n"
  display_help 2
}

unrecognized_arg(){

  if [ $__cmd = "main" ]; then
    printf "\n\n$1 is an unrecognized command\n\n"
  else
    printf "\n\n$1 is an unrecognized argument\n\n"
  fi

  display_help 2
}
