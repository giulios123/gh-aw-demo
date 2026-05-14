# 🎬 Cheat Sheet Demo — tieni aperto durante il talk

## Atto 1 — Write (5 min)

```bash
# Mostra il repo
cd gh-aw-demo
ls -la .github/workflows/

# Mostra il workflow .md (scritto in anticipo)
cat .github/workflows/issue-triage.md
```

**Talking points:**
- "È un file Markdown. Frontmatter YAML + linguaggio naturale."
- "safe-outputs: l'agente PUÒ fare solo questo, nient'altro."
- "tools.github.toolsets: limitiamo l'agente a repos e issues, senza permessi PR inutili."
- "permissions: read-only. L'agente legge, non scrive."


## Atto 2 — Compile (5 min)

```bash
# Compila (se non già fatto, altrimenti mostra il risultato)
gh aw compile issue-triage

# Confronto dimensioni
wc -l .github/workflows/issue-triage.md .github/workflows/issue-triage.lock.yml

# Mostra la struttura del .lock.yml
cat .github/workflows/issue-triage.lock.yml
```

**Talking points:**
- "40 righe Markdown → 200+ righe YAML hardened. Gratis."
- "3 job: agent (read-only), threat-detect, write (scoped)"
- "Network firewall, sandboxing, SHA pinning — tutto automatico"


## Atto 3 — Run (10 min)

```bash
# Opzione A: trigger manuale
gh aw run issue-triage

# Opzione B: crea issue live
gh issue create \
  --title "Database connection timeout under load" \
  --body "Production is down since v2.3.1. FATAL: too many connections."
```

**Mentre l'agente lavora (~2-3 min):**
1. Mostra tab Actions → workflow in esecuzione
2. Mostra log agent job → l'agente che ragiona
3. Mostra log threat-detect → validazione output
4. Mostra log write → esecuzione safe-outputs

**Risultato:** torna sulla issue → label + commento generato


## Plot Twist (se hai tempo)

```bash
# Aggiungi regola al body del .md
echo '
## Additional rule
If an issue mentions "production" or "prod", always add priority-high
and include "⚠️ PRODUCTION IMPACT" at the top of your comment.
' >> .github/workflows/issue-triage.md

# NON serve ricompilare!
git add . && git commit -m "Add production rule" && git push
```

"Le modifiche al body sono immediate. Solo il frontmatter richiede compile."


## Comandi di emergenza

```bash
# Log ultimo run
gh aw logs issue-triage

# Status workflow
gh aw status

# Audit di un run
gh aw audit <run-id>
```
