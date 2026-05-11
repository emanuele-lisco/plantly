# Documentazione tecnica ufficiale — Plantly

## 1. 🧠 Overview del progetto

### Scopo dell’app
Plantly è un’app Flutter per la gestione semplificata di piante domestiche, con una base architetturale già predisposta per:
- autenticazione utente
- persistenza del profilo su Firestore
- home informativa
- giardino virtuale demo
- ricerca piante placeholder
- futura estensione verso dominio plants reale e integrazione con dispositivi smart

### Problema che risolve
L’app fornisce una base concreta per:
- registrazione e login utente
- accesso con email/password, username/password e Google
- mantenimento di un profilo persistito separato da Firebase Auth
- visualizzazione di un’area autenticata coerente e già pronta a crescere

### Stato attuale del progetto
Lo stato reale è quello di un **MVP avanzato in sviluppo**, più maturo rispetto alle versioni precedenti della documentazione.

Funzionalità oggi presenti e realmente implementate nel codice:
- autenticazione email/password
- login via email o username
- Google Sign-In
- profilo utente persistito su Firestore
- onboarding di completamento profilo per utenti Google con dati mancanti
- shell autenticata con 4 tab
- home demo
- garden demo
- plant search placeholder
- profilo utente con ascolto realtime del documento Firestore
- helper globale per la visualizzazione di SnackBar

Funzionalità non ancora mature:
- dominio piante reale
- persistenza piante
- ricerca reale
- regole Firestore/verifica backend non documentate qui
- gestione avanzata di logging/monitoring errori

### Tecnologie effettivamente visibili nel codice
Dal codice verificato risultano presenti:
- Flutter
- Material 3
- flutter_bloc
- Equatable
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Google Sign-In
- Repository pattern

---

## 2. 🏗 Architettura generale

### Architettura reale
Il progetto adotta un layered approach pragmatico con una separazione dei livelli oggi più coerente di prima:
- `pages/` → UI e composizione schermate
- `widgets/` → componenti UI riutilizzabili
- `cubits/` e `blocs/` → logica e stato
- `repositories/` → accesso dati
- `features/` → modelli e risorse trasversali

Non è una Clean Architecture completa, perché mancano use case e domain layer dedicati, ma il progetto è ben oltre uno scheletro iniziale e ha una separazione già utilizzabile per sviluppo reale.

### Separazione dei livelli

#### UI — `pages/`
Attualmente contiene:
- `splash_screen.dart`
- `pages/sign_pages/sign_in_page.dart`
- `pages/sign_pages/sign_up_page.dart`
- `google_profile_completion_page.dart`
- `main_shell_page.dart`
- `home_page.dart`
- `garden_page.dart`
- `plant_search_page.dart`
- `profile_page.dart`
- `fake_page.dart`

**Aggiornamento importante:** `ProfilePage` non lancia più `watchProfile()` nel `build()`, ma in `initState()`. Questo chiude una criticità importante delle revisioni precedenti.

#### Widgets — `widgets/`
Oltre ai widget già presenti in precedenza, ora esistono anche sottosezioni dedicate:
- `widgets/auth/google_auth_button.dart`
- `widgets/bottom_appbar/plantly_bottom_navigation.dart`
- `widgets/feedback/snackbar_helper.dart`
- `widgets/garden/meter_row.dart`
- `widgets/garden/plant_card.dart`
- `widgets/profile/info_card.dart`
- `widgets/profile/info_user_model.dart`
- `widgets/profile/logout_button.dart`
- `widgets/profile/section_label.dart`
- `widgets/profile/stat_card.dart`
- `widgets/sign_up/password_strength.dart`

**Aggiornamento importante:** nella versione corrente non risulta più `widgets/appbar.dart`, quindi quel residuo di codice morto non è più presente nel nuovo `lib.zip` verificato.

