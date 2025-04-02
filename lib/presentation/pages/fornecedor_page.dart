import 'package:app_estoque_limpeza/data/repositories/fornecedor_repository.dart';
import 'package:flutter/material.dart';
import 'package:app_estoque_limpeza/data/model/fornecedor_model.dart';

class FornecedorPage extends StatefulWidget {
  const FornecedorPage({super.key});

  @override
  FornecedorState createState() => FornecedorState();
}

class FornecedorState extends State<FornecedorPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _cnpjController = TextEditingController();

  // Instância do repositório
  final FornecedorRepository _fornecedorRepository = FornecedorRepository();

  Future<void> _cadastrarFornecedor() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Criar o objeto fornecedor com os dados dos campos
        final fornecedor = Fornecedor(
          idfornecedor: null, // ID será gerado automaticamente
          nome: _nomeController.text,
          endereco: _enderecoController.text,
          telefone: _telefoneController.text,
          cnpj: _cnpjController.text,
        );

        // Inserir o fornecedor no banco de dados
        await _fornecedorRepository.insertFornecedor(fornecedor);

        // Verifica se o widget ainda está montado antes de usar o contexto
        if (!mounted) return;

        // Exibir mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fornecedor cadastrado com sucesso!')),
        );

        // Limpar os campos após o cadastro
        _nomeController.clear();
        _enderecoController.clear();
        _telefoneController.clear();
        _cnpjController.clear();
      } catch (e) {
        // Verifica se o widget ainda está montado antes de usar o contexto
        if (!mounted) return;

        // Exibir mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar fornecedor: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.blue[50],
      labelStyle: const TextStyle(color: Colors.black),
      hintStyle: const TextStyle(color: Colors.black54),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Fornecedor'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: inputDecoration.copyWith(labelText: 'Nome'),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _enderecoController,
                  decoration: inputDecoration.copyWith(labelText: 'Endereço'),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O endereço é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
TextFormField(
  controller: _cnpjController,
  decoration: inputDecoration.copyWith(labelText: 'CNPJ'),
  keyboardType: TextInputType.number,
  style: const TextStyle(color: Colors.black),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'O CNPJ é obrigatório';
    }
    // Remove caracteres não numéricos
    final cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    // Verifica se tem 14 dígitos
    final regex = RegExp(r'^\d{14}$');
    if (!regex.hasMatch(cleanedValue)) {
      return 'Por favor, insira um CNPJ válido (14 dígitos)';
    }
    return null;
  },
),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _cadastrarFornecedor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cadastrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
