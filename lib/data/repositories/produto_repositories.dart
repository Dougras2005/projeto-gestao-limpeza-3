import 'package:app_estoque_limpeza/core/database_helper.dart';
import 'package:app_estoque_limpeza/data/model/produto_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ProdutoRepositories {
  Future<void> insertProduto(ProdutoModel produto) async {
    final db = await DatabaseHelper.initDb();
    await db.insert(
      'Produto',
      produto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProdutoModel>> getProduto({int? quantidadeMinima}) async {
  final db = await DatabaseHelper.initDb();
  
  // Query SQL condicional
  final List<Map<String, Object?>> produtoMaps = quantidadeMinima != null
      ? await db.query(
          'Produto',
          where: 'Quantidade >= ?',
          whereArgs: [quantidadeMinima],
        )
      : await db.query('Produto');

  return produtoMaps.map((map) {
    return ProdutoModel(
      idMaterial: map['idproduto'] as int?,
      codigo: map['Codigo'] as String,
      nome: map['Nome'] as String,
      quantidade: map['Quantidade'] as int,
      validade: map['Validade'] as String?,
      local: map['Local'] as String,
      idtipo: map['idtipo'] as int,
      idfornecedor: map['idfornecedor'] as int,
      entrada: map['entrada'] as String,
    );
  }).toList();
}


  Future<void> updateProduto(ProdutoModel produto) async {
    final db = await DatabaseHelper.initDb();
    await db.update(
      'produto',
      produto.toMap(),
      where: 'idproduto = ?',
      whereArgs: [produto.idMaterial],
    );
  }

  Future<void> deleteProduto(int id) async {
    final db = await DatabaseHelper.initDb();
    await db.delete(
      'produto',
      where: 'idproduto = ?',
      whereArgs: [id],
    );
  }
}
