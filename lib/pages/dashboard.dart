import 'dart:core';
import 'package:flutter/material.dart';
import 'package:frontend_api/services/service_app.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadDashboard();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final userData = await ApiService.recupererDonneesUser('user');

    setState(() {
      _isLoading = false;
      _userData = userData;
    });
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
    });

    final dashboardData = await ApiService.getDashboard();

    setState(() {
      _isLoading = false;
      _dashboardData = dashboardData;
    });
  }

  String get deviseSymbole {
    if (_dashboardData?['devise_id'] == 1) {
      return '\$';
    } else if (_dashboardData?['devise_id'] == 2) {
      return 'FC';
    }
    return '';
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
              'Kin Store',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFC9A227), Color(0xFFC9A227)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 30,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    right: 50,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.wb_sunny_outlined,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: 40,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Bonjour !',
                                  style: TextStyle(
                                    fontSize: 28,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  'Bienvenue,',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '${_userData?['name'] ?? 'Utilisateur'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  // Text(
                                  //   '+ 5 cette semaine',
                                  //   style: TextStyle(
                                  //     color: Colors.white,
                                  //     fontWeight: FontWeight.w600,
                                  //     fontSize: 10,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.celebration_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                  'Ventes du jour',
                  '${_dashboardData?['ventes_jour'] ?? '0'}',
                  Icons.today,
                  Color(0xFFC9A227),
                  'ventes',
                ),
                _buildStatCard(
                  'Revenu du jour',
                  '${_dashboardData?['revenu_jour'] ?? '0'} $deviseSymbole',
                  Icons.attach_money,
                  Color(0xFFC9A227),
                  'revenu',
                ),
                _buildStatCard(
                  'Stock total',
                  '${_dashboardData?['stock_total'] ?? '0'}',
                  Icons.inventory_2,
                  Color(0xFFC9A227),
                  'articles',
                ),
                _buildStatCard(
                  'Depense',
                  '${_dashboardData?['clients_total'] ?? '0'}',
                  Icons.money_off_csred_sharp,
                  Color(0xFFC9A227),
                  'Depenses',
                ),
              ],
            ),

            SizedBox(height: 32),

            // Sales Table
            Text(
              'Tableau des ventes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Expanded(
                        //   flex: 1,
                        //   child: Text(
                        //     'Client',
                        //     style: TextStyle(
                        //       fontWeight: FontWeight.bold,
                        //       color: Colors.black87,
                        //     ),
                        //   ),
                        // ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Chaussure',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Date',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Prix',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Table Rows
                  ...(_dashboardData?['liste_ventes'] as List<dynamic>? ?? [])
                      .take(5)
                      .map((vente) {
                        final details =
                            vente['details'] as List<dynamic>? ?? [];
                        final devise = vente['devise'] ?? {};
                        final deviseSymbole = devise['symbole'] ?? '\$';

                        // Extraire le nom de la chaussure depuis les détails
                        String chaussureNom = 'Inconnu';
                        if (details.isNotEmpty) {
                          final firstDetail = details[0];
                          final variante = firstDetail['variante'] ?? {};
                          final chaussure = variante['chaussure'] ?? {};
                          chaussureNom = chaussure['nom'] ?? 'Inconnu';
                        }

                        // Utiliser la date formatée du backend ou créer une nouvelle
                        String dateFormatee = vente['date_vente'] ?? '';
                        if (dateFormatee.isEmpty &&
                            vente['created_at'] != null) {
                          try {
                            final date = DateTime.parse(vente['created_at']);
                            dateFormatee =
                                '${date.day}/${date.month}/${date.year}';
                          } catch (e) {
                            dateFormatee = 'Date inconnue';
                          }
                        }

                        return _buildTableRow(
                          chaussureNom,
                          dateFormatee,
                          '${vente['total'] ?? '0'} $deviseSymbole',
                        );
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String unit,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      '+12%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(String product, String quantity, String price) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              product,
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              quantity,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              price,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
