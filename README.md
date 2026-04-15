# Documentazione tecnica ufficiale — Plantly (`lib/`)

## Premessa e perimetro dell’analisi

Questa documentazione è basata **esclusivamente** sui file presenti nella cartella `lib/` fornita.  
Non sono stati analizzati file esterni a `lib/`, quindi questa documentazione **non copre**:

- `pubspec.yaml`
- asset reali
- configurazioni Android/iOS/Web
- regole Firestore
- icone/app launcher
- test automatici
- CI/CD

Di conseguenza, tutte le osservazioni qui riportate sono riferite al **layer applicativo Flutter** effettivamente presente nel codice.

---

## 1. 🧠 Overview del progetto

### Scopo dell’app
Plantly è un’app mobile Flutter orientata alla gestione semplificata delle piante domestiche. Dal codice attuale emergono tre aree principali:

- autenticazione utente
- visualizzazione di una home informativa
- visualizzazione di un “giardino virtuale”
- consultazione del profilo utente

### Problema che risolve
L’app mira a offrire un punto unico per:

- accesso/registrazione utente
- gestione di un’identità utente persistita
- consultazione rapida dello stato di piante e attività di cura

### Stato attuale del progetto
Lo stato attuale è quello di un **MVP in sviluppo** con una base architetturale già impostata ma con alcune parti ancora statiche o parziali.

In particolare:

- l’autenticazione email/password è implementata
- la persistenza del profilo utente su Firestore è implementata
- il login via **email o username** è supportato lato logica
- le schermate `Home` e `Garden` sono oggi **UI statiche/demo**
- la parte “piante” non è ancora collegata a repository o backend dedicati
- non risulta presente integrazione Google Sign-In in questa versione
- la navigazione principale authenticated/unauthenticated è già funzionante

### Tecnologie utilizzate nel codice analizzato
Dal codice risultano effettivamente presenti:

- **Flutter**
- **Material 3**
- **flutter_bloc**
- **Cubit + Bloc**
- **Equatable**
- **Firebase Core**
- **Firebase Authentication**
- **Cloud Firestore**
- **Google Fonts**
- pattern di accesso dati basato su **Repository**

---

## 2. 🏗 Architettura generale

### Stile architetturale adottato
L’architettura reale è una combinazione di:

- **presentation layer** con `pages/` e `widgets/`
- **state management** con `Bloc` e `Cubit`
- **data access** con `repositories/`
- **feature models** in `features/`

Non è una Clean Architecture completa in senso rigoroso, perché non esistono use case/interactor separati né domain layer puro. Tuttavia, la separazione dei livelli è già abbastanza chiara e vicina a una struttura scalabile.

### Struttura per livelli

#### UI — `pages/`
Contiene le schermate principali:

- `splash_screen.dart`
- `sign_in_page.dart`
- `sign_up_page.dart`
- `main_shell_page.dart`
- `home_page.dart`
- `garden_page.dart`
- `profile_page.dart`

Ruolo: rendering della UI e interazione con Cubit/Bloc.

#### Widgets — `widgets/`
Contiene componenti riutilizzabili, anche se al momento il numero è limitato:

- `widgets/bottom_appbar/plantly_bottom_navigation.dart`
- `widgets/bottom_appbar/navigation_item.dart`
- `widgets/sign_up/password_strength.dart`
- `widgets/appbar.dart` è presente ma vuoto

#### Logica — `blocs/` e `cubits/`
La logica è distribuita in modo coerente:

- `AuthBloc` per lo stato di autenticazione globale
- Cubit dedicati per sign-in, sign-up, sign-out
- Cubit form per validazione e raccolta input
- Cubit per stato di visibilità password
- Cubit per navigazione auth secondaria (`AuthFlowCubit`)
- Cubit per caricamento profilo (`ProfileCubit`)

#### Repository — `repositories/`
Sono presenti due repository:

- `AuthRepository`
- `UserRepository`

Questa separazione è corretta:
- `AuthRepository` gestisce Firebase Auth
- `UserRepository` gestisce i documenti utente su Firestore e il lookup username/email

### Flusso dati reale

```text
UI (Page)
  -> Cubit/FormCubit
      -> Cubit di azione (SignInCubit / SignUpCubit / SignOutCubit / ProfileCubit)
          -> Repository
              -> Firebase Auth / Firestore

Firebase Auth authStateChanges
  -> AuthBloc
      -> MaterialApp builder listeners
          -> Navigazione globale
```

