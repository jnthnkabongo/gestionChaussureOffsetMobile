import 'package:flutter/material.dart';
import 'package:frontend_api/services/service_app.dart';

class ChaussuresPage extends StatefulWidget {
  const ChaussuresPage({super.key});

  @override
  State<ChaussuresPage> createState() => _ChaussuresPage();
}

class _ChaussuresPage extends State<ChaussuresPage> {
  bool _isLoading = false;
  List<dynamic> _chaussures = [];
  List<dynamic> _filteredChaussures = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChaussures();
    _searchController.addListener(_filterChaussures);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChaussures() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final chaussures = await ApiService.getChaussures();
      setState(() {
        _chaussures = chaussures;
        _filteredChaussures = chaussures;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(
        'Erreur lors du chargement des chaussures: ${e.toString()}',
      );
    }
  }

  void _filterChaussures() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredChaussures = _chaussures.where((chaussure) {
        final nom = chaussure['nom']?.toString().toLowerCase() ?? '';
        final marque = chaussure['marque']?.toString().toLowerCase() ?? '';
        return nom.contains(query) || marque.contains(query);
      }).toList();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFC9A227),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Chaussures',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher des chaussures...',
                prefixIcon: Icon(Icons.search, color: Color(0xFFC9A227)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFC9A227), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),

          // Liste des chaussures
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Color(0xFFC9A227)),
                  )
                : _filteredChaussures.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'Aucune chaussure trouvée'
                              : 'Aucune chaussure disponible',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredChaussures.length,
                    itemBuilder: (context, index) {
                      final chaussure = _filteredChaussures[index];
                      return _buildChaussureCard(chaussure);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaussureCard(Map<String, dynamic> chaussure) {
    final stock = chaussure['stock_total'] ?? 0;
    final prix = chaussure['prix'] ?? 0;
    final deviseSymbole = chaussure['devise_symbole'] ?? '\$';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFC9A227), Color(0xFF8F6B12)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.shopping_bag, color: Colors.white, size: 32),
          ),
          title: Text(
            chaussure['nom'] ?? 'Chaussure',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                chaussure['marque'] ?? 'Marque inconnue',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.inventory,
                    size: 16,
                    color: stock > 5 ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Stock: $stock',
                    style: TextStyle(
                      fontSize: 12,
                      color: stock > 5 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$prix $deviseSymbole',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC9A227),
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: stock > 0
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  stock > 0 ? 'Disponible' : 'Rupture',
                  style: TextStyle(
                    fontSize: 10,
                    color: stock > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Divider(color: Colors.grey[200]),
            _buildChaussureDetails(chaussure),
          ],
        ),
      ),
    );
  }

  Widget _buildChaussureDetails(Map<String, dynamic> chaussure) {
    final variantes = chaussure['variantes'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Variantes disponibles',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        if (variantes.isEmpty)
          Text(
            'Aucune variante disponible',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: variantes.map((variante) {
              final pointure = variante['pointure']?.toString() ?? '?';
              final couleur = variante['couleur']?.toString() ?? '?';
              final stockVariante = variante['stock'] ?? 0;

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: stockVariante > 0
                      ? Color(0xFFC9A227).withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: stockVariante > 0
                        ? Color(0xFFC9A227)
                        : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$pointure - $couleur',
                      style: TextStyle(
                        fontSize: 12,
                        color: stockVariante > 0
                            ? Color(0xFFC9A227)
                            : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '($stockVariante)',
                      style: TextStyle(
                        fontSize: 10,
                        color: stockVariante > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        SizedBox(height: 16),
        _buildVenteButton(chaussure),
      ],
    );
  }

  Widget _buildVenteButton(Map<String, dynamic> chaussure) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showVenteBottomSheet(chaussure),
        icon: Icon(Icons.shopping_cart, color: Colors.white),
        label: Text(
          'Vendre',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFC9A227),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  void _showVenteBottomSheet(Map<String, dynamic> chaussure) {
    final _telephoneController = TextEditingController();
    final _quantiteController = TextEditingController();
    String? _selectedVarianteId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enregistrer une vente',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Info chaussure
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFC9A227).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shopping_bag, color: Color(0xFFC9A227)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chaussure['nom'] ?? 'Chaussure',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '${chaussure['prix'] ?? 0} ${chaussure['devise_symbole'] ?? '\$'}',
                                style: TextStyle(
                                  color: Color(0xFFC9A227),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Client
                  TextField(
                    controller: _telephoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Numéro de téléphone',
                      hintText: 'Entrez le numéro du client',
                      prefixIcon: Icon(Icons.phone, color: Color(0xFFC9A227)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFFC9A227),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Sélection variante
                  Text(
                    'Sélectionnez une variante',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (chaussure['variantes'] as List<dynamic>? ?? []).map((
                      variante,
                    ) {
                      final stock = variante['stock'] ?? 0;
                      final isSelected =
                          _selectedVarianteId == variante['id'].toString();
                      final isOutOfStock = stock <= 0;

                      return InkWell(
                        onTap: isOutOfStock
                            ? null
                            : () {
                                setModalState(() {
                                  _selectedVarianteId = variante['id']
                                      .toString();
                                });
                              },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xFFC9A227)
                                : (isOutOfStock
                                      ? Colors.grey[300]
                                      : Color(
                                          0xFFC9A227,
                                        ).withValues(alpha: 0.1)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Color(0xFFC9A227)
                                  : (isOutOfStock
                                        ? Colors.grey[400]!
                                        : Color(0xFFC9A227)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${variante['pointure']} - ${variante['couleur']}',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isOutOfStock
                                            ? Colors.grey[600]
                                            : Color(0xFFC9A227)),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '($stock)',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isOutOfStock
                                            ? Colors.grey[600]
                                            : Colors.green),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),

                  // Quantité
                  TextField(
                    controller: _quantiteController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantité',
                      hintText: 'Entrez la quantité',
                      prefixIcon: Icon(
                        Icons.inventory_2,
                        color: Color(0xFFC9A227),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFFC9A227),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Bouton valider
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedVarianteId != null
                          ? () async {
                              // Implémenter la logique de vente
                              final clientTelephone = _telephoneController.text
                                  .trim();
                              final quantite =
                                  int.tryParse(_quantiteController.text) ?? 0;

                              if (quantite <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Quantité invalide'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // Trouver la variante sélectionnée
                              final variante =
                                  (chaussure['variantes'] as List<dynamic>?)
                                      ?.firstWhere(
                                        (v) =>
                                            v['id'].toString() ==
                                            _selectedVarianteId,
                                      );

                              if (variante == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Variante non trouvée'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final stockDisponible = variante['stock'] ?? 0;
                              if (quantite > stockDisponible) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Stock insuffisant. Disponible: $stockDisponible',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final prixUnitaire =
                                  double.tryParse(
                                    (chaussure['prix'] ??
                                            chaussure['prix_vente'] ??
                                            '0')
                                        .toString(),
                                  ) ??
                                  0.0;
                              final sousTotal = prixUnitaire * quantite;
                              final remise = 0.0;
                              final total = sousTotal - remise;
                              final montantPaye = total;
                              final reste = 0.0;

                              try {
                                print(
                                  'Données de vente: client=$clientTelephone, variante=$_selectedVarianteId, quantite=$quantite, prix=$prixUnitaire, total=$total',
                                );

                                final result =
                                    await ApiService.enregistrerVente({
                                      'client_telephone':
                                          clientTelephone.isEmpty
                                          ? null
                                          : clientTelephone,
                                      'variante_id': _selectedVarianteId,
                                      'quantite': quantite,
                                      'prix_unitaire': prixUnitaire,
                                      'sous_total': sousTotal,
                                      'remise': remise,
                                      'total': total,
                                      'montant_paye': montantPaye,
                                      'reste': reste,
                                    });

                                print('Résultat de la vente: $result');

                                Navigator.pop(context);
                                _loadChaussures(); // Recharger les chaussures pour mettre à jour le stock
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Vente enregistrée avec succès: ${result['numero_vente'] ?? ''}',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                print('Erreur lors de la vente: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC9A227),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Valider la vente',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
