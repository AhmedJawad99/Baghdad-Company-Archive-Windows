import 'package:flutter/material.dart';

class Aboutwidget extends StatelessWidget {
  const Aboutwidget({super.key, required this.targetKeyAbout});
  final GlobalKey targetKeyAbout;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: targetKeyAbout,
      padding: EdgeInsets.all(17),
      width: double.infinity,
      color: Theme.of(context).colorScheme.outline,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Container(
                  //padding: const EdgeInsets.all(10),
                  //width: 200,
                  child: Text(
                    textAlign: TextAlign.center,
                    softWrap: true,
                    'من نحن - شركة بغداد العراق للنقل العام والاستثمارات العقارية',
                    style: MediaQuery.of(context).size.width >= 538
                        ? Theme.of(context).textTheme.titleLarge!.copyWith()
                        : Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    textAlign: TextAlign.center,
                    'تأسست شركة بغداد العراق للنقل العام والاستثمارات العقارية (مساهمة- مختلطة) عام 1990 بهدف تقديم خدمات نقل عالية الجودة للمواطنين والمقيمين في مدينة بغداد والمناطق المحيطة بها. تتنوع أنشطتنا بين تقديم خدمات النقل العام عبر حافلات حديثة ومتطورة، وتوفير حلول استثمارية عقارية تلبي احتياجات السوق المتنامية.',
                    style: MediaQuery.of(context).size.width >= 538
                        ? Theme.of(context).textTheme.titleMedium!.copyWith()
                        : Theme.of(context).textTheme.titleSmall!.copyWith(),
                    softWrap: true,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                    width: 400,
                    height: 400,
                    child: Image.asset(
                      'images/cover.png',
                      fit: BoxFit.cover,
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
