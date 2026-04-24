import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  runApp(const EmpireTycoonApp());
}

class EmpireTycoonApp extends StatelessWidget {
  const EmpireTycoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Empire Tycoon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF1F4F8),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// --- MODELS ---

class Business {
  final String name;
  final String icon;
  int level;
  double initialCost;
  double baseProfit;
  double riskProbability;
  bool isBroken;
  bool isUnderCrise;
  bool hasManager;

  Business({
    required this.name,
    required this.icon,
    this.level = 0,
    required this.initialCost,
    required this.baseProfit,
    required this.riskProbability,
    this.isBroken = false,
    this.isUnderCrise = false,
    this.hasManager = false,
  });

  double get upgradeCost => initialCost * pow(1.5, level);
  double get managerCost => initialCost * 25;
  double get currentProfit => (isUnderCrise || (isBroken && !hasManager)) ? 0 : (level > 0 ? baseProfit * level * 1.2 : 0);

  void upgrade() => level++;
  void repair() => isBroken = false;
  void hireManager() => hasManager = true;
}

class Property {
  final String name;
  final String icon;
  final double cost;
  final double rentIncome;
  int quantity;

  Property({required this.name, required this.icon, required this.cost, required this.rentIncome, this.quantity = 0});
}

class Asset {
  final String name;
  final String symbol;
  double currentPrice;
  final double volatility;
  List<double> history;
  final bool isCrypto;

  Asset({required this.name, required this.symbol, required this.currentPrice, required this.volatility, this.isCrypto = false}) : history = [];

  double get changePercentage => history.isNotEmpty ? ((currentPrice - history.last) / history.last) * 100 : 0;
}

class Rival {
  final String name;
  final String avatar;
  double netWorth;
  double growthRate;
  Rival({required this.name, required this.avatar, required this.netWorth, required this.growthRate});
}

// --- UTILS ---

String formatMoney(double value) {
  bool isNegative = value < 0;
  double absValue = value.abs();
  String formatted = "";
  if (absValue < 1000) {
    formatted = absValue.toStringAsFixed(2);
  } else if (absValue < 1000000) {
    formatted = '${(absValue / 1000).toStringAsFixed(2)}K';
  } else if (absValue < 1000000000) {
    formatted = '${(absValue / 1000000).toStringAsFixed(2)}M';
  } else if (absValue < 1000000000000) {
    formatted = '${(absValue / 1000000000).toStringAsFixed(2)}B';
  } else {
    formatted = '${(absValue / 1000000000000).toStringAsFixed(2)}T';
  }
  return isNegative ? "-\$ $formatted" : "\$ $formatted";
}

