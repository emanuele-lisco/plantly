
## 1. Overview del progetto

Plantly è un'app Flutter per la gestione di piante domestiche, con predisposizione progressiva per vaso intelligente, irrigazione manuale/automatica e dati meteo locali.

Il progetto usa una struttura pragmatica a livelli:

- UI in `pages/` e `widgets/`;
- stato applicativo in `Bloc`/`Cubit`;
- accesso dati in `repositories/`;
- modelli di dominio in `features/`;
- routing e configurazioni trasversali in `core/`.

### Funzionalità presenti nello stato attuale

- autenticazione email/password;
- login tramite email o username;
- Google Sign-In;
- completamento profilo per utenti Google con profilo incompleto;
- profilo utente persistito in Firestore;
- indice username in Firestore;
- profilo realtime tramite `ProfileCubit`;
- routing migrato a `go_router` con `MaterialApp.router`;
- `StatefulShellRoute.indexedStack` con tab persistenti;
- shell autenticata con 4 tab: Home, Garden, Cerca, Profilo;
- drawer laterale con riepilogo utente, voce Meteo, Profilo e Logout;
- dashboard Home reale collegata al giardino;
- ricerca piante tramite Perenual;
- dettaglio pianta;
- aggiunta pianta al giardino;
- persistenza giardino in Firestore;
- lettura realtime del giardino;
- rimozione pianta dal giardino;
- predisposizione notifiche watering reminder;
- predisposizione smart pot;
- smart pot realtime da Firestore;
- comando manuale “Annaffia ora” tramite documento pending in Firestore;
- configurazione irrigazione automatica salvata su device;
- card configurazione automatica con campi visibili solo se la modalità automatica è attiva;
- pulsante “Usa valori consigliati” nella configurazione automatica;
- selezione paese/città tramite API esterne;
- coordinate utente salvate nel profilo;
- pagina Meteo collegata alla location del profilo;
- meteo corrente da Open-Meteo;
- previsione meteo a 5 giorni;
- UI meteo con card riepilogo, metriche e forecast.

### Funzionalità ancora non complete

- firmware/consumer dei comandi smart pot;
- creazione automatica dei comandi di irrigazione;
- algoritmo avanzato di irrigazione;
- integrazione reale delle notifiche native;
- modifica avanzata dei dettagli della pianta salvata;
- collegamento effettivo device-pianta tramite UI completa;
- gestione backend/Cloud Functions per device e comandi;
- regole Firestore definitive per `devices` e `commands`;
- pulizia completa del flusso legacy `UserPlant` / `UserPlantsRepository` / `UserPlantsCubit`;
- verifica completa di `flutter analyze` sul progetto intero.

---

## 2. Stato del codice analizzato

Lo zip contiene:

```text
lib/        135 file Dart
README.md  documentazione precedente, parzialmente obsoleta e duplicata
```

Distribuzione principale dei file Dart:

```text
widgets/        47
cubits/         37
features/       15
pages/          11
repositories/   10
core/            6
services/        3
blocs/           3
```

La documentazione precedente conteneva alcune sezioni non più allineate al codice, in particolare:

- riferimenti al vecchio routing con `MaterialApp`, `AppNavigator` e `generateRoute`;
- Home descritta come ancora statica, mentre ora è collegata a `HomeCubit` e al giardino reale;
- meteo descritto come solo predisposto, mentre ora esistono `WeatherPage`, `WeatherCubit`, `WeatherRepository` e forecast a 5 giorni;
- smart pot descritto in parte come futura implementazione, mentre ora esistono modelli, repository, cubit e widget dedicati;
- sezioni duplicate e numerazione non coerente.

---

## 3. Architettura attuale

```text
lib/
  main.dart                 bootstrap Flutter/Firebase
  app.dart                  MaterialApp.router + GoRouter
  firebase_options.dart     configurazione Firebase

  core/                     router, route constants, parser, config Perenual
  blocs/                    AuthBloc globale
  cubits/                   stato applicativo e logica feature
  features/                 modelli di dominio
  repositories/             Firebase/API/repository layer
  services/                 servizi applicativi predisposti
  pages/                    schermate principali
  widgets/                  componenti UI riutilizzabili
```

