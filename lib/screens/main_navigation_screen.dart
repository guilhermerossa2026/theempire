import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../widgets/dashboard_widget.dart';
import 'business_screen.dart';
import 'market_screen.dart';
import 'property_screen.dart';
import 'government_screen.dart';
import 'ranking_screen.dart';

/// Tela principal com navegação por abas — shell da aplicação
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.storefront_rounded,
      activeIcon: Icons.storefront,
      label: 'Negócios',
    ),
    _NavItem(
      icon: Icons.currency_bitcoin_rounded,
      activeIcon: Icons.currency_bitcoin,
      label: 'Ativos',
    ),
    _NavItem(
      icon: Icons.location_city_rounded,
      activeIcon: Icons.location_city,
      label: 'Imóveis',
    ),
    _NavItem(
      icon: Icons.gavel_rounded,
      activeIcon: Icons.gavel,
      label: 'Governo',
    ),
    _NavItem(
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events_rounded,
      label: 'Ranking',
    ),
  ];

  static const List<Widget> _screens = [
    BusinessScreen(),
    MarketScreen(),
    PropertyScreen(),
    GovernmentScreen(),
    RankingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Inicia o jogo após o primeiro frame (contexto disponível)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = context.read<GameProvider>();
      game.setContext(context);
      game.startGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mercado usa fundo dark, demais usam o fundo neumórfico padrão
    final bool isDarkScreen = _selectedIndex == 1;

    return Scaffold(
      backgroundColor: isDarkScreen
          ? const Color(0xFF0D0D1A)
          : const Color(0xFFF1F4F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Dashboard só aparece nas telas que não são "dark"
            if (!isDarkScreen) const DashboardWidget(),

            // Conteúdo da tela selecionada
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD0D5DD),
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (i) => _NavButton(
                item: _navItems[i],
                isSelected: _selectedIndex == i,
                onTap: () => setState(() => _selectedIndex = i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8A2BE2).withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color:
                  isSelected ? const Color(0xFF8A2BE2) : Colors.black38,
              size: 22,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          color: Color(0xFF8A2BE2),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
