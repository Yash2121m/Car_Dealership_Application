import 'package:flutter/material.dart';

class RoundImage extends StatelessWidget{
  const RoundImage({
    super.key,
    this.width,
    this.height = 150,
    this.imageRadiusApply = true,
    this.border,
    this.fit = BoxFit.fill,
    this.padding,
    required this.imageURL,
    this.onPressed,
    this.isNetworkImage = false
  });

  final double? width, height;
  final String imageURL;
  final bool imageRadiusApply;
  final BoxBorder? border;
  final BoxFit fit;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final VoidCallback? onPressed;


  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        padding: padding,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),),
        child: ClipRRect(
            borderRadius: imageRadiusApply ? BorderRadius.circular(20) : BorderRadius.zero,
            child: Image(
              image: isNetworkImage ? NetworkImage(imageURL) : AssetImage(imageURL) as ImageProvider, fit: fit
            )
        ),
      ),
    );
  }


}