### Regole architetturali da mantenere

- Le `pages/` compongono UI, widget e provider locali.
- Le chiamate a Firebase/API stanno nei `repositories/`.
- La logica di stato/orchestrazione sta in `Cubit`/`Bloc`.
- I modelli stanno in `features/`.
- La logica business non deve finire nelle pages.
- `setState()` è accettabile solo per stato UI locale, ad esempio controller, debounce o switch grafici interni.

Nel codice attuale `setState()` compare solo in widget locali come city picker e form di configurazione automatica. Non risulta usato per orchestrare business logic delle feature principali.

---

## 4. Bootstrap e composition root

### `main.dart`

Responsabilità:

- inizializza Flutter;
- imposta `FlutterError.onError`;
- abilita `SystemUiMode.immersiveSticky`;
- inizializza Firebase;
- crea `AuthRepository` e `UserRepository`;
- registra repository e bloc/cubit globali;
- monta `App`;
- mostra una fallback UI in caso di errore bootstrap Firebase.

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

- crea `SessionCubit`;
- crea `GoRouterRefreshStream` collegato al `SessionCubit`;
- crea il router tramite `AppRouter.createRouter()`;
- monta `MaterialApp.router`;
- applica `LightTheme.make`;
- mantiene `AppStateListener` come listener globale.

Il vecchio schema `MaterialApp + onGenerateRoute + AppNavigator` non è più lo schema reale del codice analizzato.

---

## 5. Routing con `go_router`

### `core/routes.dart`

Route dichiarate:

```text
/
/sign-in
/sign-up
/google-profile-completion
/home
/garden
/search
/profile
/plant-details
/weather
```

### `core/app_router.dart`

Il routing è ora centralizzato in `GoRouter`.

Componenti principali:

- `navigatorKey` root;
- navigator key separate per Home, Garden, Search e Profile;
- `redirect` basato su `SessionCubit`;
- `StatefulShellRoute.indexedStack` per mantenere le tab montate;
- route root per `PlantDetailPage`;
- route root per `WeatherPage`;
- pagina errore interna per route non valide o args mancanti.

### Logica redirect

Il redirect gestisce:

```text
SessionInitial / SessionLoading
  -> resta o torna a Splash

SessionUnauthenticated / SessionFailure
  -> consente solo SignIn/SignUp, altrimenti manda a SignIn

SessionAuthenticatedNeedsProfileCompletion
  -> manda a GoogleProfileCompletion

SessionAuthenticatedComplete
  -> se è su Splash/Auth/Completion manda a Home
```

Questa migrazione risolve il problema della navigazione manuale dopo login/registrazione: il cambio di stato sessione guida automaticamente la destinazione.

### `go_router_refresh_stream.dart`

Adatta lo stream del `SessionCubit` a `ChangeNotifier`, in modo che `GoRouter` rivaluti il redirect quando cambia la sessione.

---

## 6. Shell autenticata

### `pages/main_shell_page.dart`

`MainShellPage` riceve una `StatefulNavigationShell` e registra provider disponibili nelle tab autenticate:

```text
RepositoryProvider<PlantRepository>
RepositoryProvider<GardenRepository>
RepositoryProvider<SmartPotRepository>
BlocProvider<GardenCubit>
BlocProvider<HomeCubit>
```

All'avvio della shell:

```text
GardenCubit.watchGarden(user.uid)
HomeCubit.watchHome(user.uid)
```

La shell contiene:

- `Scaffold` principale;
- drawer laterale `AppDrawer`;
- body con `navigationShell`;
- bottom navigation custom `PlantlyBottomNav`;
- navigazione tra branch tramite `navigationShell.goBranch()`.

---

## 7. Auth, sessione e profilo

### `AuthBloc`

Ascolta `AuthRepository.authStateChanges` e produce:

