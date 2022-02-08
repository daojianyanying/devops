#!/usr/bin/env python3
##################################################################
## ScriptName: pre-commit-server
## Description:gitlab服务端hook
##
## UpdateTime: 2022.1.21
## author: liuxiang
## status: Using
## note: 脚本放到linux上注意换行符
##################################################################
import sys, os, re
input_info = sys.stdin.read()
COMMIT_FORMER = input_info.split(' ')[0]
COMMIT_CURRENT = input_info.split(' ')[1]

def print_message_example():
    print(
        """
        ###########################################################################
        ## Example: 
        ##      【问题单号】
        ##      【描述】
        ## MessageStandard:
        ##      
        ##
        ##
        ###########################################################################
        """
    )

def check(strict):
    log_list = os.popen('git log ' + COMMIT_FORMER + '..' + COMMIT_CURRENT + ' --pretty=format:%s').readlines()
    if strict:
        for log in log_list:
            if re.match(r'^Merge\sBranch.*', log, re.I):
                pass
            elif: re.match(r'^Revert.*', log, re.I):
                pass
            elif not log.startswith('Merge branch') and re.match(r'正则匹配内容', log, re.I) is None:
                print('Message check failed:' + log)
                print_message_example
                exit(1)
        print('Message check success')
    else:
        if re.match(r'^Merge\sBranch.*', log_list[0], re.I):
            pass
        elif re.match(r'^Revert.*', log_list[0], re.I):
            pass
        elif not log_list[0].startswith('Merge branch') and re.match(r'正则匹配内容', log_list[0], re.I) is None:
            print('Message check failed:' + log_list[0])
            print_message_example
            exit(1)
        else:
            print('Message check success')

if __name__ == '__main__':
    if COMMIT_FORMER == '0000000000000000000000000000000000000000' and COMMIT_CURRENT == '0000000000000000000000000000000000000000':
        pass
    else:
        check(False)
