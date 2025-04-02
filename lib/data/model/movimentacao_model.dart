class Movimentacao {
  final int? idmovimentacao;
  final String entradaData;
  final String saidaData;
  final int idproduto;
  final int idusuario;

  Movimentacao({
    this.idmovimentacao,
    required this.entradaData,
    required this.saidaData,
    required this.idproduto,
    required this.idusuario,
  });

  Map<String, dynamic> toMap() {
    return {
      'idmovimentacao': idmovimentacao,
      'entrada_data': entradaData,
      'saida_data': saidaData,
      'idmaterial': idproduto,
      'idusuario': idusuario,
    };
  }
}