### Valutazione architetturale
Punti buoni:

- chiara separazione repository/logica/UI
- `AuthBloc` centrato sullo stream `authStateChanges`
- form validation non mescolata ai repository
- `UserRepository` separato da `AuthRepository`

Limiti attuali:

- assenza di un vero domain layer
- alcune page contengono ancora troppa UI custom interna anziché componenti riusabili
- parti statiche di prodotto (`Home`, `Garden`) non sono ancora collegate a uno stato applicativo reale
- `ProfilePage` innesca `watchProfile()` nel `build`, che è una side effect gestita con guardie ma non idealmente posizionata

---

## 3. 🔐 Sistema di autenticazione

### Come funziona `AuthBloc`
File coinvolti:

- `blocs/auth/auth_bloc.dart`
- `blocs/auth/auth_bloc_event.dart`
- `blocs/auth/auth_bloc_state.dart`

`AuthBloc` ha il compito di derivare lo stato auth globale direttamente da:

- `AuthRepository.authStateChanges`

Flusso:

1. il bloc si sottoscrive allo stream Firebase in fase di costruzione
2. ogni cambiamento genera `AuthUserChanged`
3. il bloc emette:
   - `AuthStatus.authenticated`
   - `AuthStatus.unauthenticated`
   - stato iniziale `AuthStatus.unknown`

### Stati disponibili
`AuthBlocState` modella:

- `unknown`
- `authenticated`
- `unauthenticated`

In stato `authenticated` viene mantenuto anche `fb.User user`.

### Ruolo di `AuthRepository`
`AuthRepository` incapsula Firebase Authentication e oggi espone:

- `currentUser`
- `authStateChanges`
- `signIn(email, password)`
- `signUp(email, password, displayName)`
- `signOut()`

Il repository fa bene il minimo necessario e non contiene logica di UI o navigazione.

### Flusso login
Login reale nel codice:

1. l’utente compila form in `SignInPage`
2. `SignInFormCubit` valida i campi
3. `SignInCubit.signIn(identifier, password)` riceve i dati
4. `UserRepository.resolveEmailFromIdentifier()` converte:
   - email → stessa email
   - username → email letta da Firestore
5. `AuthRepository.signIn()` esegue `signInWithEmailAndPassword`
6. Firebase emette il cambio auth
7. `AuthBloc` riceve il nuovo utente
8. `App` naviga verso `Routes.home`

### Flusso registrazione
Registrazione reale nel codice:

1. `SignUpFormCubit` valida username, nome, cognome, email, paese, città, password
2. `SignUpCubit.signUp(...)` controlla unicità username via Firestore
3. `AuthRepository.signUp(...)` crea l’utente in Firebase Auth
4. viene creato un `PlantlyUser`
5. `UserRepository.createUserProfile(...)` salva il profilo in `users/{uid}`
6. in caso di fallimento del salvataggio profilo, viene tentato `authUser.delete()`
7. il cambio auth viene rilevato da `AuthBloc`

### Flusso logout
`SignOutCubit` richiama `AuthRepository.signOut()`.  
Il logout non naviga direttamente: la navigazione dipende dal cambio emesso da Firebase e recepito da `AuthBloc`.

### Punti critici o migliorabili
1. **Username login dipendente da Firestore**  
   Se il documento profilo manca o è incoerente, il login con username non può funzionare.

2. **Unicità username non transazionale**  
   `usernameExists()` + `createUserProfile()` non garantiscono unicità assoluta in caso di richieste concorrenti.

3. **Assenza di provider multipli**  
   In questa versione non risultano Google Sign-In o altri provider.

4. **Rollback registrazione fragile ma accettabile**  
   Se Firestore fallisce dopo la creazione auth, il codice prova a cancellare l’utente auth. È una buona misura, ma non elimina tutti i possibili edge case.

---

## 4. 👤 Gestione utente

### Modello utente
File: `features/user/user.dart`

Il modello `PlantlyUser` contiene:

- `id`
- `username`
- `name`
- `surname`
- `email`
- `country`
- `city`
- `imageUrl`
- `bio`
- `createdAt`
- `updatedAt`

Sono presenti anche:

- `fullName`
- `usernameLowercase`
- `copyWith()`
- `toJson()`
- `fromJson()`

### Ruolo di `UserRepository`
File: `repositories/user_repository.dart`

