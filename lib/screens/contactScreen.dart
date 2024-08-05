import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Contactscreen extends StatefulWidget {
  const Contactscreen({super.key});

  @override
  State<Contactscreen> createState() => _ContactscreenState();
}

class _ContactscreenState extends State<Contactscreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        // height: 200,
        color: Theme.of(context).colorScheme.shadow,
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                footWidget(
                  context,
                  'عنوان الشركة',
                  'العراق - بغداد - العامرية',
                  Icons.location_on,
                ),
                footWidget(
                  context,
                  'اتصل بنا',
                  '0780000000',
                  Icons.phone,
                ),
                footWidget(
                  context,
                  'تواصل معنا',
                  'email@mail.com',
                  Icons.email,
                ),
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.8, // Adjust multiplier as needed
              child: const Divider(
                thickness: 2, // Adjust thickness as needed
                //color: Colors.black, // Adjust color as needed
              ),
            ),
            const HtmlWidget(
              '''
        <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3334.435841869032!2d44.304345323686576!3d33.30741935669049!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x15577d7683f18b41%3A0xc9e08d81f38ff0fb!2z2LTYsdmD2Kkg2KjYutiv2KfYryDYp9mE2LnYsdin2YIg2YTZhNmG2YLZhCDYp9mE2LnYp9mFINmI2KfZhNin2LPYqtir2YXYp9ix2KfYqiDYp9mE2LnZgtin2LHZitipICjZhdiz2KfZh9mF2KktINmF2K7YqtmE2LfYqSk!5e0!3m2!1sar!2siq!4v1720546184025!5m2!1sar!2siq" width="400" height="300" style="border:0;" allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe> ''',
            ),
            SizedBox(
                width: 140,
                child: Image.asset(
                  'images/logo.png',
                  color: Colors.white,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const FaIcon(
                    FontAwesomeIcons.facebook,
                    color: Colors.grey,
                  ),
                ),
                IconButton(
                    // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                    icon: const FaIcon(
                      FontAwesomeIcons.instagram,
                      color: Colors.grey,
                    ),
                    onPressed: () {}),
                IconButton(
                  onPressed: () {},
                  icon: const FaIcon(
                    FontAwesomeIcons.youtube,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Padding footWidget(
      BuildContext context, String title, String describe, IconData icon) {
    return Padding(
      padding: MediaQuery.of(context).size.width >= 890
          ? const EdgeInsets.symmetric(horizontal: 38, vertical: 38)
          : const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: MediaQuery.of(context).size.width >= 690 ? 43 : 34,
          ),
          Column(
            children: [
              SelectableText(title,
                  style: Theme.of(context).textTheme.bodyLarge),
              SelectableText(
                describe,
                style: MediaQuery.of(context).size.width >= 663
                    ? Theme.of(context).textTheme.bodyMedium
                    : Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
