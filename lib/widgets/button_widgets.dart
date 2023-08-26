import 'package:flutter/material.dart';

import '../models/constants.dart';

class MyButton extends StatefulWidget {
  const MyButton({super.key, required this.label, this.onTap, this.color, this.backgroundColor, this.radius, this.borderRadius, this.isLoading, this.disable, this.isOutlineButton});
  @required
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final Color? backgroundColor;
  final double? radius;
  final BorderRadiusGeometry? borderRadius;
  final bool? isLoading;
  final bool? disable;
  final bool? isOutlineButton;

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  DateTime? lastClickedTime;

  bool isRedundantClick(){
    final currentClickedTime = DateTime.now();
    if(lastClickedTime == null){
      lastClickedTime = currentClickedTime;
      return false;
    }else{
      return currentClickedTime.difference(lastClickedTime!).inSeconds > 2;
    }
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (widget.disable ?? false) || (widget.isLoading ?? false)
        ? null
        : (){
        if(isRedundantClick()){
          return;
        }
        if (widget.onTap != null) {
          widget.onTap!();
        }
        },
        child: widget.disable ?? false
      ? ButtonFilled(label: widget.label,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      color: Theme.of(context).colorScheme.onPrimaryContainer,
      radius: widget.radius,
      borderRadius: widget.borderRadius,
          isLoading: widget.isLoading,
    ) : widget.isOutlineButton ?? false
        ? ButtonOutlined(
            label: widget.label,
          color: widget.color,
          backgroundColor: widget.backgroundColor,
          borderRadius: widget.borderRadius,
          radius: widget.radius,
          isLoading: widget.isLoading,
        ) : ButtonFilled(label: widget.label,
          color: widget.color,
          backgroundColor: widget.backgroundColor,
          borderRadius: widget.borderRadius,
          radius: widget.radius,
          isLoading: widget.isLoading,
        )
    );
  }
}
class ButtonFilled extends StatelessWidget {
  const ButtonFilled({super.key, required this.label, this.color, this.backgroundColor, this.radius, this.borderRadius, this.isLoading});
  @required
  final String label;

  final Color? color;
  final Color? backgroundColor;
  final double? radius;
  final BorderRadiusGeometry? borderRadius;
  final bool? isLoading;


  @override
  Widget build(BuildContext context) {
    return ButtonContainer(label: label,
        color: color ?? Theme.of(context).colorScheme.onPrimary,
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        borderColor: backgroundColor ?? Theme.of(context).colorScheme.primary);
  }
}

class ButtonOutlined extends StatelessWidget {
  const ButtonOutlined({super.key, required this.label, this.color, this.backgroundColor, this.radius, this.borderRadius, this.isLoading});
  @required
  final String label;

  final Color? color;
  final Color? backgroundColor;
  final double? radius;
  final BorderRadiusGeometry? borderRadius;
  final bool? isLoading;


  @override
  Widget build(BuildContext context) {
    return ButtonContainer(label: label,
        color: color ?? Theme.of(context).colorScheme.primary,
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.onPrimary,
        borderColor: color ?? Theme.of(context).colorScheme.primary);
  }
}
class ButtonContainer extends StatelessWidget {
  const ButtonContainer({super.key, required this.label,required this.color,required this.backgroundColor, required this.borderColor, this.radius, this.borderRadius, this.isLoading});
  @required
  final String label;

  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final double? radius;
  final BorderRadiusGeometry? borderRadius;
  final bool? isLoading;


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(2),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius ?? BorderRadius.circular(radius ?? 24),
            border: Border.all(color: borderColor)
        ),
        padding: const EdgeInsets.all(4),
        child: Center(
          child: isLoading ?? false
          ? SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(color: color,),
          )
          : Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,style: SmallTextStyle(color: color),),
        ),
      ),
    );
  }
}

