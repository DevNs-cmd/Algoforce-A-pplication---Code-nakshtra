import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/margin_bar.dart';
import '../providers/revenue_models.dart';

class RevenueStreamsTable extends StatelessWidget {
  const RevenueStreamsTable({super.key, required this.streams});

  final List<RevenueStream> streams;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: AppText.body(
          size: 12,
          color: AppColors.navy,
          weight: FontWeight.w800,
        ),
        columns: const [
          DataColumn(label: Text('Stream')),
          DataColumn(label: Text('Scale')),
          DataColumn(label: Text('When')),
          DataColumn(label: Text('Per Unit')),
          DataColumn(label: Text('Margin')),
        ],
        rows: [
          for (final stream in streams)
            DataRow(
              cells: [
                DataCell(Text(stream.name)),
                DataCell(Text(stream.scale)),
                DataCell(Text(stream.when)),
                DataCell(Text(stream.perUnit)),
                DataCell(
                  SizedBox(
                    width: 130,
                    child: MarginBar(
                      percent: stream.marginPercent,
                      color: stream.color,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
