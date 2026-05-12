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
- routing modulare con router, navigator e state listener dedicati
- risoluzione della sessione tramite cubit dedicato

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
- `core/` → routing, navigator e coordinamento globale del root flow

Non è una Clean Architecture completa, perché mancano use case e domain layer dedicati, ma il progetto è ben oltre uno scheletro iniziale e ha una separazione già utilizzabile per sviluppo reale.

### Separazione dei livelli

#### UI — `pages/`
Attualmente contiene:
- `splash_screen.dart`
- `pages/auth/sign_in_page.dart`
- `pages/auth/sign_up_page.dart`
- `google_profile_completion_page.dart`
- `main_shell_page.dart`
- `home_page.dart`
- `garden_page.dart`
- `plant_search_page.dart`
- `profile_page.dart`
- `fake_page.dart`

**Aggiornamento importante:** `ProfilePage` non lancia più `watchProfile()` nel `build()`, ma in `initState()`.

**Aggiornamento importante:** le page auth reali del progetto sono ora sotto `pages/auth/`, non più sotto `pages/sign_pages/`.

#### Widgets — `widgets/`
Oltre ai widget già presenti, il progetto contiene ora sottosezioni più chiare e riutilizzabili.

##### Auth
- `widgets/auth/auth_card.dart`
- `widgets/auth/auth_header.dart`
- `widgets/auth/google_auth_button.dart`

##### Bottom navigation
- `widgets/bottom_appbar/plantly_bottom_navigation.dart`
- `widgets/bottom_appbar/navigation_item.dart`

##### Feedback
- `widgets/feedback/snackbar_helper.dart`

##### Garden
- `widgets/garden/meter_row.dart`
- `widgets/garden/plant_card.dart`

##### Profile
- `widgets/profile/info_card.dart`
- `widgets/profile/info_user_model.dart`
- `widgets/profile/logout_button.dart`
- `widgets/profile/section_label.dart`
- `widgets/profile/stat_card.dart`

##### Sign-up
- `widgets/sign_up/password_strength.dart`

**Aggiornamento importante:** le schermate auth reali usano `AuthHeader` e `AuthCard` per ridurre la duplicazione UI e mantenere le page più focalizzate sulla composizione della schermata.

#### Logica — `blocs/` e `cubits/`
Sono presenti:
- `AuthBloc`
- `SignInCubit`
- `SignUpCubit`
- `SignOutCubit`
- `ProfileCubit`
- `ShellCubit`
- `SessionCubit`
- `GoogleProfileCompletionCubit`
- `SignInFormCubit`
- `SignUpFormCubit`
- `GoogleProfileCompletionFormCubit`
- `AuthFlowCubit`
- `ObscureCubit`

**Aggiornamento importante:** `MainShellPage` usa `ShellCubit`, quindi lo stato tab non è più gestito con `setState()`.

**Aggiornamento importante:** `SessionCubit` è ora parte centrale del flusso di sessione. La sua responsabilità è risolvere la destinazione dell’utente autenticato dopo `AuthBloc`, distinguendo tra:
- sessione autenticata completa
- sessione autenticata che richiede completamento profilo Google
- sessione non autenticata
- eventuali errori di bootstrap sessione, se previsti dal codice corrente

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
      -> SessionCubit
          -> AppStateListener
              -> navigazione globale
