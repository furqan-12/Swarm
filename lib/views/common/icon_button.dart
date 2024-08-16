import "package:swarm/consts/consts.dart";


Widget iconButton({onPress,textColor,String? title}) {
  return ElevatedButton(
      onPressed: onPress,
      child: title!.text.color(textColor).fontFamily(bold).size(18).make(),
      );
}