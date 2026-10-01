import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

// Serviço responsável por gerenciar a autenticação biométrica (Impressão Digital / Face ID).
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // ATENÇÃO: Mantenha 'true' para testar no Computador/BlueStacks.
  // Mude para 'false' quando for testar em um celular físico real.
  static const bool isMockMode = true;

  /// Verifica se o dispositivo possui hardware e suporte ativo para biometria.
  Future<bool> isBiometricsAvailable() async {
    try {
      bool canCheck = await _auth.canCheckBiometrics;
      bool isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      debugPrint('Aviso de biometria: $e');
      return false;
    }
  }

  /// Dispara a verificação biométrica real ou simula o sucesso quando executado no PC.
  Future<bool> authenticate() async {
    // Modo de Simulação ativado para testes em Emuladores no Computador
    if (isMockMode) {
      debugPrint('--- BIOMETRIA SIMULADA COM SUCESSO (Modo PC/Emulador) ---');
      // Aguarda 1 segundo para simular o tempo de leitura do sensor
      await Future.delayed(const Duration(seconds: 1));
      return true; // Retorna aprovado
    }

    // Fluxo de Autenticação Real (para celulares físicos)
    try {
      bool available = await isBiometricsAvailable();
      if (!available) {
        debugPrint('Biometria não disponível neste dispositivo.');
        return false;
      }

      return await _auth.authenticate(
        localizedReason: 'Confirme a sua biometria para registrar o ponto',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      debugPrint('Erro durante a autenticação biométrica: $e');
      return false;
    }
  }
}