```text
AuthStatus.unknown
AuthStatus.authenticated
AuthStatus.unauthenticated
```

### `SessionCubit`

Responsabilità:

- risolvere l'utente Firebase autenticato;
- caricare il profilo Firestore;
- distinguere utente autenticato completo da utente che deve completare il profilo;
- emettere stati usati da `GoRouter.redirect`.

### `AppStateListener`

Ascolta:

- `AuthBloc`, per risolvere/azzerare sessione e profilo;
- `SessionCubit`, per mostrare errori globali con `SnackBarHelper`.

Nota positiva: il listener confronta anche il cambio UID, non solo il cambio status auth. Questo evita stati sporchi quando cambia account.

### `SignInCubit`

Gestisce:

- login con email o username;
- risoluzione username -> email tramite `UserRepository`;
- Google Sign-In;
- mappatura errori Firebase;
- mappatura completa dei principali `GoogleSignInExceptionCode`.

### `SignUpCubit`

Gestisce:

- registrazione email/password;
- creazione profilo `PlantlyUser`;
- rollback dell'utente Firebase se la creazione profilo Firestore fallisce;
- registrazione/accesso Google;
- mappatura errori Firebase e Google.

### `GoogleProfileCompletionCubit`

Completa i profili Google incompleti con:

- username;
- paese;
- codice paese;
- città;
- coordinate città.

---

## 8. Modello utente e location

### `features/user/user.dart`

`PlantlyUser` include ora i campi necessari per la location strutturata:

```text
country
countryCode
countryName
city
latitude
longitude
```

`locationLabel` restituisce:

```text
city, countryName
```

La location è legata all'utente, non alla singola pianta.

### `LocationRepository`

File:

```text
lib/repositories/location_repository.dart
```

Responsabilità:

- caricare paesi da Rest Countries;
- cercare città tramite Open-Meteo Geocoding API;
- restituire `CountryOption` e `CityOption`;
- evitare inserimento manuale libero del paese.

Widget collegati:

```text
widgets/location/country_picker_field.dart
widgets/location/city_picker_field.dart
```

---

## 9. Dominio piante e giardino

### `PlantSpecies`

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

Metodi principali:

```text
fromPerenualJson()
fromJson()
toJson()
copyWith()
```

### `GardenPlant`

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
deviceId
smartPotId                 legacy
targetMoistureMin
targetMoistureMax
potSize
soilType
drainageLevel
plantSize
exposure
```

Nota importante:

- `deviceId` è il campo nuovo da usare;
- `smartPotId` resta letto per compatibilità con documenti vecchi;
- `linkedDeviceId` fa fallback da `deviceId` a `smartPotId`.

---

## 10. Repository piante e giardino

### `PlantRepository`

File:

```text
lib/repositories/plant_repository.dart
```

Responsabilità:

- chiamare Perenual;
- cercare piante;
- caricare dettagli pianta;
- gestire query vuote;
- gestire API key mancante;
- gestire timeout/errori HTTP;
- restituire `PlantSpecies`, non JSON grezzo alla UI.

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

Struttura Firestore usata:

```text
users/{uid}/garden/{gardenPlantId}
```

Responsabilità:

- stream realtime del giardino;
- lettura one-shot del giardino;
- aggiunta pianta;
- aggiornamento pianta;
- rimozione pianta;
- mark as watered;
- prevenzione duplicati tramite `speciesId`.

---

## 11. Flow Search -> Detail -> Garden

### Search

`PlantSearchPage`:

- crea `PlantSearchCubit`;
- usa `SearchBarWidget`;
- applica debounce con `Timer`;
- non usa `setState()` per business logic;
- naviga al dettaglio con `context.push(Routes.plantDetails, extra: PlantDetailsRouteArgs(...))`.

### Detail

`PlantDetailPage`:

- riceve `PlantSpecies` iniziale e `userId`;
- usa `PlantDetailsCubit` per caricare dettagli aggiuntivi;
- usa `GardenCubit` per aggiungere al giardino;
- usa `TextEditingController` per nickname opzionale;
- mostra feedback con `SnackBarHelper`;
- torna indietro con `context.pop()` dopo aggiunta riuscita.

### Garden

`GardenPage`:

- legge `GardenCubit` condiviso nella shell;
- mostra loading/empty/error/success;
- mostra piante reali da Firestore;
- rimuove piante;
- espone la parte smart pot quando una pianta ha un device collegato;
- mostra stato bloccato/no device quando non c'è un device.

---

## 12. Home dashboard

### `HomeCubit`

File:

```text
lib/cubits/home/home_cubit.dart
lib/cubits/home/home_state.dart
```

Responsabilità:

- ascoltare il giardino reale tramite `GardenRepository.watchGarden()`;
- calcolare numero totale piante;
- calcolare piante da annaffiare oggi;
- calcolare prossima cura;
- gestire loading/empty/error/success.

Stati:

```text
HomeInitial
HomeLoading
HomeEmpty
HomeSuccess
HomeFailure
```

### `HomePage`

La Home non è più solo statica/demo.

Mostra:

- saluto utente;
- card utente compatta da `ProfileCubit`;
- numero piante da `GardenCubit`;
- metriche reali da `HomeCubit`;
- prossima cura;
- empty state se il giardino è vuoto;
- placeholder Smart pot;
- pull-to-refresh.

La metrica Smart pot è ancora placeholder e vale `0`.

---

## 13. Smart pot

### Modelli

```text
features/smart_pot/smart_pot_device.dart
features/smart_pot/smart_pot_telemetry.dart
features/smart_pot/smart_pot_config.dart
features/smart_pot/irrigation_calculator.dart
features/smart_pot/irrigation_recommendation.dart
```

### Struttura Firestore prevista

```text
devices/{deviceId}
  ownerUid
  linkedUserPlantId
  telemetry
  config
  updatedAt