#### Logica — `blocs/` e `cubits/`
Sono presenti:
- `AuthBloc`
- `SignInCubit`
- `SignUpCubit`
- `SignOutCubit`
- `ProfileCubit`
- `ShellCubit`
- `GoogleProfileCompletionCubit`
- `SignInFormCubit`
- `SignUpFormCubit`
- `GoogleProfileCompletionFormCubit`
- `AuthFlowCubit`
- `ObscureCubit`

**Aggiornamento importante:** `MainShellPage` usa `ShellCubit`, quindi lo stato tab non è più gestito con `setState()`.

#### Dati — `repositories/`
Sono presenti:
- `AuthRepository`
- `UserRepository`

**Aggiornamento importante:** `UserRepository` usa ora due collection:
- `users/{uid}`
- `usernames/{usernameLowercase}`

Questo cambia in modo sostanziale la strategia di gestione username rispetto alle versioni precedenti.

### Flusso dati reale

```text
Page
  -> FormCubit / ActionCubit
      -> Repository
          -> Firebase Auth / Firestore

Firebase authStateChanges
  -> AuthBloc
      -> App (MultiBlocListener)
          -> decisione routing globale
```

### Valutazione architetturale aggiornata
Punti forti:
- confini di layer più rispettati di prima
- nessun `setState()` nella shell autenticata
- introduzione di `SnackBarHelper` per uniformare i feedback UI
- navigazione auth/profilo incompleto centralizzata meglio in `App`
- onboarding Google separato in page + cubit dedicati

Punti deboli ancora presenti:
- assenza di domain/use-case layer
- alcuni file residui come `fake_page.dart`
- feature plants ancora mock
- qualche incoerenza nominale negli state file

---

## 3. 🔐 Sistema di autenticazione

### Come funziona `AuthBloc`
`AuthBloc` ascolta `AuthRepository.authStateChanges` e converte lo stream Firebase in stato globale dell’app.

Eventi:
- `AuthUserChanged`

Stati:
- `unknown`
- `authenticated`
- `unauthenticated`

**Aggiornamento importante:** ora la subscription a `authStateChanges` ha anche `onError`, quindi il bloc è più robusto rispetto alla versione precedente.

### Ruolo di `AuthRepository`
Responsabilità reali:
- login email/password
- registrazione email/password
- Google Sign-In
- logout
- esposizione di `currentUser` e `authStateChanges`

Metodi principali:
- `signIn(...)`
- `signUp(...)`
- `signInWithGoogle()`
- `signOut()`

### Flusso login email/username
1. l’utente compila il form in `SignInPage`
2. `SignInFormCubit` valida presenza dei campi
3. `SignInCubit.signIn()` chiama `UserRepository.resolveEmailFromIdentifier()`
4. se l’identificatore è email, viene usato direttamente
5. se è username, viene risolta l’email tramite `usernames/{username}`
6. `AuthRepository.signIn()` esegue il login Firebase
7. `AuthBloc` riceve il cambiamento auth
8. `App` legge il profilo Firestore e decide la navigazione

### Flusso registrazione email/password
1. `SignUpPage` raccoglie i dati
2. `SignUpFormCubit` valida il form
3. `SignUpCubit.signUp()` crea l’utente Firebase
4. costruisce un `PlantlyUser`
5. `UserRepository.createUserProfile()` scrive il profilo **e** l’indice username in transaction
6. se il salvataggio fallisce, prova a cancellare l’utente auth
7. `AuthBloc` rileva il login risultante e `App` naviga

**Aggiornamento importante:** la documentazione precedente parlava ancora di `usernameExists()` seguito da creazione non atomica come flusso principale. Nel codice corrente il repository usa una transaction e l’indice `usernames`, quindi il quadro è migliorato sensibilmente.

### Flusso Google Sign-In / Sign-Up
Il supporto Google è presente sia in sign-in sia in sign-up.

#### Web
`AuthRepository.signInWithGoogle()` usa:
- `FirebaseAuth.signInWithPopup(GoogleAuthProvider())`

#### Native
Usa:
- `GoogleSignIn.instance.initialize()`
- `authenticate()`
- conversione in Firebase credential
- `signInWithCredential(...)`

