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

* 识别 `ISSUE`、 `ISSUE|PR comments`、`PR`中的 `/check` 指令
* 有PR时就会回复开始测试。并返回结果
* 获取PR的id并向kernel-build传递
* 获取PR的url并向kernel-build传递
* 获取需要回复信息的URL
* 获取 /check 的参数，并传递给`rvck-lava-trigger`

###### /check 参数解析

指令模板：`/check [key=value ...]`

|支持的key|描述|默认值|获取途径|
|:-:|:-:|:-:|:-:|
|lava_template|lava模板文件路径|lava-job-template/qemu/qemu-ltp.yaml|从[RAVA项目](https://github.com/RVCK-Project/lavaci)获取|
|testcase_url|lava测试用例路径|llava-testcases/common-test/ltp/ltp.yaml|从[RAVA项目](https://github.com/RVCK-Project/lavaci)获取|
|testcase|测试用例的参数(ltp测试时，设置为空，效果为执行全部ltp测试)|math|从[RAVA项目](https://github.com/RVCK-Project/lavaci)获取|
|fetch|当前仓库的分支名或commmit_sha,用于告知内核构建所需代码来源. ISSUE、ISSUE_COMMENT 必要参数。PR、PR_COMMENT 不读取此参数|issue必填参数|当前仓库的分支名，或commit_sha|

```bash
# Example:
/check lava_template='path/to/lava template.yaml' testcase_url=path/to/xxx.yaml testcase=math

# 全量ltp测试
/check lava_template='path/to/lava template.yaml' testcase_url=path/to/xxx.yaml testcase=
### or
/check lava_template='path/to/lava template.yaml' testcase_url=path/to/xxx.yaml testcase=''
```

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

## git fetch与 git am patch 区别

`git fetch pull/12/head` 和使用 GitHub 提供的 PR 补丁链接（例如 `https://github.com/{owner}/{repo}/pull/{pr_number}.patch`）来应用 PR 提交，虽然最终都可以让你将 PR 的更改合并到你的分支，但它们的工作方式是不同的，具体区别如下：

### 1. **`git fetch pull/12/head` 的效果**

- **拉取 PR 分支**：当你使用 `git fetch pull/12/head` 时，Git 会从 GitHub 拉取指定 PR 的提交到本地的一个新分支（通常会创建一个本地分支，例如 `pull/12/head`）。
- **与目标分支合并**：你可以选择将这个 PR 分支合并到目标分支（例如 `base`），或者查看这个 PR 的提交差异。
- **保留提交历史**：这将保留 PR 分支的提交历史，使得你能够看到每个提交以及它们的变更。如果你选择合并这些提交，它们将以合并提交的形式进入目标分支。
  
#### 示例：
```bash
git fetch origin pull/12/head:pr-branch
git checkout base
git merge pr-branch
```

这种方法适用于你希望保留 PR 分支的提交历史，并且希望从远程仓库获取 PR 数据。

### 2. **通过 `.patch` 链接应用 PR 补丁**

- **直接应用补丁**：当你使用 `.patch` 文件时，Git 会将 PR 的提交作为补丁（patch）文件应用到目标分支。补丁文件是通过 `git format-patch` 生成的，其中包含所有更改的文件和提交信息。你可以使用 `git am` 将这些补丁文件应用到目标分支。
- **不保留提交历史**：这种方法不会保留 PR 分支的提交历史。所有 PR 的提交会被压缩成一个或多个补丁文件，然后直接应用到目标分支。补丁中的提交不会作为单独的 Git 提交存在，而是作为一个新的提交或一系列新提交加入到目标分支。
- **适用于对代码做修改而不关注提交历史的情况**：如果你不关心 PR 提交的具体历史，只希望将 PR 的修改应用到你的分支中，这种方法更简洁。

#### 示例：
```bash
curl -L https://github.com/octocat/Hello-World/pull/12.patch -o pr-12.patch
git am pr-12.patch
```

### 3. **两者的主要区别**

| 特性                             | `git fetch pull/12/head`                                   | `.patch` 文件（`git am`）                           |
|----------------------------------|-----------------------------------------------------------|----------------------------------------------------|
| **拉取方式**                     | 拉取整个 PR 分支并在本地创建一个对应的分支。                 | 拉取并应用补丁文件，通常不会创建新的分支。           |
| **提交历史**                     | 保留完整的提交历史，包括每个提交和提交信息。               | 不保留 PR 的提交历史，提交通常作为一个新的提交被添加到目标分支。 |
| **适用场景**                     | 适用于需要保留 PR 提交历史或想要拉取整个 PR 分支内容的情况。 | 适用于只关心合并 PR 代码内容而不需要保留历史记录的情况。 |
| **合并方式**                     | 使用 `git merge` 合并 PR 分支。                           | 使用 `git am` 将补丁文件应用到目标分支。              |
| **冲突处理**                     | 与普通的 Git 合并一样，可能会有合并冲突。                   | 需要手动解决冲突，`git am` 会在冲突时暂停。            |

### 总结

- 如果你希望 **保留 PR 的完整提交历史** 或 **合并整个 PR 分支**，使用 `git fetch pull/12/head` 会更合适。
- 如果你只关心 **将 PR 的更改作为补丁应用到你的分支**，并且不需要保留完整的提交历史，使用 `.patch` 文件和 `git am` 更加简洁。

两者的效果确实可以达到类似的目的，但取决于你对提交历史的需求以及如何合并这些更改。