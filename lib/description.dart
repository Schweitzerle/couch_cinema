import 'package:couch_cinema/widgets/popular_series.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Description extends StatelessWidget {
  final String name, description, bannerURL, posterURL, vote, launchOn;

  const Description({
    Key? key,
    required this.name,
    required this.description,
    required this.bannerURL,
    required this.posterURL,
    required this.vote,
    required this.launchOn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double averageRating = double.parse(vote);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 250,
              width: double.infinity,
              child: Stack(
                children: [
                  Image.network(
                    bannerURL,
                    fit: BoxFit.cover,
                    color: Color.fromRGBO(0, 0, 0, 0.6),
                    colorBlendMode: BlendMode.darken,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name != null ? name : 'Not Loaded',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 200,
                            width: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                posterURL,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 1,
                            left: 1,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: PopularSeries.getCircleColor(averageRating),
                              ),
                              child: Center(
                                child: Text(
                                  vote,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Release: ' + launchOn,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: FoldableOptions(),
          ),
        ],
      ),
    );
  }
}

class FoldableOptions extends StatefulWidget {
  @override
  _FoldableOptionsState createState() => _FoldableOptionsState();
}

class _FoldableOptionsState extends State<FoldableOptions>
    with SingleTickerProviderStateMixin {
  final List<IconData> options = [
    Icons.settings,
    Icons.person,
    Icons.favorite,
    Icons.home,
    Icons.star,
  ];

  late Animation<Alignment> firstAnim;
  late Animation<Alignment> secondAnim;
  late Animation<Alignment> thirdAnim;
  late Animation<Alignment> fourthAnim;
  late Animation<Alignment> fifthAnim;
  late Animation<double> verticalPadding;
  late AnimationController controller;
  final duration = Duration(milliseconds: 190);

  Widget getItem(IconData source) {
    final size = 45.0;
    return GestureDetector(
      onTap: () {
        controller.reverse();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Color(0XFFE95A8B),
          borderRadius: BorderRadius.all(
            Radius.circular(40),
          ),
        ),
        child: Icon(
          source,
          color: Colors.white.withOpacity(1.0),
          size: 20,
        ),
      ),
    );
  }

  Widget buildPrimaryItem(IconData source) {
    final size = 45.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(0XFFE95A8B),
        borderRadius: BorderRadius.all(
          Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
              color: Color(0XFFE95A8B).withOpacity(0.8),
              blurRadius: verticalPadding.value),
        ],
      ),
      child: Icon(
        source,
        color: Colors.white.withOpacity(1),
        size: 20,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: duration);

    final anim = CurvedAnimation(parent: controller, curve: Curves.linear);
    firstAnim =
        Tween<Alignment>(begin: Alignment.centerRight, end: Alignment.topRight)
            .animate(anim);
    secondAnim =
        Tween<Alignment>(begin: Alignment.centerRight, end: Alignment.topLeft)
            .animate(anim);
    thirdAnim = Tween<Alignment>(
        begin: Alignment.centerRight, end: Alignment.centerLeft)
        .animate(anim);
    fourthAnim = Tween<Alignment>(
        begin: Alignment.centerRight, end: Alignment.bottomLeft)
        .animate(anim);
    fifthAnim = Tween<Alignment>(
        begin: Alignment.centerRight, end: Alignment.bottomRight)
        .animate(anim);
    verticalPadding = Tween<double>(begin: 0, end: 26).animate(anim);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 210,
      margin: EdgeInsets.only(right: 15),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            children: <Widget>[
              Align(
                alignment: firstAnim.value,
                child: getItem(
                  options.elementAt(0),
                ),
              ),
              Align(
                alignment: secondAnim.value,
                child: Container(
                  padding:
                  EdgeInsets.only(left: 37, top: verticalPadding.value),
                  child: getItem(
                    options.elementAt(1),
                  ),
                ),
              ),
              Align(
                alignment: thirdAnim.value,
                child: getItem(
                  options.elementAt(2),
                ),
              ),
              Align(
                  alignment: fourthAnim.value,
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 38, bottom: verticalPadding.value),
                    child: getItem(
                      options.elementAt(3),
                    ),
                  )),
              Align(
                alignment: fifthAnim.value,
                child: getItem(
                  options.elementAt(4),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    controller.isCompleted
                        ? controller.reverse()
                        : controller.forward();
                  },
                  child: buildPrimaryItem(
                    controller.isCompleted || controller.isAnimating
                        ? Icons.close
                        : Icons.add,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