**Aggiornamento importante:** `_serverClientIdForCurrentPlatform()` non esiste più nel codice corrente. Questa criticità è stata rimossa.

### Onboarding profilo post-Google
Questo è uno dei cambi più importanti rispetto alla documentazione precedente.

Adesso esiste davvero:
- `GoogleProfileCompletionPage`
- `GoogleProfileCompletionCubit`
- `GoogleProfileCompletionFormCubit`

Flusso reale:
1. l’utente entra con Google
2. `ensureGoogleUserProfile()` garantisce l’esistenza di un profilo Firestore minimo
3. `App` controlla se il profilo è completo (`username`, `country`, `city`)
4. se il profilo è incompleto, naviga a `Routes.googleProfileCompletion`
5. l’utente completa i campi richiesti
6. il profilo viene aggiornato in Firestore
7. l’utente entra nell’area autenticata

Questa parte era segnalata come mancante nella documentazione precedente. Ora va considerata **implementata**.

### Flusso logout
`SignOutCubit` richiama `AuthRepository.signOut()`.

`AuthRepository.signOut()` esegue:
- `FirebaseAuth.signOut()`
- `GoogleSignIn.signOut()` in modalità safe

**Aggiornamento importante:** `_signOutFromGoogleSafely()` non usa più `catch (_) {}` silenzioso, ma logga con `debugPrint`.

### Punti critici o migliorabili aggiornati
1. **Il flusso Google è ora presente e funzionante a livello applicativo**  
   La documentazione precedente che lo dava come assente non è più valida.

2. **Il profilo incompleto Google è ora gestito**  
   Anche questa non è più una criticità architetturale aperta: resta solo da validarne bene il comportamento end-to-end con regole Firestore coerenti.

3. **`AuthRepository` è più pulito di prima**  
   La criticità su `_serverClientIdForCurrentPlatform()` è chiusa.

4. **Il logout resta migliorabile lato dettaglio eccezioni**  
   `SignOutCubit` usa ancora un catch generico.

---

## 4. 👤 Gestione utente

### Modello utente
File: `features/user/user.dart`

`PlantlyUser` contiene:
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
Responsabilità reali:
- osservare un profilo (`watchUser`)
- caricare un profilo (`getUser`)
- controllare esistenza username (`usernameExists`)
- creare un profilo (`createUserProfile`)
- aggiornare un profilo (`updateUserProfile`)
- risolvere email da username/email (`resolveEmailFromIdentifier`)
- creare automaticamente il profilo minimo per utenti Google (`ensureGoogleUserProfile`)
- verificare completezza minima (`isProfileComplete`)

### Struttura dati reale
Nel codice attuale esistono due collection distinte:

#### `users/{uid}`
Contiene:
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

#### `usernames/{usernameLowercase}`
Contiene:
- `uid`
- `email`
- `username`
- `updatedAt`

### Aggiornamento molto importante
La criticità “username non atomico” va aggiornata: **nel codice corrente la creazione e l’aggiornamento del profilo usano `runTransaction`** e sincronizzano anche l’indice `usernames`.

Quindi:
- la documentazione precedente era superata
- il problema non è più “mancanza totale di atomicità”
- resta comunque una dipendenza dalle regole Firestore corrette e dalla strategia complessiva, ma il codice è significativamente migliorato

### Criticità ancora aperte
1. **Date ancora salvate come stringhe ISO**  
   Questo punto resta valido: non vengono usati `serverTimestamp` o `FieldValue.serverTimestamp()`.

2. **Deserializzazione ancora duplicata**  
   `_fromFirestore()` nel repository e `PlantlyUser.fromJson()` nel model non sono ancora una singola fonte di verità.

3. **La privacy del login via username dipende dalle regole su `usernames`**  
   È una scelta architetturale pratica, ma richiede attenzione nella definizione delle regole Firestore.

---

## 5. 📱 Struttura delle pagine

### `pages/splash_screen.dart`
**Scopo**  
Schermata iniziale visiva.

**Aggiornamento importante**  
La robustezza del bootstrap non dipende più solo dalla splash: `main.dart` ha ora una UI fallback `_BootstrapErrorApp` se Firebase fallisce all’avvio.

