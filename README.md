# Registro de Ponto Eletrônico

Aplicativo Flutter para registrar ponto com validação de localização, escolha de autenticação biométrica ou por e-mail e senha, e gravação no Cloud Firestore. O projeto também possui modos de simulação para desenvolvimento sem Firebase e para biometria.

## Requisitos

- Flutter SDK compatível com Dart `^3.13.2` (veja `environment` em `pubspec.yaml`).
- Android Studio com Android SDK e ferramentas de linha de comando; Java 17 para o build Android.
- Um emulador Android ou dispositivo físico. Para localização e biometria reais, prefira um celular com GPS e sensor biométrico.
- Firebase CLI e FlutterFire CLI somente se for configurar Firebase.

Confira a instalação do ambiente e os dispositivos disponíveis:

```powershell
flutter doctor
flutter devices
```

## Executar localmente

No PowerShell, na pasta do projeto:

```powershell
flutter pub get
flutter run
```

Para selecionar um dispositivo específico, use o identificador listado por `flutter devices`:

```powershell
flutter run -d <id-do-dispositivo>
```

O aplicativo pode ser executado sem Firebase. Nesse modo, a gravação é simulada: os dados do ponto são enviados ao log de depuração, mas não persistidos. Na biometria, o modo atual também simula uma aprovação após um segundo. Emuladores podem não fornecer uma posição útil por padrão; configure uma localização nas opções do emulador ou use um dispositivo físico com o GPS ativado.

## Configurar Firebase

O projeto usa Firebase Core, Firebase Authentication com e-mail/senha e Cloud Firestore. No estado atual, não há arquivo de configuração Firebase no repositório e o Gradle Android ainda não aplica o plugin Google Services. Sem configuração, a inicialização é capturada em `main.dart` e o aplicativo segue em modo de simulação.

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/) e adicione um aplicativo Android com o ID `com.example.app_de_registro` (definido em `android/app/build.gradle.kts`). Se mudar esse ID, use o mesmo no Firebase.
2. Baixe o `google-services.json` desse aplicativo e coloque-o em `android/app/google-services.json`. Não versionar credenciais de ambientes privados sem a autorização da equipe; prefira gerenciar o arquivo por ambiente.
3. No Firebase Console, habilite **Authentication > Sign-in method > E-mail/Senha** e crie/importe as contas de teste.
4. Crie o banco Cloud Firestore. Configure regras que autorizem somente usuários autenticados e limitem leitura/escrita conforme a política do projeto. Não publique regras abertas.
5. Configure o plugin Google Services para o projeto Android seguindo a documentação oficial do Firebase para Flutter/Gradle Kotlin DSL: declare o plugin `com.google.gms.google-services` no bloco `plugins` de `android/settings.gradle.kts` (com uma versão compatível atual) e aplique-o em `android/app/build.gradle.kts`.
6. Depois da configuração, execute:

   ```powershell
   flutter clean
   flutter pub get
   flutter run
   ```

