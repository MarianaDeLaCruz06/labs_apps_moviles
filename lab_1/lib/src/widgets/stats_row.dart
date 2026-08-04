import 'package:flutter/material.dart';

import 'stat_item.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: StatItem(
            value: '248',
            label: 'Posts',
          ),
        ),

        SizedBox(
          height: 40,
          child: VerticalDivider(
            width: 1,
            thickness: 1,
            color: Color(0xFFE5E2EC),
          ),
        ),

        Expanded(
          child: StatItem(
            value: '12.4K',
            label: 'Seguidores',
          ),
        ),

        SizedBox(
          height: 40,
          child: VerticalDivider(
            width: 1,
            thickness: 1,
            color: Color(0xFFE5E2EC),
          ),
        ),

        Expanded(
          child: StatItem(
            value: '180',
            label: 'Siguiendo',
          ),
        ),
      ],
    );
  }
}