### `pages/sign_pages/sign_in_page.dart`
**Scopo**  
Accesso con email/username e Google.

**Dipendenze**
- `SignInCubit`
- `SignInFormCubit`
- `ObscureCubit`
- `AuthFlowCubit`
- `GoogleAuthButton`
- `SnackBarHelper`

**Aggiornamento importante**  
La page usa ora `SnackBarHelper.showError(...)` invece di costruire manualmente la `SnackBar`.

### `pages/sign_pages/sign_up_page.dart`
**Scopo**  
Registrazione email/password e ingresso con Google.

**Dipendenze**
- `SignUpCubit`
- `SignUpFormCubit`
- `ObscureCubit`
- `AuthFlowCubit`
- `PasswordStrength`
- `GoogleAuthButton`
- `SnackBarHelper`

**Aggiornamento importante**  
Usa `SnackBarHelper` sia per errori sia per successi.

### `pages/google_profile_completion_page.dart`
**Scopo**  
Completare il profilo obbligatorio per utenti Google con dati mancanti.

**Dipendenze**
- `GoogleProfileCompletionCubit`
- `GoogleProfileCompletionFormCubit`
- `SnackBarHelper`

**Aggiornamento importante**  
Questa pagina ora è una parte reale e importante del flusso auth. Inoltre non crea più `TextEditingController` nel `build()`.

### `pages/main_shell_page.dart`
**Scopo**  
Shell autenticata con 4 tab:
- Home
- Garden
- Cerca
- Profilo

**Dettagli tecnici reali**
- `ShellCubit`
- `extendBody: true`
- `AnimatedSwitcher`
- `IndexedStack`
- `ValueKey(currentIndex)`

**Aggiornamento importante**  
Lo stato tab non è più gestito localmente con `setState()`, ma tramite `ShellCubit`.

### `pages/home_page.dart`
**Scopo**  
Dashboard informativa.

**Stato reale**  
UI demo/statica.

### `pages/garden_page.dart`
**Scopo**  
Giardino virtuale.

**Stato reale**  
Dati mock, ma componentizzata meglio tramite widget dedicati in `widgets/garden/`.

### `pages/plant_search_page.dart`
**Scopo**  
Placeholder per futura ricerca piante.

**Valutazione**  
Continua a essere un placeholder corretto e ben integrato.

### `pages/profile_page.dart`
**Scopo**  
Visualizzazione profilo utente e logout.

**Dipendenze**
- `AuthBloc`
- `ProfileCubit`
- `SignOutCubit`
- `SnackBarHelper`
- widget profilo dedicati

**Aggiornamento molto importante**  
La precedente criticità “`watchProfile()` nel build” è chiusa: `watchProfile(uid)` viene chiamato in `initState()`.

### `pages/fake_page.dart`
**Stato**  
Presente ma non parte del flusso principale.

**Valutazione**  
Continua a essere dead code/residuo.

---

## 6. 🧩 Widget riutilizzabili

### Nuovi elementi da documentare
Rispetto alla documentazione precedente, il catalogo widget è più ricco.

#### Auth / feedback
- `widgets/auth/google_auth_button.dart`
- `widgets/feedback/snackbar_helper.dart`

#### Bottom navigation
- `widgets/bottom_appbar/plantly_bottom_navigation.dart`
- `widgets/bottom_appbar/navigation_item.dart`

#### Sign-up
- `widgets/sign_up/password_strength.dart`

#### Garden
- `widgets/garden/meter_row.dart`
- `widgets/garden/plant_card.dart`

#### Profile
- `widgets/profile/info_card.dart`
- `widgets/profile/info_user_model.dart`
- `widgets/profile/logout_button.dart`
- `widgets/profile/section_label.dart`
- `widgets/profile/stat_card.dart`

### Aggiornamento importante
`SnackBarHelper` va considerato ora parte del design/feedback system del progetto.

---

## 7. 🧠 Bloc / Cubit