users/{ownerUid}/garden/{plantId}
  deviceId
```

Comandi manuali:

```text
devices/{deviceId}/commands/{commandId}
  type: irrigate
  status: pending
  requestedBy
  payload:
    ml
    durationMs
  createdAt
```

### `SmartPotRepository`

Responsabilità:

- leggere realtime un device;
- leggere one-shot un device;
- link/unlink transazionale device-pianta;
- aggiornare config;
- creare comando manuale pending;
- validare device esistente, online, ownership, pompa inattiva, acqua sufficiente e portata pompa valida.

### `SmartPotCubit`

Responsabilità:

- osservare un device;
- esporre stati loading/loaded/notFound/failure;
- cancellare subscription al cambio device o close.

### Widget smart pot

```text
widgets/smart_pot/smart_pot_status_card.dart
widgets/smart_pot/smart_pot_no_device_card.dart
widgets/smart_pot/soil_moisture_indicator.dart
widgets/smart_pot/light_indicator.dart
widgets/smart_pot/water_tank_estimate_widget.dart
widgets/smart_pot/irrigation_control_button.dart
widgets/smart_pot/auto_irrigation_settings_card.dart
```

### Stato funzionale attuale

Implementato lato app:

- lettura device;
- visualizzazione stato/telemetria;
- configurazione automatica;
- comando manuale pending.

Non implementato:

- firmware consumer;
- Cloud Function consumer;
- esecuzione reale comando;
- algoritmo automatico;
- meteo come input dell'irrigazione;
- storico irrigazioni.

---

## 14. Irrigazione manuale e automatica

### Manuale

`IrrigationControlCubit` usa `SmartPotRepository.createManualIrrigationCommand()`.

Prima di scrivere il comando vengono verificati:

- `deviceId` valido;
- `requestedBy` valido;
- device esistente;
- device online;
- ownership coerente;
- pompa non attiva;
- quantità per ciclo configurata;
- acqua residua sufficiente;
- `pumpMlPerSecond` valido.

### Automatica

`AutoIrrigationSettingsCubit` e `AutoIrrigationSettingsCard` salvano solo configurazione.

Campi configurabili:

```text
autoIrrigationEnabled
soilMoistureThreshold
maxWaterMlPerCycle
maxWaterMlPerDay
```

Regola UI corretta nello stato attuale:

- se `autoIrrigationEnabled == false`: mostra solo header, descrizione, switch e hint;
- se `autoIrrigationEnabled == true`: mostra valori consigliati, campi numerici e pulsante salva.

Il pulsante “Usa valori consigliati” propone valori prudenti in base al fabbisogno idrico testuale disponibile.

---

## 15. Meteo

### Route e accesso

La pagina meteo è raggiungibile da drawer:

```text
Drawer -> Meteo -> context.push(Routes.weather)
```

Route:

```text
/weather
```

### `WeatherPage`

Responsabilità:

- leggere profilo da `ProfileCubit`;
- usare coordinate salvate nel profilo;
- non usare GPS del device;
- mostrare card missing-location se città/coordinate sono assenti;
- supportare pull-to-refresh;
- mostrare loading/error/success.

### `WeatherCubit`

Stati:

```text
WeatherInitial
WeatherLoading
WeatherNoLocation
WeatherLoaded
WeatherFailure
```

Responsabilità:

- leggere `latitude`, `longitude`, `city`, `countryName` da `PlantlyUser`;
- bloccare il caricamento se la location è incompleta;
- chiamare `WeatherRepository`;
- non calcolare irrigazione.

### `WeatherRepository`

API usata:

```text
api.open-meteo.com/v1/forecast
```

Parametri principali:

```text
current=temperature_2m,weather_code,relative_humidity_2m,wind_speed_10m
daily=temperature_2m_min,temperature_2m_max,weather_code,precipitation_probability_max
timezone=auto
forecast_days=6
```

`forecast_days=6` significa:

```text
indice 0 = oggi
indici 1-5 = prossimi 5 giorni
```

### `WeatherData`

Campi principali:

```text
city
countryName
temperatureCelsius
minTemperatureCelsius
maxTemperatureCelsius
condition
conditionIcon
humidity
windSpeedKmh
precipitationProbability
forecast
fetchedAt
```

### `DailyForecast`

Campi:

```text
date
minTemperatureCelsius
maxTemperatureCelsius
condition
conditionIcon
```

Getter utili:

```text
dayLabel
minDisplay
maxDisplay
```

### Widget meteo

```text
widgets/weather/weather_summary_card.dart
widgets/weather/five_day_forecast_card.dart
widgets/weather/weather_metric_tile.dart
widgets/weather/weather_location_missing_card.dart
widgets/weather/condition_wether_animation.dart
```

Nota: `condition_wether_animation.dart` contiene un refuso nel nome file (`wether` invece di `weather`). Non blocca il codice se gli import sono coerenti, ma conviene rinominarlo in una futura pulizia.

---

## 16. Notifiche

### Stato attuale

La struttura è predisposta ma no-op.

File:

```text
repositories/notification_repository.dart
cubits/notifications/notification_cubit.dart
cubits/notifications/notification_state.dart
```

Il repository espone:

```text
initialize()
requestPermission()
scheduleWateringReminder(GardenPlant plant)
cancelWateringReminder(String plantId)
rescheduleWateringReminder(GardenPlant plant)
```

Per ora non usa plugin nativi, Firebase Messaging o Cloud Functions.

Da implementare in futuro:

- reminder irrigazione;
- umidità troppo bassa;
- serbatoio acqua basso;
- smart pot offline;
- completamento irrigazione.

---

## 17. UI e tema

### Tema

File:

```text
features/theme/models/theme.dart
```

Contiene:

- palette colori;
- gradienti;
- typography;
- tema Material.

Nota tecnica: il file tema è grande e centralizza molte responsabilità. Non è un problema bloccante, ma in futuro può essere separato in design tokens, typography e gradients.

### Aggiornamenti UI recenti

- profilo aggiornato con header botanico più curato;
- Home dashboard reale;
- drawer utente con avatar, username/email e location;
- pagina meteo con card principale e forecast 5 giorni;
- `AutoIrrigationSettingsCard` corretta: campi nascosti quando lo switch è spento;
- bottom navigation con `StatefulShellRoute`;
- Smart pot card e indicatori dedicati.

---

## 18. Firestore

### Struttura dati attuale

```text
users/{uid}
usernames/{usernameLowercase}
users/{uid}/garden/{gardenPlantId}
devices/{deviceId}
devices/{deviceId}/commands/{commandId}
```

### `users/{uid}`

Campi principali:

```text
id
username
username_lowercase
name
surname
email
country
countryCode
countryName
city
latitude
longitude
imageUrl
bio
createdAt
updatedAt
```

### `usernames/{usernameLowercase}`

Campi principali:

```text
uid
email
username
updatedAt
```

### `users/{uid}/garden/{gardenPlantId}`

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
notificationEnabled
deviceId
targetMoistureMin
targetMoistureMax
potSize
soilType
drainageLevel
plantSize
exposure
```

