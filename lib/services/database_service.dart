import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Serviço responsável por gerir a gravação dos registos de ponto.
class DatabaseService {
  // Grava o registo de ponto no Firebase Firestore.
  // Caso o Firebase não esteja configurado, executa uma simulação em modo de teste.
  Future<void> savePointRecord({
    required String userId,
    required double latitude,
    required double longitude,
    required double distance,
  }) async {
    // Verifica se existe pelo menos uma aplicação Firebase inicializada com sucesso
    if (Firebase.apps.isNotEmpty) {
      final FirebaseFirestore db = FirebaseFirestore.instance;

      await db.collection('registros_ponto').add({
        'userId': userId,
        'dataHora': FieldValue.serverTimestamp(),
        'latitude': latitude,
        'longitude': longitude,
        'distanciaMetros': distance,
        'status': 'Aprovado',
      });
      debugPrint('Sucesso: Registo gravado no Firestore.');
    } else {
      // Modo de simulação para desenvolvimento local (evita erros quando o Firebase não está ligado)
      debugPrint('--- MODO DE TESTE ATIVO (Sem conexão ao Firebase) ---');
      debugPrint('ID do Utilizador: $userId');
      debugPrint('Coordenadas: $latitude, $longitude');
      debugPrint('Distância calculada: ${distance.toStringAsFixed(2)} metros');

      // Simula uma pequena pausa de rede de 1 segundo
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}