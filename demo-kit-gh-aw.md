# 🎬 Demo Kit — GitHub Agentic Workflows

## Panoramica

Demo in 3 atti (~20 minuti) che mostra l'intero ciclo di vita di un agentic workflow:
dal Markdown alla PR/issue generata automaticamente.

**Workflow scelto:** Issue Triage Agent — il più visivo e immediato per il pubblico.

---

## Pre-requisiti (da fare PRIMA del talk)

### 1. Crea il repo di demo

```bash
# Crea un repo pubblico (il pubblico lo vedrà)
gh repo create giuliosciarappa/gh-aw-demo --public --clone
cd gh-aw-demo

# Aggiungi un README di base per dare contesto all'agente
cat > README.md << 'EOF'
# gh-aw-demo

Demo repository per GitHub Agentic Workflows.

Questo progetto è un'applicazione web Node.js con:
- Backend Express.js
- Frontend React
- Database PostgreSQL
- CI/CD con GitHub Actions

## Come contribuire

Apri una issue descrivendo il problema o la feature richiesta.
EOF

git add README.md
git commit -m "Initial commit"
git push
```

### 2. Installa gh-aw CLI

```bash
# Installa l'estensione
gh extension install github/gh-aw

# Verifica
gh aw version
```

### 3. Inizializza il repo

```bash
gh aw init --engine copilot
```

