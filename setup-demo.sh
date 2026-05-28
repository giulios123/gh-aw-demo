#!/bin/bash
set -e

# ╔══════════════════════════════════════════════════════════════╗
# ║  GitHub Agentic Workflows — Demo Setup Script               ║
# ║  Esegui questo script UNA VOLTA prima del talk              ║
# ╚══════════════════════════════════════════════════════════════╝

# ─── CONFIG ───
REPO_OWNER="giuliosciarappa"   # ← Cambia col tuo username GitHub
REPO_NAME="gh-aw-demo"
REPO_FULL="${REPO_OWNER}/${REPO_NAME}"

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  🚀 Demo Setup — GitHub Agentic Workflows               ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# ─── STEP 0: Verifica prerequisiti ───
echo "▸ [0/7] Verifica prerequisiti..."

if ! command -v gh &> /dev/null; then
    echo "  ✗ GitHub CLI (gh) non trovato. Installa: https://cli.github.com"
    exit 1
fi
echo "  ✓ GitHub CLI: $(gh --version | head -1)"

if ! gh auth status &> /dev/null 2>&1; then
    echo "  ✗ Non autenticato. Esegui: gh auth login --scopes repo,workflow"
    exit 1
fi
echo "  ✓ Autenticato su GitHub"

if ! gh extension list 2>/dev/null | grep -q "gh-aw"; then
    echo "  ⚠ gh-aw non installato. Installo ora..."
    gh extension install github/gh-aw
fi
echo "  ✓ gh-aw: $(gh aw version 2>/dev/null || echo 'installato')"

echo ""

# ─── STEP 1: Crea il repo su GitHub ───
echo "▸ [1/7] Creazione repository ${REPO_FULL}..."

if gh repo view "${REPO_FULL}" &> /dev/null 2>&1; then
    echo "  ⚠ Repository già esiste. Vuoi eliminarlo e ricrearlo? (y/N)"
    read -r answer
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        gh repo delete "${REPO_FULL}" --yes
        sleep 2
    else
        echo "  → Uso il repository esistente"
    fi
fi

if ! gh repo view "${REPO_FULL}" &> /dev/null 2>&1; then
    gh repo create "${REPO_FULL}" --public --description "Demo: GitHub Agentic Workflows — Continuous AI per la manutenzione del software"
    echo "  ✓ Repository creato"
else
    echo "  ✓ Repository esistente"
fi

echo ""

# ─── STEP 2: Init git e push iniziale ───
echo "▸ [2/7] Inizializzazione git e push..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "${SCRIPT_DIR}"

if [ ! -d .git ]; then
    git init
    git branch -M main
fi

git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/${REPO_FULL}.git"

git add -A
git commit -m "Initial commit: demo repo for GitHub Agentic Workflows talk" 2>/dev/null || echo "  → Nessuna modifica da committare"
git push -u origin main --force

echo "  ✓ Repository pushato"
echo ""

# ─── STEP 3: Inizializza gh-aw ───
echo "▸ [3/7] Inizializzazione gh-aw..."
echo "  ℹ Se gh aw init chiede conferme interattive, segui le istruzioni."
echo "  ℹ Seleziona 'copilot' come engine."
echo ""

gh aw init --engine copilot 2>/dev/null || echo "  → gh aw init potrebbe richiedere interazione manuale"

echo ""

# ─── STEP 4: Compila il workflow ───
echo "▸ [4/7] Compilazione workflow issue-triage..."

gh aw compile 2>/dev/null || gh aw compile issue-triage 2>/dev/null || echo "  ⚠ Compilazione potrebbe richiedere --approve"

if [ -f ".github/workflows/issue-triage.lock.yml" ]; then
    echo "  ✓ issue-triage.lock.yml generato"
    echo "  → Righe .md:       $(wc -l < .github/workflows/issue-triage.md)"
    echo "  → Righe .lock.yml: $(wc -l < .github/workflows/issue-triage.lock.yml)"
else
    echo "  ⚠ .lock.yml non generato — esegui manualmente:"
    echo "    gh aw compile issue-triage --approve"
fi

echo ""

# ─── STEP 5: Push dei file compilati ───
echo "▸ [5/7] Push dei file compilati..."

git add -A
git commit -m "Add issue triage agentic workflow" 2>/dev/null || true
git push

echo "  ✓ Workflow pushato"
echo ""

