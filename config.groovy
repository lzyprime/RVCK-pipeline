
all_params_desc = [
    'REPO': '指定所属仓库, 用于gh ... -R "$REPO"',
    "FETCH_REF": '代码分支或commit_sha',
    'ISSUE_ID': '需要评论的issue|pr id',
    "PATCH_URL": '要合入的patch连接, git am 合入到BASE_REF, 为空时直接使用BASE_REF构建',
    
    'kernel_download_url': '内核下载链接',
    'rootfs_download_url': 'rootfs下载链接',
    'lava_template': 'lava测试模板',
    'testcase_url': '需要执行的用例yaml 文件路径',
    'testcase': 'ltp测试时，指定测试套',
    'testcase_repo': 'lava 仓库地址',

    'COMMENT_CONTENT': '评论内容, 用于 gh issue $ISSUE_ID -b "$COMMENT_CONTENT"',
    'SET_LABEL': "清空所有标签并设置新LABEL, 多个以英文逗号 ',' 分割, 不能与ADD_LABEL,REMOVE_LABEL混用",
    'ADD_LABEL': "'添加标签，多个以英文逗号 ',' 分割', name: 'ADD_LABEL'",
    'REMOVE_LABEL': "添加标签，多个以英文逗号 ',' 分割",
]

params_defaultvalue = [
    "testcase_repo": 'https://github.com/RVCK-Project/lavaci.git',
    "lava_template": "lava-job-template/qemu/qemu-ltp.yaml",
    "testcase_url": "lava-testcases/common-test/ltp/ltp.yaml",
    "testcase": "math",
]

all_params = all_params_desc.collectEntries { name, desc ->
    [(name): string(name: name, description: desc, trim: true, defaultValue: params_defaultvalue.get(name, ''))]
}


kernel_build_params_keys = [
    "REPO",
    "ISSUE_ID",
    "FETCH_REF",
    'lava_template',
    'testcase_url',
    'testcase',
]

gh_actions_params_keys = [
    "REPO",
    "ISSUE_ID",
    "COMMENT_CONTENT",
    "SET_LABEL",
    "ADD_LABEL",
    "REMOVE_LABEL",
]

lava_trigger_params_keys = [
    "REPO",
    "ISSUE_ID",
    "kernel_download_url",
    "rootfs_download_url",
    'testcase_repo',
    "lava_template",
    "testcase_url",
    "testcase",
]

label_group = [
    "kernel":[
        "kernel_build_failed",
        "kernel_build_succeed",
        "kernel_building",
    ],
    "lava": [
        "lava_check_fail",
        "lava_check_pass",
        "lava_checking",
        "lava_waiting",
    ]
]

all_label = label_group.values().collectMany { it }

return this