# -*- coding: utf-8 -*-
__Author__ = "liuxiang"
__Date__ = '2017/12/26 13:46'

import gitlab
gitlab_url = "http://192.168.36.150/"
gitlab_token = "dS22do8rvMug4Lwo7vyx"



gl = gitlab.Gitlab(gitlab_url, gitlab_token)
projects = gl.projects.list()
for project in projects:
    print(project.branches.list())

