---
description: Restart the opencode server (supervisor restarts it in ~1s)
---

Restart the opencode server. Run exactly this bash command:

```
nohup sh -c 'sleep 3; restart-opencode' >/dev/null 2>&1 &
```

It schedules a detached restart 3 seconds from now, so your reply can finish
streaming before the server goes down. After running it, reply with one short
sentence telling the user the server will restart in a few seconds and the
page may briefly disconnect — sessions are persisted and will still be there
after reload. Do not run anything else.
