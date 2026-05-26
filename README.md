# Plantly — Documentazione tecnica aggiornata

## 1. Overview del progetto

Plantly è un'app Flutter per la gestione di piante domestiche. Il progetto usa un'architettura pragmatica a livelli con Firebase Auth, Cloud Firestore, Google Sign-In, `flutter_bloc`, `Equatable`, Material 3 e Repository Pattern.

### Funzionalità presenti

- autenticazione email/password;
- login via email o username;
- Google Sign-In;
- completamento profilo per utenti Google con dati mancanti;
- profilo utente persistito in Firestore;
- indice username in Firestore;
- shell autenticata con 4 tab: Home, Garden, Cerca, Profilo;
- routing modulare con `AppRouter`, `AppNavigator`, `AppStateListener`;
- gestione sessione con `SessionCubit`;
- gestione tab con `ShellCubit`;
- helper centralizzato `SnackBarHelper`;
- ricerca piante tramite Perenual;
- pagina dettaglio pianta;
- aggiunta pianta al giardino;
- persistenza giardino in Firestore;
- lettura realtime del giardino;
- rimozione pianta dal giardino;
- irrigazione dall'app disabilitata finché non sarà collegato un vaso intelligente.

### Funzionalità ancora non complete

- Home dashboard reale collegata al giardino;
- smart pot/Arduino completo;
- notifiche native;
- formula avanzata di irrigazione;
- gestione modifica dettagli pianta salvata;
- regole Firestore definitive da consolidare e testare;
- pulizia dei vecchi file legacy `UserPlant`, `UserPlantsRepository`, `UserPlantsCubit` se non più usati.

---

## 2. Stack tecnico

Dal codice e dal `pubspec.yaml` risultano usate o disponibili queste dipendenze principali:

```yaml
flutter_bloc: ^8.1.6
equatable: ^2.0.8
firebase_core: ^4.6.0
firebase_auth: ^6.3.0
cloud_firestore: ^6.3.0
google_sign_in: ^7.2.0
http: ^1.2.2
translator: ^1.0.4
google_fonts: ^8.0.2
provider: ^6.1.5
flutter_secure_storage: ^9.2.2
uuid: ^4.5.3
```

Nota: `provider`, `flutter_secure_storage`, `collection`, `uuid` risultano presenti nel `pubspec.yaml`, ma non necessariamente centrali nel flusso analizzato sotto `lib/`.

---

## 3. Architettura reale

Il progetto segue una separazione a livelli semplice e coerente:

```text
lib/
  main.dart                 bootstrap Flutter/Firebase
  app.dart                  composition root UI
  firebase_options.dart     configurazione Firebase

  core/                     routing, parsing, navigator, config API
  blocs/                    bloc globali, soprattutto AuthBloc
  cubits/                   logica applicativa e stati locali/globali
  features/                 modelli e risorse trasversali
  repositories/             accesso dati Firebase/API
  pages/                    schermate principali
  widgets/                  componenti UI riutilizzabili
```

### Regola architetturale da mantenere

- Le `pages/` devono comporre UI e widget.
- Le chiamate API/Firebase devono stare nei `repositories/`.
- La logica di stato e di orchestrazione deve stare in `Cubit`/`Bloc`.
- I modelli devono stare in `features/`.
- Non usare `setState()` per la logica delle feature principali.

Nel codice corrente non risultano chiamate reali a `setState()`. Restano `StatefulWidget` dove servono controller UI o debounce, ad esempio in `PlantDetailPage`, `PlantSearchPage`, `ProfilePage` e `SplashScreen`.

---

## 4. Entry point e bootstrap

### `main.dart`

Responsabilità:

- inizializza Flutter;
- imposta `FlutterError.onError`;
- abilita modalità immersiva sticky;
- inizializza Firebase;
- crea `AuthRepository` e `UserRepository`;
- registra repository e cubit/bloc globali;
- avvia `App`;
- mostra una fallback UI se Firebase fallisce l'inizializzazione.

Provider globali registrati:

```text
RepositoryProvider<AuthRepository>
RepositoryProvider<UserRepository>
BlocProvider<AuthBloc>
BlocProvider<SignInCubit>
BlocProvider<SignUpCubit>
BlocProvider<SignOutCubit>
BlocProvider<ProfileCubit>
```

