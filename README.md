# RVCK
[RVCK-Project](https://github.com/RVCK-Project) 项目 **CI** 的**Jenkinsfile**

## 项目地址
|支持的Github仓库地址|
|---|
|https://github.com/RVCK-Project/rvck|
|https://github.com/RVCK-Project/rvck-olk|
|https://github.com/RVCK-Project/lavaci|

## 服务/工具
|服务/工具|
|---|
|[Jenkins](https://www.jenkins.io/doc/)|
|[Kernelci](https://github.com/kernelci/dashboard)|
|[Lava](https://docs.lavasoftware.org/lava/index.html)|
|[gh](https://github.com/cli/cli#installation)|
|[lavacli](https://build.tarsier-infra.isrc.ac.cn/package/show/home:Suyun/lavacli)|

## 需求
|需求|完成状态|
|---|---|
|仓库的**PR**要自动触发**LAVA**内核测试，并回复结果至**PR**下|**done**|
|**/check**添加参数功能|**to do**|
|仓库的**ISSUE**里要能触发**LAVA**内核测试，并回复结果至**ISSUE**里|**to do**|

## 实现
### 实现思路
PR/issue -> webhook -> jenkins job -> 分析 issue:/check sg2042 commitid , PR： /check -> gh 回复 开始，并打标签 -> kernel 构建 -> gh回复构建结果，并打标签 -> 触发lavacli -> Lava -> Lava agent（qemu sg2042 lpi4a unmatched visionfive2 k1）-> 结果显示网页kernelci -> lavacli 获取结果（result,url）-> gh回复结果，并打标签 -> issue/pr 

#### job
##### rvck/rvck-webhook
* 识别 ISSUE comments、PR回复中的 /check
* 有PR时就会回复开始测试。并返回结果
* 获取PR的id并向kernel-build传递
* 获取PR的url并向kernel-build传递
* 获取需要回复信息的URL
* 获取 /check 的参数 lava_template、testcase_url、testcase，并传递给rvck-lava-trigger

###### /check
指令模板：   
``` 
/check  lava模板文件路径  lava测试用例路径  测试用例的参数(ltp测试时，参数为all，设置为空，效果为执行全部ltp测试)  
/check ${lava_template} ${testcase_url} ${testcase}

Example:
/check lava-job-template/qemu/qemu-ltp.yaml lava-testcases/common/ltp/ltp.yaml math 

/check lava-job-template/qemu/qemu-ltp.yaml lava-testcases/common/ltp/ltp.yaml all
```
> **lava模板文件路径**、**lava测试用例路径**、**测试用例的参数**从[RAVA项目](https://github.com/RVCK-Project/lavaci)获取
##### rvck/rvck-lava-trigger
* 获取 kernel-build 传递的变量

|变量名|作用|
|---|---|
|kernel_download_url|内核下载链接|
|rootfs_download_url|rootfs下载链接|
|REPO|指定所属仓库, 用于gh ... -R "$REPO"|
|ISSUE_ID|需要评论的issue pr id|
|testcase_url|需要执行的用例yaml 文件路径 |
|testcase|ltp测试时，指定测试套|
|lava_template|lava模板文件路径|
* 检查**testcase_url**、**lava_template**文件是否存在
* 对**lava_template**文件里的变量进行替换
* 触发**lava**测试后，等待并返回**lava**结果至**gh_actions**

### webhook设置
|webhook events|
|---|
|Issue comments|
|Issues|
|Pull requests|

### Jenkins
#### Jenkins plugin
|Jenkins plugin|
|---|
|https://plugins.jenkins.io/generic-webhook-trigger|
|https://plugins.jenkins.io/rebuild|

#### Jenkins agent
|架构|获取地址| 
|---|---|
|x86|hub.oepkgs.net/oerv-ci/jenkins-agent-lavacli-gh:latest|
|riscv64|hub.oepkgs.net/oerv-ci/jenkins-sshagent:latest|

#### 注意事项
> Docker Compose v1切换到Docker Compose v2 ,需使用 docker compose 启动：
        https://docs.docker.com/compose/install/linux/#install-the-plugin-manually