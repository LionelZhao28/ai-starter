#!/usr/bin/env bash
set -e

# Print log
function log() {
    echo $(date +"[%Y%m%d %H:%M:%S]: ") $1
}

# Print usage
function usage() {
  echo "usage: delete_notebook.sh -n <namespace>  --notebook-name <notbook_name>"
}

# Upgrade notebook's image
function delete_notebook() {
  if [[ -z $NAMESPACE ]];then
    NAMESPACE="default"
  fi
  
  if [[ -z $NOTEBOOK_NAME ]];then
    usage
    exit 1
  fi
  NOTEBOOK_NAME=$NOTEBOOK_NAME-notebook

  # if the notebook exists
  local exist=$(check_resource_exist sts $NOTEBOOK_NAME $NAMESPACE)
  if [[ "$exist" == "0" ]]; then
  	    set -x
		    kubectl delete -n $NAMESPACE sts $NOTEBOOK_NAME
	else
		log "notebook $NOTEBOOK_NAME in namespace $NAMESPACE is not found. Please check"
  fi
}

function check_resource_exist() {
  resource_type=$1
  resource_name=$2
  namespace=${3:-"default"}
  kubectl get -n $namespace $resource_type $resource_name &> /dev/null
  echo $?
}


function main() {
	while [ $# -gt 0 ];do
	    case $1 in
	        -n|--namespace)
	          NAMESPACE=$2
              shift
	            ;;
          --notebook-name)
              NOTEBOOK_NAME=$2
              shift
              ;;
	        -h|--help)
	            exit 0
	            ;;
	        *)
	            echo "unknown option [$key]"
	            exit 1
	        ;;
	    esac
        shift
	done
	delete_notebook
}

main "$@"
