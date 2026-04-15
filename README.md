# Pollice Blu — Refactor Guide

## File da sostituire nel tuo progetto

Copia ogni file nella cartella corrispondente del tuo progetto:

| File generato | Destinazione nel progetto |
|---|---|
| `lib/blocs/auth/auth_bloc_state.dart` | `lib/blocs/auth/auth_bloc_state.dart` *(nuovo file)* |
| `lib/blocs/auth/auth_bloc_event.dart` | `lib/blocs/auth/auth_bloc_event.dart` |
| `lib/blocs/auth/auth_bloc.dart` | `lib/blocs/auth/auth_bloc.dart` |
| `lib/repositories/auth_repository.dart` | `lib/repositories/auth_repository.dart` |
| `lib/cubits/sign_out/sign_out_cubit.dart` | `lib/cubits/sign_out/sign_out_cubit.dart` |
| `lib/cubits/sign_out/sign_out_state.dart` | `lib/cubits/sign_out/sign_out_state.dart` *(nuovo file)* |
| `lib/main.dart` | `lib/main.dart` |
| `lib/app.dart` | `lib/app.dart` |
| `lib/features/theme/models/theme.dart` | `lib/features/theme/models/theme.dart` |
| `lib/pages/sign_in_page.dart` | `lib/pages/sign_in_page.dart` |
| `lib/pages/home_page.dart` | `lib/pages/home_page.dart` |
| `lib/pages/splash_screen.dart` | `lib/pages/splash_screen.dart` |

## Ordine consigliato di sostituzione

1. `auth_bloc_state.dart` (nuovo)
2. `auth_bloc_event.dart`
3. `auth_bloc.dart`
4. `auth_repository.dart`
5. `sign_out_state.dart` (nuovo)
6. `sign_out_cubit.dart`
7. `main.dart`
8. `app.dart`
9. `theme.dart`
10. `sign_in_page.dart`
11. `home_page.dart`
12. `splash_screen.dart`

## ⚠️ Note importanti

- Sostituisci `polliceblu_app` negli import con il nome del tuo package da `pubspec.yaml`
- Aggiungi `collection: ^1.17.0` al `pubspec.yaml` se non presente
- `sign_out_state.dart` è un file **nuovo** da creare
- `auth_bloc_state.dart` è un file **nuovo** da creare (prima era inline)
- Adatta `SignInBloc.signIn(email, password)` se la firma è diversa
