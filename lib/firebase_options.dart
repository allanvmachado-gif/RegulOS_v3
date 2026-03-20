// ═══════════════════════════════════════════════════════════
//  firebase_options.dart
//  ⚠️  NÃO EDITE ESTE ARQUIVO MANUALMENTE se usar GitHub Actions.
//  O CI injeta os valores automaticamente via Secrets.
//  Se quiser testar local, substitua os COLE_AQUI pelos seus dados.
//  Guia: console.firebase.google.com → Configurações do projeto
// ═══════════════════════════════════════════════════════════
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return web;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  WEB  (também usada como fallback)
  //  Encontre em: Configurações do projeto → Seus apps → </> Web
  // ─────────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'COLE_AQUI_apiKey',
    appId:             'COLE_AQUI_appId',
    messagingSenderId: 'COLE_AQUI_messagingSenderId',
    projectId:         'COLE_AQUI_projectId',
    authDomain:        'COLE_AQUI_authDomain',
    storageBucket:     'COLE_AQUI_storageBucket',
  );

  // ─────────────────────────────────────────────────────────
  //  ANDROID
  //  Encontre em: Configurações do projeto → Seus apps → Android
  //  Ou baixe o google-services.json e copie os valores de lá.
  // ─────────────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'COLE_AQUI_apiKey_android',
    appId:             'COLE_AQUI_appId_android',
    messagingSenderId: 'COLE_AQUI_messagingSenderId',
    projectId:         'COLE_AQUI_projectId',
    storageBucket:     'COLE_AQUI_storageBucket',
  );
}