### `app.dart`

Responsabilità:

- registra `AuthFlowCubit`;
- registra `SessionCubit`;
- crea `MaterialApp`;
- collega `AppNavigator.navigatorKey`;
- collega `AppRouter.generateRoute`;
- monta `AppStateListener` nel builder globale.

`app.dart` è oggi un composition root leggero e non contiene logica diretta di navigazione auth.

---

## 5. Core

### `core/routes.dart`

Route dichiarate:

```text
/
/sign-in
/sign-up
/home
/google-profile-completion
/plant-details
```

### `core/app_router.dart`

Gestisce le route principali:

- splash;
- sign in;
- sign up;
- home/shell;
- plant details;
- completamento profilo Google;
- fallback route.

Nota tecnica: la route `Routes.plantDetails` crea un `PlantDetailsCubit` e un `GardenCubit` dedicati. Tuttavia, nel flusso reale della Search, `PlantSearchPage` apre il dettaglio con `MaterialPageRoute` e passa il `GardenCubit` condiviso tramite `BlocProvider.value`. Questo è corretto per mantenere sincronizzato il giardino, ma crea una piccola duplicazione di strategia di navigazione.

### `core/app_navigator.dart`

Centralizza:

- `navigatorKey`;
- `navigateReplace`;
- `push`;
- `pushReplacement`.

### `core/app_state_listener.dart`

Ascolta:

- `AuthBloc`;
- `SessionCubit`;
- `AuthFlowCubit`.

Gestisce la navigazione globale tra:

- splash;
- sign in;
- sign up;
- home;
- completamento profilo Google.

### `core/parse_from_json.dart`

File trasversale per parsing robusto di:

- stringhe;
- stringhe nullable;
- liste di stringhe;
- bool;
- numeri;
- `DateTime`;
- `Timestamp` Firestore.

È usato dai modelli `PlantlyUser`, `PlantSpecies`, `GardenPlant` e dai modelli legacy.

### `core/perenual_config.dart`

Centralizza configurazione API Perenual:

```dart
PERENUAL_BASE_URL
PERENUAL_API_KEY
```

Come avviare l'app:

```bash
flutter run --dart-define=PERENUAL_API_KEY=LA_TUA_KEY
```
---

## 6. Autenticazione e sessione

### `AuthBloc`

`AuthBloc` ascolta `AuthRepository.authStateChanges` e produce:

```text
unknown
authenticated
unauthenticated
```

La subscription gestisce anche errori dello stream auth con fallback a utente nullo.

### `AuthRepository`

Responsabilità:

- login email/password;
- registrazione email/password;
- Google Sign-In web/native;
- logout Firebase e Google;
- esposizione `currentUser`;
- esposizione `authStateChanges`.

### `SessionCubit`

Responsabilità:

- riceve l'utente autenticato;
- carica il profilo Firestore;
- distingue utente con profilo completo da utente Google con profilo incompleto;
- emette stato per `AppStateListener`.

### `UserRepository`

Gestisce:

- `users/{uid}`;
- `usernames/{usernameLowercase}`;
- creazione profilo in transaction;
- aggiornamento profilo in transaction;
- risoluzione email da username;
- generazione username per utenti Google;
- verifica completezza profilo.

Struttura Firestore utente:

```text
users/{uid}
  id
  username
  username_lowercase
  name
  surname
  email
  country
  city
  imageUrl
  bio
  createdAt
  updatedAt

usernames/{usernameLowercase}
  uid
  email
  username
  updatedAt
```

---

## 7. Dominio plants/garden

La vertical slice plants/garden è ora implementata tramite nuovi modelli, repository e cubit dedicati.

### Modello `PlantSpecies`

File:

```text
lib/features/plant/plant_species.dart
```

Rappresenta una specie vegetale proveniente da Perenual.

Campi principali:

```text
id
commonName
scientificName
watering
sunlight
indoor
poisonousToHumans
poisonousToPets
imageThumbnailUrl
imageSmallUrl
imageMediumUrl
imageOriginalUrl
description
careLevel
cycle
dimension
```

Metodi presenti:

```text
fromPerenualJson()
fromJson()
toJson()
copyWith()
Equatable props
```

Getter utili:

```text
imageUrl
heroImageUrl
hasUsefulImage
```

### Modello `GardenPlant`