### `AuthBloc`
**Responsabilità**
- derivare lo stato auth globale da Firebase
- reagire agli errori dello stream auth con fallback a `unauthenticated`

### `SignInCubit`
**Responsabilità**
- login email/username
- login con Google
- bootstrap profilo Google minimo
- mapping errori Firebase e Google

**Aggiornamento importante**  
Non usa più `pendingProfileCompletion` né stati speciali di navigazione.

### `SignUpCubit`
**Responsabilità**
- registrazione email/password
- accesso/registrazione con Google
- creazione profilo utente

**Aggiornamento importante**  
Non usa più stati speciali di profile completion.

### `SignOutCubit`
**Responsabilità**
- logout

**Stato attuale**
- `SignOutInitial`
- `SignOutLoading`
- `SignOutSuccess`
- `SignOutFailure`

**Nota**  
È ancora uno dei pochi cubit che usa un catch generico senza dettaglio.

### `ProfileCubit`
**Responsabilità**
- ascolto realtime del profilo Firestore
- gestione subscribe/unsubscribe al documento utente

**Aggiornamento importante**  
La gestione della subscription è più robusta rispetto a prima.

### `ShellCubit`
**Responsabilità**
- gestire il tab index della shell autenticata

**Aggiornamento importante**  
Questo cubit è ora parte rilevante dell’architettura e va documentato esplicitamente.

### `GoogleProfileCompletionCubit`
**Responsabilità**
- completamento del profilo minimo richiesto dopo Google
- validazione di base lato action cubit
- create/update su Firestore tramite repository

### `GoogleProfileCompletionFormCubit`
**Responsabilità**
- stato e validazione del form di completamento profilo Google

### `SignInFormCubit`, `SignUpFormCubit`, `ObscureCubit`, `AuthFlowCubit`
Restano coerenti con quanto già documentato, ma il loro contesto è oggi più pulito grazie al refactor generale del flusso auth.

---

## 8. 🔄 Routing e navigazione

### Gestione del routing
Il routing resta centralizzato in `app.dart` con:
- `MaterialApp`
- `navigatorKey`
- `initialRoute`
- `onGenerateRoute`
- `MultiBlocListener`

### Ruolo aggiornato di `app.dart`
`App` oggi fa molto più di prima in modo strutturato:
- ascolta `AuthBloc`
- ascolta `AuthFlowCubit`
- decide `home` vs `googleProfileCompletion` sulla base del profilo Firestore
- crea la route di completamento profilo con i cubit dedicati
- offre una fallback route esplicita

### Flusso reale aggiornato
```text
App start
  -> SplashScreen
  -> Firebase bootstrap in main.dart
  -> AuthBloc ascolta authStateChanges
  -> se authenticated:
       App legge il profilo utente
       -> se completo: home
       -> se incompleto: googleProfileCompletion
  -> se unauthenticated: signIn
  -> AuthFlowCubit gestisce signIn <-> signUp
```

### Aggiornamento importante
La criticità “default route senza fallback” è chiusa: nel codice corrente esiste `_buildFallbackRoute(...)`.

### Criticità residue
- il routing è ancora molto centrato su `App` e richiede disciplina se in futuro aumentano i trigger di navigazione
- `_handleAuthenticatedUser(...)` contiene ancora una quota importante di orchestrazione

---

## 9. 🎨 UI / Theme system

### Struttura del tema
Il tema principale resta in:
- `features/theme/models/theme.dart`

### Coerenza visiva
La UI è oggi più coerente perché, oltre al theme, ha acquisito:
- widget dedicati per profile
- widget dedicati per garden
- helper centralizzato per feedback snackbar

### Punti migliorabili
- alcune page restano ancora ricche di styling inline
- la collocazione del theme in `features/theme/models/` resta poco semantica
- il design system non è ancora raccolto in una cartella dedicata

---

## 10. ⚠️ Problemi e criticità aggiornati

### 10.1 `fake_page.dart` ancora presente
**Gravità:** bassa  
**File:** `pages/fake_page.dart`

Resta dead code o residuo temporaneo.

