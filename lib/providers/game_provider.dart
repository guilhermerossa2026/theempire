import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../models/business.dart';
import '../models/property.dart';
import '../models/asset.dart';
import '../models/rival.dart';
import '../utils/formatters.dart';

/// [GameProvider] — Cérebro da economia do Empire Tycoon.
/// Toda lógica de jogo passa por aqui. UI apenas lê e notifica.
class GameProvider extends ChangeNotifier {
  // ─── Estado Financeiro ───────────────────────────────────────────────
  double _balance = 1000.0;
  double _debt = 0.0;
  double _totalTaxesPaid = 0.0;
  double _monthlyGrossProfit = 0.0;
  int _taxCountdown = 60;

  // ─── Upgrades Fiscais ────────────────────────────────────────────────
  bool hasJuniorAccountant = false;
  bool hasLawFirm = false;
  bool hasIntlConsulting = false;

  // ─── Portfólio de Ativos ─────────────────────────────────────────────
  final Map<String, int> portfolio = {};

  // ─── Timer do Jogo ───────────────────────────────────────────────────
  Timer? _gameTimer;
  final Random _random = Random();

  // ─── Contexto para Snackbars ─────────────────────────────────────────
  BuildContext? _context;

  // ─── GETTERS PÚBLICOS ────────────────────────────────────────────────
  double get balance => _balance;
  double get debt => _debt;
  double get totalTaxesPaid => _totalTaxesPaid;
  double get monthlyGrossProfit => _monthlyGrossProfit;
  int get taxCountdown => _taxCountdown;

  double get totalIncomePerSecond {
    final bizIncome = businesses.fold(0.0, (s, b) => s + b.currentProfit);
    final propIncome = properties.fold(0.0, (s, p) => s + p.totalIncome);
    return bizIncome + propIncome;
  }

  // ─── DADOS DO JOGO ───────────────────────────────────────────────────
  final List<Business> businesses = [
    Business(
      name: 'Quiosque de Café',
      icon: '☕',
      initialCost: 50,
      baseProfit: 2,
      riskProbability: 0.01,
    ),
    Business(
      name: 'Loja de Roupas',
      icon: '👕',
      initialCost: 500,
      baseProfit: 15,
      riskProbability: 0.02,
    ),
    Business(
      name: 'Restaurante Gourmet',
      icon: '🍽️',
      initialCost: 5000,
      baseProfit: 100,
      riskProbability: 0.025,
    ),
    Business(
      name: 'Fábrica Tech',
      icon: '💻',
      initialCost: 50000,
      baseProfit: 800,
      riskProbability: 0.04,
    ),
    Business(
      name: 'Banco Privado',
      icon: '🏦',
      initialCost: 500000,
      baseProfit: 5000,
      riskProbability: 0.05,
    ),
    Business(
      name: 'Empresa de Energia',
      icon: '⚡',
      initialCost: 2000000,
      baseProfit: 18000,
      riskProbability: 0.06,
    ),
  ];

  final List<Property> properties = [
    Property(
      name: 'Casa de Luxo',
      icon: '🏡',
      cost: 100000,
      rentIncome: 1200,
    ),
    Property(
      name: 'Sala Comercial',
      icon: '🏢',
      cost: 500000,
      rentIncome: 7500,
    ),
    Property(
      name: 'Prédio Residencial',
      icon: '🌇',
      cost: 5000000,
      rentIncome: 85000,
    ),
    Property(
      name: 'Campo de Futebol',
      icon: '⚽',
      cost: 2000000000,
      rentIncome: 65000000,
    ),
  ];

  final List<Asset> marketAssets = [
    Asset(
        name: 'Bitcoin',
        symbol: 'BTC',
        currentPrice: 65000.0,
        volatility: 0.35,
        isCrypto: true),
    Asset(
        name: 'Ethereum',
        symbol: 'ETH',
        currentPrice: 3500.0,
        volatility: 0.40,
        isCrypto: true),
    Asset(
        name: 'Solana',
        symbol: 'SOL',
        currentPrice: 150.0,
        volatility: 0.55,
        isCrypto: true),
    Asset(
        name: 'EmpireCoin',
        symbol: 'EMP',
        currentPrice: 1.0,
        volatility: 0.60,
        isCrypto: true),
    Asset(
        name: 'Dogecoin',
        symbol: 'DOGE',
        currentPrice: 0.15,
        volatility: 0.80,
        isCrypto: true),
    Asset(
        name: 'Sky Airways',
        symbol: 'SKY',
        currentPrice: 240.0,
        volatility: 0.12),
    Asset(
        name: 'Ouro Puro',
        symbol: 'GOLD',
        currentPrice: 2300.0,
        volatility: 0.05),
  ];

