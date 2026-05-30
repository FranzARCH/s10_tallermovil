// lib/presentation/pages/catalogo_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/producto_viewmodel.dart';
import '../viewmodels/producto_state.dart';
import '../widgets/nav_drawer.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  @override
  void initState() {
    super.initState();
    // Cargar productos al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductoViewModel>().cargarProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductoViewModel>();
    return Scaffold(
      appBar: AppBar(
        title:           const Text('Catálogo de Productos'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon:     const Icon(Icons.refresh),
            onPressed: () => context.read<ProductoViewModel>().cargarProductos(),
          ),
        ],
      ),
      drawer: const NavDrawer(),
      body: switch (vm.state.status) {
        ProductoStatus.loading => const Center(child: CircularProgressIndicator()),
        ProductoStatus.error   => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text(vm.state.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.read<ProductoViewModel>().cargarProductos(),
                icon:  const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        ProductoStatus.success when vm.state.productos.isEmpty =>
          const Center(child: Text('No hay productos registrados.')),
        ProductoStatus.success => ListView.separated(
          padding:          const EdgeInsets.all(12),
          itemCount:        vm.state.productos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (ctx, i) {
            final p = vm.state.productos[i];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.indigo,
                      radius: 24,
                      child: Text(p.nombre[0],
                        style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('${p.categoria}  •  Cód: ${p.codigo}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('Stock: ${p.stock} unidades',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('S/ ${p.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color:      Colors.indigo,
                            fontWeight: FontWeight.bold,
                            fontSize:   16)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        _ => const Center(child: Text('Cargando...')),
      },
    );
  }
}
