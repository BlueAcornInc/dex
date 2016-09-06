#
# lib.d/helpers/argparse.sh for dex -*- shell-script -*-
#

# flag_explode, normalizes short and long flags to support commands like:
#  `command -abcooutput.txt` => `command -a -b -c -o output.txt`
#  * turns "-abc --def -z" into "-a -b -c --def -z"
#  * turns "--long=yes --opt yes" into "--long yes --opt yes"
flag_explode(){
  echo "got $@"
  while [ $# -ne 0 ]; do
    if [ "--" = ${1:0:2} ]; then
      echo ${1%=*}
      [[ "$1" == *"="* ]] && echo ${1#*=}
    elif [ "-" = ${1:0:1} ]; then
      local i=1
      while read -n1 flag; do
        ((i++))
        echo "-$flag"
        if [[ "$__flag_explode_fargs" == *"$flag"* ]]; then
          echo ${1:$i}
          break
        fi
      done < <(echo -n "${1:1}")
    else
      echo $1
    fi
    shift
  done
}

# space-delimeted string of short flags requiring an argument.
#   e.g. `command -abcooutput.txt` expands to `command -a -b -c -o output.txt`
#         when __flag_explode_fargs="o"
__flag_explode_fargs=""



#
# @TODO deprecate below
#

# usage:  arg_var <arg> <variiable>
# assigns a variable from an argument if <arg> is not a flag, else clears it
arg_var(){
  if [[  $1 == -* ]]; then
    eval "$2="
    return 1
  else
    eval "$2=\"$1\""
    return 0
  fi
}

unrecognized_flag(){
  if [ $__cmd = "main" ]; then
    printf "\n\n$1 is an unrecognized flag\n\n"
  else
    printf "\n\n$1 is unrecognized by the $__cmd command.\n\n"
  fi

  display_help 2
}

unrecognized_arg(){

  if [ $__cmd = "main" ]; then
    printf "\n\n$1 is an unrecognized command\n\n"
  else
    printf "\n\n$1 is an unrecognized argument to the $__cmd command.\n\n"
  fi

  display_help 2
}
