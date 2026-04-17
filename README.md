# Documentazione tecnica ufficiale — Plantly

## Premessa e perimetro dell’analisi

Questa versione aggiornata della documentazione è basata sui file realmente analizzati in:
- `lib/`
- `pubspec.yaml`

Non sono stati verificati direttamente:
- asset fisicamente presenti sul filesystem
- configurazioni native Android/iOS/macOS/web oltre a quanto deducibile da `firebase_options.dart` e `pubspec.yaml`
- regole Firestore
- test automatici
- CI/CD

Di conseguenza, ogni valutazione è riferita al codice e alla configurazione effettivamente visibili nei file forniti.

---

## SECTION 1 — DOCUMENTATION REVIEW

### Valutazione generale
La documentazione precedente era complessivamente ben scritta, leggibile e vicina al codice reale. Tuttavia non era più aggiornata rispetto allo stato attuale del progetto e conteneva alcune omissioni rilevanti.

### Disallineamenti corretti in questa versione

#### 1. Google Sign-In presente ma non documentato
Nel codice attuale Google Sign-In è effettivamente integrato.

Elementi reali presenti:
- `AuthRepository.signInWithGoogle()`
- supporto separato per web (`signInWithPopup`) e piattaforme native (`GoogleSignIn.instance.initialize()` + `authenticate()`)
- `GoogleAuthResult`
- `SignInCubit.signInWithGoogle()`
- `SignUpCubit.signUpWithGoogle()`
- `GoogleAuthButton`
- mapping completo di `GoogleSignInExceptionCode`, incluso `uiUnavailable`

La precedente affermazione secondo cui Google Sign-In fosse assente non è più corretta.

#### 2. Validazione dell’identificatore nel login
La form di login non verifica se l’identificatore sia una email valida.

Comportamento reale:
- `SignInFormCubit._validateIdentifier()` controlla solo che il campo non sia vuoto
- la distinzione email/username è interamente delegata a `UserRepository.resolveEmailFromIdentifier()`
- la validazione del formato email avviene quindi solo indirettamente, lato repository / Firebase

Questo dettaglio comportamentale è importante e ora viene documentato.

#### 3. MainShellPage più avanzata di quanto documentato
`MainShellPage` usa:
- `AnimatedSwitcher`
- `IndexedStack`
- `ValueKey(_currentIndex)`
- `extendBody: true`

La documentazione precedente la descriveva in modo troppo semplice e incompleto.

#### 4. Search page ora presente nel codice
Il progetto contiene una nuova pagina placeholder:
- `pages/plant_search_page.dart`

È collegata realmente alla bottom navigation e alla shell principale.

#### 5. Incoerenza tra `sealed class` e `abstract class`
Nel progetto attuale:
- `SignOutState` è definito come `sealed class`
- altri state file analoghi usano `abstract class`

Non è un bug funzionale, ma è una inconsistenza stilistica reale del codebase.

#### 6. Duplicazione tra deserializzazione Firestore e modello
La precedente documentazione non esplicitava abbastanza bene che:
- `PlantlyUser.fromJson()`
- `UserRepository._fromFirestore()`

svolgono responsabilità simili ma con logica non identica.

Questa è una fonte reale di rischio di disallineamento.

### Parti nuove o mancanti ora incluse
Questa versione aggiornata documenta esplicitamente:
- Google Sign-In end-to-end
- `GoogleAuthButton` nel catalogo widget
- la nuova `PlantSearchPage`
- `_serverClientIdForCurrentPlatform()` sempre `null`
- la differenza tra `_fromFirestore()` e `fromJson()`
- il fatto che `watchProfile()` venga chiamato nel `build()` di `ProfilePage`
- il package reale `plantly_app` nel `pubspec.yaml`
- la presenza in `pubspec.yaml` di configurazioni per splash e launcher icon

---

## 1. 🧠 Overview del progetto

