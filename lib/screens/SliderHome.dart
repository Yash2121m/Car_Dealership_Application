import 'package:cardealer/screens/HomeController.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'CircularContainer.dart';
import 'RoundedSlider.dart';

class SliderHome extends StatelessWidget {
  const SliderHome({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Column(
      children: [
        CarouselSlider(
            items: [
              RoundImage(imageURL: 'images/cae_sale_1.jpg',),
              RoundImage(imageURL: 'images/cae_sale_2.jpg',),
              RoundImage(imageURL: 'images/cae_sale_3.jpg',),
              RoundImage(imageURL: 'images/cae_sale_4.jpg',),
            ] ,
            options: CarouselOptions(
              autoPlay: true,
              autoPlayAnimationDuration: Duration(milliseconds: 1000),
              viewportFraction: 1,
              enlargeCenterPage: true,
              onPageChanged: (index, _) => controller.updatePageIndicator(index),
            )
        ),
        SizedBox(height: 10,),
        Center(
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for(int i = 0; i < 4; i++)CircularContainer(width: 20, height: 4, backgrounColor: controller.currentIndex.value == i ? Colors.blue : Colors.grey, margin: EdgeInsets.only(right: 10),),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