Responsabilità reali:

- osservare un profilo utente (`watchUser`)
- caricare un profilo (`getUser`)
- verificare esistenza username (`usernameExists`)
- creare profilo (`createUserProfile`)
- aggiornare profilo (`updateUserProfile`)
- risolvere login `email/username` → email (`resolveEmailFromIdentifier`)

### Dati salvati
Nel documento utente Firestore vengono salvati:

- `id`
- `username`
- `username_lowercase`
- `name`
- `surname`
- `email`
- `country`
- `city`
- `imageUrl`
- `bio`
- `createdAt`
- `updatedAt`

### Flusso creazione profilo
Il profilo non viene creato da `AuthRepository`, ma da `SignUpCubit` attraverso `UserRepository`.  
Questa scelta è corretta perché separa:

- autenticazione
- dati utente applicativi

### Osservazioni tecniche
- il repository usa la collection `users`
- il document id è il `uid`
- `createdAt` e `updatedAt` sono scritti come stringhe ISO UTC, non come `serverTimestamp`
- `_fromFirestore()` supporta sia `Timestamp` sia stringa per la data

### Criticità
1. **Date come stringa**  
   Funzionano, ma sono meno robuste di `FieldValue.serverTimestamp()`.

2. **Dipendenza forte dal campo `username_lowercase`**  
   È corretta per il lookup, ma va considerata come chiave tecnica da preservare in tutte le future migrazioni.

3. **Assenza di schema validation lato backend**  
   Tutta la validazione è lato app. Per un ambiente production-ready serve rafforzamento via Firestore rules/backend.

---

## 5. 📱 Struttura delle pagine

### `pages/splash_screen.dart`
**Scopo**  
Schermata iniziale visuale con logo, titolo e animazione di caricamento.

**Ruolo nella navigazione**  
È la route iniziale (`Routes.splash`).

**Dipendenze principali**  
Nessuna dipendenza diretta da Cubit/Bloc.

**Osservazioni**
- non contiene logica di decisione routing
- la permanenza in splash dipende indirettamente al fatto che `AuthBloc` guiderà la navigazione quando emette stato diverso da `unknown`

**Criticità**
- la schermata non definisce un timeout né una strategia fallback se Firebase non inizializza o se lo stato auth resta `unknown`

---

### `pages/sign_in_page.dart`
**Scopo**  
Form di accesso con supporto a email o username + password.

**Ruolo nella navigazione**  
Schermata di ingresso per utenti non autenticati.

**Dipendenze principali**
- `SignInCubit`
- `SignInFormCubit`
- `ObscureCubit`
- `AuthFlowCubit`

**Comportamento**
- ascolta `SignInCubit` per mostrare errori con `SnackBar`
- usa `SignInFormCubit` per validazione
- usa `ObscureCubit` per mostrare/nascondere password
- usa `AuthFlowCubit` per passare a Sign Up

**Criticità**
- contiene molto markup UI monolitico: il form potrebbe essere scomposto in widget riutilizzabili
- la pagina usa direttamente `ScaffoldMessenger` e listener localizzati, cosa accettabile ma da standardizzare in futuro

---

### `pages/sign_up_page.dart`
**Scopo**  
Form di registrazione completa con dati profilo.

**Ruolo nella navigazione**  
Schermata di creazione account.

**Dipendenze principali**
- `SignUpCubit`
- `SignUpFormCubit`
- `ObscureCubit`
- `AuthFlowCubit`
- `PasswordStrength`

**Comportamento**
- raccoglie username, nome, cognome, email, paese, città, password, conferma password
- visualizza feedback di forza password
- usa validazione progressiva e validazione finale su submit

**Criticità**
- pagina molto lunga e fortemente monolitica
- i campi non sono stati estratti in widget form dedicati
- è una delle schermate più candidate a refactor di presentation

---

### `pages/main_shell_page.dart`
**Scopo**  
Contenitore principale authenticated con navigazione tab interna.

**Ruolo nella navigazione**
Espone tre tab:

- `HomePage`
- `GardenPage`
- `ProfilePage`

**Dipendenze principali**
- `PlantlyBottomNav`

**Comportamento**
- mantiene `_currentIndex`
- usa `IndexedStack`
- cambia tab con bottom navigation custom

**Criticità**
- la selezione tab è solo locale alla pagina; nessuna persistenza dello stato selezionato
- per un’app più grande, si potrebbe preferire una shell con router nested