### Scopo dell’app
Plantly è un’app Flutter dedicata alla gestione di piante domestiche tramite un’interfaccia mobile semplice e visivamente curata. Dallo stato attuale del codice emergono quattro aree principali:
- autenticazione utente
- profilo utente persistito su Firestore
- dashboard / home informativa
- giardino virtuale e ricerca piante ancora in forma placeholder/demo

### Problema che risolve
L’app fornisce una base per:
- registrazione e login utente
- identificazione persistente dell’utente
- visualizzazione di informazioni e stato legati al mondo “plant care”
- futura estensione verso ricerca, gestione piante reali e integrazione con dispositivi smart

### Stato attuale del progetto
Lo stato attuale è quello di un **MVP avanzato ma ancora in sviluppo**.

Funzionalità oggi presenti:
- autenticazione email/password
- login via email o username
- Google Sign-In
- persistenza profilo utente su Firestore
- home demo
- garden demo
- pagina search placeholder per futura estensione
- profilo utente con ascolto realtime del documento Firestore

Funzionalità non ancora mature:
- dominio piante reale
- persistenza dati piante
- ricerca reale
- gestione avanzata di onboarding profilo post-Google
- robustezza transazionale su username

### Tecnologie effettivamente utilizzate
Dal codice e da `pubspec.yaml` risultano presenti:
- Flutter
- Material 3
- flutter_bloc
- Equatable
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Google Sign-In
- Google Fonts
- Repository pattern

### Configurazioni visibili in `pubspec.yaml`
Il package name dichiarato è:
- `plantly_app`

Sono inoltre dichiarati:
- `flutter_native_splash`
- `flutter_launcher_icons`
- asset sotto `assets/images/` e `assets/icon/`

Quindi il nome tecnico del package, nello stato attuale analizzato, è coerente con Plantly.

---

## 2. 🏗 Architettura generale

### Architettura reale
Il progetto adotta un layered approach pragmatico con una buona separazione tra livelli:
- `pages/` per la UI
- `widgets/` per componenti riutilizzabili
- `cubits/` e `blocs/` per logica e stato
- `repositories/` per accesso dati
- `features/` per modelli e risorse trasversali

Non è una Clean Architecture completa, perché mancano un domain layer puro e use case espliciti, ma la struttura è già adatta a un MVP scalabile.

### Separazione dei livelli

#### UI — `pages/`
Contiene le schermate principali:
- `splash_screen.dart`
- `sign_in_page.dart`
- `sign_up_page.dart`
- `main_shell_page.dart`
- `home_page.dart`
- `garden_page.dart`
- `plant_search_page.dart`
- `profile_page.dart`
- `fake_page.dart`

Ruolo: rendering, binding a cubit/bloc, ascolto stato e gestione del layout.

#### Widgets — `widgets/`
Contiene:
- `widgets/auth/google_auth_button.dart`
- `widgets/bottom_appbar/plantly_bottom_navigation.dart`
- `widgets/bottom_appbar/navigation_item.dart` (via `part`)
- `widgets/sign_up/password_strength.dart`
- `widgets/appbar.dart` (vuoto)

Ruolo: componenti UI riutilizzabili.

#### Logica — `blocs/` e `cubits/`
Sono presenti:
- `AuthBloc`
- `SignInCubit`
- `SignUpCubit`
- `SignOutCubit`
- `ProfileCubit`
- `SignInFormCubit`
- `SignUpFormCubit`
- `AuthFlowCubit`
- `ObscureCubit`

#### Dati — `repositories/`
Sono presenti:
- `AuthRepository`
- `UserRepository`

### Flusso dati reale

```text
Page
  -> FormCubit / ActionCubit
      -> Repository
          -> Firebase Auth / Firestore

Firebase authStateChanges
  -> AuthBloc
      -> App (MultiBlocListener)
          -> Navigazione globale
```

### Valutazione architetturale
Punti forti:
- confini di layer abbastanza rispettati
- i repository non contengono UI
- i cubit non navigano direttamente
- l’auth globale dipende dallo stream Firebase e non da eventi artificiali locali