Questo crea:
- `copilot-setup-steps.yml` (ambiente runtime dell'agente)
- La struttura `.github/workflows/`

### 4. Configura il secret

```bash
# Crea un Fine-grained PAT su github.com/settings/personal-access-tokens/new
# Account permissions → Copilot Requests → Read-only
# Poi:
gh secret set COPILOT_GITHUB_TOKEN -R giuliosciarappa/gh-aw-demo
```

### 5. Prepara le issue di test

Crea 3-4 issue che l'agente triagerà durante la demo.
Crearle il giorno prima così esistono già nel repo.

```bash
# Issue 1: Bug classico
gh issue create \
  --title "App crashes on login with special characters in password" \
  --body "When I try to login with a password containing '&' or '<', the app returns a 500 error. 
  
Steps to reproduce:
1. Go to /login
2. Enter username: test@example.com
3. Enter password: p@ss&word<123
4. Click Login

Expected: successful login
Actual: 500 Internal Server Error

Stack trace shows an unescaped HTML entity in the SQL query.
This might be a security issue (SQL injection?)."

# Issue 2: Feature request
gh issue create \
  --title "Add dark mode support" \
  --body "It would be great to have a dark mode option in the app.

Many users work late at night and the bright white background is hard on the eyes.

Could we add a toggle in the settings page? 
Ideally it should respect the OS preference too (prefers-color-scheme)."

# Issue 3: Documentazione
gh issue create \
  --title "README is missing API documentation" \
  --body "The README doesn't include any information about the REST API endpoints.

New developers joining the team have no idea how to use the API.
We need at least a basic list of endpoints with request/response examples."

# Issue 4: Bug vago (per mostrare che l'agente chiede chiarimenti)
gh issue create \
  --title "It doesn't work" \
  --body "The thing is broken. Please fix."
```

### 6. Prepara il workflow (ma NON pusharlo ancora)

Salva questo file localmente, lo creerai live durante la demo:

```bash
mkdir -p .github/workflows
```

Il contenuto del workflow lo scriverai in tempo reale (vedi Atto 1 della scaletta).

### 7. Backup: salva un run già completato

Fai un run completo prima del talk e salva gli screenshot/log:

```bash
# Dopo aver fatto un run di test completo:
gh aw logs issue-triage --json > backup-logs.json

# Screenshot della issue triagata (con label e commento dell'agente)
# Screenshot della tab Actions con i 3 job (agent, threat-detect, write)
# Screenshot dei log dell'agente che ragiona
```

---

## Scaletta Demo (~20 minuti)

### Atto 1 — "Write" (5 min)

**Cosa fai:** Scrivi il workflow .md dal vivo nel terminale.

```bash
# Apri il terminale, mostra il repo
cd gh-aw-demo
ls -la .github/workflows/
# (vuoto o solo copilot-setup-steps.yml)
```

**Crea il file live** (usa `cat` o il tuo editor preferito — VS Code è più visivo):

```bash
cat > .github/workflows/issue-triage.md << 'WORKFLOW'
---
name: Issue Triage Agent
description: Automatically triage, label and comment on new issues

on:
  issues:
    types: [opened]
  workflow_dispatch:

permissions:
  contents: read
  issues: read

safe-outputs:
  add-labels:
    allowed:
      - bug
      - feature
      - enhancement
      - documentation
      - question
      - help-wanted
      - good-first-issue
      - security
      - needs-info
      - duplicate
      - priority-high
      - priority-medium
      - priority-low
  add-comment:

tools:
  github:
    toolsets: [repos, issues]
---

# Issue Triage Agent

You are an expert issue triage agent for this repository.

## Your task

Analyze the current issue that triggered this workflow and perform triage:

1. **Read the issue** title and body carefully
2. **Read the repository** README and recent issues for context
3. **Classify** the issue by type (bug, feature, documentation, question, etc.)
4. **Assess priority** based on severity and impact (high, medium, low)
5. **Check for duplicates** among open issues
6. **Add appropriate labels** from the allowed set
7. **Post a helpful comment** with:
   - Your classification reasoning
   - Priority assessment
   - Suggested next steps
   - If the issue is unclear, ask specific clarifying questions

## Guidelines

- Be friendly and welcoming to contributors
- If the issue mentions security concerns, always add the "security" label and flag as priority-high
- If the issue description is too vague, add "needs-info" and ask clarifying questions
- Never close issues, only label and comment
- Write comments in English
WORKFLOW
```

**Talking points durante la scrittura:**
- "Notate: è un file Markdown. Frontmatter YAML per la configurazione, poi linguaggio naturale per le istruzioni."
- "I `safe-outputs` definiscono cosa l'agente PUÒ fare — nient'altro."
- "La lista `allowed` è un vincolo: l'agente non può inventare label."
- "`tools.github.toolsets` limita l'agente a repo e issue: niente permessi inutili."
- "Le `permissions` sono read-only: l'agente legge, non scrive direttamente."

---

### Atto 2 — "Compile" (5 min)

**Cosa fai:** Compili il workflow e mostri il risultato.

```bash
# Compila
gh aw compile issue-triage

# Mostra cosa ha generato
ls -la .github/workflows/
# → issue-triage.md (il tuo sorgente)
# → issue-triage.lock.yml (il workflow compilato)

# Apri il .lock.yml e fai vedere la struttura
cat .github/workflows/issue-triage.lock.yml
```

**Talking points durante il compile:**
- "Il compiler ha generato un workflow Actions completo con 3 job separati."
- "Job 1: `agent` — gira in un container sandboxed, token read-only, network firewall attivo."
- "Job 2: `threat-detect` — valida l'output dell'agente prima di scrivere qualsiasi cosa."
- "Job 3: `write` — ha il token scoped per la scrittura, esegue solo i safe-outputs validati."
- "Fate il diff mentale: 40 righe di Markdown → 200+ righe di YAML hardened. Gratis."

```bash
# Se vuoi mostrare le righe:
wc -l .github/workflows/issue-triage.md .github/workflows/issue-triage.lock.yml
```

**Push:**

```bash
git add .github/workflows/
git commit -m "Add issue triage agentic workflow"
git push
```

---

### Atto 3 — "Run" (10 min)

**Opzione A: Dispatch manuale (più controllabile sul palco)**

```bash
# Trigger manuale sul workflow
gh aw run issue-triage
```

Oppure crea una issue live:

```bash
gh issue create \
  --title "Database connection timeout under load" \
  --body "When we have more than 100 concurrent users, the PostgreSQL connection pool exhausts and new requests get a timeout error after 30s.

This is happening in production since the last deploy (v2.3.1).
Error: FATAL: too many connections for role 'webapp'

This is blocking our users. Please investigate urgently."
```

**Mentre l'agente lavora (~2-3 minuti), mostra:**

1. **Tab Actions su GitHub** — il workflow in esecuzione, i 3 job visibili
2. **Log dell'agent job** — l'agente che:
   - Legge il README del repo
   - Analizza la issue
   - Ragiona sulla classificazione
   - Decide i label
   - Compone il commento
3. **Log del threat-detect job** — la validazione dell'output
4. **Log del write job** — l'esecuzione dei safe-outputs

**Risultato finale:** Torna sulla issue e mostra:
- I label applicati automaticamente (es. `bug`, `priority-high`)
- Il commento dell'agente con analisi, priorità e suggerimenti

**Opzione B: Mostra anche la issue vaga**

Se hai tempo, apri la issue #4 ("It doesn't work") e mostra che l'agente:
- Aggiunge `needs-info`
- Commenta chiedendo dettagli specifici

**Plot twist finale (se hai 2-3 minuti extra):**

Modifica il workflow live per aggiungere un comportamento:

```bash
# Aggiungi al body del .md:
echo '
## Additional rule
If an issue mentions "production" or "prod", always add priority-high label 
and include "⚠️ PRODUCTION IMPACT" at the top of your comment.
' >> .github/workflows/issue-triage.md

# Non serve ricompilare! Le modifiche al body sono immediate.
git add . && git commit -m "Add production rule" && git push
```

"Notate: non ho ricompilato. Le modifiche al body (istruzioni) hanno effetto immediato.
Solo le modifiche al frontmatter (configurazione) richiedono `gh aw compile`."

---

## Checklist pre-talk

```
[ ] Repo creato e pubblico
[ ] gh-aw installato e funzionante
[ ] gh aw init completato
[ ] COPILOT_GITHUB_TOKEN configurato
[ ] 4 issue di test create
[ ] Run di backup completato con successo
[ ] Screenshot dei risultati salvati (fallback)
[ ] Terminale con font grande (almeno 18pt)
[ ] Browser loggato su GitHub con il repo aperto
[ ] Tab Actions già aperta in background
[ ] Connessione internet testata (tethering come backup)
[ ] File .md del workflow pronto in un buffer (per il copia-incolla di emergenza)
```

## Fallback plan

Se la rete non funziona o l'agente ci mette troppo:

1. Mostra il .md e il .lock.yml già preparati (diff side-by-side)
2. Apri i log del run di backup salvato
3. Mostra le issue già triagiate dal run precedente
4. Il messaggio chiave passa comunque: "40 righe di Markdown → automazione completa con 5 livelli di sicurezza"

## Consigli per la presentazione

- **Font del terminale grande** (18-20pt) — il pubblico in fondo alla sala deve leggere
- **Usa un tema dark** nel terminale e nel browser (coerente con le slide)
- **Splitta lo schermo**: terminale a sinistra, browser (GitHub) a destra
- **Non leggere il codice**: scrivi e spiega a voce cosa stai facendo
- **Il momento wow** è quando i label appaiono sulla issue — fai una pausa drammatica
- **Se l'agente sbaglia** (può succedere): è un ottimo talking point! "Ecco perché servono i safe-outputs e la human review"
