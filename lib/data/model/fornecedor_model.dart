class Fornecedor {
  final int? idfornecedor;
  final String nome;
  final String endereco;
  final String telefone; 
  final String cnpj;

  Fornecedor(
      {this.idfornecedor,
      required this.nome,
      required this.endereco,
      required this.telefone,
      required this.cnpj,});

  Map<String, dynamic> toMap() {
    return {
      'idfornecedor': idfornecedor,
      'nome': nome,
      'endereco': endereco,
      'telefone': telefone,
      'cnpj': cnpj,
    };
  }
}
