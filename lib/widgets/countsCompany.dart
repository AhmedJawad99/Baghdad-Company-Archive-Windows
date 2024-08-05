import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class CountsCompany extends StatelessWidget {
  const CountsCompany({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.inversePrimary,
      child: Padding(
        padding: const EdgeInsets.all(38.0),
        child: MediaQuery.of(context).size.width >= 412
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  countsOF(
                    context,
                    'عدد الموظفين',
                    '26',
                    Icons.groups,
                  ),
                  countsOF(
                    context,
                    'عدد المركبات',
                    '126',
                    Icons.commute,
                  ),
                  countsOF(
                    context,
                    'عدد الاقسام',
                    '6',
                    Icons.apps,
                  ),
                  countsOF(
                    context,
                    'عدد الزيارات',
                    '3426',
                    Icons.person,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  countsOF(
                    context,
                    'عدد الموظفين',
                    '26',
                    Icons.groups,
                  ),
                  countsOF(
                    context,
                    'عدد المركبات',
                    '126',
                    Icons.commute,
                  ),
                  countsOF(
                    context,
                    'عدد الاقسام',
                    '6',
                    Icons.apps,
                  ),
                  countsOF(
                    context,
                    'عدد الزيارات',
                    '3426',
                    Icons.person,
                  ),
                ],
              ),
      ),
    );
  }

  Column countsOF(
      BuildContext context, String name, String number, IconData icon) {
    return Column(
      children: [
        Center(
          child: DottedBorder(
            borderType: BorderType.Circle,
            color: Theme.of(context).colorScheme.onSurface,
            dashPattern: const [5, 3], // Adjust the pattern to your liking
            strokeWidth: 2,
            child: Container(
              width: MediaQuery.of(context).size.width >= 516 ? 100 : 70,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              ),
              child: Center(
                child: Icon(icon,
                    size: 50,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface // Change to your desired icon color
                    ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          name,
          style: MediaQuery.of(context).size.width >= 516
              ? Theme.of(context).textTheme.bodyLarge!.copyWith()
              : Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          number,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
