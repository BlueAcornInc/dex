#
# lib.d/main_run.sh for dex -*- shell-script -*-
#

main_run(){
  operand="display_help"
  operand_args=

  # defaults
  __build_flag=false
  __pull_flag=false
  __interactive_flag=false
  __persist_flag=false

  if [ $# -eq 0 ]; then
    display_help 2
  else
    __flag_explode_fargs=
    set -- $(explode_flags "$@")
    while [ $# -ne 0 ]; do
      case $1 in
        -b|--build)     __build_flag=true ;;
        -p|--pull)      __build_flag=true ; __pull_flag=true ;;
        -i|-t)          __interactive_flag=true ;;
        -h|--help)      display_help ;;
        --entrypoint)   DEX_DOCKER_ENTRYPOINT="$2" ; shift ;;
        --home)         DEX_DOCKER_HOME="$2" ; shift ;;
        --log-driver)   DEX_DOCKER_LOG_DRIVER="$2" ; shift ;;
        --persist)      __persist_flag=true ;;
        --uid|--user)   DEX_DOCKER_UID="$2" ; shift ;;
        --workspace)    DEX_DOCKER_WORKSPACE="$2" ; shift ;;
        --)             shift ; operand_args="$@" ; break ;;
        -*)             
        *)                arg_var "$1" __imgstr && {
                            shift
                            dex-init
                            dex-run $@
                            exit $?
                          } ;;
      esac
      shift
    done
  fi

  dex-init
  $runstr
  exit $?
}


# argparsing, short and long, e.g.
#   `command -abcooutput.txt` expands to `command -a -b -c -o output.txt`
#   `command --long=yes --opt yes` expands to `command --long yes --opt yes`
#

while [ $# -ne 0 ]; do
  case $1 in

    #...

    # 1. verbose, in code
    --entrypoint)
      DEX_DOCKER_ENTRYPOINT="$2"; shift
      ;;
    --entrypoint=*)
      DEX_DOCKER_ENTRYPOINT="${1#*=}"
      ;;

    # 2. using a helper  [saves n * 3x loc]
    --entrypoint|--entrypoint=*)
      helperFn DEX_DOCKER_ENTRYPOINT "$1" "$2" && shift
      ;;


    # 3. using a helper + shopt -s globext
    --entrypoint?(\=*))
      helperFn DEX_DOCKER_ENTRYPOINT "$1" "$2" && shift
      ;;

    # ...
  esac

  shift
done
