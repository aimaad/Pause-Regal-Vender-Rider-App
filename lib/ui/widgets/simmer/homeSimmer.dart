import 'package:erestro_single_vender_rider/ui/styles/color.dart';
import 'package:erestro_single_vender_rider/ui/styles/design.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeSimmer extends StatelessWidget {
  final double? width, height;
  const HomeSimmer({Key? key, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Shimmer.fromColors(
            baseColor: shimmerBaseColor,
            highlightColor: shimmerhighlightColor,
            
            child: Column(
              children: [
                Container(
                    margin: EdgeInsetsDirectional.only(
                        start: width! / 20.0,
                        end: width! / 20.0,
                        top: height! / 80.0),
                    height: height! / 12,
                    decoration: DesignConfig.boxDecorationContainer(
                        shimmerContentColor, 4.0)),
                Row(children: [
                  Expanded(
                    child: Container(
                        height: 128,
                        width: 166.5,
                        decoration: DesignConfig.boxDecorationContainer(
                            shimmerContentColor, 8.0),
                        margin: EdgeInsetsDirectional.only(
                            top: height! / 50,
                            start: width! / 20.0,
                            end: width! / 40.0),
                        padding: EdgeInsetsDirectional.only(
                            start: width! / 40.0,
                            end: width! / 40.0,
                            top: height! / 80.0,
                            bottom: height! / 80.0)),
                  ),
                  Expanded(
                    child: Container(
                        height: 128,
                        width: 166.5,
                        decoration: DesignConfig.boxDecorationContainer(
                            shimmerContentColor, 8.0),
                        margin: EdgeInsetsDirectional.only(
                            top: height! / 50,
                            start: width! / 40.0,
                            end: width! / 20.0),
                        padding: EdgeInsetsDirectional.only(
                            start: width! / 40.0,
                            end: width! / 40.0,
                            top: height! / 80.0,
                            bottom: height! / 80.0)),
                  )
                ]),
                Row(children: [
                  Expanded(
                    child: Container(
                        height: 128,
                        width: 166.5,
                        decoration: DesignConfig.boxDecorationContainer(
                            shimmerContentColor, 8.0),
                        margin: EdgeInsetsDirectional.only(
                            top: height! / 50,
                            start: width! / 20.0,
                            end: width! / 40.0),
                        padding: EdgeInsetsDirectional.only(
                            start: width! / 40.0,
                            end: width! / 40.0,
                            top: height! / 80.0,
                            bottom: height! / 80.0)),
                  ),
                  Expanded(
                    child: Container(
                        height: 128,
                        width: 166.5,
                        decoration: DesignConfig.boxDecorationContainer(
                            shimmerContentColor, 8.0),
                        margin: EdgeInsetsDirectional.only(
                            top: height! / 50,
                            start: width! / 40.0,
                            end: width! / 20.0),
                        padding: EdgeInsetsDirectional.only(
                            start: width! / 40.0,
                            end: width! / 40.0,
                            top: height! / 80.0,
                            bottom: height! / 80.0)),
                  )
                ]),
                Container(
                    margin: EdgeInsetsDirectional.only(
                        start: width! / 20.0,
                        end: width! / 20.0,
                        top: height! / 40.0),
                    height: height! / 20,
                    decoration: DesignConfig.boxDecorationContainer(
                        shimmerContentColor, 4.0)),
                Container(
                  height: height! / 4.0,
                  margin: EdgeInsetsDirectional.only(
                      start: width! / 20.0,
                      end: width! / 20.0,
                      top: height! / 40.0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    child: Container(
                      width: width,
                      height: height! / 4.0,
                      color: shimmerContentColor,
                    ),
                  ),
                ),
              ],
            )));
  }
}
