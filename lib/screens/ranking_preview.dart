import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking Global'),
      ),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .orderBy('pontuacao', descending: true)
            .snapshots(),
            
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          
          if (snapshot.hasError) {
            return const Center(
              child: Text('Ocorreu um erro ao carregar o ranking.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nenhum jogador encontrado no ranking.'),
            );
          }

          final List<DocumentSnapshot> documentos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documentos.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data = documentos[index].data() as Map<String, dynamic>;
              
              String nomeJogador = data['nome'] ?? 'Jogador Anônimo';
              int pontuacao = data['pontuacao'] ?? 0;

              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}º'),
                ),
                title: Text(
                  nomeJogador,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  '$pontuacao pts',
                  style: const TextStyle(fontSize: 16, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}