import 'package:app_estoque_limpeza/presentation/pages/users/movimenta%C3%A7%C3%A3o_page_user.dart';
import 'package:flutter/material.dart';
import 'package:app_estoque_limpeza/data/model/produto_model.dart';
import 'package:app_estoque_limpeza/data/repositories/produto_repositories.dart';

class HomePageFuncionario extends StatefulWidget {
  const HomePageFuncionario({super.key});

  @override
  HomePageFuncionarioState createState() => HomePageFuncionarioState();
}

class HomePageFuncionarioState extends State<HomePageFuncionario> {
  final ProdutoRepositories _produtoRepository = ProdutoRepositories();
  final TextEditingController _searchController = TextEditingController();
  List<ProdutoModel> _produtos = [];
  List<ProdutoModel> _produtosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
    _searchController.addListener(_filtrarProdutos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Método para carregar os produtos cadastrados
  _carregarProdutos() async {
    final produtos = await _produtoRepository.getProduto();
    if (mounted) {
      setState(() {
        _produtos = produtos;
        _produtosFiltrados = produtos; // Inicialmente, exibe todos
      });
    }
  }

  // Método para filtrar produtos pelo nome
  void _filtrarProdutos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _produtosFiltrados = _produtos
          .where((produto) => produto.nome.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos Cadastrados',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar Produto',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _produtosFiltrados.isEmpty
                  ? const Center(child: Text('Nenhum produto encontrado'))
                  : ListView.builder(
                      itemCount: _produtosFiltrados.length,
                      itemBuilder: (context, index) {
                        final produto = _produtosFiltrados[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          child: ListTile(
                            leading: const Icon(Icons.shopping_cart,
                                color: Colors.blue),
                            title: Text(produto.nome,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text('Quantidade: ${produto.quantidade}'),
                            onTap: () {
                              _showProdutoDetails(produto);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Função para mostrar detalhes do produto
  void _showProdutoDetails(ProdutoModel produto) {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProdutoDetalhesPageFun(produto: produto),
    ),
  );
}
}
