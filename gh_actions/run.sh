#!/bin/bash
set -e

CONFIG_all_labels="${CONFIG_all_labels:-}"


if [ "$REPO" = "" ] || [ "$ISSUE_ID" = "" ]; then
    echo "'REPO' and 'ISSUE_ID' is required"
    exit 1
fi


if [ "$ADD_LABLE" != "" ] || [ "$REMOVE_LABEL" != "" ]; then
    if [ "$SET_LABEL" != "" ]; then
        echo "SET_LABEL 和 ADD_LABEL,REMOVE_LABEL 不能同时使用"
        exit 1
    fi
fi

set -x
if [ "$COMMENT_CONTENT" != "" ]; then
    gh issue comment "$ISSUE_ID" -b "$COMMENT_CONTENT" -R "$REPO"
fi

if [ "$REMOVE_LABEL" != "" ]; then
    gh issue edit "$ISSUE_ID" --remove-label "$REMOVE_LABEL" -R "$REPO" || true
fi

if [ "$ADD_LABEL" != "" ]; then
    gh issue edit "$ISSUE_ID" --add-label "$ADD_LABEL" -R "$REPO"
fi

if [ "$SET_LABEL" != "" ]; then
    gh issue edit "$ISSUE_ID" --remove-label "$CONFIG_all_labels" -R "$REPO"
    gh issue edit "$ISSUE_ID" --add-label "$SET_LABEL" -R "$REPO"
fi
