#!/bin/bash

#
# Trim leading and trailing whitespaces
#
function trim() {
  local var="$*"
  # remove leading whitespace characters
  var="${var#"${var%%[![:space:]]*}"}"
  # remove trailing whitespace characters
  var="${var%"${var##*[![:space:]]}"}"   
  echo -n "$var"
}

#
# java_change
#
function java_change() {
  # readlink to get symlink path
  java_bin=$(readlink /etc/alternatives/java)

  echo "${java_bin}"
  IFS='/' read -ra JSPLIT <<< "$java_bin"
  unset IFS
  # create string to add to /etc/ld.so.conf.d/java-x86_64
  ld_value="${JSPLIT[0]}/${JSPLIT[1]}/${JSPLIT[2]}/${JSPLIT[3]}/${JSPLIT[4]}/lib/amd64/jli"

  # /sbin/getcap of the java binary
  GP=$(/sbin/getcap "${java_bin}")

  # Check if getcap returned anything
  if [ -z "$GP" ];
  then
    echo "Getcap is empty. Need to take action to setcap on ${java_bin}"
    echo "Actions include: "
    echo "1. Identify new java version (listed above)"
    echo "2. Edit /etc/ld.so.conf.d/java-x86_64.conf and change value to ${ld_value}"
    echo "3. /usr/sbin/setcap cap_net_bind_service=+ep ${java_bin}"
    echo "4. Run ldconfig"
  else
    # split the result from getcap and look at last element
    # getcap returns with: 
    # [steve@eew-ci-prod1 ~]$ getcap /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-8.b10.el7_5.x86_64/jre/bin/java
    # /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-8.b10.el7_5.x86_64/jre/bin/java = cap_net_bind_service+ep
    # else returns nothing if not set
    IFS='=' read -ra ARR <<< "$GP"
    unset IFS
    getcap_properties=${ARR[-1]}
    gc_value=$(trim ${getcap_properties})
    echo "Getcap returned ${gc_value}"
 fi
}


#
# Main
#
function main() {
  java_change
}

#
# Main function entry
#
main "${@}"

