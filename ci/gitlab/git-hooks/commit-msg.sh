#!/usr/bin/env bash
##############################################################################
##
##
##
##
##
##
##
#############################################################################

FIRST_LINE = `sed -n '1p' $1`
SECOND_LINE = `sed -n '2p' $1`
THREAD_LINE = `sed -n '3p' $1`

function echo_message_example(){
    echo '###########################################################################'
    echo '## Example: '
    echo '##      【问题单号】'
    echo '##      【描述】'
    echo '## MessageStandard:'
    echo '##    '
    echo '##'
    echo '##'
    echo '###########################################################################'
}
function commit_message_check(){
    if ! echo $FIRST_LINE | grep -qiE "正则规范";then
        echo '![error]: Commit Message against in line 1'
        echo_message_example
        exit 1
    fi

        if ! echo $SECOND_LINE | grep -qiE "正则规范";then
        echo '![error]: Commit Message against in line 2'
        echo_message_example
        exit 1
    fi

        if ! echo $THREAD_LINE | grep -qiE "正则规范";then
        echo '![error]: Commit Message against in line 3'
        echo_message_example
        exit 1
    fi
	echo "Commit Message check success"
}

function main(){
	if echo $FIRST_LINE | grep -qiE "^Merge\sBranch";then
		exit 0
	elif echo $FIRST_LINE | grep -qiE "^Revert";then
		exit 0
	else
		commit_message_check
}

main
