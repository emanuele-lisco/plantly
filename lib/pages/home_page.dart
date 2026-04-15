import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFECE6D9),
            Color(0xFFF7F4EE),
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            Text(
              'Bentornata 🌿',
              style: textTheme.bodyLarge?.copyWith(
                color: LightTheme.deepForest.withOpacity(0.72),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Il tuo spazio verde, semplice e sotto controllo.',
              style: textTheme.displaySmall,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF173726),
                    Color(0xFF2B4A36),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.water_drop_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Oggi',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '2 piante da controllare',
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monstera e Ficus hanno bisogno di una verifica di umidità e luce.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.82),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      _SoftBadge(label: 'Umidità bassa'),
                      _SoftBadge(label: '1 irrigazione suggerita'),
                      _SoftBadge(label: 'Primavera'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: const [
                Expanded(
                  child: _MetricCard(
                    title: 'Piante attive',
                    value: '4',
                    icon: Icons.local_florist_rounded,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Da annaffiare',
                    value: '1',
                    icon: Icons.opacity_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: _MetricCard(
                    title: 'Stato medio',
                    value: '82%',
                    icon: Icons.favorite_rounded,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Fioritura',
                    value: '2 in arrivo',
                    icon: Icons.wb_sunny_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text('Cosa deve fare l’app ora', style: textTheme.titleLarge),
            const SizedBox(height: 12),
            const _ChecklistTile(
              title: 'Aggiungere una pianta',
              subtitle: 'Ingresso semplice nel giardino virtuale.',
            ),
            const _ChecklistTile(
              title: 'Controllare parametri essenziali',
              subtitle: 'Stato, luce e umidità senza schermate complesse.',
            ),
            const _ChecklistTile(
              title: 'Annaffiare manualmente',
              subtitle: 'Azione chiara, immediata e sempre disponibile.',
            ),
            const _ChecklistTile(
              title: 'Mostrare consigli di cura',
              subtitle: 'In base a stagione, data di impianto e posizione.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  const _SoftBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: LightTheme.primary),
          const SizedBox(height: 14),
          Text(title, style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(value, style: textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: LightTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(Icons.check_rounded, size: 16, color: LightTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