File:

```text
lib/features/plant/garden_plant.dart
```

Rappresenta una pianta salvata nel giardino dell'utente.

Campi principali:

```text
id
userId
speciesId
commonName
scientificName
nickname
imageUrl
watering
sunlight
indoor
poisonousToHumans
poisonousToPets
addedAt
updatedAt
lastWateredAt
nextWateringAt
notes
location
notificationEnabled
smartPotId
```

Metodi presenti:

```text
fromJson()
fromFirestore()
toJson()
copyWith()
Equatable props
```

Nota: `smartPotId` è già presente come campo nullable, ma la logica smart pot non è ancora implementata.

---

## 8. Repository plants/garden

### `PlantRepository`

File:

```text
lib/repositories/plant_repository.dart
```

Responsabilità:

- chiamare Perenual;
- cercare piante;
- caricare dettaglio pianta;
- gestire query vuote;
- gestire API key mancante;
- gestire timeout;
- gestire errori HTTP;
- restituire solo `PlantSpecies`, mai JSON grezzo alla UI.

Metodi:

```dart
Future<List<PlantSpecies>> searchPlants(String query)
Future<PlantSpecies?> getPlantDetails(String speciesId)
```

Endpoint usati:

```text
/species-list?q=...
/species/details/{id}
```

### `GardenRepository`

File:

```text
lib/repositories/garden_repository.dart
```

Responsabilità:

- leggere realtime il giardino;
- leggere una lista puntuale del giardino;
- aggiungere piante;
- aggiornare piante;
- rimuovere piante;
- segnare una pianta come annaffiata;
- evitare duplicati tramite `speciesId`.

Struttura Firestore usata:

```text
users/{uid}/garden/{gardenPlantId}
```

Metodi:

```dart
Stream<List<GardenPlant>> watchGarden(String userId)
Future<List<GardenPlant>> getGarden(String userId)
Future<void> addPlantToGarden(String userId, GardenPlant plant)
Future<void> updateGardenPlant(String userId, GardenPlant plant)
Future<void> removeGardenPlant(String userId, String plantId)
Future<void> markAsWatered(String userId, String plantId, DateTime wateredAt)
Future<bool> plantAlreadyInGarden(String userId, String speciesId)
```

Nota tecnica: `markAsWatered` esiste nel repository, ma dalla UI il pulsante di irrigazione è disabilitato finché non sarà collegato un vaso intelligente e non saranno disponibili i dati minimi di cura.

---

## 9. Cubit plants/garden

### `PlantSearchCubit`

File:

```text
lib/cubits/plant_search/plant_search_cubit.dart
lib/cubits/plant_search/plant_search_state.dart
```

Stati:

```text
PlantSearchInitial
PlantSearchLoading
PlantSearchSuccess
PlantSearchEmpty
PlantSearchFailure
```

Responsabilità:

- gestire query ricerca;
- chiamare `PlantRepository`;
- gestire query vuote;
- evitare chiamate concorrenti obsolete tramite request id;
- mostrare errori leggibili.

### `PlantDetailsCubit`

File:

```text
lib/cubits/plant_details/plant_details_cubit.dart
lib/cubits/plant_details/plant_details_state.dart
```

Stati:

```text
PlantDetailsInitial
PlantDetailsLoading
PlantDetailsSuccess
PlantDetailsFailure
```

Responsabilità:

- caricare i dettagli della pianta;
- usare la pianta iniziale come fallback se il dettaglio non è disponibile;
- non bloccare la UI in caso di fallimento del dettaglio.

### `GardenCubit`

File:

```text
lib/cubits/garden/garden_cubit.dart
lib/cubits/garden/garden_state.dart
```

Stati:

```text
GardenInitial
GardenLoading
GardenSuccess
GardenEmpty
GardenFailure
```

Ogni stato espone anche:

```text
isActionInProgress
```

Responsabilità:

- ascoltare realtime il giardino;
- aggiungere piante da `PlantSpecies`;
- rimuovere piante;
- aggiornare piante;
- segnare come annaffiata a livello repository, ma la UI attuale blocca l'azione;
- gestire errori leggibili;
- esporre `GardenMutationResult` per feedback UI.

---

## 10. Flusso reale Search -> Detail -> Garden

### 10.1 Ricerca

