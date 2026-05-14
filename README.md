# gh-aw-demo

Demo repository per **GitHub Agentic Workflows** — talk di Giulio Sciarappa.

Un'applicazione web Node.js minimale ma funzionante, usata come contesto per dimostrare l'automazione agentica con GitHub Actions.

## Stack

- **Runtime:** Node.js 20+ con TypeScript
- **Framework:** Express.js 4
- **Storage:** In-memory store (nessun database esterno richiesto)
- **Build:** `tsc` (TypeScript compiler)

## Architettura

```
┌─────────────────────────────────────────────┐
│                Express.js                    │
│                                             │
│  /api/auth/login      POST  Autenticazione  │
│  /api/auth/register   POST  Registrazione   │
│  /api/users/me        GET   Profilo utente  │
│  /api/items           GET   Lista items     │
│  /api/items           POST  Crea item       │
│  /api/items/:id       PUT   Aggiorna item   │
│  /api/items/:id       DELETE Elimina item   │
│  /api/health          GET   Health check    │
│                                             │
│  Store: in-memory Map<string, T>            │
└─────────────────────────────────────────────┘
```

## Setup locale

```bash
npm install
npm run dev        # dev server con hot-reload
npm run build      # compila TypeScript → dist/
npm start          # avvia la build compilata
npm run typecheck  # verifica tipi senza emettere file
```

## Come contribuire

1. Apri una issue descrivendo il problema o la feature richiesta
2. Forka il repository
3. Crea un branch per la tua modifica
4. Apri una Pull Request

## Known Issues

- L'autenticazione usa token demo (non JWT reali)
- Il password hashing è un placeholder (non bcrypt)
- Lo store è in-memory, i dati si perdono al restart
- Nessuna validazione input avanzata sulle route

## License

MIT