  final List<Rival> rivals = [
    Rival(
        name: 'Elon Tusk',
        avatar: '🚀',
        netWorth: 250000000000,
        growthRate: 8000),
    Rival(
        name: 'Bernard A.',
        avatar: '💼',
        netWorth: 210000000000,
        growthRate: 6000),
    Rival(
        name: 'Jeff Bezos',
        avatar: '📦',
        netWorth: 190000000000,
        growthRate: 7000),
    Rival(
        name: 'Mark Zucc',
        avatar: '👓',
        netWorth: 170000000000,
        growthRate: 6500),
    Rival(
        name: 'Warren Buffet',
        avatar: '📈',
        netWorth: 135000000000,
        growthRate: 4000),
    Rival(
        name: 'Bill G.',
        avatar: '🪟',
        netWorth: 125000000000,
        growthRate: 5500),
  ];

  // ─── INICIALIZAÇÃO ───────────────────────────────────────────────────

  void setContext(BuildContext context) {
    _context = context;
  }

  void startGame() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), _gameTick);
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  // ─── LOOP PRINCIPAL DO JOGO ──────────────────────────────────────────

  void _gameTick(Timer timer) {
    double incomeThisSecond = 0;

    // 1. Renda de Negócios
    for (final biz in businesses) {
      if (biz.level > 0) {
        // Chance de quebrar
        if (!biz.isBroken &&
            _random.nextDouble() < biz.riskProbability &&
            !biz.hasManager) {
          biz.isBroken = true;
        }
        incomeThisSecond += biz.currentProfit;
      }
    }

    // 2. Renda de Imóveis
    for (final prop in properties) {
      incomeThisSecond += prop.totalIncome;
    }

    // 3. Juros da Dívida (1% ao segundo)
    if (_debt > 0) _debt *= 1.01;

    // 4. Ciclo Fiscal
    _taxCountdown--;
    _monthlyGrossProfit += incomeThisSecond;

    if (_taxCountdown <= 0) {
      _processTaxes();
      _taxCountdown = 60;
      _monthlyGrossProfit = 0;
    }

    // 5. Mercado e Rivais (a cada 5s)
    if (timer.tick % 5 == 0) {
      _updateMarket();
      _updateRivals();
    }

    // 6. Eventos Aleatórios (a cada 30s)
    final double eventChance = hasLawFirm ? 0.06 : 0.12;
    if (timer.tick % 30 == 0 && _random.nextDouble() < eventChance) {
      _triggerRandomEvent();
    }

    // 7. Aplicar saldo
    if (_debt > 0) {
      if (_balance >= _debt) {
        _balance -= _debt;
        _debt = 0;
      } else {
        _debt -= _balance;
        _balance = 0;
      }
    }
    _balance += incomeThisSecond;

    notifyListeners();
  }

  // ─── SISTEMA FISCAL ──────────────────────────────────────────────────

  void _processTaxes() {
    double incomeTax = _monthlyGrossProfit * 0.10;
    double wealthTax = (_balance > 500000) ? _balance * 0.002 : 0;
    double totalTax = incomeTax + wealthTax;

    double reduction = 0.0;
    if (hasJuniorAccountant) reduction += 0.10;
    if (hasIntlConsulting) reduction += 0.30;
    totalTax *= (1 - reduction);

    if (_balance >= totalTax) {
      _balance -= totalTax;
      _totalTaxesPaid += totalTax;
      _showNotify(
        'IMPOSTOS PAGOS',
        'Total de ${formatMoney(totalTax)} recolhido.',
      );
    } else {
      _debt += (totalTax - _balance);
      _balance = 0;
      _showNotify(
        'DÍVIDA ATIVA!',
        'Saldo insuficiente! Você entrou em dívida fiscal.',
        isError: true,
      );
    }
  }

  void _triggerRandomEvent() {
    final double loss = _balance * 0.05;
    _balance -= loss;
    _showNotify(
      'EVENTO FISCAL',
      'Multa inesperada de ${formatMoney(loss)}',
      isError: true,
    );
  }

  // ─── MERCADO ─────────────────────────────────────────────────────────

  void _updateMarket() {
    for (final asset in marketAssets) {
      asset.history.add(asset.currentPrice);
      if (asset.history.length > 20) asset.history.removeAt(0);

      final double change =
          (_random.nextDouble() * asset.volatility * 2) - asset.volatility;
      asset.currentPrice *= (1 + change);
      if (asset.currentPrice < 0.01) asset.currentPrice = 0.01;
    }
  }

  void _updateRivals() {
    for (final rival in rivals) {
      rival.netWorth += rival.growthRate * (5 + _random.nextDouble() * 20);
    }
  }

  // ─── AÇÕES DO JOGADOR ────────────────────────────────────────────────

  /// Clique para ganhar $1
  void clickToEarn() {
    _balance += 1.0;
    notifyListeners();
  }

  /// Fazer upgrade de um negócio
  bool upgradeBusiness(Business biz) {
    if (_balance < biz.upgradeCost) return false;
    _balance -= biz.upgradeCost;
    biz.upgrade();
    notifyListeners();
    return true;
  }

  /// Contratar gerente para um negócio
  bool hireManager(Business biz) {
    if (_balance < biz.managerCost) return false;
    _balance -= biz.managerCost;
    biz.hireManager();
    notifyListeners();
    return true;
  }

  /// Reparar negócio quebrado
  bool repairBusiness(Business biz) {
    final double repairCost = biz.upgradeCost * 0.5;
    if (_balance < repairCost) return false;
    _balance -= repairCost;
    biz.repair();
    notifyListeners();
    return true;
  }

  /// Comprar imóvel
  bool buyProperty(Property prop) {
    if (_balance < prop.cost) return false;
    _balance -= prop.cost;
    prop.quantity++;
    notifyListeners();
    return true;
  }

  /// Comprar ativo
  bool buyAsset(Asset asset) {
    if (_balance < asset.currentPrice) return false;
    _balance -= asset.currentPrice;
    portfolio[asset.symbol] = (portfolio[asset.symbol] ?? 0) + 1;
    notifyListeners();
    return true;
  }

  /// Vender ativo
  bool sellAsset(Asset asset) {
    final int owned = portfolio[asset.symbol] ?? 0;
    if (owned <= 0) return false;
    _balance += asset.currentPrice;
    portfolio[asset.symbol] = owned - 1;
    notifyListeners();
    return true;
  }

  /// Comprar upgrade fiscal
  bool buyFiscalUpgrade(String upgradeId, double cost) {
    if (_balance < cost) return false;
    _balance -= cost;

    switch (upgradeId) {
      case 'junior_accountant':
        hasJuniorAccountant = true;
        break;
      case 'law_firm':
        hasLawFirm = true;
        break;
      case 'intl_consulting':
        hasIntlConsulting = true;
        break;
    }

    notifyListeners();
    return true;
  }

  // ─── RANKING ─────────────────────────────────────────────────────────

  /// Retorna lista ordenada de rivais + jogador
  List<Map<String, dynamic>> getRanking() {
    final List<Map<String, dynamic>> all = rivals.map((r) {
      return <String, dynamic>{
        'name': r.name,
        'avatar': r.avatar,
        'netWorth': r.netWorth,
        'isMe': false,
      };
    }).toList();

    all.add(<String, dynamic>{
      'name': 'Você',
      'avatar': '👑',
      'netWorth': _balance,
      'isMe': true,
    });

    all.sort((a, b) =>
        (b['netWorth'] as double).compareTo(a['netWorth'] as double));

    return all;
  }

  // ─── NOTIFICAÇÕES ────────────────────────────────────────────────────

  void _showNotify(String title, String message, {bool isError = false}) {
    if (_context == null) return;

    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isError ? const Color(0xFFB71C1C) : const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.warning_amber_rounded : Icons.check_circle,
                color: isError ? Colors.amber : Colors.greenAccent,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
