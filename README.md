# ZIP Game (Flutter)

Cliente Flutter (web y Android) con arquitectura por capas presentation / domain / data. Consume la API en `zip_game_api`.

## Instalación y ejecución
```bash
flutter pub get
# con el backend encendido en http://localhost:3333
flutter run -d chrome
# Android (emulador): flutter run --dart-define=API_URL=http://10.0.2.2:3333/api
```
Usuario demo: demo@zipgame.test / demo12345

## Pruebas
```bash
flutter test
flutter test test/integration --dart-define=INTEGRATION=true   # requiere backend encendido
```