Punti deboli:
- assenza di use case/domain layer
- alcuni side effect ancora in page
- alcune classi e file residui (`fake_page.dart`, `widgets/appbar.dart`)
- feature plants ancora puramente mock/placeholder

---

## 3. 🔐 Sistema di autenticazione

### Come funziona `AuthBloc`
`AuthBloc` ascolta `AuthRepository.authStateChanges` e converte lo stream Firebase in uno stato globale dell’app.

Eventi:
- `AuthUserChanged`

Stati:
- `unknown`
- `authenticated`
- `unauthenticated`

Flusso:
1. il bloc si sottoscrive a `authStateChanges`
2. ogni cambio emette `AuthUserChanged`
3. lo stato diventa `authenticated` o `unauthenticated`
4. `App` ascolta il bloc e naviga

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
2. `SignInFormCubit` valida solo presenza di identificatore e password
3. `SignInCubit.signIn()` chiama `UserRepository.resolveEmailFromIdentifier()`
4. se l’identificatore è email, la restituisce invariata
5. se è username, Firestore viene interrogato per recuperare l’email associata
6. `AuthRepository.signIn()` esegue il login Firebase
7. `AuthBloc` riceve il cambiamento auth
8. `App` naviga verso la shell autenticata

### Flusso registrazione email/password
1. `SignUpPage` raccoglie i dati utente
2. `SignUpFormCubit` valida i campi
3. `SignUpCubit.signUp()` verifica `usernameExists()`
4. `AuthRepository.signUp()` crea l’utente Firebase
5. `UserRepository.createUserProfile()` scrive il profilo in Firestore
6. se Firestore fallisce, il cubit tenta `authUser.delete()`
7. l’evento Firebase attiva `AuthBloc`

### Flusso Google Sign-In
Il supporto Google è presente sia in sign-in che in sign-up.

#### Web
`AuthRepository.signInWithGoogle()` usa:
- `FirebaseAuth.signInWithPopup(GoogleAuthProvider())`

#### Native
Usa:
- `GoogleSignIn.instance.initialize(serverClientId: ...)`
- `authenticate()`
- conversione in Firebase credential
- `signInWithCredential(...)`

#### Profilo utente dopo Google
Dopo il login con Google:
- `SignInCubit.signInWithGoogle()` chiama `UserRepository.ensureGoogleUserProfile(...)`
- `SignUpCubit.signUpWithGoogle()` fa lo stesso

Se il documento utente non esiste, viene creato automaticamente un profilo minimo con:
- username generato
- nome/cognome derivati da `displayName`
- email
- `country` e `city` vuoti
- `photoURL` come `imageUrl`

### Flusso logout
`SignOutCubit` richiama `AuthRepository.signOut()`.

`AuthRepository.signOut()` esegue in parallelo:
- `FirebaseAuth.signOut()`
- `GoogleSignIn.signOut()` in modalità safe

La navigazione post-logout avviene via `AuthBloc`, non tramite il cubit stesso.

### Punti critici o migliorabili
1. **`_serverClientIdForCurrentPlatform()` restituisce sempre `null`**  
   Questo rende la configurazione Google nativa fragile o dipendente solo dalla configurazione esterna. È il problema auth più importante oggi.

2. **Google crea profili con campi incompleti**  
   `country` e `city` restano vuoti. Non esiste ancora un onboarding dedicato al completamento profilo.

3. **Username login dipendente da Firestore**  
   Se il documento utente manca o è inconsistente, il login via username fallisce.

4. **Rollback registrazione solo parziale**  
   Il tentativo di `authUser.delete()` migliora la coerenza, ma non copre tutti gli edge case.

5. **Possibile doppia navigazione teorica**  
   `_navigate()` in `App` usa `addPostFrameCallback` e il listener usa `listenWhen`, quindi la situazione è migliorata. Resta comunque un punto da tenere monitorato se in futuro aumentano i listener di navigazione.

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