---

### `pages/home_page.dart`
**Scopo**
Dashboard introduttiva con messaggi, metriche e checklist.

**Ruolo nella navigazione**
Prima tab nella shell authenticated.

**Dipendenze principali**
- `LightTheme`

**Comportamento reale**
- contenuto interamente statico
- usa widget privati `_SoftBadge`, `_MetricCard`, `_ChecklistTile`

**Criticità**
- nessun collegamento a stato reale, backend o repository
- ottima come UI demo, non ancora come feature di dominio

---

### `pages/garden_page.dart`
**Scopo**
Presentazione visiva del “giardino virtuale”.

**Ruolo nella navigazione**
Seconda tab nella shell authenticated.

**Dipendenze principali**
- modello `Plant`
- `LightTheme`

**Comportamento reale**
- contiene una lista statica `_plants`
- mostra carte planta con umidità, luce, salute e azione successiva
- pulsanti non collegati a use case reali

**Criticità**
- dati completamente mockati
- nessun `Cubit` o `Repository`
- nessuna persistenza o sincronizzazione

---

### `pages/profile_page.dart`
**Scopo**
Visualizzazione del profilo utente autenticato e logout.

**Ruolo nella navigazione**
Terza tab nella shell authenticated.

**Dipendenze principali**
- `AuthBloc`
- `ProfileCubit`
- `SignOutCubit`

**Comportamento**
- legge l’utente auth da `AuthBloc`
- avvia `watchProfile(authUser.uid)`
- mostra:
  - nome
  - email
  - username
  - località
  - stato di sincronizzazione

**Criticità**
- `watchProfile(authUser.uid)` viene chiamato dentro `build`
- il cubit contiene una guardia che limita le sottoscrizioni duplicate, ma il side effect nel `build` resta una scelta migliorabile
- logica di calcolo iniziali (`_initials`) è dentro la pagina; accettabile ma non idealmente riusabile

---

### `pages/fake_page.dart`
**Scopo**
Pagina placeholder con testo “prova”.

**Stato**
Presente nel progetto ma al momento non collegata al flusso principale.

**Criticità**
- codice morto / di supporto temporaneo
- da rimuovere o utilizzare esplicitamente

---

## 6. 🧩 Widget riutilizzabili

### `widgets/bottom_appbar/plantly_bottom_navigation.dart`
Bottom navigation personalizzata con tre voci:

- Home
- Giardino
- Profilo

Usata in:
- `MainShellPage`

### `widgets/bottom_appbar/navigation_item.dart`
Componente privato `_NavItem` usato esclusivamente dalla bottom nav.

### `widgets/sign_up/password_strength.dart`
Widget che visualizza:

- barre di forza password
- testo descrittivo

Usato in:
- `SignUpPage`

Dipende da:
- enum `Strength` in `features/enumType.dart`

### `widgets/appbar.dart`
File presente ma vuoto.

**Valutazione**
- è un forte indicatore di refactor incompleto o codice non ancora rimosso
- da eliminare o implementare realmente

---

## 7. 🧠 Bloc / Cubit

### `AuthBloc`
**Responsabilità**
Gestire lo stato auth globale basato su Firebase.

**Eventi**
- `AuthUserChanged`

**Stati**
- `unknown`
- `authenticated`
- `unauthenticated`

**Interazioni**
- ascolta `AuthRepository.authStateChanges`
- guida la navigazione globale tramite listener in `App`

---

### `SignInCubit`
**Responsabilità**
Orchestrare il login.

**Stati**
- `SignInInitial`
- `SignInLoading`
- `SignInSuccess`
- `SignInFailure`

**Interazioni**
- usa `UserRepository` per convertire username/email in email
- usa `AuthRepository` per autenticare

**Nota**
`SignInSuccess` è emesso, ma la navigazione non dipende da esso: dipende dal cambio auth globale. Questa scelta è corretta.

---

### `SignUpCubit`
**Responsabilità**
Orchestrare la registrazione completa utente.

**Stati**
- `SignUpInitial`
- `SignUpLoading`
- `SignUpSuccess`
- `SignUpFailure`

**Interazioni**
- controlla username via `UserRepository`
- crea auth account via `AuthRepository`
- crea profilo via `UserRepository`

---

### `SignOutCubit`
**Responsabilità**
Eseguire il logout.

