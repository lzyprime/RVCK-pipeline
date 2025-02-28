#!/bin/python3

import json
import os

all_keys = ["pr_id", "pr_id_url", "REPO", "testcase_url", 'dst_pr', "dst_pr_sha"]

def write_properties_file(info:dict):
    assert all([k in all_keys for k in info])
    for k, v in info.items():
        if v is None:
            continue
        open(k, 'w').write(str(v))


def issue_comment(payload: dict):
    """pr|issue comment 触发"""

    # comment 创建
    if payload["action"] != "created":
        return

    if "pull_request" in payload["issue"]:  # pr
        # 解析评论内容
        comment_items = str(payload["comment"]["body"]).strip().split()
        if comment_items[0] != "/check" or len(comment_items) > 2:
            print("comment:", str(
                payload["comment"]["body"]).strip(), "| ignore")
            return
        cmd_output = os.popen(f'gh pr view {payload["issue"]["number"]} --json baseRefOid,baseRefName -R {payload["repository"]["clone_url"]}').read()
        print("gh pr view:", cmd_output)
        pr_info = json.loads(cmd_output)
        print(f"from pr comment")

        write_properties_file({
            "pr_id": payload["issue"]["number"],
            "pr_id_url": payload["issue"]["pull_request"]["html_url"],
            "REPO": payload["repository"]["clone_url"],
            "testcase_url": comment_items[1] if len(comment_items) == 2 else None,
            'dst_pr': pr_info["baseRefName"],
            "dst_pr_sha": pr_info["baseRefOid"],
        })

    else:  # 普通issue
        pass


def pull_request(payload: dict):
    # pr 创建
    if payload["action"] != "opened":
        return
    comment_items = str(payload["pull_request"]["body"]).strip().split()
    if comment_items[0] != "/check" or len(comment_items) > 2:
        print("comment:", str(
            payload["pull_request"]["body"]).strip(), "| ignore")
        return

    print("from pr opened")

    write_properties_file({
        "pr_id": payload["number"],
        "pr_id_url": payload["pull_request"]["url"],
        "REPO": payload["repository"]["clone_url"],
        "testcase_url": comment_items[1] if len(comment_items) == 2 else None,
        "dst_pr":payload["pull_request"]["base"]["sha"]["ref"],
        "dst_pr_sha":payload["pull_request"]["base"]["sha"],
    })

def issues(payload: dict):
    pass


support_actions = {
    i.__name__: i
    for i in [issue_comment, pull_request, issues]
}


def main():
    gh_event = os.getenv("x_github_event", "")

    if gh_event not in support_actions:
        raise Exception("unknown event:", gh_event)

    support_actions[gh_event](payload=json.loads(os.getenv("payload", '{}')))


if __name__ == "__main__":
    main()
