import 'package:baghdadcompany/widgets/footer.dart';
import 'package:flutter/material.dart';

class Aboutscreen extends StatelessWidget {
  const Aboutscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('البيانات الأساسية'),
                              Divider(),
                              titleAndValue('اسم الشركة',
                                  'بغداد العراق للنقل العام والاستثمارات العقارية (SBPT)'),
                              titleAndValue('مجال عمل الشركة',
                                  'نقل الأشخاص والمسافرين و الاستثمارات العقارية'),
                              titleAndValue(
                                  'تاريخ إنشاء الشركة', '27 يوليو 1987'),
                              titleAndValue(
                                  'بداية السنة المالية', 'الربع الاول'),
                              titleAndValue(
                                  'مُراجع الحسابات', 'ديوان الرقابة المالية'),
                            ],
                          ),
                        ),
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('هيكل الملكية'),
                              Divider(),
                              titleAndValue(
                                  'الشركة العامة لنقل المسافرين والوفود',
                                  '20.00%'),
                              titleAndValue('حارث جعفر كاظم', '11.30%'),
                              titleAndValue('عباس جميل مجيد', '8.74%'),
                              titleAndValue(
                                  'وزارة الأوقاف والشؤون الإسلامية - قطر',
                                  '7.37%'),
                              titleAndValue('العامة للنقل البري', '5.00%'),
                              titleAndValue('زهير عبد الحسن جعفر', '2.762%'),
                              titleAndValue('فراس جميل مجيد', '2.311%'),
                              titleAndValue('جعفر محمد علي جعفر', '0.084%'),
                              titleAndValue('خالدة علي حسن', '0.0154%'),
                              titleAndValue('محمد عبد المجيد حميد', '0.015%'),
                              titleAndValue('ثائر غانم محمد علي', '0.0112%'),
                              titleAndValue('ازاد جميل مجيد', '0.0029%'),
                              titleAndValue('اركان حسين حسن', '0.001%'),
                            ],
                          ),
                        ),
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('أعضاء مجلس الإدارة'),
                              Divider(),
                              titleAndValue(
                                  'حارث جعفر كاظم', 'رئيس مجلس الادارة'),
                              titleAndValue('جعفر محمد علي جعفر',
                                  'نائب رئيس مجلس الادارة'),
                              titleAndValue(
                                  'زهير عبد الحسن جعفر', 'عضو مجلس إدارة'),
                              titleAndValue('اركان حسين حسن', 'عضو مجلس إدارة'),
                              titleAndValue('قاسم بديوي علي',
                                  'عضو مجلس إدارة يمثل وزارة النقل'),
                              titleAndValue('جاسم جاسم محمد',
                                  'عضو مجلس إدارة يمثل وزارة النقل'),
                              titleAndValue('عباس جميل مجيد', 'عضو مجلس إدارة'),
                            ],
                          ),
                        ),
                        MediaQuery.of(context).size.width <= 658
                            ? sideWidget()
                            : const Text(''),
                      ],
                    )),
                MediaQuery.of(context).size.width >= 658
                    ? Expanded(
                        flex: 1,
                        child: sideWidget(),
                      )
                    : const Text(''),
              ],
            ),
          ),
          const footerWidget(),
        ],
      ),
    );
  }

  Column sideWidget() {
    return Column(
      children: [
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('السهم'),
              Divider(),
              titleAndValue('القيمة الاسمية', '1.00 دينار عراقي'),
              titleAndValue('القيمة السوقية', '54,600,000,000.00 دينار عراقي'),
              titleAndValue('القيمة الدفترية', '6.78 دينار عراقي'),
              titleAndValue('مضاعف القيمة الدفترية', '3.99'),
              titleAndValue('ربحية السهم', '3.45 دينار عراقي'),
              titleAndValue('مضاعف الربحية', '9.04'),
              titleAndValue('عملة التداول', 'دينار عراقي'),
            ],
          ),
        ),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('إحصائيات الشركة'),
              Divider(),
              titleAndValue('عدد أسهم الشركة الحالي', '1,300,000,000'),
              titleAndValue('رأس المال', '1,300,000,000.00')
            ],
          ),
        ),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('استثمارات أخرى'),
              Divider(),
              titleAndValue(
                  'طريق الخازر لإنتاج وتجارة المواد الإنشائية والاستثمارات العقارية والمقاولات العامة',
                  '12.19%'),
              titleAndValue('البادية للنقل العام', '0.25%'),
              titleAndValue('العراقية لإنتاج البذور', '0.1949%'),
              titleAndValue('العشار لنقل الركاب', 'نسبة غير معلومة'),
            ],
          ),
        ),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('معلومات الاتصال'),
              Divider(),
              titleAndValue(
                  'العنوان', 'بغداد / العامرية / طريق أبو غريب القديم'),
              titleAndValue('التليفون', '96415556611+'),
              titleAndValue('الفاكس', ''),
              titleAndValue('الموقع الإلكتروني', ''),
              titleAndValue('البريد الإلكتروني', 'baghdadiraqco@yahoo.com'),
              titleAndValue('مسؤول الاتصال', 'ثائر غانم محمد علي')
            ],
          ),
        ),
      ],
    );
  }

  Padding titleAndValue(String title, String value) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                value,
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }
}