### 10.2 Duplicazione di deserializzazione
**Gravità:** media  
**File:** `user_repository.dart`, `user.dart`

`_fromFirestore()` e `PlantlyUser.fromJson()` non sono ancora una singola fonte di verità.

### 10.3 Date come stringhe ISO
**Gravità:** media  
**File:** `user_repository.dart`, `user.dart`

Resta aperta la scelta di usare stringhe invece di timestamp server-side.

### 10.4 `SignOutCubit` usa catch generico
**Gravità:** media  
**File:** `sign_out_cubit.dart`

Il logout ha ancora una gestione errori poco granulare.

### 10.5 Rollback registrazione ancora migliorabile
**Gravità:** media  
**File:** `sign_up_cubit.dart`

Se `createUserProfile()` fallisce, viene tentata `authUser.delete()`, ma senza logging strutturato e senza recovery avanzata.

### 10.6 Regole Firestore non verificabili da `lib/`
**Gravità:** media  
**Contesto:** sistema

La correttezza del nuovo schema `users` + `usernames` dipende dalle regole Firestore effettive, che non sono verificabili in questo file zip.

### 10.7 Incoerenza naming negli state
**Gravità:** bassa  
**File:** state vari

Esempio: `SignInFailure.message`, `SignUpFailure.message`, ma `GoogleProfileCompletionFailure.error`.

### 10.8 `GoogleProfileCompletionState` usa ancora `abstract class`
**Gravità:** bassa  
**File:** `google_profile_completion_state.dart`

Non è un bug, ma resta una piccola incoerenza stilistica rispetto agli state più recenti.

### 10.9 `App` contiene ancora molta orchestrazione
**Gravità:** media  
**File:** `app.dart`

La navigazione è ora corretta, ma il file resta un punto sensibile del progetto.

### 10.10 Feature plants ancora mock
**Gravità:** media  
**File:** `home_page.dart`, `garden_page.dart`, `plant_search_page.dart`

Il prodotto è strutturalmente pronto, ma il dominio piante reale non è ancora implementato.

### Criticità risolte rispetto alla documentazione precedente
Questi punti **non vanno più riportati come aperti**:
- `watchProfile()` nel `build()`
- assenza del flusso Google profile completion
- `_serverClientIdForCurrentPlatform()` sempre `null`
- stato tab in `MainShellPage` gestito con `setState()`
- mancanza di route fallback
- assenza di gestione globale minima degli errori bootstrap
- assenza di helper globale per SnackBar

---

## 11. 🚀 Miglioramenti suggeriti aggiornati

### Priorità alta attuale
1. consolidare le regole Firestore coerenti con `users` + `usernames`
2. migliorare la gestione errori di `SignOutCubit`
3. valutare logging più strutturato nel rollback di registrazione
4. ridurre gradualmente l’orchestrazione contenuta in `app.dart`

### Priorità media
1. unificare `_fromFirestore()` e `fromJson()`
2. sostituire le date stringa con timestamp reali
3. continuare l’adozione del feedback globale centralizzato dove manca
4. iniziare un `PlantRepository` e i cubit di dominio plants

### Priorità bassa
1. rimuovere `fake_page.dart`
2. uniformare gli state file
3. riorganizzare il theme in una cartella più semantica

---

## 12. 📈 Scalabilità futura

### Auth
La base auth attuale è ormai solida per evolvere verso:
- reset password
- verifica email
- provider aggiuntivi
- onboarding più raffinato

### Plants
La progressione naturale è:

```text
Plant model
  -> PlantRepository
  -> GardenCubit / PlantSearchCubit / PlantDetailsCubit
  -> Pages / Widgets
```

### Feedback UI
Con `SnackBarHelper` è stato introdotto un primo standard di feedback globale. Questo è un buon punto di partenza per:
- success
- error
- warning
- info
- eventuale sistema più ricco di feedback globali in futuro

### Navigazione
Per ora il routing regge bene il perimetro attuale. Se il progetto cresce, le opzioni naturali saranno:
- router dichiarativo
- guard dedicate
- nested navigation più strutturata