### Dati salvati
Nel documento `users/{uid}` vengono salvati:
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
#### Registrazione standard
La creazione profilo è orchestrata da `SignUpCubit`, non da `AuthRepository`.

#### Google
`ensureGoogleUserProfile()`:
- legge `users/{uid}`
- se il profilo esiste, lo restituisce
- altrimenti genera uno username disponibile e crea il documento

### Criticità
1. **Username non atomico**  
   `usernameExists()` seguito da `createUserProfile()` non è transazionale.

2. **Date salvate come stringa**  
   `createdAt` e `updatedAt` vengono salvati in ISO string, non come `serverTimestamp`.

3. **Duplicazione di deserializzazione**  
   `_fromFirestore()` nel repository e `PlantlyUser.fromJson()` nel modello non sono allineati al 100%.

4. **Google profile incompleto**  
   `country` e `city` sono vuoti per i nuovi utenti Google.

---

## 5. 📱 Struttura delle pagine

### `pages/splash_screen.dart`
**Scopo**  
Schermata iniziale visiva.

**Ruolo nella navigazione**  
Route iniziale.

**Criticità**  
Nessuna logica fallback se lo stato auth restasse `unknown` troppo a lungo.

### `pages/sign_in_page.dart`
**Scopo**  
Accesso utente con email/username + password e pulsante Google.

**Dipendenze**
- `SignInCubit`
- `SignInFormCubit`
- `ObscureCubit`
- `AuthFlowCubit`
- `GoogleAuthButton`

**Criticità**
- molto markup inline
- gestione errori ancora localizzata via `SnackBar`

### `pages/sign_up_page.dart`
**Scopo**  
Registrazione completa email/password + ingresso con Google.

**Dipendenze**
- `SignUpCubit`
- `SignUpFormCubit`
- `ObscureCubit`
- `AuthFlowCubit`
- `PasswordStrength`
- `GoogleAuthButton`

**Criticità**
- pagina lunga e monolitica
- componentizzazione migliorabile

### `pages/main_shell_page.dart`
**Scopo**  
Shell autenticata con bottom navigation.

**Pagine contenute**
- `HomePage`
- `GardenPage`
- `PlantSearchPage`
- `ProfilePage`

**Dettagli tecnici reali**
- `extendBody: true`
- `AnimatedSwitcher`
- `IndexedStack`
- `ValueKey(_currentIndex)`

**Criticità**
- stato tab solo locale e non persistito

### `pages/home_page.dart`
**Scopo**  
Dashboard informativa.

**Stato reale**  
UI demo/statica.

### `pages/garden_page.dart`
**Scopo**  
Giardino virtuale.

**Stato reale**  
Dati mock e interazioni non collegate a casi d’uso reali.

### `pages/plant_search_page.dart`
**Scopo**  
Placeholder production-ready per futura ricerca piante.

**Stato reale**  
Pagina statica ma ben integrata nella navigazione.

**Contenuto**
- heading
- search bar visiva non funzionale
- card “In arrivo”
- chip di categorie future

**Valutazione**  
Buon placeholder: chiaro, coerente, non rompe l’architettura.

### `pages/profile_page.dart`
**Scopo**  
Visualizzazione profilo utente e logout.

**Dipendenze**
- `AuthBloc`
- `ProfileCubit`
- `SignOutCubit`

**Criticità principale**  
`watchProfile(authUser.uid)` viene invocato nel `build()`.

Funziona grazie alla guardia nel cubit, ma semanticamente è un side effect posizionato male.

### `pages/fake_page.dart`
**Stato**  
Presente ma non parte del flusso principale.

**Valutazione**  
Dead code o residuo temporaneo.

---

## 6. 🧩 Widget riutilizzabili

### `widgets/auth/google_auth_button.dart`
Pulsante riutilizzabile per accesso/registrazione con Google.