`PlantSearchPage` crea `PlantSearchCubit` usando il `PlantRepository` fornito nella shell.

La pagina contiene:

- `TextEditingController`;
- debounce con `Timer`;
- `SearchBarWidget`;
- gestione stati search;
- risultati con `PlantSpeciesCard`.

Nota: l'uso di `StatefulWidget` qui è limitato a controller e debounce. Non risulta uso di `setState()`.

### 10.2 Apertura dettaglio

Quando l'utente tocca una pianta:

```text
PlantSearchPage
  -> legge userId da AuthBloc
  -> legge PlantRepository
  -> legge GardenCubit condiviso
  -> apre PlantDetailPage con MaterialPageRoute
  -> passa GardenCubit con BlocProvider.value
  -> crea PlantDetailsCubit per il dettaglio
```

Questa scelta mantiene sincronizzato il `GardenCubit` usato anche da `GardenPage`.

### 10.3 Aggiunta al giardino

`PlantDetailPage` mostra:

- immagine hero;
- nome comune;
- nome scientifico;
- nickname opzionale;
- acqua;
- luce;
- ambiente;
- tossicità;
- descrizione se disponibile;
- CTA “Aggiungi al mio giardino”.

Alla pressione della CTA:

```text
PlantDetailPage
  -> GardenCubit.addPlantFromSpecies()
  -> GardenRepository.addPlantToGarden()
  -> users/{uid}/garden/{gardenPlantId}
  -> SnackBarHelper
  -> pop della pagina dettaglio
```

### 10.4 Garden reale

`GardenPage` legge `GardenCubit` e mostra:

- loading;
- empty state;
- error state;
- lista reale delle piante;
- card pianta;
- tasto rimuovi;
- CTA “Aggiungi una pianta”.

Il tasto “Annaffia” non è disponibile finché:

- non esiste un `smartPotId`;
- non sono presenti i dati minimi di cura richiesti;
- non sarà implementata la gestione smart pot.

---

## 11. Pages principali

### `MainShellPage`

Tab presenti:

```text
HomePage
GardenPage
PlantSearchPage
ProfilePage
```

Responsabilità:

- legge utente corrente da `AuthBloc`;
- crea `PlantRepository`;
- crea `GardenRepository`;
- crea `ShellCubit`;
- crea `GardenCubit` e avvia `watchGarden(user.uid)`;
- gestisce tab con `ShellCubit`;
- usa `IndexedStack` per mantenere le tab montate.

### `HomePage`

Stato attuale:

- ancora demo/statica;
- non legge ancora `GardenCubit`;
- usa widget dedicati in `widgets/home/`.

Prossima fase consigliata: collegarla al giardino reale per mostrare:

- numero piante;
- prossime cure;
- alert piante senza smart pot;
- CTA verso Search/Garden.

### `GardenPage`

Stato attuale:

- reale;
- legge `GardenCubit`;
- mostra piante da Firestore;
- rimuove piante;
- blocca irrigazione fino a smart pot.

### `PlantSearchPage`

Stato attuale:

- reale;
- usa Perenual tramite `PlantRepository`;
- apre dettaglio;
- nessun dato mock.

Criticità da verificare: nel file è presente un possibile refuso di parentesi doppia in `_InitialSearchState`. Se `flutter analyze` segnala errore sintattico in `plant_search_page.dart`, controllare quella sezione.

### `PlantDetailPage`

Stato attuale:

- reale;
- usa `PlantDetailsCubit`;
- usa `GardenCubit` per aggiungere al giardino;
- usa `TextEditingController` per nickname opzionale;
- non usa `setState()`.

Criticità minore: in `_sunlightLabel` è presente un `return value.trim();` duplicato, con una riga irraggiungibile. Non dovrebbe rompere il flusso, ma va pulito.

### `ProfilePage`

Stato attuale:

- legge profilo con `ProfileCubit`;
- avvia `watchProfile(uid)` in `initState()`;
- usa `SignOutCubit`;
- usa widget dedicati per header, info, statistiche e logout.

---

## 12. Widgets principali

### Garden

```text
widgets/garden/garden_empty_state.dart
widgets/garden/garden_header_widget.dart
widgets/garden/garden_orb_preview.dart
widgets/garden/garden_stats_banner.dart
widgets/garden/meter_row.dart
widgets/garden/plant_card.dart
```

