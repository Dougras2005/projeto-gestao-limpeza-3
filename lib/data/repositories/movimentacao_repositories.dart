import 'package:app_estoque_limpeza/core/database_helper.dart';
import 'package:app_estoque_limpeza/data/model/movimentacao_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MovimentacaoRepository {
  Future<void> insertMovimentacao(Movimentacao movimentacao) async {
    final db = await DatabaseHelper.initDb();
    await db.insert(
      'movimentacao',
      movimentacao.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Movimentacao>> getMovimentacoes() async {
    final db = await DatabaseHelper.initDb();
    final List<Map<String, Object?>> movimentacaoMaps =
        await db.query('movimentacao');
    return movimentacaoMaps.map((map) {
      return Movimentacao(
        idmovimentacao: map['idmovimentacao'] as int?,
        entradaData: map['entrada_data'] as String,
        saidaData: map['saida_data'] as String,
        idproduto: map['idmaterial'] as int,
        idusuario: map['idusuario'] as int,
      );
    }).toList();
  }

  Future<void> updateMovimentacao(Movimentacao movimentacao) async {
    final db = await DatabaseHelper.initDb();
    await db.update(
      'movimentacao',
      movimentacao.toMap(),
      where: 'idmovimentacao = ?',
      whereArgs: [movimentacao.idmovimentacao],
    );
  }

  Future<void> deleteMovimentacao(int id) async {
    final db = await DatabaseHelper.initDb();
    await db.delete(
      'movimentacao',
      where: 'idmovimentacao = ?',
      whereArgs: [id],
    );
  }
}