```

**Aggiornamento importante:** `App` non decide più direttamente tutta la logica di sessione e non costruisce più direttamente la route factory. Queste responsabilità sono state distribuite tra `SessionCubit`, `AppRouter`, `AppNavigator` e `AppStateListener`.

### Valutazione architetturale aggiornata
Punti forti:
- confini di layer più rispettati di prima
- nessun `setState()` nella shell autenticata
- introduzione di `SnackBarHelper` per uniformare i feedback UI
- navigazione auth/profilo incompleto centralizzata meglio
- onboarding Google separato in page + cubit dedicati
- `app.dart` più vicino a un composition root
- routing root separato in componenti specifici

Punti deboli ancora presenti:
- assenza di domain/use-case layer
- presenza residua di `fake_page.dart`
- feature plants ancora mock
- alcune criticità backend/Firestore non verificabili dal solo `lib/`

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

**Aggiornamento importante:** la subscription a `authStateChanges` ha `onError`, quindi il bloc è più robusto rispetto alla versione precedente.

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
8. `SessionCubit` risolve la sessione utente
9. `AppStateListener` attiva la navigazione finale

### Flusso registrazione email/password
1. `SignUpPage` raccoglie i dati
2. `SignUpFormCubit` valida il form
3. `SignUpCubit.signUp()` crea l’utente Firebase
4. costruisce un `PlantlyUser`
5. `UserRepository.createUserProfile()` scrive il profilo **e** l’indice username in transaction
6. se il salvataggio fallisce, prova a cancellare l’utente auth
7. `AuthBloc` rileva il login risultante
8. `SessionCubit` risolve la sessione

**Aggiornamento importante:** il repository usa una transaction e l’indice `usernames`, quindi il quadro è sensibilmente migliorato rispetto alla vecchia gestione non atomica.

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
Questa è una parte realmente implementata.

Esistono:
- `GoogleProfileCompletionPage`
- `GoogleProfileCompletionCubit`
- `GoogleProfileCompletionFormCubit`

Flusso reale:
1. l’utente entra con Google
2. `ensureGoogleUserProfile()` garantisce l’esistenza di un profilo Firestore minimo
3. `SessionCubit` controlla se il profilo è completo (`username`, `country`, `city`)
4. se il profilo è incompleto, la sessione viene indirizzata a `Routes.googleProfileCompletion`
5. l’utente completa i campi richiesti
6. il profilo viene aggiornato in Firestore
7. l’utente entra nell’area autenticata

### Flusso logout
`SignOutCubit` richiama `AuthRepository.signOut()`.

`AuthRepository.signOut()` esegue:
- `FirebaseAuth.signOut()`
- `GoogleSignIn.signOut()` in modalità safe

**Aggiornamento importante:** il sign out Google non usa più un catch completamente silenzioso, ma fa logging minimo con `debugPrint`.

### Punti critici o migliorabili aggiornati
1. **Il flusso Google è presente e funzionante a livello applicativo**
2. **Il profilo incompleto Google è gestito**
3. **`AuthRepository` è più pulito di prima**
4. **`SignOutCubit` resta migliorabile lato granularità delle eccezioni**
5. **il rollback di registrazione resta migliorabile lato logging strutturato**

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
- `fromFirestore()` se presente nel codice attuale

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
Nel codice attuale esistono due collection distinte.

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

### Aggiornamento importante
La criticità “username non atomico” va aggiornata: nel codice corrente la creazione e l’aggiornamento del profilo usano `runTransaction` e sincronizzano anche l’indice `usernames`.

### Criticità ancora aperte
1. **Regole Firestore non documentate qui**  
   La correttezza del nuovo schema `users` + `usernames` dipende dalle regole effettive.

2. **Date e parsing vanno tenuti coerenti**  
   La documentazione precedente segnalava stringhe ISO; se il codice attuale è già passato a timestamp reali, questa parte va verificata e aggiornata di conseguenza.

3. **Il login via username dipende dalla collection `usernames`**  
   È una scelta architetturale pratica, ma richiede attenzione lato regole e privacy.

---

## 5. 📱 Struttura delle pagine

### `pages/splash_screen.dart`
**Scopo**  
Schermata iniziale visiva.

**Aggiornamento importante**  
La robustezza del bootstrap non dipende più solo dalla splash: `main.dart` ha una UI fallback se Firebase fallisce all’avvio.

### `pages/auth/sign_in_page.dart`
**Scopo**  
Accesso con email/username e Google.

**Dipendenze**
- `SignInCubit`
- `SignInFormCubit`
- `ObscureCubit`
- `AuthFlowCubit`
- `AuthHeader`
- `AuthCard`
- `GoogleAuthButton`
- `SnackBarHelper`

**Aggiornamento importante**  
La page usa widget condivisi (`AuthHeader`, `AuthCard`) per ridurre la duplicazione UI e usa `SnackBarHelper.showError(...)` per uniformare il feedback.

### `pages/auth/sign_up_page.dart`
**Scopo**  
Registrazione email/password e ingresso con Google.

**Dipendenze**
- `SignUpCubit`
- `SignUpFormCubit`
- `ObscureCubit`
- `AuthFlowCubit`
- `AuthHeader`
- `AuthCard`
- `PasswordStrength`
- `GoogleAuthButton`
- `SnackBarHelper`

**Aggiornamento importante**  
La page usa widget condivisi (`AuthHeader`, `AuthCard`) e adotta `SnackBarHelper` per feedback di errore e di successo, se previsto dal flusso attuale.

### `pages/google_profile_completion_page.dart`
**Scopo**  
Completare il profilo obbligatorio per utenti Google con dati mancanti.

**Dipendenze**
- `GoogleProfileCompletionCubit`
- `GoogleProfileCompletionFormCubit`
- `SnackBarHelper`

**Aggiornamento importante**  
Questa pagina è una parte reale del flusso auth e non crea più `TextEditingController` nel `build()`.

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
Placeholder corretto e ben integrato.

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
Dead code o residuo temporaneo.

---

## 6. 🧩 Widget riutilizzabili

### Auth
#### `widgets/auth/auth_header.dart`
Header condiviso delle schermate auth:
- logo
- titolo “Plantly”
- sottotitolo contestuale

Usato in:
- `pages/auth/sign_in_page.dart`
- `pages/auth/sign_up_page.dart`

#### `widgets/auth/auth_card.dart`
Contenitore condiviso delle schermate auth:
- padding
- bordo
- radius
- ombra
- styling coerente

Usato in:
- `pages/auth/sign_in_page.dart`
- `pages/auth/sign_up_page.dart`

#### `widgets/auth/google_auth_button.dart`
Pulsante riutilizzabile per accesso/registrazione con Google.

Usato in:
- `pages/auth/sign_in_page.dart`
- `pages/auth/sign_up_page.dart`

### Feedback
#### `widgets/feedback/snackbar_helper.dart`
Helper centralizzato per feedback UI coerente:
- error
- success
- info
- warning, se previsto

**Aggiornamento importante:** fa ormai parte del feedback system del progetto.

### Bottom navigation
- `widgets/bottom_appbar/plantly_bottom_navigation.dart`
- `widgets/bottom_appbar/navigation_item.dart`

### Garden
- `widgets/garden/meter_row.dart`
- `widgets/garden/plant_card.dart`

### Profile
- `widgets/profile/info_card.dart`
- `widgets/profile/info_user_model.dart`
- `widgets/profile/logout_button.dart`
- `widgets/profile/section_label.dart`
- `widgets/profile/stat_card.dart`

### Sign-up
- `widgets/sign_up/password_strength.dart`

---

## 7. 🧠 Bloc / Cubit

### `AuthBloc`
**Responsabilità**
- derivare lo stato auth globale da Firebase
- reagire agli errori dello stream auth con fallback coerente

### `SessionCubit`
**Responsabilità**
- risolvere la sessione dell’utente autenticato dopo il cambio di stato auth
- distinguere tra:
   - utente non autenticato
   - utente autenticato con profilo completo
   - utente autenticato che richiede completamento profilo
   - eventuale errore di bootstrap sessione, se previsto dal codice

**Ruolo architetturale**
Permette di togliere da `app.dart` la logica diretta di lettura del profilo Firestore e di decisione `home` vs `googleProfileCompletion`.

### `SignInCubit`
**Responsabilità**
- login email/username
- login con Google
- bootstrap profilo Google minimo
- mapping errori Firebase e Google

### `SignUpCubit`
**Responsabilità**
- registrazione email/password
- accesso/registrazione con Google
- creazione profilo utente

### `SignOutCubit`
**Responsabilità**
- logout

**Nota**
Resta uno dei cubit migliorabili lato dettaglio eccezioni.

### `ProfileCubit`
**Responsabilità**
- ascolto realtime del profilo Firestore
- gestione subscribe/unsubscribe al documento utente
- eventuale pulizia esplicita del profilo al logout, se prevista dal codice corrente

### `ShellCubit`
**Responsabilità**
- gestire il tab index della shell autenticata

### `GoogleProfileCompletionCubit`
**Responsabilità**
- completamento del profilo minimo richiesto dopo Google
- validazione di base lato action cubit
- create/update su Firestore tramite repository

### `GoogleProfileCompletionFormCubit`
**Responsabilità**
- stato e validazione del form di completamento profilo Google

### `SignInFormCubit`, `SignUpFormCubit`, `ObscureCubit`, `AuthFlowCubit`
Restano coerenti con il loro ruolo:
- stato e validazione dei form
- visibilità password
- transizione sign-in ↔ sign-up

---

## 8. 🔄 Routing e navigazione

### Gestione del routing
Il routing è oggi distribuito in modo più pulito tra:
- `app.dart`
- `core/app_router.dart`
- `core/app_navigator.dart`
- `core/app_state_listener.dart`
- `core/routes.dart`

### Ruolo aggiornato di `app.dart`
`App` ha il ruolo di composition root dell’interfaccia:
- registra `AuthFlowCubit`
- registra `SessionCubit`
- costruisce `MaterialApp`
- collega `AppNavigator.navigatorKey`
- collega `AppRouter.generateRoute`
- monta `AppStateListener`

Non contiene più direttamente:
- la route factory completa
- la logica completa di decisione del profilo incompleto
- gli helper locali di navigazione

### Ruolo di `AppRouter`
`AppRouter` costruisce le route reali dell’app:
- splash
- sign in
- sign up
- home
- completamento profilo Google

Gestisce anche:
- fallback route
- argomenti della route di completamento profilo tramite `GoogleProfileCompletionRouteArgs`

### Ruolo di `AppNavigator`
`AppNavigator` centralizza:
- `navigatorKey`
- `navigateReplace(...)`
- `push(...)`
- `pushReplacement(...)`

### Ruolo di `AppStateListener`
`AppStateListener` ascolta gli stati globali e orchestra la navigazione:
- `AuthBloc`
- `SessionCubit`
- `AuthFlowCubit`

### Flusso reale aggiornato
```text
App start
  -> SplashScreen
  -> Firebase bootstrap in main.dart
  -> AuthBloc ascolta authStateChanges
  -> se authenticated:
       SessionCubit risolve la sessione utente
       -> se profilo completo: home
       -> se profilo incompleto: googleProfileCompletion
  -> se unauthenticated: signIn
  -> AuthFlowCubit gestisce signIn <-> signUp