// --- NAVIGATION SCREEN ---

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  double balance = 1000.0;
  double debt = 0.0; // Dívida Ativa
  Timer? _gameTimer;
  final Random _random = Random();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // TAX SYSTEM STATE
  int taxCountdown = 60;
  double monthlyGrossProfit = 0.0;
  double totalTaxesPaid = 0.0;
  bool hasJuniorAccountant = false;
  bool hasLawFirm = false;
  bool hasIntlConsulting = false;

  final List<Business> businesses = [
    Business(name: 'Quiosque de Café', icon: '☕', initialCost: 50, baseProfit: 2, riskProbability: 0.01),
    Business(name: 'Loja de Roupas', icon: '👕', initialCost: 500, baseProfit: 15, riskProbability: 0.02),
    Business(name: 'Fábrica Tech', icon: '💻', initialCost: 50000, baseProfit: 800, riskProbability: 0.04),
    Business(name: 'Banco Privado', icon: '🏦', initialCost: 500000, baseProfit: 5000, riskProbability: 0.05),
  ];

  final List<Property> properties = [
    Property(name: 'Casa de Luxo', icon: '🏡', cost: 100000, rentIncome: 1200),
    Property(name: 'Sala Comercial', icon: '🏢', cost: 500000, rentIncome: 7500),
    Property(name: 'Prédio Residencial', icon: '🌇', cost: 5000000, rentIncome: 85000),
    Property(name: 'Campo de Futebol', icon: '⚽', cost: 2000000000, rentIncome: 65000000),
  ];

  final List<Asset> marketAssets = [
    Asset(name: 'Bitcoin', symbol: 'BTC', currentPrice: 65000.0, volatility: 0.35, isCrypto: true),
    Asset(name: 'Ethereum', symbol: 'ETH', currentPrice: 3500.0, volatility: 0.40, isCrypto: true),
    Asset(name: 'Solana', symbol: 'SOL', currentPrice: 150.0, volatility: 0.55, isCrypto: true),
    Asset(name: 'EmpireCoin', symbol: 'EMP', currentPrice: 1.0, volatility: 0.60, isCrypto: true),
    Asset(name: 'Dogecoin', symbol: 'DOGE', currentPrice: 0.15, volatility: 0.80, isCrypto: true),
    Asset(name: 'Sky Airways', symbol: 'SKY', currentPrice: 240.0, volatility: 0.12),
    Asset(name: 'Ouro Puro', symbol: 'GOLD', currentPrice: 2300.0, volatility: 0.05),
  ];

  final List<Rival> rivals = [
    Rival(name: "Elon Tusk", avatar: "🚀", netWorth: 250000000000, growthRate: 8000),
    Rival(name: "Bernard A.", avatar: "💼", netWorth: 210000000000, growthRate: 6000),
    Rival(name: "Jeff Bezos", avatar: "📦", netWorth: 190000000000, growthRate: 7000),
    Rival(name: "Mark Zucc", avatar: "👓", netWorth: 170000000000, growthRate: 6500),
    Rival(name: "Warren Buffet", avatar: "📈", netWorth: 135000000000, growthRate: 4000),
    Rival(name: "Bill G.", avatar: "🪟", netWorth: 125000000000, growthRate: 5500),
  ];

  Map<String, int> portfolio = {};

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startGameLoop();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _clickToEarn() {
    setState(() {
      balance += 1.0; // Ganha $1 por clique
    });
  }

  void _startGameLoop() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      double incomeThisSecond = 0;

      // 1. Business & Property Income
      for (var biz in businesses) {
        if (biz.level > 0) {
          if (!biz.isBroken && _random.nextDouble() < biz.riskProbability && !biz.hasManager) {
            biz.isBroken = true;
          }
          incomeThisSecond += biz.currentProfit;
        }
      }
      for (var prop in properties) {
        incomeThisSecond += prop.quantity * prop.rentIncome;
      }

      // 2. Debt Interest (1% per second)
      if (debt > 0) {
        debt *= 1.01;
      }

      // 3. Tax Countdown & Processing
      taxCountdown--;
      monthlyGrossProfit += incomeThisSecond;

      if (taxCountdown <= 0) {
        _processTaxes();
        taxCountdown = 60;
        monthlyGrossProfit = 0;
      }

      // 4. Market & Rivals (5s)
      if (timer.tick % 5 == 0) {
        for (var a in marketAssets) {
          a.history.add(a.currentPrice);
          double change = (_random.nextDouble() * a.volatility * 2) - a.volatility;
          a.currentPrice *= (1 + change);
          if (a.currentPrice < 0.01) {
            a.currentPrice = 0.01;
          }
        }
        for (var r in rivals) {
          r.netWorth += r.growthRate * (5 + _random.nextDouble() * 20);
        }
      }

      // 5. Random Events (30s) - Law Firm reduces chance by 50%
      double eventChance = hasLawFirm ? 0.06 : 0.12;
      if (timer.tick % 30 == 0 && _random.nextDouble() < eventChance) {
        _triggerRandomEvent();
      }

      setState(() {
        if (debt > 0) {
          if (balance > 0) {
            if (balance >= debt) {
              balance -= debt;
              debt = 0;
            } else {
              debt -= balance;
              balance = 0;
            }
          }
        }
        balance += incomeThisSecond;
      });
    });
  }

  void _processTaxes() {
    double incomeTax = monthlyGrossProfit * 0.10;
    double wealthTax = (balance > 500000) ? balance * 0.002 : 0;
    double totalTax = incomeTax + wealthTax;

    // Apply reductions
    double reduction = 0.0;
    if (hasJuniorAccountant) {
      reduction += 0.10;
    }
    if (hasIntlConsulting) {
      reduction += 0.30;
    }
    totalTax *= (1 - reduction);

    if (balance >= totalTax) {
      balance -= totalTax;
      totalTaxesPaid += totalTax;
      _showNotify("IMPOSTOS PAGOS", "Total de ${formatMoney(totalTax)} recolhido.");
    } else {
      debt += (totalTax - balance);
      balance = 0;
      _showNotify("DÍVIDA ATIVA!", "Saldo insuficiente! Você entrou em dívida fiscal.", isError: true);
    }
  }

  void _triggerRandomEvent() {
    double loss = balance * 0.05;
    setState(() => balance -= loss);
    _showNotify("EVENTO FISCAL", "Multa inesperada de ${formatMoney(loss)}", isError: true);
  }

  void _showNotify(String t, String m, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isError ? Colors.red[800] : const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(16)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(m, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildDashboard(),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildBusinessList(),
                  _buildMarketList(),
                  _buildPropertyList(),
                  _buildGovernmentTab(),
                  _buildRankingList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF007AFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Negócios'),
          BottomNavigationBarItem(icon: Icon(Icons.currency_bitcoin), label: 'Ativos'),
          BottomNavigationBarItem(icon: Icon(Icons.location_city), label: 'Imóveis'),
          BottomNavigationBarItem(icon: Icon(Icons.gavel), label: 'Governo'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Ranking'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    double income = businesses.fold(0.0, (s, b) => s + b.currentProfit) + properties.fold(0.0, (s, p) => s + p.quantity * p.rentIncome);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0xD9E0E5EC),
              blurRadius: 15,
              offset: Offset(10, 10),
            ),
            BoxShadow(
              color: Colors.white,
              blurRadius: 15,
              offset: Offset(-10, -10),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              "EMPRESÁRIO",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              debt > 0 ? formatMoney(debt) : formatMoney(balance),
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: debt > 0 ? Colors.red[700] : Colors.black,
              ),
            ),
            if (income > 0)
              Container(
                margin: const EdgeInsets.only(top: 15),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  "+ ${formatMoney(income)}/s",
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            if (debt > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "DÍVIDA ATIVA",
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _clickToEarn,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xD9E0E5EC),
                      blurRadius: 15,
                      offset: Offset(10, 10),
                    ),
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 15,
                      offset: Offset(-10, -10),
                    ),
                  ],
                ),
                child: Center(
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF8A2BE2), // BlueViolet
                            Color(0xFF4B0082), // Indigo
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8A2BE2).withValues(alpha: 0.4),
                            blurRadius: 25,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Color(0xFFFFD700),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGovernmentTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildGovStatusCard(),
        const SizedBox(height: 20),
        const Text("CONTABILIDADE & JURÍDICO", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 10),
        _buildUpgradeCard("Contador Júnior", "Reduz impostos em 10%", 5000, hasJuniorAccountant, Icons.account_balance_wallet, () {
          if (balance >= 5000) {
            setState(() {
              balance -= 5000;
              hasJuniorAccountant = true;
            });
          }
        }),
        _buildUpgradeCard("Escritório de Advocacia", "Reduz multas em 50%", 50000, hasLawFirm, Icons.gavel, () {
          if (balance >= 50000) {
            setState(() {
              balance -= 50000;
              hasLawFirm = true;
            });
          }
        }),
        _buildUpgradeCard("Consultoria Internacional", "Reduz impostos em 30%", 500000, hasIntlConsulting, Icons.public, () {
          if (balance >= 500000) {
            setState(() {
              balance -= 500000;
              hasIntlConsulting = true;
            });
          }
        }),
      ],
    );
  }

  Widget _buildGovStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Mês Fiscal", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Próximo Pagamento", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
          Text("${taxCountdown}s", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF007AFF))),
        ]),
        const Divider(height: 32),
        _buildInfoRow("Lucro Bruto (Mês)", formatMoney(monthlyGrossProfit)),
        _buildInfoRow("Total Pago ao Governo", formatMoney(totalTaxesPaid)),
      ]),
    );
  }

  Widget _buildUpgradeCard(String t, String d, double c, bool bought, IconData i, VoidCallback onBuy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(i, color: bought ? Colors.green : Colors.grey, size: 30),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(d, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ])),
        ElevatedButton(
          onPressed: bought ? null : onBuy,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007AFF), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: Text(bought ? "ATIVO" : formatMoney(c)),
        ),
      ]),
    );
  }

  Widget _buildInfoRow(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
    );
  }

  // --- MÉTODOS DE LISTAS REUTILIZADOS ---
  Widget _buildBusinessList() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: businesses.length,
      itemBuilder: (context, i) => _buildBusinessCardNeumorphic(businesses[i]),
    );
  }

  Widget _buildBusinessCardNeumorphic(Business biz) {
    bool canAfford = balance >= biz.upgradeCost;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[400]!,
            blurRadius: 10,
            offset: const Offset(6, 6),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 10,
            offset: Offset(-6, -6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2D1B4D), // Roxo suave/profundo
              ),
              child: const Icon(
                Icons.storefront,
                color: Color(0xFF9D50BB),
                size: 50,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  biz.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Nível ${biz.level}",
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  "+ ${formatMoney(biz.currentProfit)}/s",
                  style: const TextStyle(
                    color: Color(0xFF39FF14), // Verde Neon
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: canAfford
                ? () => setState(() {
                      balance -= biz.upgradeCost;
                      biz.upgrade();
                    })
                : null,
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37), // Dourado
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(-2, -2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  formatMoney(biz.upgradeCost),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketList() => ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: marketAssets.length, itemBuilder: (context, i) {
    final a = marketAssets[i];
    final owned = portfolio[a.symbol] ?? 0;
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(a.symbol, style: const TextStyle(color: Colors.grey, fontSize: 12))]),
      Text("\$ ${a.currentPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w900)),
      Row(children: [
        IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: owned > 0 ? () => setState(() { balance += a.currentPrice; portfolio[a.symbol] = owned - 1; }) : null),
        IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: balance >= a.currentPrice ? () => setState(() { balance -= a.currentPrice; portfolio[a.symbol] = (portfolio[a.symbol] ?? 0) + 1; }) : null),
      ]),
    ]));
  });

  Widget _buildPropertyList() => ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: properties.length, itemBuilder: (context, i) {
    final p = properties[i];
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(children: [
      Text(p.icon, style: const TextStyle(fontSize: 24)), const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)), Text("Renda: ${formatMoney(p.rentIncome)}/s", style: const TextStyle(color: Colors.green, fontSize: 11))])),
      ElevatedButton(onPressed: balance >= p.cost ? () => setState(() { balance -= p.cost; p.quantity++; }) : null, child: Text(formatMoney(p.cost))),
    ]));
  });

  Widget _buildRankingList() {
    List<dynamic> all = [...rivals, {'name': 'Você', 'avatar': '👑', 'netWorth': balance}];
    all.sort((a, b) => (b is Rival ? b.netWorth : b['netWorth']).compareTo(a is Rival ? a.netWorth : a['netWorth']));
    return ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: all.length, itemBuilder: (context, index) {
      final p = all[index]; bool isMe = p is Map;
      return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isMe ? const Color(0xFF007AFF).withValues(alpha: 0.1) : Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(children: [
        Text("${index + 1}º", style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF007AFF))), const SizedBox(width: 16),
        Text(isMe ? p['avatar'] : p.avatar, style: const TextStyle(fontSize: 20)), const SizedBox(width: 12),
        Expanded(child: Text(isMe ? p['name'] : p.name, style: const TextStyle(fontWeight: FontWeight.bold))),
        Text(formatMoney(isMe ? p['netWorth'] : p.netWorth), style: const TextStyle(fontWeight: FontWeight.w900)),
      ]));
    });
  }
}
