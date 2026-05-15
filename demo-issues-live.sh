#!/usr/bin/env bash


# Installa l'estensione
gh extension install github/gh-aw

# Verifica
gh aw version

gh aw init --engine copilot

gh aw compile issue-triage

gh aw run issue-triage


set -euo pipefail

# Run this from the repository root when you want to create demo issues live.
# The Issue Triage workflow will process each new issue after creation.

# High-impact bug / security
gh issue create \
  --title "Webhook signature validation fails intermittently in production" \
  --body $'Since yesterday, incoming webhook requests from our payment provider are randomly rejected with a 401 error.\n\nObserved behavior:\n1. About 1 in 5 webhook deliveries fail\n2. The failures started after the last deployment\n3. Logs show: "invalid signature" even though the raw payload looks correct\n4. This is happening in production and some orders remain stuck in pending state\n\nExpected: webhook signatures should be validated consistently\nActual: intermittent 401 responses block order processing\n\nThis may have security implications because the validation logic seems unstable.'

# Feature request
gh issue create \
  --title "Add bulk export for users in admin dashboard" \
  --body $'Our support team needs a way to export users from the admin dashboard without querying the database manually.\n\nRequested behavior:\n1. Add an "Export CSV" action in the admin users page\n2. Allow filtering by signup date and account status\n3. Include email, role, createdAt, and lastLogin fields\n\nThis is not urgent, but it would save a lot of manual work for operations and customer support.'

# Vague mobile issue
gh issue create \
  --title "Search page feels broken on mobile" \
  --body $'Several teammates reported that the search page is "basically unusable" on their phones.\n\nI do not have precise reproduction steps yet, but people mentioned strange scrolling behavior and controls moving around.\n\nCan someone investigate what is going on and let me know what extra details would help?'

# Documentation gap
gh issue create \
  --title "API rate limiting behavior is undocumented" \
  --body $'While integrating a new client, we realized the repository does not explain whether the API has rate limits or what headers are returned when a client is throttled.\n\nWhat is missing:\n1. Any mention of per-user or per-token limits\n2. Response examples for 429 Too Many Requests\n3. Retry guidance for client applications\n\nThis is causing confusion for new developers and support engineers. We need the README or API docs updated.'

# Performance issue
gh issue create \
  --title "Item list endpoint becomes very slow with large datasets" \
  --body $'The /items endpoint responds quickly in local development, but in staging it becomes noticeably slow once the database has more realistic data.\n\nObserved behavior:\n1. Response time jumps from under 300ms to 6-8 seconds\n2. This happens when browsing pages beyond the first 2-3 results\n3. CPU usage on the API container spikes during these requests\n\nExpected: pagination should stay responsive with larger datasets\nActual: the endpoint becomes too slow for normal use\n\nThis is not a full outage yet, but it is starting to affect QA and internal demos.'

# Ambiguous UX report
gh issue create \
  --title "Notifications look wrong sometimes" \
  --body $'A few people said that notifications in the app sometimes look wrong, but the reports are inconsistent.\n\nI do not know yet if this is a visual bug, duplicate messages, or delayed delivery.\n\nPlease take a look and let me know which details, screenshots, or reproduction steps would help narrow it down.'

# Security-sensitive bug
gh issue create \
  --title "Password reset link can be reused after logout" \
  --body $'During a basic security review, we noticed that a password reset link appears to remain valid even after the user logs in and logs out again.\n\nObserved behavior:\n1. Request a password reset email\n2. Open the reset link and change the password\n3. Log in successfully with the new password\n4. Reuse the same reset link in another browser session\n\nExpected: the reset token should be invalidated immediately after first successful use\nActual: the same link still works for some time\n\nThis could allow account takeover if the email link is exposed, so please treat it as a security-sensitive bug.'

# Help wanted
gh issue create \
  --title "Help wanted: add seed data script for local demos" \
  --body $'It would help contributors a lot if the repo included a simple script to populate the database with demo users, items, and a few realistic transactions.\n\nRequested outcome:\n1. One command to seed local development data\n2. Safe to run multiple times without breaking existing rows\n3. Small enough dataset for demos, but realistic enough to show the UI properly\n\nI can help test this, but I probably cannot implement it end-to-end on my own.'

# Potential duplicate of bulk export
gh issue create \
  --title "Admin CSV export would be useful for support team" \
  --body $'Our support team often asks engineering to export user lists from the admin area.\n\nA CSV export from the admin dashboard would reduce manual work and speed up investigations. Useful filters would include account status and signup date.\n\nI am not sure whether this already exists somewhere else, but I could not find it in the current UI.'

# Needs-info case 1
gh issue create \
  --title "Checkout sometimes fails" \
  --body $'A couple of people mentioned that checkout sometimes fails, but we have not pinned down a reliable way to reproduce it yet.\n\nWhat we know so far:\n1. It seems to happen more often in the afternoon\n2. One person said it might involve discount codes\n3. Another person thought it happened only on Safari\n\nI do not know if this is a frontend issue, a payment issue, or bad test data. Please advise what logs, screenshots, account details, or steps would help isolate the problem.'

# Needs-info case 2
gh issue create \
  --title "User profile page looks weird for some accounts" \
  --body $'Support forwarded a few complaints saying that some user profile pages look weird, but the descriptions are inconsistent.\n\nPossible symptoms that were mentioned:\n1. Layout looks misaligned\n2. Some fields may be missing\n3. One report mentioned duplicated sections\n\nI do not currently have screenshots, affected user IDs, browser versions, or a clear repro path. Let me know exactly what information we should collect next.'

# Needs-info case 3
gh issue create \
  --title "Emails are delayed or missing" \
  --body $'We have a vague report that transactional emails are delayed or sometimes do not arrive, but the examples so far are incomplete.\n\nUnknowns:\n1. Which email types are affected\n2. Whether the issue is provider-side or app-side\n3. Whether the messages are delayed, dropped, or landing in spam\n\nThere are not enough details yet to investigate properly. Please ask the reporter for the most useful next data points.'