`PlantCard` ora lavora con `GardenPlant`, supporta immagini URL reali, rimozione, stato irrigazione bloccato e notice dedicata.

### Search

```text
widgets/search/plant_info_badge.dart
widgets/search/plant_species_card.dart
widgets/search/plant_species_grid.dart
widgets/search/search_bar_widget.dart
widgets/search/search_category_chips.dart
widgets/search/search_coming_soon_card.dart
```

Nota: `SearchComingSoonCard` è ormai legacy rispetto alla search reale; può restare non usato oppure essere rimosso in una pulizia futura.

### Home

```text
widgets/home/home_greeting_widget.dart
widgets/home/home_hero_card.dart
widgets/home/home_metric_grid.dart
widgets/home/home_quick_actions.dart
widgets/home/home_reminder_card.dart
widgets/home/home_summary_card.dart
widgets/home/home_tip_card.dart
```

Nota: `home_summary_card.dart` e `home_tip_card.dart` risultano vuoti o quasi vuoti nel codice analizzato. Sono candidati a pulizia o completamento.

### Profile

```text
widgets/profile/info_card.dart
widgets/profile/info_user_model.dart
widgets/profile/logout_button.dart
widgets/profile/profile_action_tile.dart
widgets/profile/profile_header_widget.dart
widgets/profile/profile_info_card.dart
widgets/profile/profile_stats_row.dart
widgets/profile/section_label.dart
widgets/profile/stat_card.dart
```

### Feedback

```text
widgets/feedback/snackbar_helper.dart
```

Centralizza snackbar di tipo:

- success;
- error;
- info;
- warning.

---

## 13. Firestore

### Struttura attuale

```text
users/{uid}
usernames/{usernameLowercase}
users/{uid}/garden/{gardenPlantId}
```

### Regole minime consigliate

```js
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;

      match /garden/{plantId} {
        allow read, write: if request.auth != null
                           && request.auth.uid == userId;
      }
    }

    match /usernames/{username} {
      allow read: if true;
      allow create, update, delete: if request.auth != null;
    }
  }
}
```

Nota sicurezza: le regole su `usernames` sono minime e pragmatiche, ma non rappresentano la soluzione più robusta possibile. Per maggiore sicurezza, la creazione/modifica dell'indice username dovrebbe essere protetta con logica backend o regole più restrittive.

---

## 14. Comandi di sviluppo

Installazione dipendenze:

```bash
flutter pub get
```

Analisi statica:

```bash
flutter analyze
```

Avvio con Perenual:

```bash
flutter run --dart-define=PERENUAL_API_KEY=LA_TUA_KEY
```

Avvio con base URL custom:

```bash
flutter run \
  --dart-define=PERENUAL_API_KEY=LA_TUA_KEY \
  --dart-define=PERENUAL_BASE_URL=https://perenual.com/api/v2
```

Test manuale consigliato per la vertical slice:

```text
1. Login
2. Tab Cerca
3. Cerca “monstera” o altra pianta
4. Apri dettaglio
5. Aggiungi al mio giardino
6. Verifica documento in users/{uid}/garden
7. Torna in Garden
8. Verifica card reale
9. Rimuovi pianta
10. Verifica rimozione da Firestore
```

---

## 15. Criticità rilevate nel codice attuale

### Criticità alta

1. **API key Perenual presente in commento**
   - File: `core/perenual_config.dart`
   - Azione: rimuovere immediatamente dal sorgente.

2. **Possibile refuso sintattico in `PlantSearchPage`**
   - File: `pages/plant_search_page.dart`
   - Zona: `_InitialSearchState`
   - Azione: eseguire `flutter analyze`; se segnala errore, rimuovere la chiusura extra.

3. **Doppio sistema garden legacy/nuovo**
   - Nuovo: `GardenPlant`, `GardenRepository`, `GardenCubit`, collection `garden`.
   - Legacy: `UserPlant`, `UserPlantsRepository`, `UserPlantsCubit`, collection `plants`.
   - Azione: verificare se i file legacy sono ancora referenziati. Se non servono più, rimuoverli in una fase di pulizia.

### Criticità media

4. **Home ancora demo/statica**
   - File: `pages/home_page.dart`
   - Azione: collegare a `GardenCubit` o creare `HomeCubit` dopo la vertical slice.