### `devices/{deviceId}`

Campi principali:

```text
ownerUid
linkedUserPlantId
telemetry
config
updatedAt
```

### Regole Firestore minime indicative

Queste regole sono solo una base di sviluppo e vanno consolidate prima della pubblicazione:

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

    match /devices/{deviceId} {
      allow read: if request.auth != null
                  && resource.data.ownerUid == request.auth.uid;

      allow create: if request.auth != null;

      allow update: if request.auth != null
                    && resource.data.ownerUid == request.auth.uid;

      match /commands/{commandId} {
        allow create: if request.auth != null;
        allow read: if request.auth != null;
      }
    }
  }
}
```

Nota sicurezza: le regole per `devices` e `commands` sono volutamente indicative. In produzione conviene distinguere chiaramente permessi app, backend e firmware.

---

## 19. Configurazioni esterne

### Perenual

File:

```text
core/perenual_config.dart
```

L'app legge:

```text
PERENUAL_API_KEY
PERENUAL_BASE_URL
```

Avvio consigliato:

```bash
flutter run --dart-define=PERENUAL_API_KEY=LA_TUA_KEY
```

Con base URL custom:

```bash
flutter run \
  --dart-define=PERENUAL_API_KEY=LA_TUA_KEY \
  --dart-define=PERENUAL_BASE_URL=https://perenual.com/api/v2
