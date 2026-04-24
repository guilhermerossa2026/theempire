import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/asset.dart';
import '../providers/game_provider.dart';

/// Tela de Mercado de Ativos — estilo dark premium
class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assets = context.read<GameProvider>().marketAssets;

    return Container(
      color: const Color(0xFF0D0D1A),
      child: Column(
        children: [
          // Header dark
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MERCADO DE ATIVOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Cripto & Ações em Tempo Real',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8A2BE2).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF8A2BE2).withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFF39FF14), size: 8),
                      SizedBox(width: 5),
                      Text(
                        'AO VIVO',
                        style: TextStyle(
                          color: Color(0xFF39FF14),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de Ativos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: assets.length,
              itemBuilder: (context, i) => _AssetTile(asset: assets[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetTile extends StatelessWidget {
  final Asset asset;

  const _AssetTile({required this.asset});

  // Cor do ativo baseado no símbolo
  Color _getAssetColor() {
    switch (asset.symbol) {
      case 'BTC':
        return const Color(0xFFF7931A);
      case 'ETH':
        return const Color(0xFF627EEA);
      case 'SOL':
        return const Color(0xFF9945FF);
      case 'DOGE':
        return const Color(0xFFC2A633);
      case 'EMP':
        return const Color(0xFF8A2BE2);
      case 'GOLD':
        return const Color(0xFFFFD700);
      default:
        return const Color(0xFF00BFFF);
    }
  }

  String _getAssetIcon() {
    if (asset.isCrypto) return '₿';
    switch (asset.symbol) {
      case 'GOLD':
        return '🥇';
      default:
        return '📈';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GameProvider, (double, int)>(
      selector: (_, g) => (
        g.balance,
        g.portfolio[asset.symbol] ?? 0,
      ),
      builder: (context, data, _) {
        final (balance, owned) = data;
        final game = context.read<GameProvider>();
        final assetColor = _getAssetColor();
        final isPositive = asset.isPositive;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Ícone do ativo
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: assetColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: assetColor.withValues(alpha: 0.4)),
                    ),
                    child: Center(
                      child: Text(
                        _getAssetIcon(),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nome e símbolo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              asset.symbol,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                            if (owned > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8A2BE2)
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'x$owned',
                                  style: const TextStyle(
                                    color: Color(0xFFD4B0FF),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Preço e variação
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$ ${asset.currentPrice >= 1 ? asset.currentPrice.toStringAsFixed(2) : asset.currentPrice.toStringAsFixed(4)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            color: isPositive
                                ? const Color(0xFF39FF14)
                                : Colors.red[400],
                            size: 16,
                          ),
                          Text(
                            '${asset.changePercentage.abs().toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: isPositive
                                  ? const Color(0xFF39FF14)
                                  : Colors.red[400],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Botões de compra/venda
              Row(
                children: [
                  // Vender
                  Expanded(
                    child: GestureDetector(
                      onTap: owned > 0
                          ? () {
                              HapticFeedback.lightImpact();
                              game.sellAsset(asset);
                            }
                          : null,
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: owned > 0
                              ? Colors.red[900]
                              : Colors.grey[900],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: owned > 0
                                ? Colors.red[700]!
                                : Colors.grey[800]!,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'VENDER',
                            style: TextStyle(
                              color: owned > 0
                                  ? Colors.red[300]
                                  : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Comprar
                  Expanded(
                    child: GestureDetector(
                      onTap: balance >= asset.currentPrice
                          ? () {
                              HapticFeedback.mediumImpact();
                              game.buyAsset(asset);
                            }
                          : null,
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: balance >= asset.currentPrice
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF8A2BE2),
                                    Color(0xFF4B0082)
                                  ],
                                )
                              : null,
                          color: balance >= asset.currentPrice
                              ? null
                              : Colors.grey[900],
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: balance >= asset.currentPrice
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF8A2BE2)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'COMPRAR',
                            style: TextStyle(
                              color: balance >= asset.currentPrice
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
