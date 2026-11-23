import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class BudgetSummaryCard extends StatelessWidget {
  final double totalBudget;
  final double spentBudget;
  final double paidBudget;
  final double remainingBudget;
  final VoidCallback onTap;

  const BudgetSummaryCard({
    super.key,
    required this.totalBudget,
    required this.spentBudget,
    required this.paidBudget,
    required this.remainingBudget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalBudget > 0 ? (spentBudget / totalBudget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = spentBudget > totalBudget;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGoldLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: AppTheme.accentGold, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Anggaran Pernikahan',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppTheme.textLight,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Numbers
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  Formatters.currency(spentBudget),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isOverBudget ? AppTheme.errorRed : AppTheme.textDark,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '/ ${Formatters.currency(totalBudget)}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppTheme.cardBorder,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? AppTheme.errorRed : AppTheme.primaryRose,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Mini stats: Sudah Dibayar & Sisa Budget
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniStat(
                  'Terbayar (DP/Lunas)',
                  Formatters.currency(paidBudget),
                  AppTheme.successGreen,
                ),
                _buildMiniStat(
                  isOverBudget ? 'Melebihi Budget' : 'Sisa Alokasi',
                  Formatters.currency(remainingBudget.abs()),
                  isOverBudget ? AppTheme.errorRed : AppTheme.textDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
