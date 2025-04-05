import 'package:app_estoque_limpeza/data/model/movimentacao_model.dart';
import 'package:app_estoque_limpeza/presentation/viewmodel/produto_viewmodel.dart';
import 'package:app_estoque_limpeza/presentation/viewmodel/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:app_estoque_limpeza/data/model/produto_model.dart';
import 'package:app_estoque_limpeza/data/repositories/movimentacao_repositories.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:provider/provider.dart';

class ProdutoDetalhesPage extends StatefulWidget {
  final ProdutoModel produto;

  const ProdutoDetalhesPage({super.key, required this.produto});

  @override
  ProdutoDetalhesPageState createState() => ProdutoDetalhesPageState();
}

class ProdutoDetalhesPageState extends State<ProdutoDetalhesPage> {
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final MovimentacaoRepository _movimentacaoRepository = MovimentacaoRepository();
 
  String _tipoMovimentacao = 'Entrada';
  ProdutoModel? _produtoAtual; // Removido o late e tornando nullable
  bool _isAdmin = false;
  late UsuarioViewModel _usuarioViewModel;

  @override
  void initState() {
    super.initState();
    _initializeProdutoAtual();
    // Adicionamos um post-frame callback para acessar o Provider após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserPermission();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtemos os ViewModels aqui
    _usuarioViewModel = Provider.of<UsuarioViewModel>(context, listen: false);
  }

  void _initializeProdutoAtual() {
    _produtoAtual = ProdutoModel(
      idMaterial: widget.produto.idMaterial,
      codigo: widget.produto.codigo,
      nome: widget.produto.nome,
      quantidade: widget.produto.quantidade,
      validade: widget.produto.validade,
      local: widget.produto.local,
      idtipo: widget.produto.idtipo,
      idfornecedor: widget.produto.idfornecedor,
      entrada: widget.produto.entrada,
    );
  }

  
  void _checkUserPermission() {
    final usuarioViewModel = _usuarioViewModel;
    _isAdmin = usuarioViewModel.usuarioLogado?.idperfil == 1;
    
    // Se não for admin, seta o tipo padrão como Saída
    if (!_isAdmin) {
      _tipoMovimentacao = 'Saída';
    }
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _registrarMovimentacao() async {
    if (_produtoAtual == null) {
      _showDialog('Erro', 'Produto não foi carregado corretamente.');
      return;
    }

    // Verifica se é uma entrada e se o usuário tem permissão
    if (_tipoMovimentacao == 'Entrada' && !_isAdmin) {
      _showDialog('Acesso Negado', 'Somente administradores podem registrar entradas.');
      return;
    }

    final int quantidade = int.tryParse(_quantidadeController.text) ?? 0;
    final String data = _dataController.text;

    if (quantidade <= 0) {
      _showDialog('Erro', 'Informe uma quantidade válida maior que zero.');
      return;
    }

    if (data.isEmpty || !RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(data)) {
      _showDialog('Erro', 'Informe uma data válida no formato DD/MM/AAAA.');
      return;
    }

    if (_tipoMovimentacao == 'Saída' && quantidade > _produtoAtual!.quantidade) {
      _showDialog('Erro', 'Quantidade insuficiente em estoque.');
      return;
    }

    try {
      final usuarioViewModel = Provider.of<UsuarioViewModel>(context, listen: false);
      final userId = usuarioViewModel.usuarioLogado?.idusuario ?? 0;

      final movimentacao = Movimentacao(
        entradaData: _tipoMovimentacao == 'Entrada' ? data : '',
        saidaData: _tipoMovimentacao == 'Saída' ? data : '',
        idproduto: _produtoAtual!.idMaterial!,
        idusuario: userId,
      );

      await _movimentacaoRepository.insertMovimentacao(movimentacao);
      
      final produtoViewModel = Provider.of<ProdutoViewModel>(context, listen: false);
      
      setState(() {
        _produtoAtual = ProdutoModel(
          idMaterial: _produtoAtual!.idMaterial,
          codigo: _produtoAtual!.codigo,
          nome: _produtoAtual!.nome,
          quantidade: _tipoMovimentacao == 'Entrada'
              ? _produtoAtual!.quantidade + quantidade
              : _produtoAtual!.quantidade - quantidade,
          validade: _produtoAtual!.validade,
          local: _produtoAtual!.local,
          idtipo: _produtoAtual!.idtipo,
          idfornecedor: _produtoAtual!.idfornecedor,
          entrada: _produtoAtual!.entrada,
        );
      });

      await produtoViewModel.updateProduto(_produtoAtual!);

      _quantidadeController.clear();
      _dataController.clear();

      _showDialog('Sucesso', 'Movimentação registrada com sucesso.\n'
          'Nova quantidade: ${_produtoAtual!.quantidade}');
    } catch (e) {
      _showDialog('Erro', 'Ocorreu um erro ao registrar a movimentação: $e');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
   Widget build(BuildContext context) {
    if (_produtoAtual == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalhes do Produto: ${_produtoAtual!.nome}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalhes do Produto',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      const Divider(),
                      Text('Código: ${_produtoAtual!.codigo}'),
                      Text('Nome: ${_produtoAtual!.nome}'),
                      Text('Quantidade: ${_produtoAtual!.quantidade}'),
                      Text('Data de Entrada: ${_produtoAtual!.entrada}'),
                      if (_produtoAtual!.validade != null)
                        Text('Validade: ${_produtoAtual!.validade}'),
                      Text('Local: ${_produtoAtual!.local}'),
                      Text('Tipo: ${_produtoAtual!.idtipo}'),
                      Text('Fornecedor: ${_produtoAtual!.idfornecedor}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Registrar Movimentação',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blueGrey,
                        ),
                      ),
                       const Divider(),
                      _isAdmin 
                          ? DropdownButtonFormField<String>(
                              value: _tipoMovimentacao,
                              decoration: InputDecoration(
                                labelText: 'Tipo de Movimentação',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              items: ['Entrada', 'Saída']
                                  .map((tipo) => DropdownMenuItem(
                                        value: tipo,
                                        child: Text(tipo),
                                      ))
                                  .toList(),
                              onChanged: (valor) {
                                setState(() {
                                  _tipoMovimentacao = valor!;
                                });
                              },
                            )
                          : IgnorePointer(
                              child: DropdownButtonFormField<String>(
                                value: 'Saída',
                                decoration: InputDecoration(
                                  labelText: 'Tipo de Movimentação (Somente Saída)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                  ),
                                 items: ['Entrada', 'Saída']
                                    .map((tipo) => DropdownMenuItem(
                                          value: tipo,
                                          child: Text(tipo),
                                        ))
                                    .toList(),
                                    onChanged: (valor) {
                                setState(() {
                                  _tipoMovimentacao = 'Saída';
                                });
                              },
                              ),
                            ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _quantidadeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantidade',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.blue[50],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _dataController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          MaskedInputFormatter('##/##/####'),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Data (DD/MM/YYYY)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.blue[50],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _registrarMovimentacao,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: const Text(
                                'Registrar Movimentação',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: const Text(
                                'Voltar',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}