5. **Route plant details duplicata rispetto al flow reale**
   - File: `core/app_router.dart` e `pages/plant_search_page.dart`
   - Azione: scegliere se usare sempre route named oppure mantenere il direct push con provider condiviso.

6. **`PlantDetailPage` contiene una riga irraggiungibile**
   - File: `pages/plant_detail_page.dart`
   - Azione: rimuovere `return value.trim();` duplicato in `_sunlightLabel`.

7. **File Home vuoti/quasi vuoti**
   - File: `widgets/home/home_summary_card.dart`, `widgets/home/home_tip_card.dart`
   - Azione: completarli o rimuoverli.

8. **`SearchComingSoonCard` è legacy**
   - File: `widgets/search/search_coming_soon_card.dart`
   - Azione: verificare se è ancora usato; se non è usato, rimuoverlo.

### Criticità bassa

9. **Theme molto grande in un solo file**
   - File: `features/theme/models/theme.dart`
   - Azione futura: valutare separazione in design tokens, typography, colors.

10. **Uso di `StatefulWidget` per controller UI**
   - Non è un problema se non viene usato `setState()` per business logic.
   - Attualmente non risultano chiamate reali a `setState()`.

---

## 16. Roadmap consigliata

### Fase 1 — Stabilizzazione vertical slice

- rimuovere API key commentata;
- correggere eventuale refuso sintattico in `PlantSearchPage`;
- pulire riga irraggiungibile in `PlantDetailPage`;
- verificare `flutter analyze`;
- verificare flow completo Search -> Detail -> Garden.

### Fase 2 — Home dashboard reale

- collegare Home ai dati di `GardenCubit`;
- mostrare numero piante reale;
- mostrare piante senza smart pot;
- mostrare prossima cura se disponibile;
- evitare dati mock.

### Fase 3 — Pulizia legacy

- decidere se rimuovere `UserPlant`, `UserPlantsRepository`, `UserPlantsCubit`;
- rimuovere widget non usati;
- uniformare naming garden/plants;
- scegliere una sola strategia di navigazione per `PlantDetailPage`.

### Fase 4 — Smart pot readiness

- creare modello `SmartPotDevice`;
- creare `SmartPotRepository`;
- creare `SmartPotCubit`;
- collegare `smartPotId` alle piante del giardino;
- abilitare il pulsante irrigazione solo quando il device è collegato e configurato.

### Fase 5 — Irrigazione e notifiche

- creare calcolatore irrigazione centralizzato;
- programmare reminder irrigazione;
- gestire notifiche device offline, serbatoio basso, umidità bassa;
- integrare sensori e comandi reali.

---

## 17. Mappa completa dei file analizzati

### Root

```text
lib/app.dart
lib/main.dart
lib/firebase_options.dart
```

### Core

```text
lib/core/app_navigator.dart
lib/core/app_router.dart
lib/core/app_state_listener.dart
lib/core/parse_from_json.dart
lib/core/perenual_config.dart
lib/core/routes.dart
```

### Auth Bloc

```text
lib/blocs/auth/auth_bloc.dart
lib/blocs/auth/auth_bloc_event.dart
lib/blocs/auth/auth_bloc_state.dart
```

### Cubits

```text
lib/cubits/custom/obscure/obscure_cubit.dart
lib/cubits/forms/google_profile_completion_form_cubit.dart
lib/cubits/forms/sign_in_form_cubit.dart
lib/cubits/forms/sign_up_form_cubit.dart
lib/cubits/garden/garden_cubit.dart
lib/cubits/garden/garden_state.dart
lib/cubits/google_profile_completion/google_profile_completion_cubit.dart
lib/cubits/google_profile_completion/google_profile_completion_state.dart
lib/cubits/navigation/auth_flow_cubit.dart
lib/cubits/plant_details/plant_details_cubit.dart
lib/cubits/plant_details/plant_details_state.dart
lib/cubits/plant_search/plant_search_cubit.dart
lib/cubits/plant_search/plant_search_state.dart
lib/cubits/profile/profile_cubit.dart
lib/cubits/profile/profile_state.dart
lib/cubits/session/session_cubit.dart
lib/cubits/session/session_state.dart
lib/cubits/shell/shell_cubit.dart
lib/cubits/sign_in/sign_in_cubit.dart
lib/cubits/sign_in/sign_in_state.dart
lib/cubits/sign_out/sign_out_cubit.dart
lib/cubits/sign_out/sign_out_state.dart
lib/cubits/sign_up/sign_up_cubit.dart
lib/cubits/sign_up/sign_up_state.dart
lib/cubits/user_plants/user_plants_cubit.dart
lib/cubits/user_plants/user_plants_state.dart
```