**Stati**
- `SignOutInitial`
- `SignOutLoading`
- `SignOutSuccess`
- `SignOutFailure`

**Interazioni**
- usa `AuthRepository.signOut()`

---

### `ProfileCubit`
**Responsabilità**
Osservare e pubblicare lo stato del profilo utente.

**Stati**
- `ProfileInitial`
- `ProfileLoading`
- `ProfileLoaded`
- `ProfileFailure`

**Interazioni**
- usa `UserRepository.watchUser(userId)`
- mantiene una `StreamSubscription`

**Nota**
Ha una protezione contro chiamate ripetute allo stesso `userId`.

---

### `SignInFormCubit`
**Responsabilità**
Gestire stato e validazione del form di login.

**Campi**
- `identifier`
- `password`
- errori associati
- `showErrors`

**Interazioni**
- delega il submit a `SignInCubit`

---

### `SignUpFormCubit`
**Responsabilità**
Gestire stato e validazione del form di registrazione.

**Campi principali**
- `username`
- `nome`
- `cognome`
- `email`
- `country`
- `city`
- `password`
- `confirmPassword`
- errori per ogni campo
- `showErrors`
- `passwordStrength`

**Interazioni**
- delega il submit a `SignUpCubit`

---

### `ObscureCubit`
**Responsabilità**
Gestire visibilità password/confirm password.

**Stato**
- `password`
- `confirmPassword`

**Interazioni**
- usato nelle pagine auth

---

### `AuthFlowCubit`
**Responsabilità**
Gestire la transizione manuale tra Sign In e Sign Up.

**Stato**
- destinazione opzionale:
  - `signIn`
  - `signUp`

**Interazioni**
- consumato da `App` tramite listener

**Valutazione**
Funziona, ma è una soluzione locale e leggera, non un routing state manager completo.

---

## 8. 🔄 Routing e navigazione

### Come è gestito il routing
Il routing è gestito in `app.dart` tramite:

- `MaterialApp`
- `navigatorKey`
- `initialRoute`
- `onGenerateRoute`
- `MultiBlocListener` nel `builder`

### Ruolo di `app.dart`
`App` è il punto centrale della navigazione globale.  
Responsabilità reali:

- definire route map via `onGenerateRoute`
- applicare il tema
- ascoltare `AuthBloc`
- ascoltare `AuthFlowCubit`
- eseguire navigazioni tramite `navigatorKey`

### Uso di `navigatorKey`
`App` usa un `GlobalKey<NavigatorState>` interno per navigare senza dipendere dal contesto di una singola pagina.  
La funzione `_navigate()` usa `addPostFrameCallback` per evitare problemi se il bloc emette uno stato prima che il `Navigator` sia montato.

Questa è una scelta pragmatica e corretta per il problema risolto.

### Flusso splash → auth → home

```text
App start
  -> Route iniziale: SplashScreen
  -> AuthBloc ascolta Firebase authStateChanges
  -> quando lo stato passa da unknown a:
       authenticated   -> navigate(home)
       unauthenticated -> navigate(signIn)
```

### Criticità
- `SplashScreen` è solo visuale; la logica di decisione vive altrove
- `onGenerateRoute` restituisce `null` sul default; meglio prevedere una fallback route o error page
- l’architettura di routing è sufficiente per un MVP ma non ancora strutturata per feature complesse, deep linking o nested flows

---

## 9. 🎨 UI / Theme system

### Struttura del tema
Il tema è definito in:

- `features/theme/models/theme.dart`

Esiste una sola implementazione esplicita:
- `LightTheme.make`

### Palette colori
Colori principali definiti:

- `seed`
- `primary`
- `deepForest`
- `moss`
- `sand`
- `clay`
- `mist`

La palette è coerente con un prodotto “green/nature” ma evita il solo verde saturo, usando anche toni sabbia e terra.

### Tipografia
Il progetto usa:

- `GoogleFonts.interTextTheme`
- override di diversi stili:
  - `displayLarge`
  - `displaySmall`
  - `headlineMedium`
  - `titleLarge`
  - `titleMedium`
  - `bodyLarge`
  - `bodyMedium`

### Componenti tematizzati
Nel theme sono già configurati:

- `AppBarTheme`
- `CardTheme`
- `SnackBarTheme`
- `ElevatedButtonTheme`
- `OutlinedButtonTheme`
- `TextButtonTheme`
- `InputDecorationTheme`

### Coerenza design
Nel complesso la UI è visivamente coerente:

- uso sistematico di bordi arrotondati
- carte con ombre morbide
- gradiente leggero su molte schermate
- linguaggio visivo consistente tra Home, Garden e Profile

### Punti migliorabili
1. alcune schermate definiscono molto styling inline invece di appoggiarsi di più al theme
2. mancano componenti design-system riusabili per card, section header, empty state, form field wrapper
3. il file theme si trova sotto `features/theme/models/`, ma è di fatto un asset di **design system**, non un “model”

---

## 10. ⚠️ Problemi e criticità

### 10.1 Username uniqueness non atomica
Il controllo:

- `usernameExists()`
- poi `createUserProfile()`

non è atomico. In condizioni concorrenti due richieste possono superare il controllo e provare a usare lo stesso username.

**Soluzione consigliata**
- usare documento dedicato/indice per username
- oppure transazione Firestore

---

### 10.2 `ProfilePage` avvia side effect nel `build`
`watchProfile(authUser.uid)` è invocato nel `build`.

Il cubit evita sottoscrizioni ripetute, ma questa scelta resta fragile e meno leggibile.

**Soluzione consigliata**
- spostare l’avvio in un widget stateful con `initState`
- oppure creare la pagina con il `ProfileCubit` già istruito all’ingresso

---

### 10.3 `HomePage` e `GardenPage` sono statiche
Le due schermate principali di prodotto sono, allo stato attuale, quasi interamente demo UI.

**Implicazioni**
- l’MVP è credibile visivamente ma non ancora funzionale sul dominio piante
- manca uno state management dedicato alle piante

---

### 10.4 File vuoti o inutilizzati
- `widgets/appbar.dart` è vuoto
- `pages/fake_page.dart` sembra non usata nel flusso attuale

**Impatto**
- aumenta rumore nel codice
- peggiora l’onboarding dei nuovi sviluppatori

---

### 10.5 Validazione solo lato app
La validazione form è ben presente lato client, ma manca visibilità su enforcement lato backend/rules.

**Rischio**
- dati incoerenti se regole Firestore o altri client non applicano gli stessi vincoli

---

### 10.6 Date come stringhe
`createdAt` e `updatedAt` sono memorizzati come stringhe ISO.

**Rischi**
- sorting/query meno solide
- dipendenza da parsing client
- assenza di source-of-truth server-side

---

### 10.7 Assenza di gestione errori strutturata globale
Gli errori vengono mostrati con `SnackBar` direttamente nelle pagine.

**Limite**
- comportamento non centralizzato
- rischio di inconsistenza futura tra schermate

---

### 10.8 `SystemUiMode.immersiveSticky` in `main.dart`
Il progetto forza:

- `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)`

Per un’app gestionale/mobile standard questa scelta può essere discutibile.

**Rischi**
- UX inattesa
- comportamento non uniforme tra dispositivi
- potenziale attrito con pattern standard Android/iOS

---

### 10.9 `onGenerateRoute` senza fallback forte
Il default ritorna `null`.

**Rischio**
- route sconosciute non gestite con una schermata esplicita di errore

---

## 11. 🚀 Miglioramenti suggeriti

### Priorità alta

#### A. Rendere atomico l’username
Introdurre un meccanismo transazionale per garantire davvero unicità.

#### B. Introdurre `PlantRepository` e stato piante
Separare la feature piante dal mock attuale.  
Struttura minima suggerita:

- `repositories/plant_repository.dart`
- `cubits/garden/garden_cubit.dart`
- `features/plant/plant.dart` esteso
- collegamento Firestore o altro backend

#### C. Spostare il caricamento profilo fuori dal `build`
Rendere `ProfilePage` più pulita e side-effect free.

#### D. Pulire il codice morto
Rimuovere:
- `widgets/appbar.dart` se non serve
- `pages/fake_page.dart` se non serve

### Priorità media

#### E. Estrarre componenti riusabili dalle page auth
Dalle page `SignInPage` e `SignUpPage` si possono estrarre:

- auth card container
- branded header/logo section
- field wrappers
- footers di navigazione auth

#### F. Migliorare il layer di error handling
Introdurre eccezioni di dominio/app e mappatura errori più uniforme.

#### G. Migliorare il theme placement
Spostare il theme in un’area più centrale tipo:

- `core/theme/`
- oppure `presentation/theme/`

### Priorità bassa

