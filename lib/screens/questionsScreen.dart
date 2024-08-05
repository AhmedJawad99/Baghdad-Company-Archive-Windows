import 'package:flutter/material.dart';

class Questionsscreen extends StatelessWidget {
  const Questionsscreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> faq = [
      {
        'question': 'ما هي خطوط النقل التي تغطيها الشركة؟',
        'answer':
            'نقدم خدمات النقل على مختلف الخطوط الرئيسية في بغداد وضواحيها. يمكنك الاطلاع على خريطة الخطوط وتفاصيل الرحلات من هنا.'
      },
      {
        'question': 'ما هي أوقات العمل الخاصة بالنقل العام؟',
        'answer':
            'تعمل خدمات النقل العام من الساعة 6 صباحاً حتى الساعة 11 مساءً طوال أيام الأسبوع.'
      },
      {
        'question': 'كيف يمكنني شراء تذاكر النقل؟',
        'answer':
            'يمكنك شراء التذاكر عبر موقعنا الإلكتروني أو من مراكز البيع المعتمدة المنتشرة في مختلف أنحاء بغداد.'
      },
      {
        'question': 'هل توجد خصومات أو اشتراكات للطلاب وكبار السن؟',
        'answer':
            'نعم، نقدم خصومات خاصة للطلاب وكبار السن. يمكنك الاطلاع على التفاصيل من هنا.'
      },
      {
        'question': 'ماذا أفعل إذا فقدت شيئًا في إحدى الحافلات؟',
        'answer':
            'إذا فقدت شيئًا في إحدى حافلاتنا، يرجى الاتصال بفريق خدمة العملاء وتقديم تفاصيل المفقودات. سنبذل قصارى جهدنا لمساعدتك في العثور على ممتلكاتك.'
      },
      {
        'question': 'ما هي الخدمات العقارية التي تقدمها الشركة؟',
        'answer':
            'نقدم مجموعة متنوعة من الخدمات العقارية تشمل بيع وشراء العقارات، إدارة الأملاك، وتطوير المشاريع العقارية.'
      },
      {
        'question': 'كيف يمكنني البحث عن عقار مناسب؟',
        'answer':
            'يمكنك استخدام محرك البحث على موقعنا للبحث عن العقارات المتاحة وفقًا لمتطلباتك الخاصة.'
      },
      {
        'question': 'هل تقدمون خدمات الاستشارة العقارية؟',
        'answer':
            'نعم، لدينا فريق من الخبراء العقاريين الذين يقدمون خدمات الاستشارة لمساعدتك في اتخاذ قرارات مدروسة بشأن استثماراتك العقارية.'
      },
      {
        'question': 'ما هي المناطق التي تركز عليها استثماراتكم العقارية؟',
        'answer':
            'نركز على تطوير المشاريع العقارية في بغداد والمناطق المجاورة، مع خطط للتوسع في مناطق أخرى مستقبلاً.'
      },
      {
        'question': 'كيف يمكنني التواصل مع فريق المبيعات؟',
        'answer':
            'يمكنك التواصل مع فريق المبيعات عبر الهاتف أو البريد الإلكتروني، أو زيارة مكتبنا الرئيسي في بغداد.'
      },
      {
        'question': 'كيف يمكنني تقديم شكوى أو اقتراح؟',
        'answer':
            'يمكنك تقديم شكوى أو اقتراح من خلال نموذج الاتصال على موقعنا، أو عبر الاتصال بفريق خدمة العملاء.'
      },
      {
        'question': 'ما هي طرق الدفع المقبولة؟',
        'answer':
            'نقبل مجموعة متنوعة من طرق الدفع تشمل البطاقات الائتمانية، الدفع النقدي، والتحويلات البنكية.'
      },
      {
        'question': 'هل لديكم تطبيق موبايل؟',
        'answer':
            'نعم، يمكنك تحميل تطبيقنا على الهواتف الذكية للحصول على أحدث المعلومات والخدمات بسهولة.'
      },
      {
        'question': 'كيف يمكنني متابعة آخر الأخبار والعروض الخاصة بالشركة؟',
        'answer':
            'يمكنك متابعة آخر الأخبار والعروض من خلال الاشتراك في النشرة البريدية أو متابعتنا على وسائل التواصل الاجتماعي.'
      },
    ];
    return ListView.builder(
        shrinkWrap: true,
        itemCount: faq.length,
        itemBuilder: (context, index) {
          return qAndA('${faq[index]['question']}', '${faq[index]['answer']}');
        });
  }

  Padding qAndA(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                      child: Icon(
                    Icons.question_mark,
                    color: Colors.white,
                  )),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    flex: 9,
                    child: Text(
                      question,
                      softWrap: true,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const Divider(),
              Row(
                children: [
                  const Expanded(
                    child: Icon(
                      Icons.question_answer,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    flex: 9,
                    child: Text(
                      answer,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
