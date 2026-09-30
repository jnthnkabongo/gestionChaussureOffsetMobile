import 'package:flutter/material.dart';
import 'package:frontend_api/services/service_app.dart';

class DepensesPage extends StatefulWidget {
  const DepensesPage({super.key});

  @override
  State<DepensesPage> createState() => _DepensesPage();
}

class _DepensesPage extends State<DepensesPage> {
  bool _isLoading = false;
  List<dynamic> _depenses = [];
  List<dynamic> _filteredDepenses = [];
  List<dynamic> _devises = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDepenses();
    _loadDevises();
    _searchController.addListener(_filterDepenses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDepenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final depenses = await ApiService.getDepenses();
      setState(() {
        _depenses = depenses;
        _filteredDepenses = depenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(
        'Erreur lors du chargement des dépenses: ${e.toString()}',
      );
    }
  }

  Future<void> _loadDevises() async {
    try {
      final devises = await ApiService.getDevises();
      setState(() {
        _devises = devises;
      });
    } catch (e) {
      _showErrorSnackBar(
        'Erreur lors du chargement des devises: ${e.toString()}',
      );
    }
  }

  void _filterDepenses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDepenses = _depenses.where((depense) {
        final description =
            depense['description']?.toString().toLowerCase() ?? '';
        final categorie = depense['categorie']?.toString().toLowerCase() ?? '';
        return description.contains(query) || categorie.contains(query);
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
              'Dépenses',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDepenseBottomSheet(),
        backgroundColor: Color(0xFFC9A227),
        elevation: 4,
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher des dépenses...',
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
          SizedBox(height: 16),

          // Stats Cards
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total dépenses',
                    _getTotalDepenses(),
                    Icons.account_balance_wallet,
                    Color(0xFFC9A227),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Ce mois',
                    _getDepensesThisMonth(),
                    Icons.calendar_today,
                    Color(0xFF8F6B12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Liste des dépenses
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Color(0xFFC9A227)),
                  )
                : _filteredDepenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'Aucune dépense trouvée'
                              : 'Aucune dépense disponible',
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
                    itemCount: _filteredDepenses.length,
                    itemBuilder: (context, index) {
                      final depense = _filteredDepenses[index];
                      return _buildDepenseCard(depense);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getTotalDepenses() {
    double total = 0;
    for (var depense in _depenses) {
      final montant = depense['montant'] ?? 0;
      if (montant is String) {
        total += double.tryParse(montant) ?? 0;
      } else if (montant is num) {
        total += montant.toDouble();
      }
    }
    return total.toStringAsFixed(2);
  }

  String _getDepensesThisMonth() {
    final now = DateTime.now();
    double total = 0;
    for (var depense in _depenses) {
      final date = DateTime.tryParse(depense['date_depense'] ?? '');
      if (date != null && date.year == now.year && date.month == now.month) {
        final montant = depense['montant'] ?? 0;
        if (montant is String) {
          total += double.tryParse(montant) ?? 0;
        } else if (montant is num) {
          total += montant.toDouble();
        }
      }
    }
    return total.toStringAsFixed(2);
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

  Widget _buildDepenseCard(Map<String, dynamic> depense) {
    final montant = depense['montant'] ?? 0;
    final devise = depense['devise'] ?? {};
    final statut = depense['statut'] ?? 'payee';
    final description = depense['description'] ?? 'Sans description';
    final categorie = depense['categorie'] ?? 'Général';
    final date = depense['date_depense'] ?? '';

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
            child: Icon(Icons.receipt_long, color: Colors.white, size: 28),
          ),
          title: Text(
            description,
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
                categorie,
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
                '$montant ${devise['symbole'] ?? '\$'}',
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
            _buildDepenseDetails(depense),
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
      case 'en_attente':
        color = Colors.orange;
        label = 'En attente';
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
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildDepenseDetails(Map<String, dynamic> depense) {
    final user = depense['user'] ?? {};
    final notes = depense['notes'] ?? '';
    final devise = depense['devise'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Informations
        Row(
          children: [
            Icon(Icons.person, size: 16, color: Colors.grey[600]),
            SizedBox(width: 4),
            Text(
              user['name'] ?? 'Utilisateur inconnu',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        SizedBox(height: 8),

        if (notes.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.note, size: 16, color: Colors.grey[600]),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  notes,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
        ],

        // Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(Icons.edit, 'Modifier', Color(0xFFC9A227), () {
              _showEditDepenseBottomSheet(depense);
            }),
            _buildActionButton(Icons.delete, 'Supprimer', Colors.red, () {
              _showDeleteDepenseBottomSheet(depense);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDepenseBottomSheet() {
    final deviseController = TextEditingController();
    final descriptionController = TextEditingController();
    final montantController = TextEditingController();
    final categorieController = TextEditingController();
    final dateController = TextEditingController();
    final statutController = TextEditingController(text: 'payee');
    final factureController = TextEditingController();
    final commentaireController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
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
                          'Nouvelle dépense',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Devise dropdown
                    Text(
                      'Devise',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: deviseController.text.isEmpty
                          ? null
                          : deviseController.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: _devises.map((devise) {
                        return DropdownMenuItem<String>(
                          value: devise['id'].toString(),
                          child: Text('${devise['code']} - ${devise['nom']}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          deviseController.text = value ?? '';
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // Description
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Description de la dépense',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Catégorie
                    Text(
                      'Catégorie',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: categorieController.text.isEmpty
                          ? null
                          : categorieController.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(value: 'loyer', child: Text('Loyer')),
                        DropdownMenuItem(
                          value: 'salaires',
                          child: Text('Salaires'),
                        ),
                        DropdownMenuItem(
                          value: 'achat_stock',
                          child: Text('Achat de stock'),
                        ),
                        DropdownMenuItem(
                          value: 'transport',
                          child: Text('Transport'),
                        ),
                        DropdownMenuItem(
                          value: 'publicite',
                          child: Text('Publicité'),
                        ),
                        DropdownMenuItem(
                          value: 'factures_electricite',
                          child: Text('Factures d\'électricité'),
                        ),
                        DropdownMenuItem(
                          value: 'factures_eau',
                          child: Text('Factures d\'eau'),
                        ),
                        DropdownMenuItem(
                          value: 'frais_generaux',
                          child: Text('Frais généraux'),
                        ),
                        DropdownMenuItem(value: 'autre', child: Text('Autre')),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          categorieController.text = value ?? '';
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // Montant
                    Text(
                      'Montant',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: montantController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: '1000.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Date
                    Text(
                      'Date de la dépense',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setModalState(() {
                            dateController.text = picked
                                .toIso8601String()
                                .split('T')[0];
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Sélectionner une date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Statut
                    Text(
                      'Statut',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: statutController.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(value: 'payee', child: Text('Payée')),
                        DropdownMenuItem(
                          value: 'en_attente',
                          child: Text('En attente'),
                        ),
                        DropdownMenuItem(
                          value: 'annulee',
                          child: Text('Annulée'),
                        ),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          statutController.text = value ?? 'payee';
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // Référence facture (optionnel)
                    Text(
                      'Référence facture (optionnel)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: factureController,
                      decoration: InputDecoration(
                        hintText: 'Référence de la facture',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Commentaire (optionnel)
                    Text(
                      'Commentaire (optionnel)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: commentaireController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Commentaires additionnels',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (deviseController.text.isEmpty ||
                              descriptionController.text.isEmpty ||
                              categorieController.text.isEmpty ||
                              montantController.text.isEmpty ||
                              dateController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Veuillez remplir tous les champs obligatoires',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          try {
                            await ApiService.createDepense({
                              'devise_id': deviseController.text,
                              'description': descriptionController.text,
                              'categorie_depense': categorieController.text,
                              'montant': double.parse(montantController.text),
                              'date_depense': dateController.text,
                              'statut': statutController.text,
                              'facture_reference': factureController.text,
                              'commentaire': commentaireController.text,
                            });

                            Navigator.pop(context);
                            _loadDepenses();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Dépense créée avec succès'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFC9A227),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Enregistrer',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showEditDepenseBottomSheet(Map<String, dynamic> depense) {
    final deviseController = TextEditingController(
      text: depense['devise_id']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: depense['description'] ?? '',
    );
    final montantController = TextEditingController(
      text: depense['montant']?.toString() ?? '',
    );
    final categorieController = TextEditingController(
      text: depense['categorie_depense'] ?? '',
    );
    final dateController = TextEditingController(
      text: depense['date_depense']?.toString().split('T')[0] ?? '',
    );
    final statutController = TextEditingController(
      text: depense['statut'] ?? 'payee',
    );
    final factureController = TextEditingController(
      text: depense['facture_reference'] ?? '',
    );
    final commentaireController = TextEditingController(
      text: depense['commentaire'] ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
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
                          'Modifier la dépense',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Devise dropdown
                    Text(
                      'Devise',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: deviseController.text.isEmpty
                          ? null
                          : deviseController.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: _devises.map((devise) {
                        return DropdownMenuItem<String>(
                          value: devise['id'].toString(),
                          child: Text('${devise['code']} - ${devise['nom']}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          deviseController.text = value ?? '';
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // Description
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Description de la dépense',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Catégorie
                    Text(
                      'Catégorie',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: categorieController.text.isEmpty
                          ? null
                          : categorieController.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(value: 'loyer', child: Text('Loyer')),
                        DropdownMenuItem(
                          value: 'salaires',
                          child: Text('Salaires'),
                        ),
                        DropdownMenuItem(
                          value: 'achat_stock',
                          child: Text('Achat de stock'),
                        ),
                        DropdownMenuItem(
                          value: 'transport',
                          child: Text('Transport'),
                        ),
                        DropdownMenuItem(
                          value: 'publicite',
                          child: Text('Publicité'),
                        ),
                        DropdownMenuItem(
                          value: 'factures_electricite',
                          child: Text('Factures d\'électricité'),
                        ),
                        DropdownMenuItem(
                          value: 'factures_eau',
                          child: Text('Factures d\'eau'),
                        ),
                        DropdownMenuItem(
                          value: 'frais_generaux',
                          child: Text('Frais généraux'),
                        ),
                        DropdownMenuItem(value: 'autre', child: Text('Autre')),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          categorieController.text = value ?? '';
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // Montant
                    Text(
                      'Montant',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: montantController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: '1000.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Date
                    Text(
                      'Date de la dépense',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setModalState(() {
                            dateController.text = picked
                                .toIso8601String()
                                .split('T')[0];
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Sélectionner une date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Statut
                    Text(
                      'Statut',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: statutController.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(value: 'payee', child: Text('Payée')),
                        DropdownMenuItem(
                          value: 'en_attente',
                          child: Text('En attente'),
                        ),
                        DropdownMenuItem(
                          value: 'annulee',
                          child: Text('Annulée'),
                        ),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          statutController.text = value ?? 'payee';
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // Référence facture (optionnel)
                    Text(
                      'Référence facture (optionnel)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: factureController,
                      decoration: InputDecoration(
                        hintText: 'Référence de la facture',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Commentaire (optionnel)
                    Text(
                      'Commentaire (optionnel)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: commentaireController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Commentaires additionnels',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (deviseController.text.isEmpty ||
                              descriptionController.text.isEmpty ||
                              categorieController.text.isEmpty ||
                              montantController.text.isEmpty ||
                              dateController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Veuillez remplir tous les champs obligatoires',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          try {
                            await ApiService.updateDepense(
                              depense['id'].toString(),
                              {
                                'devise_id': deviseController.text,
                                'description': descriptionController.text,
                                'categorie_depense': categorieController.text,
                                'montant': double.parse(montantController.text),
                                'date_depense': dateController.text,
                                'statut': statutController.text,
                                'facture_reference': factureController.text,
                                'commentaire': commentaireController.text,
                              },
                            );

                            Navigator.pop(context);
                            _loadDepenses();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Dépense modifiée avec succès'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFC9A227),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Enregistrer les modifications',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteDepenseBottomSheet(Map<String, dynamic> depense) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete, color: Colors.red, size: 32),
            ),
            SizedBox(height: 16),

            // Title
            Text(
              'Supprimer la dépense',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),

            // Description
            Text(
              'Êtes-vous sûr de vouloir supprimer "${depense['description'] ?? 'cette dépense'}" ?',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),

            Text(
              'Cette action est irréversible.',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await ApiService.deleteDepense(
                          depense['id'].toString(),
                        );
                        Navigator.pop(context);
                        _loadDepenses();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Dépense supprimée avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Supprimer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