Usato in:
- `SignInPage`
- `SignUpPage`

### `widgets/bottom_appbar/plantly_bottom_navigation.dart`
Bottom navigation custom con quattro voci:
- Home
- Giardino
- Cerca
- Profilo

Usata in:
- `MainShellPage`

### `widgets/bottom_appbar/navigation_item.dart`
Parte privata della bottom navigation.

### `widgets/sign_up/password_strength.dart`
Visualizza la forza password nella registrazione.

Usato in:
- `SignUpPage`

### `widgets/appbar.dart`
File vuoto.

Valutazione:
- codice morto / refactor incompleto

---

## 7. 🧠 Bloc / Cubit

### `AuthBloc`
**Responsabilità**
- derivare lo stato auth globale da Firebase

**Eventi**
- `AuthUserChanged`

**Stati**
- `unknown`
- `authenticated`
- `unauthenticated`

### `SignInCubit`
**Responsabilità**
- login email/username
- login con Google
- mapping errori Firebase e Google

**Stati**
- `SignInInitial`
- `SignInLoading`
- `SignInSuccess`
- `SignInFailure`

### `SignUpCubit`
**Responsabilità**
- registrazione email/password
- registrazione/accesso con Google
- creazione profilo utente

**Stati**
- `SignUpInitial`
- `SignUpLoading`
- `SignUpSuccess`
- `SignUpFailure`

### `SignOutCubit`
**Responsabilità**
- logout

**Stati**
- `SignOutInitial`
- `SignOutLoading`
- `SignOutSuccess`
- `SignOutFailure`

**Nota**
Usa `sealed class`, a differenza di altri state file.

### `ProfileCubit`
**Responsabilità**
- ascolto realtime del profilo Firestore

**Stati**
- `ProfileInitial`
- `ProfileLoading`
- `ProfileLoaded`
- `ProfileFailure`

**Punto forte**
Ha una guardia che evita resubscribe duplicate sullo stesso `userId`.

### `SignInFormCubit`
**Responsabilità**
- stato e validazione del form di login

**Nota importante**
`_validateIdentifier()` verifica solo che il campo non sia vuoto.

### `SignUpFormCubit`
**Responsabilità**
- stato e validazione del form di registrazione

### `ObscureCubit`
**Responsabilità**
- visibilità password / confirm password

### `AuthFlowCubit`
**Responsabilità**
- gestire la transizione tra sign-in e sign-up

**Valutazione**
Semplice ma coerente con il perimetro attuale.

---

## 8. 🔄 Routing e navigazione

### Gestione del routing
Il routing è centralizzato in `app.dart` con:
- `MaterialApp`
- `navigatorKey`
- `initialRoute`
- `onGenerateRoute`
- `MultiBlocListener`

### Ruolo di `app.dart`
Responsabilità:
- definizione route
- applicazione tema
- ascolto `AuthBloc`
- ascolto `AuthFlowCubit`
- navigazione globale

### Uso di `navigatorKey`
La navigazione globale passa da `_navigatorKey`.

`_navigate()` usa `WidgetsBinding.instance.addPostFrameCallback(...)` per evitare problemi di navigazione prima del mount del Navigator.

### Flusso reale
```text
App start
  -> SplashScreen
  -> AuthBloc ascolta Firebase authStateChanges
  -> se authenticated: home
  -> se unauthenticated: signIn
  -> AuthFlowCubit gestisce il passaggio signIn <-> signUp
```

### Criticità
1. **default route senza fallback**  
   `onGenerateRoute` restituisce `null` nel caso default.

2. **potenziale fragilità futura se aumentano i trigger di navigazione**  
   Attualmente la situazione è sotto controllo, ma il design richiede disciplina per restare robusto.

---

## 9. 🎨 UI / Theme system

### Struttura del tema
Il tema è definito in:
- `features/theme/models/theme.dart`

Esiste una implementazione principale:
- `LightTheme.make`

