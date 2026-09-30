import 'package:flutter/material.dart';
import 'package:frontend_api/services/service_app.dart';

class VentesPage extends StatefulWidget {
  const VentesPage({super.key});

  @override
  State<VentesPage> createState() => _VentesPage();
}

class _VentesPage extends State<VentesPage> {
  bool _isLoading = false;
  List<dynamic> _ventes = [];
  List<dynamic> _filteredVentes = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVentes();
    _searchController.addListener(_filterVentes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVentes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ventes = await ApiService.getVentes();
      setState(() {
        _ventes = ventes;
        _filteredVentes = ventes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(
        'Erreur lors du chargement des ventes: ${e.toString()}',
      );
    }
  }

  void _filterVentes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVentes = _ventes.where((vente) {
        final numero = vente['numero_vente']?.toString().toLowerCase() ?? '';
        final client =
            vente['client']?['telephone']?.toString().toLowerCase() ?? '';
        return numero.contains(query) || client.contains(query);
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
              'Ventes',
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
                hintText: 'Rechercher des ventes...',
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

          // Stats Cards
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total ventes',
                    '${_ventes.length}',
                    Icons.receipt_long,
                    Color(0xFFC9A227),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Aujourd\'hui',
                    '${_getVentesToday()}',
                    Icons.today,
                    Color(0xFF8F6B12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Liste des ventes
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Color(0xFFC9A227)),
                  )
                : _filteredVentes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'Aucune vente trouvée'
                              : 'Aucune vente disponible',
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
                    itemCount: _filteredVentes.length,
                    itemBuilder: (context, index) {
                      final vente = _filteredVentes[index];
                      return _buildVenteCard(vente);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  int _getVentesToday() {
    final today = DateTime.now();
    return _ventes.where((vente) {
      final date = DateTime.tryParse(vente['created_at'] ?? '');
      if (date == null) return false;
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).length;
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenteCard(Map<String, dynamic> vente) {
    final client = vente['client'] ?? {};
    final devise = vente['devise'] ?? {};
    final total = vente['total'] ?? 0;
    final statut = vente['statut'] ?? 'payee';
    final numero = vente['numero_vente'] ?? 'N/A';
    final date = vente['created_at'] ?? '';

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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFC9A227), Color(0xFF8F6B12)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.receipt, color: Colors.white, size: 28),
          ),
          title: Text(
            numero,
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
                client['telephone'] ?? 'Client anonyme',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 4),
              Text(
                _formatDate(date),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$total ${devise['symbole'] ?? '\$'}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC9A227),
                ),
              ),
              SizedBox(height: 4),
              _buildStatusBadge(statut),
            ],
          ),
          children: [
            Divider(color: Colors.grey[200]),
            _buildVenteDetails(vente),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String statut) {
    Color color;
    String label;

    switch (statut) {
      case 'payee':
        color = Colors.green;
        label = 'Payée';
        break;
      case 'partiel':
        color = Colors.orange;
        label = 'Partielle';
        break;
      default:
        color = Colors.red;
        label = 'Annulée';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildVenteDetails(Map<String, dynamic> vente) {
    final details = vente['details'] as List<dynamic>? ?? [];
    final reste = vente['reste'] ?? 0;
    final montantPaye = vente['montant_paye'] ?? 0;
    final devise = vente['devise'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Montants
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMontantItem('Total', vente['total'] ?? 0, true),
            _buildMontantItem('Payé', montantPaye, false),
            _buildMontantItem('Reste', reste, false),
          ],
        ),
        SizedBox(height: 16),

        // Détails produits
        Text(
          'Articles vendus',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        if (details.isEmpty)
          Text(
            'Aucun détail disponible',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          )
        else
          ...details.map((detail) {
            final variante = detail['variante'] ?? {};
            final chaussure = variante['chaussure'] ?? {};
            final pointure = variante['pointure'] ?? {};
            final couleur = variante['couleur'] ?? {};

            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFFC9A227).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shopping_bag,
                      color: Color(0xFFC9A227),
                      size: 20,
                    ),
                  ),
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
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${pointure['taille'] ?? '?'} - ${couleur['nom'] ?? '?'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'x${detail['quantite'] ?? 0}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC9A227),
                        ),
                      ),
                      Text(
                        '${detail['total'] ?? 0} ${devise['symbole'] ?? '\$'}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMontantItem(String label, dynamic value, bool isTotal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Color(0xFFC9A227) : Colors.black87,
          ),
        ),
      ],
    );
  }
}
