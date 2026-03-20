# Agenda Allan — Flutter Web + Android + Firebase Sync

> **Agenda inteligente com gamificação RPG, sincronização em tempo real e PWA instalável.**

---

## ✅ O que já está implementado

| Módulo | Status |
|---|---|
| Tela de Login (Google) | ✅ Pronto |
| Rotina (blocos + check-in + XP) | ✅ Pronto |
| Tarefas (Eisenhower matrix) | ✅ Pronto |
| Reuniões (agendamento + notificação) | ✅ Pronto |
| Compromissos (eventos pessoais) | ✅ Pronto |
| Diário (humor + energia) | ✅ Pronto |
| Stats (heatmap + KPIs) | ✅ Pronto |
| Perfil (XP + nível + streaks) | ✅ Pronto |
| Firebase Auth (Google Sign-In) | ✅ Pronto |
| Firebase Firestore (sync bidirecional) | ✅ Pronto |
| PWA instalável (web/manifest.json) | ✅ Pronto |
| GitHub Actions (APK + Web deploy) | ✅ Pronto |

---

## 🔥 Configurar Firebase (passo a passo)

### Passo 1 — Criar projeto Firebase

1. Acesse [console.firebase.google.com](https://console.firebase.google.com)
2. Clique **Adicionar projeto** → nome: `agenda-allan`
3. Desative Google Analytics (opcional) → **Criar projeto**

### Passo 2 — Adicionar app Android

1. Clique no ícone Android (🤖)
2. Nome do pacote: `com.allanvinicius.agendaallan`
3. Baixe o `google-services.json` e coloque em `android/app/google-services.json`
4. Copie os valores para `lib/firebase_options.dart` (seção android)

### Passo 3 — Adicionar app Web

1. Clique no ícone `</>` (Web)
2. Nome: `Agenda Allan Web` → **Registrar app**
3. Copie os valores `firebaseConfig` para `lib/firebase_options.dart` (seção web)

### Passo 4 — Ativar Authentication

1. No menu lateral: **Authentication → Começar**
2. Aba **Método de login** → Google → Ativar → Salvar
3. Em **Domínios autorizados**, adicione o domínio do Netlify depois do deploy

### Passo 5 — Ativar Firestore

1. No menu lateral: **Firestore Database → Criar banco de dados**
2. Modo: **Produção** → Região: `southamerica-east1`
3. Em **Regras**, substitua o conteúdo por:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🔐 Configurar GitHub Secrets (para CI/CD)

Vá em **Settings → Secrets and variables → Actions → New repository secret** e adicione:

| Secret | Onde encontrar |
|---|---|
| `FIREBASE_WEB_API_KEY` | Firebase → Configurações → Web app → apiKey |
| `FIREBASE_WEB_APP_ID` | Firebase → Configurações → Web app → appId |
| `FIREBASE_MESSAGING_SENDER_ID` | Firebase → Configurações → messagingSenderId |
| `FIREBASE_PROJECT_ID` | Firebase → Configurações → projectId |
| `FIREBASE_AUTH_DOMAIN` | Firebase → Configurações → authDomain |
| `FIREBASE_STORAGE_BUCKET` | Firebase → Configurações → storageBucket |
| `FIREBASE_ANDROID_API_KEY` | google-services.json → api_key[0].current_key |
| `FIREBASE_ANDROID_APP_ID` | google-services.json → mobilesdk_app_id |
| `NETLIFY_AUTH_TOKEN` | app.netlify.com → User settings → Personal access tokens |
| `NETLIFY_SITE_ID` | Netlify → Site → Site configuration → Site ID |

---

## 🌐 Deploy no Netlify (site web / PWA)

### Opção A — Via GitHub Actions (automático)

Depois de configurar os Secrets acima, todo `push` na branch `main`:
- Compila o APK Android
- Compila o Flutter Web
- Publica automaticamente no Netlify

### Opção B — Upload manual (primeiro deploy)

1. Faça o build local: `flutter build web --release`
2. Acesse [app.netlify.com](https://app.netlify.com)
3. Arraste a pasta `build/web/` para a área de upload
4. Copie o URL gerado (ex: `https://agenda-allan-xxx.netlify.app`)
5. Adicione esse domínio no Firebase Authentication → Domínios autorizados

---

## 📱 Instalar PWA no computador do trabalho (sem instalar nada)

1. Abra o Chrome e acesse `https://seu-site.netlify.app`
2. Na barra de endereço, clique no ícone **Instalar** (⊞)
3. Ou: Menu Chrome (⋮) → **Instalar Agenda Allan**
4. O app abre sem barra de navegador, igual a um app nativo

---

## 🔨 Build local

```bash
# Instalar dependências
flutter pub get

# Build APK
flutter build apk --release

# Build Web (PWA)
flutter build web --release

# Rodar no browser
flutter run -d chrome
```

---

## 📁 Estrutura do projeto

```
agenda_firebase/
├── lib/
│   ├── main.dart                    # Entrada do app
│   ├── firebase_options.dart        # Configuração Firebase
│   ├── models/
│   │   ├── models.dart              # Entidades Hive
│   │   └── models.g.dart            # Adapters gerados
│   ├── screens/
│   │   ├── login_screen.dart        # Login Google
│   │   ├── home_screen.dart         # Nav + sync bar
│   │   ├── rotina_screen.dart       # Blocos do dia
│   │   ├── tarefas_screen.dart      # To-do + Eisenhower
│   │   ├── reunioes_screen.dart     # Reuniões
│   │   ├── compromissos_screen.dart # Compromissos
│   │   ├── diario_screen.dart       # Diário pessoal
│   │   ├── stats_screen.dart        # Estatísticas
│   │   └── perfil_screen.dart       # Perfil + XP
│   ├── services/
│   │   ├── app_state.dart           # Estado global (Provider)
│   │   ├── sync_service.dart        # Firestore sync
│   │   └── notification_service.dart# Push notifications
│   ├── theme/
│   │   └── app_theme.dart           # Dark theme RPG
│   └── widgets/
│       ├── level_up_overlay.dart    # Animação level up
│       ├── lock_screen.dart         # PIN/senha
│       └── xp_badge.dart            # Badge de XP
├── web/
│   ├── index.html                   # PWA entry point
│   ├── manifest.json                # PWA manifest
│   ├── favicon.png                  # Favicon
│   └── icons/                       # Ícones PWA
├── android/                         # Configuração Android
├── .github/workflows/
│   └── build_and_deploy.yml         # CI/CD automático
├── netlify.toml                     # Config Netlify
└── pubspec.yaml                     # Dependências
```