```

### Criticità residue
- il routing globale è oggi più pulito, ma resta una parte sensibile del progetto
- l’eventuale crescita dell’app potrebbe richiedere router dichiarativo, guard dedicate o nested navigation

---

## 9. 🎨 UI / Theme system

### Struttura del tema
Il tema principale resta in:
- `features/theme/models/theme.dart`

### Coerenza visiva
La UI è oggi più coerente perché, oltre al theme, ha acquisito:
- widget dedicati per auth
- widget dedicati per profile
- widget dedicati per garden
- helper centralizzato per feedback snackbar

### Punti migliorabili
- alcune page restano ricche di styling inline
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

Se nel codice corrente esistono ancora `_fromFirestore()` e `PlantlyUser.fromJson()` come percorsi separati, resta una possibile fonte di incoerenza.

### 10.3 Coerenza date / parsing da verificare
**Gravità:** media  
**File:** `user_repository.dart`, `user.dart`

Questa parte va sempre allineata al formato realmente usato in Firestore.

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

La correttezza dello schema `users` + `usernames` dipende dalle regole Firestore effettive.

### 10.7 Incoerenze stilistiche minori negli state
**Gravità:** bassa  
**File:** state vari

Residui di naming/stile possono ancora esistere tra file più vecchi e più recenti.

### 10.8 `App` resta un nodo centrale del root flow
**Gravità:** media  
**File:** `app.dart`

È molto più pulito di prima, ma resta comunque il punto di composizione globale dell’app.

### 10.9 Feature plants ancora mock
**Gravità:** media  
**File:** `home_page.dart`, `garden_page.dart`, `plant_search_page.dart`

Il prodotto è strutturalmente pronto, ma il dominio piante reale non è ancora implementato.

### Criticità risolte rispetto alle versioni precedenti
Questi punti non vanno più riportati come aperti:
- `watchProfile()` nel `build()`
- assenza del flusso Google profile completion
- `_serverClientIdForCurrentPlatform()` sempre `null`
- stato tab in `MainShellPage` gestito con `setState()`
- mancanza di route fallback
- assenza di helper globale per SnackBar
- `app.dart` come unico contenitore della route factory

---

## 11. 🚀 Miglioramenti suggeriti aggiornati

### Priorità alta attuale
1. consolidare le regole Firestore coerenti con `users` + `usernames`
2. migliorare la gestione errori di `SignOutCubit`
3. valutare logging più strutturato nel rollback di registrazione
4. consolidare la gestione della sessione e dei casi edge di bootstrap profilo

### Priorità media
1. unificare definitivamente parsing e deserializzazione utente
2. consolidare la gestione di date/timestamp nel model e nel repository
3. continuare l’adozione del feedback globale centralizzato dove manca
4. iniziare un `PlantRepository` e i cubit di dominio plants

### Priorità bassa
1. rimuovere `fake_page.dart`
2. uniformare completamente gli state file
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
Con `SnackBarHelper` è stato introdotto uno standard iniziale per:
- success
- error
- warning
- info

### Navigazione
La base attuale è già più modulare rispetto alle versioni precedenti grazie alla separazione tra:
- `AppRouter`
- `AppNavigator`
- `AppStateListener`
- `SessionCubit`

Questo rende il routing più estendibile e riduce il coupling diretto di `app.dart`.

Se il progetto crescerà ulteriormente, le opzioni naturali saranno:
- router dichiarativo
- guard dedicate
- nested navigation

---

## Appendice A — Mappa sintetica dei file aggiornata

### Entry points
- `main.dart`
- `app.dart`
- `firebase_options.dart`

### Core
- `core/routes.dart`
- `core/app_router.dart`
- `core/app_navigator.dart`
- `core/app_state_listener.dart`

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
- `cubits/session/session_cubit.dart`
- `cubits/session/session_state.dart`
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
- `pages/auth/sign_in_page.dart`
- `pages/auth/sign_up_page.dart`
- `pages/fake_page.dart`
- `pages/garden_page.dart`
- `pages/google_profile_completion_page.dart`
- `pages/home_page.dart`
- `pages/main_shell_page.dart`
- `pages/plant_search_page.dart`
- `pages/profile_page.dart`
- `pages/splash_screen.dart`

### Repositories
- `repositories/auth_repository.dart`
- `repositories/user_repository.dart`

### Widgets
- `widgets/auth/auth_card.dart`
- `widgets/auth/auth_header.dart`
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
- `app.dart` alleggerito e più vicino a un composition root
- routing e navigazione root separati in componenti dedicati
- page auth reali componentizzate con `AuthHeader` e `AuthCard`

### Cosa oggi limita davvero il progetto
- feature plants ancora mock
- regole Firestore non verificate in questa revisione
- alcuni aspetti di error handling ancora migliorabili
- residui di pulizia finale (`fake_page.dart`, uniformazione completa di alcuni file)

### Giudizio complessivo
Il progetto è sensibilmente più maturo rispetto alle versioni precedenti della documentazione. Il layer auth/profilo è oggi una base reale da MVP avanzato: Google Sign-In, completamento profilo, fallback route, bootstrap robusto, gestione profilo realtime e separazione migliore dello stato sono tutti presenti nel codice verificato.

Non è ancora production-ready pieno, ma molte criticità che prima erano centrali sono state chiuse. Le aree che richiedono ora più attenzione non sono più il flusso auth di base, bensì:
1. regole e robustezza backend/Firestore
2. formalizzazione del dominio plants
3. rifinitura di error handling e coerenza interna

### Aggiornamento architetturale rilevante
Rispetto alle versioni precedenti della documentazione, l’app è oggi più matura anche perché:
- `app.dart` è stato alleggerito e reso più vicino a un composition root
- il routing è stato estratto in `AppRouter`
- la navigazione root usa `AppNavigator`
- l’ascolto degli stati globali è stato separato in `AppStateListener`
- le page auth reali sono state componentizzate con `AuthHeader` e `AuthCard`
- `SessionCubit` è stato introdotto per separare la risoluzione della sessione dalla UI root