### Palette
La palette usa toni naturali e morbidi:
- verdi
- sabbia
- clay
- toni neutri chiari

### Tipografia
Uso di `GoogleFonts` e configurazione coerente dei text styles.

### Coerenza del design
Nel complesso la UI è coerente:
- bordi arrotondati
- carte morbide
- ombre leggere
- linguaggio visivo consistente tra home, giardino, ricerca e profilo

### Punti migliorabili
- troppo styling inline in alcune page
- pochi widget design-system estratti
- collocazione del file theme poco intuitiva (`features/theme/models/`)

---

## 10. ⚠️ Problemi e criticità

### 10.1 `watchProfile()` nel `build()`
**Gravità:** media  
**File:** `profile_page.dart`, `profile_cubit.dart`

`ProfilePage` invoca `watchProfile(authUser.uid)` nel `build()`.

Funziona grazie alla guardia interna del cubit, ma è semanticamente un side effect nel posto sbagliato.

**Soluzione consigliata**
- spostare l’avvio in `initState()` di un widget stateful
- oppure istanziare la pagina già con il cubit avviato

### 10.2 `_fromFirestore()` e `fromJson()` non perfettamente allineati
**Gravità:** media  
**File:** `user_repository.dart`, `user.dart`

Esistono due percorsi di deserializzazione simili ma non identici.

**Rischio**
- evoluzioni future possono rompere uno dei due flussi

**Soluzione consigliata**
- unificare la mappatura in un solo entry point

### 10.3 `_serverClientIdForCurrentPlatform()` sempre `null`
**Gravità:** alta  
**File:** `auth_repository.dart`

La funzione restituisce `null` per tutte le piattaforme.

**Impatto**
- integrazione Google nativa fragile
- possibile dipendenza eccessiva da configurazione esterna

**Soluzione consigliata**
- configurare e passare il client ID corretto dove necessario

### 10.4 Unicità username non atomica
**Gravità:** alta  
**File:** `sign_up_cubit.dart`, `user_repository.dart`

Il controllo `usernameExists()` non è transazionale rispetto alla creazione.

**Rischio**
- collisioni in condizioni concorrenti

**Soluzione consigliata**
- usare transazione Firestore o indice dedicato username

### 10.5 Rollback registrazione parziale
**Gravità:** media  
**File:** `sign_up_cubit.dart`

Se il profilo Firestore fallisce dopo la creazione auth, viene tentata la cancellazione dell’utente Firebase.

**Rischio**
- coerenza non garantita al 100% in edge case

### 10.6 Possibile double-fire della navigazione in scenari futuri
**Gravità:** media  
**File:** `app.dart`

La logica attuale è ragionevole, ma la navigazione è centralizzata e sensibile alla moltiplicazione di listener o side effect futuri.

### 10.7 `context.watch` / side effect combinati in `ProfilePage`
**Gravità:** bassa-media  
**File:** `profile_page.dart`

La pagina miscela lettura stato e trigger side effect in modo non ideale.

### 10.8 `fake_page.dart` è dead code
**Gravità:** bassa  
**File:** `pages/fake_page.dart`

### 10.9 `widgets/appbar.dart` è vuoto
**Gravità:** bassa  
**File:** `widgets/appbar.dart`

### 10.10 Incoerenza `sealed class` vs `abstract class`
**Gravità:** bassa  
**File:** state files

Non rompe il runtime, ma abbassa la coerenza stilistica del progetto.

### 10.11 Date come stringhe
**Gravità:** media  
**File:** `user_repository.dart`, `user.dart`

Le date vengono salvate come stringhe ISO.

**Soluzione consigliata**
- usare `FieldValue.serverTimestamp()` e normalizzare il parsing

### 10.12 Validazione solo client-side
**Gravità:** media  
**File:** forms + Firestore integration

Manca visibilità su enforcement lato regole backend.

---

## 11. 🚀 Miglioramenti suggeriti