```

### Open-Meteo

Usato per:

- geocoding città;
- meteo corrente;
- previsione a 5 giorni.

Non richiede API key nella configurazione attuale.

### Rest Countries

Usato per lista paesi.

---

## 20. Comandi di sviluppo

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

Pulizia build:

```bash
flutter clean
flutter pub get
```

Se è stato cambiato package Android o `MainActivity`, disinstallare le vecchie app dal device/emulatore prima di rilanciare:

```bash
adb uninstall it.fudeo.my_garden
adb uninstall com.plantly.app
flutter run
```

---

## 21. Test manuale consigliato

### Auth e sessione

```text
1. Avvia app non autenticata
2. Verifica redirect a SignIn
3. Registrati con email/password
4. Verifica redirect automatico alla Home
5. Logout
6. Login con email
7. Logout
8. Login con username
9. Login/registrazione Google
10. Se profilo incompleto, verifica redirect a completamento profilo
11. Salva paese/città e verifica redirect alla Home
```

### Search e Garden

```text
1. Vai in Cerca
2. Cerca “monstera”
3. Apri dettaglio
4. Aggiungi nickname opzionale
5. Aggiungi al giardino
6. Verifica documento in users/{uid}/garden
7. Torna in Garden
8. Verifica card reale
9. Rimuovi pianta
10. Verifica rimozione da Firestore
```

### Home

```text
1. Con giardino vuoto: verifica empty state
2. Aggiungi una pianta
3. Verifica totale piante
4. Verifica prossima cura se nextWateringAt è presente
5. Pull-to-refresh
```

### Meteo

```text
1. Completa profilo con paese e città
2. Verifica che latitude/longitude siano salvate
3. Apri Drawer > Meteo
4. Verifica meteo corrente
5. Verifica forecast 5 giorni
6. Pull-to-refresh
7. Rimuovi coordinate/profilo incompleto e verifica card missing-location
```

### Smart pot manuale

```text
1. Crea un documento devices/{deviceId} valido
2. Collega deviceId a una pianta in users/{uid}/garden/{plantId}
3. Verifica card smart pot nella PlantCard
4. Verifica stato online/offline in base a lastSeenAt
5. Premi Annaffia ora
6. Verifica creazione comando pending in devices/{deviceId}/commands
```

---

## 22. Criticità e cleanup rilevati

### Priorità alta

1. **Verificare `flutter analyze` sul progetto completo**  
   Lo zip contiene solo `lib/` e README. Alcuni problemi possono emergere solo con `pubspec.yaml`, asset e piattaforme native.

2. **Consolidare Firestore Rules per smart pot**  
   I path `devices/{deviceId}` e `devices/{deviceId}/commands` richiedono regole più rigorose prima di usare hardware reale.

3. **Completare consumer comandi smart pot**  
   L'app crea comandi pending, ma nessun backend/firmware li consuma nello zip analizzato.

4. **Pulire definitivamente il flusso legacy `UserPlant`**  
   Il flusso reale usa `GardenPlant`, ma restano file legacy:
   ```text
   features/plant/user_plant.dart
   repositories/user_plants_repository.dart
   cubits/user_plants/
   ```

### Priorità media

5. **Rinominare `condition_wether_animation.dart`**  
   Refuso nel nome file. Suggerito:
   ```text
   condition_weather_animation.dart
   ```
   Aggiornare anche gli import.

6. **Aggiornare commenti `UserPlant` nei file smart pot**  
   Alcuni commenti parlano ancora di `UserPlant`, mentre il modello reale è `GardenPlant`.

7. **Gestire deprecazioni `withOpacity()`**  
   Sono warning diffusi, non bloccanti. Flutter recente suggerisce alternative basate su `withValues()`.

8. **Valutare performance dei Cubit locali nelle card smart pot**  
   Per pochi elementi va bene. Con molte piante potrebbe convenire una gestione più centralizzata.

9. **Separare il tema in file più piccoli**  
   `theme.dart` è molto grande. Si può dividere in palette, typography, gradients e theme factory.

### Priorità bassa

10. **Rimuovere widget legacy non usati**  
   Esempio: `SearchComingSoonCard`, se non è più referenziato.

11. **Uniformare naming `deviceId` / `smartPotId`**  
   Il fallback è corretto, ma in futuro conviene migrare i documenti vecchi e usare solo `deviceId`.

12. **Verificare asset Lottie/GIF del meteo**  
   Lo zip non include gli asset, quindi il caricamento reale va verificato nel progetto completo.

---

## 23. Roadmap consigliata

### Fase 1 — Stabilizzazione immediata

- eseguire `flutter analyze`;
- correggere warning bloccanti o errori reali;
- verificare package Android e `MainActivity`;
- verificare asset meteo registrati nel `pubspec.yaml`;
- verificare redirect auth dopo email/password e Google;
- verificare flow meteo con location completa/incompleta.

### Fase 2 — Pulizia tecnica

- rimuovere o archiviare `UserPlant` legacy;
- rinominare `condition_wether_animation.dart`;
- aggiornare commenti smart pot;
- sostituire gradualmente `withOpacity()`;
- ridurre dimensione del file tema.

### Fase 3 — Smart pot reale

- completare UI collegamento device-pianta;
- definire security rules definitive;
- implementare consumer comandi lato firmware/backend;
- gestire stati comando: pending, running, completed, failed;
- scrivere storico irrigazioni;
- aggiornare serbatoio stimato dopo comando completato.

### Fase 4 — Irrigazione automatica

- definire algoritmo operativo iniziale;
- usare soglie umidità, cooldown, limite giornaliero, serbatoio e sicurezza;
- aggiungere meteo solo quando il flusso base è stabile;
- non far generare comandi automatici direttamente alla UI se serve affidabilità: preferire backend/Cloud Function.

### Fase 5 — Notifiche

- integrare plugin nativo o FCM;
- reminder irrigazione;
- alert serbatoio basso;
- alert umidità bassa;
- alert device offline;
- notifica completamento irrigazione.

---

## 24. Mappa dei file principali

### Core

```text
lib/core/app_router.dart
lib/core/app_state_listener.dart
lib/core/go_router_refresh_stream.dart
lib/core/parse_from_json.dart
lib/core/perenual_config.dart
lib/core/routes.dart
```

### Auth e sessione

```text
lib/blocs/auth/auth_bloc.dart
lib/cubits/session/session_cubit.dart
lib/cubits/sign_in/sign_in_cubit.dart
lib/cubits/sign_up/sign_up_cubit.dart
lib/cubits/sign_out/sign_out_cubit.dart
lib/cubits/google_profile_completion/google_profile_completion_cubit.dart
lib/cubits/profile/profile_cubit.dart
```

### Plants/Garden

```text
lib/features/plant/plant_species.dart
lib/features/plant/garden_plant.dart
lib/repositories/plant_repository.dart
lib/repositories/garden_repository.dart
lib/cubits/plant_search/plant_search_cubit.dart
lib/cubits/plant_details/plant_details_cubit.dart
lib/cubits/garden/garden_cubit.dart
```

### Home

```text
lib/cubits/home/home_cubit.dart
lib/pages/home_page.dart
lib/widgets/home/home_greeting_widget.dart
lib/widgets/home/home_metric_grid.dart
lib/widgets/home/home_reminder_card.dart
lib/widgets/home/home_user_card.dart
```

### Smart pot

```text
lib/features/smart_pot/smart_pot_device.dart
lib/features/smart_pot/smart_pot_telemetry.dart
lib/features/smart_pot/smart_pot_config.dart
lib/repositories/smart_pot_repository.dart
lib/cubits/smart_pot/smart_pot_cubit.dart
lib/cubits/irrigation_control/irrigation_control_cubit.dart
lib/cubits/auto_irrigation_settings/auto_irrigation_settings_cubit.dart
lib/widgets/smart_pot/
```

### Location/Meteo

```text
lib/features/location/country_option.dart
lib/features/location/city_option.dart
lib/repositories/location_repository.dart
lib/widgets/location/country_picker_field.dart
lib/widgets/location/city_picker_field.dart
lib/features/weather/weather_data.dart
lib/repositories/weather_repository.dart
lib/cubits/weather/weather_cubit.dart
lib/pages/weather_page.dart
lib/widgets/weather/
```

### Navigazione/UI

```text
lib/pages/main_shell_page.dart
lib/widgets/navigation/app_drawer.dart
lib/widgets/bottom_appbar/plantly_bottom_navigation.dart
```

---

## 25. Stato finale sintetico

### Solido

- auth email/password;
- login con username;
- Google Sign-In;
- completamento profilo Google;
- profilo Firestore realtime;
- routing `go_router`;
- shell con tab persistenti;
- Home collegata al giardino reale;
- search Perenual;
- dettaglio pianta;
- garden Firestore realtime;
- rimozione pianta;
- drawer con meteo;
- pagina meteo con Open-Meteo;
- forecast 5 giorni;
- predisposizione smart pot ben separata;
- comando manuale pending;
- configurazione automatica salvata senza generare comandi;
- feedback centralizzato con `SnackBarHelper`.

### Da completare prima di considerare la feature smart pot realmente pronta

- regole Firestore definitive;
- linking device-pianta da UI;
- backend/firmware consumer comandi;
- stati comando;
- gestione serbatoio dopo irrigazione;
- algoritmo automatico;
- notifiche reali;
- test su device fisico.

### Da completare prima di una release pulita

- `flutter analyze` pulito;
- pulizia legacy `UserPlant`;
- verifica asset e `pubspec.yaml`;
- verifica package Android/iOS;
- cleanup deprecazioni;
- test manuale dei principali flow.
