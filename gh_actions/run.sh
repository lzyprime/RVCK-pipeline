#!/bin/bash
set -e

if [ "$REPO" = "" ] || [ "$ISSUE_ID" = "" ]; then
    echo "'REPO' and 'ISSUE_ID' is required"
    exit 1
fi


if [ "$COMMENT_CONTENT" != "" ]; then
    #gh issue view "$ISSUE_ID" --json comments --jq '.comments|.[-1]|.body' -R "$REPO"
    gh issue comment "$ISSUE_ID" -b "$COMMENT_CONTENT" -R "$REPO"
    #gh issue view "$ISSUE_ID" --json comments --jq '.comments|.[-1]|.body' -R "$REPO"
    #set +x
fi

if [ "$REMOVE_LABEL" != "" ]; then
    set -x
    #gh issue view "$ISSUE_ID" --json labels --jq '.labels|.[]|.name' -R "$REPO"
    gh issue edit "$ISSUE_ID" --remove-label "$REMOVE_LABEL" -R "$REPO" || true
    #gh issue view "$ISSUE_ID" --json labels --jq '.labels|.[]|.name' -R "$REPO"
    set +x
fi

if [ "$ADD_LABEL" != "" ]; then
    set -x
    #gh issue view "$ISSUE_ID" --json labels --jq '.labels|.[]|.name' -R "$REPO"
    gh issue edit "$ISSUE_ID" --add-label "$ADD_LABEL" -R "$REPO"
    #gh issue view "$ISSUE_ID" --json labels --jq '.labels|.[]|.name' -R "$REPO"
    set +x
fi