#### H. Aggiungere route fallback
Pagina `NotFoundPage` o route error.

#### I. Introdurre test unitari e widget test
Particolarmente utili per:
- `AuthBloc`
- `SignInCubit`
- `SignUpCubit`
- `UserRepository`

---

## 12. 📈 Scalabilità futura

### Come evolvere il progetto

#### 1. Evoluzione feature autenticazione
Lo stato attuale è una buona base per estendere:

- Google Sign-In
- reset password
- verifica email
- completamento profilo post-provider esterni

L’integrazione andrebbe fatta **senza spostare logica nelle page**, mantenendo:

- repository per provider auth
- cubit/bloc per orchestrazione
- eventuale onboarding profilo separato

#### 2. Evoluzione feature piante
Per passare dal mock a una feature reale, il percorso corretto è:

```text
Plant model
  -> PlantRepository
  -> GardenCubit / PlantDetailsCubit
  -> Pages
```

Funzionalità future coerenti con la struttura attuale:

- lista piante reale per utente
- dettaglio pianta
- annaffiatura manuale
- cronologia eventi
- reminder e calendario
- sincronizzazione con vaso smart

#### 3. Evoluzione della navigazione
Per un MVP la navigazione attuale va bene.  
Se il prodotto cresce, sarà utile valutare:

- router dichiarativo
- route guards
- nested navigation
- gestione deep link

#### 4. Mantenere il codice pulito nel tempo
Regole consigliate per il team:

- nessuna logica repository nelle page
- nessuna navigazione business-driven nei repository
- form state separato dagli action cubit
- modelli dominio separati da DTO quando il backend cresce
- ogni nuova feature con struttura dedicata: page + cubit/bloc + repository + model

---

## Appendice A — Mappa sintetica dei file

### Entry points
- `main.dart`
- `app.dart`

### Core
- `core/routes.dart`

### Bloc
- `blocs/auth/auth_bloc.dart`
- `blocs/auth/auth_bloc_event.dart`
- `blocs/auth/auth_bloc_state.dart`

### Cubit
- `cubits/custom/obscure/obscure_cubit.dart`
- `cubits/forms/sign_in_form_cubit.dart`
- `cubits/forms/sign_up_form_cubit.dart`
- `cubits/navigation/auth_flow_cubit.dart`
- `cubits/profile/profile_cubit.dart`
- `cubits/profile/profile_state.dart`
- `cubits/sign_in/sign_in_cubit.dart`
- `cubits/sign_in/sign_in_state.dart`
- `cubits/sign_out/sign_out_cubit.dart`
- `cubits/sign_out/sign_out_state.dart`
- `cubits/sign_up/sign_up_cubit.dart`
- `cubits/sign_up/sign_up_state.dart`

### Models / Features
- `features/enumType.dart`
- `features/plant/plant.dart`
- `features/theme/models/theme.dart`
- `features/user/user.dart`

### Pages
- `pages/fake_page.dart`
- `pages/garden_page.dart`
- `pages/home_page.dart`
- `pages/main_shell_page.dart`
- `pages/profile_page.dart`
- `pages/sign_in_page.dart`
- `pages/sign_up_page.dart`
- `pages/splash_screen.dart`

### Repositories
- `repositories/auth_repository.dart`
- `repositories/user_repository.dart`

### Widgets
- `widgets/appbar.dart`
- `widgets/bottom_appbar/navigation_item.dart`
- `widgets/bottom_appbar/plantly_bottom_navigation.dart`
- `widgets/sign_up/password_strength.dart`

---

## Appendice B — Valutazione finale

### Cosa è già solido
- base auth ben impostata
- repository separati correttamente
- login con email o username già previsto
- buon livello di UX visiva per un MVP
- theme consistente
- separazione abbastanza chiara tra livelli

### Cosa oggi limita davvero il progetto
- feature “garden” ancora mockata
- alcuni punti architetturali non ancora puliti del tutto
- unicità username non blindata
- assenza di test
- alcuni file residui/incompleti

### Giudizio complessivo
Il progetto ha una base concreta da MVP e una struttura già idonea a evolvere, ma non è ancora production-ready in senso pieno.  
La parte più matura è il flusso auth/profilo; la parte meno matura è il dominio piante. La prossima evoluzione dovrebbe concentrarsi su:

1. robustezza dati utente
2. formalizzazione feature plants
3. pulizia del presentation layer
4. rafforzamento dei vincoli lato backend
