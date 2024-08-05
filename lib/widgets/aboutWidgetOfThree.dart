import 'package:baghdadcompany/models/about.dart';
import 'package:flutter/material.dart';

class Aboutwidgetofthree extends StatelessWidget {
  const Aboutwidgetofthree({super.key});

  @override
  Widget build(BuildContext context) {
    List<About> about = [
      About(
        title: 'رؤيتنا',
        body:
            'نسعى لأن نكون الشركة الرائدة في قطاع النقل العام والاستثمارات العقارية في العراق، من خلال تقديم خدمات متميزة تعتمد على الابتكار والجودة العالية.',
      ),
      About(
        title: 'مهتمتنا',
        body:
            'توفير خدمات نقل آمنة وموثوقة تساهم في تحسين حياة المواطنين وتسهيل تنقلاتهم اليومية، بالإضافة إلى تطوير مشاريع عقارية تعزز من البنية التحتية وتلبي احتياجات السكان المختلفة.',
      ),
      About(
        title: 'قيمنا',
        body:
            'الجودة: الالتزام بتقديم خدمات ذات مستوى عالٍ من الجودة في جميع أنشطتنا. \n الابتكار: استخدام أحدث التقنيات والأساليب لتقديم حلول فعالة ومستدامة. \n المسؤولية الاجتماعية: المساهمة في تنمية المجتمع المحلي وتعزيز البنية التحتية. \n الشفافية: التعامل بصدق وشفافية مع عملائنا وشركائنا في العمل. \n',
      ),
      About(
        title: 'خدماتنا',
        body:
            'نسعى لأن نكون الشركة الرائدة في قطاع النقل العام والاستثمارات العقارية في العراق، من خلال تقديم خدمات متميزة تعتمد على الابتكار والجودة العالية.',
      ),
      About(
        title: 'فريقنا',
        body:
            'النقل العام: تقديم خدمات نقل عام عبر شبكة واسعة من الحافلات تغطي مختلف مناطق بغداد، مع التركيز على الراحة والسلامة. \n  الاستثمارات العقارية: تطوير وإدارة مشاريع عقارية سكنية وتجارية تهدف إلى تلبية احتياجات السوق المتنوعة وتعزيز التنمية العمرانية في العراق.',
      ),
    ];
    return Container(
      padding: EdgeInsets.all(17),
      width: double.infinity,
      color: Theme.of(context).colorScheme.outline,
      child: MediaQuery.of(context).size.width >= 431
          ? pcWidget(context, about)
          : Column(
              children: [
                mobileTitleAndBody(context, about, 0),
                mobileTitleAndBody(context, about, 1),
                mobileTitleAndBody(context, about, 2),
                mobileTitleAndBody(context, about, 3),
                mobileTitleAndBody(context, about, 4),
              ],
            ),
    );
  }

  Padding mobileTitleAndBody(
      BuildContext context, List<About> about, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              titles(context, about[index].title),
            ],
          ),
          Row(
            children: [
              bodyDescribe(context, about[index].body),
            ],
          ),
        ],
      ),
    );
  }

  Column pcWidget(BuildContext context, List about) {
    return Column(
      children: [
        Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              titles(context, about[0].title),
              titles(context, about[1].title),
              titles(context, about[2].title),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bodyDescribe(context, about[0].body),
              bodyDescribe(context, about[1].body),
              bodyDescribe(context, about[2].body),
            ],
          ),
        ]),
        const SizedBox(
          height: 80,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                titles(context, about[3].title),
                titles(context, about[4].title),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bodyDescribe(context, about[3].body),
                bodyDescribe(context, about[4].body),
              ],
            ),
          ]),
        ),
        const SizedBox(
          height: 30,
        )
      ],
    );
  }

  Expanded bodyDescribe(BuildContext context, String body) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          // textAlign: TextAlign.right,
          body,
          style: MediaQuery.of(context).size.width >= 538
              ? Theme.of(context).textTheme.titleMedium!.copyWith()
              : Theme.of(context).textTheme.titleSmall!.copyWith(),
          softWrap: true,
        ),
      ),
    );
  }

  Expanded titles(BuildContext context, String title) {
    return Expanded(
      child: Text(
        textAlign: TextAlign.center,
        title,
        style: MediaQuery.of(context).size.width >= 538
            ? Theme.of(context).textTheme.titleLarge!.copyWith()
            : Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