O aplicativo grava os documentos na coleção `registros_ponto`, com os campos `userId`, `dataHora` (timestamp do servidor), `latitude`, `longitude`, `distanciaMetros` e `status` (`Aprovado`). Antes de considerar a integração pronta para produção, corrija o comportamento de autenticação descrito em [limitações e segurança](#limitações-e-segurança).

## APIs e permissões

### Geolocalização

O pacote `geolocator` verifica se o serviço de localização está ativo, solicita permissão em tempo de execução e obtém uma posição de alta precisão. No Android, as permissões `ACCESS_FINE_LOCATION` e `ACCESS_COARSE_LOCATION` já estão declaradas em `android/app/src/main/AndroidManifest.xml`. O serviço compara a posição com as coordenadas atualmente definidas em `LocationService`:

- Latitude: `-22.736829`
- Longitude: `-47.332353`
- Raio efetivamente aplicado: `100 m`

Para apontar para outra unidade, altere as coordenadas e o limite em `lib/services/location_service.dart`. A mensagem mostrada pela tela também deve ser atualizada para refletir o mesmo limite.

### Biometria

O pacote `local_auth` é usado pelo `BiometricService`. O Android já declara `USE_BIOMETRIC` e `USE_FINGERPRINT`, e a atividade usa `FlutterFragmentActivity`, necessária para essa integração. No momento, `BiometricService.isMockMode` está em `true`; portanto, a autenticação real não é chamada. Para testar biometria real, use um dispositivo configurado com biometria, mude o valor para `false` e trate os casos de dispositivo sem sensor ou sem biometria cadastrada.

## Como usar

1. Abra o aplicativo e toque em **Registrar Ponto**.
2. Permita o acesso à localização e mantenha o GPS ativado.
3. O aplicativo calcula a distância até as coordenadas configuradas. Se estiver fora do raio, o registro é interrompido.
4. Dentro do raio, escolha **Biometria** ou **E-mail e Senha**.
5. Após a autenticação, o registro é enviado ao Firestore quando Firebase está configurado; sem Firebase, a operação é simulada e aparece no log.
6. A tela informa o resultado. No login, o campo aceita e-mail; apesar do rótulo mencionar NIF, o Firebase Auth usado no código exige um endereço de e-mail.

## Fluxo implementado

```text
[Toque em "Registrar Ponto"]
          |
          v
[Obter GPS e calcular distância]
          |
          +-- Fora de 100 m --> [Interromper e informar distância]
          |
          +-- Até 100 m ------> [Escolher autenticação]
                                  /                \
                         [Biometria]        [E-mail e senha]
                         [simulada hoje]    [Firebase ou simulação]
                                  \                /
                                   v              v
                              [Gravar ponto no Firestore
                               ou simular sem Firebase]
```

## Implementação

- `lib/main.dart`: inicializa o Flutter e tenta inicializar Firebase; se falhar, inicia a interface em modo de simulação.
- `lib/screens/home_srceen.dart`: tela principal e coordenação das etapas de localização, autenticação e registro.
- `lib/services/location_service.dart`: permissões, leitura de localização, distância até a unidade e validação do raio.
- `lib/services/biometric_service.dart`: biometria real ou simulada, conforme `isMockMode`.
- `lib/services/database_service.dart`: gravação na coleção Firestore ou simulação sem Firebase.

Dependências principais: `geolocator`, `local_auth`, `firebase_core`, `firebase_auth` e `cloud_firestore`. As versões declaradas ficam em `pubspec.yaml`.

## Desenvolvimento e verificações

Baixe dependências e execute os testes/análises disponíveis:

```powershell
flutter pub get
flutter analyze
flutter test
```

Para gerar um APK de depuração:

```powershell
flutter build apk --debug
```

Ao testar geolocalização, permita o acesso, ative o GPS e forneça uma posição dentro do raio configurado. Para testar o Firestore, confirme também que o dispositivo tem acesso à internet e que as regras do banco permitem a operação.

## Limitações e segurança

- **Autenticação permissiva:** se Firebase estiver configurado e o login falhar, a tela captura o erro e continua o registro em modo de teste. Assim, credenciais inválidas podem resultar em um ponto registrado. Isso é inadequado para produção; falhas de autenticação devem interromper o fluxo.
- **Identidade biométrica:** o registro biométrico usa o identificador fixo `funcionario_biometria`, não uma conta individual autenticada.
- **Simulações:** sem Firebase, nada é persistido. A biometria simulada não verifica a identidade do usuário.
- **NFC:** não há suporte implementado.
- **Validação de localização:** a checagem acontece no dispositivo e, isoladamente, não é uma prova antifraude. Um produto de produção precisa avaliar validação no servidor e controles adicionais.

## OBSERVAÇÕES IMPORTANTES:

- caso precise para testar o aplicativo, altere as coordenadas da empresa em `lib/services/location_service.dart` para o local desejado.