---

## Appendice A — Mappa sintetica dei file aggiornata

### Entry points
- `main.dart`
- `app.dart`
- `firebase_options.dart`

### Core
- `core/routes.dart`

### Bloc
- `blocs/auth/auth_bloc.dart`
- `blocs/auth/auth_bloc_event.dart`
- `blocs/auth/auth_bloc_state.dart`

### Cubit
- `cubits/custom/obscure/obscure_cubit.dart`
- `cubits/forms/google_profile_completion_form_cubit.dart`
- `cubits/forms/sign_in_form_cubit.dart`
- `cubits/forms/sign_up_form_cubit.dart`
- `cubits/google_profile_completion/google_profile_completion_cubit.dart`
- `cubits/google_profile_completion/google_profile_completion_state.dart`
- `cubits/navigation/auth_flow_cubit.dart`
- `cubits/profile/profile_cubit.dart`
- `cubits/profile/profile_state.dart`
- `cubits/shell/shell_cubit.dart`
- `cubits/sign_in/sign_in_cubit.dart`
- `cubits/sign_in/sign_in_state.dart`
- `cubits/sign_out/sign_out_cubit.dart`
- `cubits/sign_out/sign_out_state.dart`
- `cubits/sign_up/sign_up_cubit.dart`
- `cubits/sign_up/sign_up_state.dart`

### Features / Models
- `features/enumType.dart`
- `features/plant/plant.dart`
- `features/theme/models/theme.dart`
- `features/user/user.dart`

### Pages
- `pages/fake_page.dart`
- `pages/garden_page.dart`
- `pages/google_profile_completion_page.dart`
- `pages/home_page.dart`
- `pages/main_shell_page.dart`
- `pages/plant_search_page.dart`
- `pages/profile_page.dart`
- `pages/sign_pages/sign_in_page.dart`
- `pages/sign_pages/sign_up_page.dart`
- `pages/splash_screen.dart`

### Repositories
- `repositories/auth_repository.dart`
- `repositories/user_repository.dart`

### Widgets
- `widgets/auth/google_auth_button.dart`
- `widgets/bottom_appbar/navigation_item.dart`
- `widgets/bottom_appbar/plantly_bottom_navigation.dart`
- `widgets/feedback/snackbar_helper.dart`
- `widgets/garden/meter_row.dart`
- `widgets/garden/plant_card.dart`
- `widgets/profile/info_card.dart`
- `widgets/profile/info_user_model.dart`
- `widgets/profile/logout_button.dart`
- `widgets/profile/section_label.dart`
- `widgets/profile/stat_card.dart`
- `widgets/sign_up/password_strength.dart`

---

## Appendice B — Valutazione finale aggiornata

### Cosa è già solido
- base auth stream-first ben impostata
- Google Sign-In realmente integrato
- onboarding profilo incompleto per Google implementato
- profilo Firestore separato da Firebase Auth
- username index su collection dedicata
- shell senza `setState()` grazie a `ShellCubit`
- `ProfilePage` ripulita dal side effect nel `build()`
- `SnackBarHelper` introdotto come standard iniziale per il feedback UI

### Cosa oggi limita davvero il progetto
- feature plants ancora mock
- date ancora come stringhe
- regole Firestore non verificate in questa revisione
- `App` ancora molto centrale nella logica di navigazione
- alcune incoerenze stilistiche minori nei file state

### Giudizio complessivo
Il progetto è sensibilmente più maturo rispetto alla documentazione precedente. Il layer auth/profilo è oggi una base reale da MVP avanzato: Google Sign-In, completamento profilo, fallback route, bootstrap robusto, gestione profilo realtime e separazione migliore dello stato sono tutti presenti nel codice verificato.

Non è ancora production-ready pieno, ma molte criticità che prima erano centrali sono state chiuse. Le aree che richiedono ora più attenzione non sono più il flusso auth di base, bensì:
1. regole e robustezza backend/Firestore
2. formalizzazione del dominio plants
3. rifinitura di error handling e coerenza interna