# ─── STEP 6: Configura il secret ───
echo "▸ [6/7] Configurazione COPILOT_GITHUB_TOKEN..."
echo ""
echo "  ╔═══════════════════════════════════════════════════════════╗"
echo "  ║  AZIONE MANUALE RICHIESTA                                ║"
echo "  ║                                                          ║"
echo "  ║  1. Vai su: github.com/settings/personal-access-tokens   ║"
echo "  ║  2. Crea un Fine-grained PAT                             ║"
echo "  ║  3. Account permissions → Copilot Requests → Read-only   ║"
echo "  ║  4. Copia il token e incollalo quando richiesto          ║"
echo "  ╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "  Vuoi configurare il secret ora? (y/N)"
read -r answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "  Incolla il token (non verrà mostrato):"
    gh secret set COPILOT_GITHUB_TOKEN -R "${REPO_FULL}"
    echo "  ✓ Secret configurato"
else
    echo "  → Configura manualmente con:"
    echo "    gh secret set COPILOT_GITHUB_TOKEN -R ${REPO_FULL}"
fi

echo ""

# ─── STEP 7: Crea le issue di test ───
echo "▸ [7/7] Creazione issue di test..."

# Issue 1: Bug con sospetto security
gh issue create -R "${REPO_FULL}" \
  --title "App crashes on login with special characters in password" \
  --body "When I try to login with a password containing '&' or '<', the app returns a 500 error.

**Steps to reproduce:**
1. Go to /login
2. Enter username: test@example.com
3. Enter password: p@ss&word<123
4. Click Login

**Expected:** successful login
**Actual:** 500 Internal Server Error

Stack trace shows an unescaped HTML entity in the SQL query.
This might be a security issue (SQL injection?)." 2>/dev/null && echo "  ✓ Issue #1: Bug + security concern" || echo "  ⚠ Issue #1 non creata"

sleep 1

# Issue 2: Feature request
gh issue create -R "${REPO_FULL}" \
  --title "Add dark mode support" \
  --body "It would be great to have a dark mode option in the app.

Many users work late at night and the bright white background is hard on the eyes.

Could we add a toggle in the settings page?
Ideally it should respect the OS preference too (prefers-color-scheme).

I think this would improve the UX significantly for power users." 2>/dev/null && echo "  ✓ Issue #2: Feature request" || echo "  ⚠ Issue #2 non creata"

sleep 1

# Issue 3: Documentazione mancante
gh issue create -R "${REPO_FULL}" \
  --title "README is missing API documentation" \
  --body "The README doesn't include any information about the REST API endpoints.

New developers joining the team have no idea how to use the API.
We need at least a basic list of endpoints with request/response examples.

Also, there's no mention of authentication flow or how to get a JWT token." 2>/dev/null && echo "  ✓ Issue #3: Documentation" || echo "  ⚠ Issue #3 non creata"

sleep 1

# Issue 4: Issue vaga (l'agente chiederà chiarimenti)
gh issue create -R "${REPO_FULL}" \
  --title "It doesn't work" \
  --body "The thing is broken. Please fix." 2>/dev/null && echo "  ✓ Issue #4: Vaga (test needs-info)" || echo "  ⚠ Issue #4 non creata"

sleep 1

# Issue 5: Production incident (per il plot twist finale)
issue_5_body=$(cat <<'EOF'
When we have more than 100 concurrent users, the PostgreSQL connection pool exhausts and new requests get a timeout error after 30s.

This is happening in production since the last deploy (v2.3.1).
Error: `FATAL: too many connections for role 'webapp'`

This is blocking our users in production. Please investigate urgently.

Metrics from Azure Monitor show the connection count spiking to 100 (pool max) around 14:30 UTC daily.
EOF
)
gh issue create -R "${REPO_FULL}" \
  --title "Database connection timeout under load" \
  --body "${issue_5_body}" 2>/dev/null && echo "  ✓ Issue #5: Production incident" || echo "  ⚠ Issue #5 non creata"

echo ""

# ─── SUMMARY ───
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  ✅ Setup completato!                                    ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "  Repository: https://github.com/${REPO_FULL}"
echo "  Workflow:   .github/workflows/issue-triage.md"
echo ""
echo "  ┌─────────────────────────────────────────────────────┐"
echo "  │ CHECKLIST PRE-TALK                                  │"
echo "  │                                                     │"
echo "  │ [ ] Verifica che il secret sia configurato          │"
echo "  │ [ ] Fai un run di test: gh aw run issue-triage      │"
echo "  │ [ ] Salva screenshot del risultato (fallback)       │"
echo "  │ [ ] Testa la connessione internet della venue       │"
echo "  │ [ ] Prepara tethering mobile come backup            │"
echo "  │ [ ] Terminale con font 18-20pt                      │"
echo "  │ [ ] Browser loggato su GitHub + tab Actions aperta  │"
echo "  └─────────────────────────────────────────────────────┘"
echo ""
echo "  Per lanciare la demo:"
echo "    gh aw run issue-triage"
echo ""
echo "  Per i log in tempo reale:"
echo "    gh aw logs issue-triage"
echo ""
