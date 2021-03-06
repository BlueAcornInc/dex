# usage: dex-fetch <url> <target-path>
dex-fetch(){

  ! $DEX_NETWORK && \
    log "refused to fetch $2 from $1" "networking disabled" && \
    return 1

  fetch-url $1 $2
}

dex-init(){

  [ -d $DEX_HOME ] || mkdir -p $DEX_HOME || error_perms \
    "could not create working directory \$DEX_HOME"

  [ -d $DEX_HOME/checkouts ] || mkdir -p $DEX_HOME/checkouts || error_perms \
    "could not create checkout directory under \$DEX_HOME"

  ( type docker >/dev/null 2>&1 ) || error_noent \
    "dex requires docker"

  [ -e $DEX_HOME/sources.list ] || dex-init-sources

  for path in $DEX_HOME $DEX_HOME/checkouts $DEX_HOME/sources.list; do
    [ -w $path ] || error_perms "$path is not writable"
  done

  return 0
}

dex-init-sources(){
  rm -rf $DEX_HOME/sources.list.fetched &>/dev/null

  if [ ! -e $DEX_HOME/sources.list ]; then
    if dex-fetch "https://raw.githubusercontent.com/dockerland/dex/master/sources.list" $DEX_HOME/sources.list.fetched ; then
      cat $DEX_HOME/sources.list.fetched > $DEX_HOME/sources.list || error_perms \
        "error writing sources.list from fetched file"
    else
      dex-sources-cat > $DEX_HOME/sources.list || error_perms \
        "error creating $DEX_HOME/sources.list"
    fi
  fi
}

dex-sources-cat(){
  cat <<-EOF
#
# dex sources.list
#

core git@github.com:dockerland/dex-dockerfiles-core.git
extra git@github.com:dockerland/dex-dockerfiles-extra.git

EOF
}