### Priorità alta
1. rendere atomico l’username
2. introdurre onboarding profilo post-Google per completare `country` e `city`
3. spostare `watchProfile()` fuori dal `build()`
4. sistemare `_serverClientIdForCurrentPlatform()`
5. aggiungere fallback route

### Priorità media
1. unificare `fromJson()` e `_fromFirestore()`
2. introdurre un error handling più centralizzato
3. estrarre componenti riutilizzabili dalle page auth
4. sostituire le date stringa con timestamp reali

### Priorità bassa
1. rimuovere dead code
2. uniformare gli state file
3. riorganizzare il theme in una cartella più semantica

---

## 12. 📈 Scalabilità futura

### Come evolvere il progetto

#### Auth
La base auth è buona per estendere:
- reset password
- verifica email
- onboarding profilo incompleto
- multi-provider più robusti

#### Plants
La progressione naturale è:
```text
Plant model
  -> PlantRepository
  -> GardenCubit / PlantSearchCubit / PlantDetailsCubit
  -> Pages
```

Feature coerenti con la struttura attuale:
- lista piante reali
- dettaglio pianta
- ricerca reale
- reminder e calendario
- eventi di annaffiatura
- integrazione IoT futura

#### Navigazione
Per ora la soluzione attuale regge. Se l’app cresce, sarà opportuno valutare:
- router dichiarativo
- route guards
- nested navigation
- deep linking

#### Manutenibilità
Regole consigliate:
- niente side effect nel `build()`
- niente repository chiamati direttamente dalle page
- niente navigazione dentro i repository
- ogni feature nuova con page + cubit/bloc + repository + model dedicati

---

## Appendice A — Mappa sintetica dei file

### Entry points
- `main.dart`
- `app.dart`

### Core
- `core/routes.dart`
- `firebase_options.dart`

### Bloc
- `blocs/auth/auth_bloc.dart`
- `blocs/auth/auth_bloc_event.dart`
- `blocs/auth/auth_bloc_state.dart`

### Cubit
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
- `cubits/custom/obscure/obscure_cubit.dart`

### Features / Models
- `features/enumType.dart`
- `features/plant/plant.dart`
- `features/theme/models/theme.dart`
- `features/user/user.dart`

### Pages
- `pages/fake_page.dart`
- `pages/garden_page.dart`
- `pages/home_page.dart`
- `pages/main_shell_page.dart`
- `pages/plant_search_page.dart`
- `pages/profile_page.dart`
- `pages/sign_in_page.dart`
- `pages/sign_up_page.dart`
- `pages/splash_screen.dart`

### Repositories
- `repositories/auth_repository.dart`
- `repositories/user_repository.dart`

### Widgets
- `widgets/appbar.dart`
- `widgets/auth/google_auth_button.dart`
- `widgets/bottom_appbar/plantly_bottom_navigation.dart`
- `widgets/sign_up/password_strength.dart`

---

## Appendice B — Valutazione finale

### Cosa è già solido
- separazione generale dei layer buona per un MVP
- auth stream-first ben impostata
- Google Sign-In integrato a livello applicativo
- profilo utente su Firestore ben separato da Firebase Auth
- search page placeholder aggiunta in modo pulito
- bottom navigation aggiornata coerentemente

### Cosa oggi limita davvero il progetto
- feature plants ancora mock
- onboarding Google incompleto
- username non blindato
- Google native config non chiusa del tutto
- qualche residuo di codice morto e incoerenza stilistica

### Giudizio complessivo
Il progetto è più maturo di quanto risultasse nella documentazione precedente: il layer auth/profilo è ormai una base concreta da MVP avanzato, con supporto Google e gestione Firestore reale. Non è ancora production-ready pieno, perché restano alcune criticità strutturali su configurazione Google, atomicità dello username, onboarding profilo e formalizzazione del dominio plants. Tuttavia la traiettoria tecnica è buona e la base architetturale è abbastanza sana da sostenere l’evoluzione successiva.