### Features

```text
lib/features/plant/garden_plant.dart
lib/features/plant/plant_species.dart
lib/features/plant/user_plant.dart
lib/features/strenght_enum.dart
lib/features/theme/models/theme.dart
lib/features/user/user.dart
```

### Repositories

```text
lib/repositories/auth_repository.dart
lib/repositories/garden_repository.dart
lib/repositories/plant_repository.dart
lib/repositories/plant_species_repository.dart
lib/repositories/user_plants_repository.dart
lib/repositories/user_repository.dart
```

### Pages

```text
lib/pages/auth/sign_in_page.dart
lib/pages/auth/sign_up_page.dart
lib/pages/garden_page.dart
lib/pages/google_profile_completion_page.dart
lib/pages/home_page.dart
lib/pages/initial/splash_screen.dart
lib/pages/main_shell_page.dart
lib/pages/plant_detail_page.dart
lib/pages/plant_search_page.dart
lib/pages/profile_page.dart
```

### Widgets Auth

```text
lib/widgets/auth/auth_card.dart
lib/widgets/auth/auth_header.dart
lib/widgets/auth/google_auth_button.dart
```

### Widgets Bottom App Bar

```text
lib/widgets/bottom_appbar/navigation_item.dart
lib/widgets/bottom_appbar/plantly_bottom_navigation.dart
```

### Widgets Feedback

```text
lib/widgets/feedback/snackbar_helper.dart
```

### Widgets Garden

```text
lib/widgets/garden/garden_empty_state.dart
lib/widgets/garden/garden_header_widget.dart
lib/widgets/garden/garden_orb_preview.dart
lib/widgets/garden/garden_stats_banner.dart
lib/widgets/garden/meter_row.dart
lib/widgets/garden/plant_card.dart
```

### Widgets Home

```text
lib/widgets/home/home_greeting_widget.dart
lib/widgets/home/home_hero_card.dart
lib/widgets/home/home_metric_grid.dart
lib/widgets/home/home_quick_actions.dart
lib/widgets/home/home_reminder_card.dart
lib/widgets/home/home_summary_card.dart
lib/widgets/home/home_tip_card.dart
```

### Widgets Profile

```text
lib/widgets/profile/info_card.dart
lib/widgets/profile/info_user_model.dart
lib/widgets/profile/logout_button.dart
lib/widgets/profile/profile_action_tile.dart
lib/widgets/profile/profile_header_widget.dart
lib/widgets/profile/profile_info_card.dart
lib/widgets/profile/profile_stats_row.dart
lib/widgets/profile/section_label.dart
lib/widgets/profile/stat_card.dart
```

### Widgets Search

```text
lib/widgets/search/plant_info_badge.dart
lib/widgets/search/plant_species_card.dart
lib/widgets/search/plant_species_grid.dart
lib/widgets/search/search_bar_widget.dart
lib/widgets/search/search_category_chips.dart
lib/widgets/search/search_coming_soon_card.dart
```

### Widgets Sign-up

```text
lib/widgets/sign_up/password_strength.dart
```

---

## 18. Stato finale aggiornato

### Solido

- auth email/password;
- login username;
- Google Sign-In;
- completamento profilo Google;
- profilo Firestore realtime;
- routing root separato;
- shell senza `setState()`;
- search reale via Perenual;
- dettaglio pianta reale;
- garden reale su Firestore;
- rimozione pianta funzionante;
- irrigazione bloccata finché non sarà supportata dal vaso intelligente;
- feedback centralizzato con `SnackBarHelper`.

### Da completare prima della pubblicazione

- correggere criticità di codice rilevate da `flutter analyze`;
- rimuovere API key commentata;
- collegare Home a dati reali;
- pulire legacy plants/garden;
- consolidare Firestore rules;
- testare su Android/Web/iOS;
- implementare gestione smart pot e notifiche solo in fasi successive.

