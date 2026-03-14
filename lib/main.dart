import 'dart:math' as math;
import 'package:arcore_flutter_plus/arcore_flutter_plus.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
// import 'dart:async';
// import 'dart:math' as math;

//--Example 4 to place emojis in the enviornment

void main() => runApp(
  const MaterialApp(
    debugShowCheckedModeBanner: false,
    // home: AREmojiWorld()    ////-- uncomment to run this example
    home: ARDistanceMeasurer(),
  ),
);

////--Example 1 to calculate distance b/w 2 marks on floor

class ARDistanceMeasurer extends StatefulWidget {
  const ARDistanceMeasurer({super.key});

  @override
  State<ARDistanceMeasurer> createState() => _ARDistanceMeasurerState();
}

class _ARDistanceMeasurerState extends State<ARDistanceMeasurer> {
  ArCoreController? arCoreController;

  // Do points ko store karne ke liye
  ArCoreNode? startNode;
  ArCoreNode? endNode;
  String distanceText = "Tap on floor to place marks";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR Distance Meter')),
      body: Stack(
        children: [
          ArCoreView(
            onArCoreViewCreated: _onArCoreViewCreated,
            enableTapRecognizer: true,
            enablePlaneRenderer: true, // this will show dots
            planeColor: Colors.red,
            // debugOptions: ArCoreDebugOptions(showFeaturePoints: true), // Tracking dekhne ke li
          ),
          // Distance display karne ke liye UI
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.black54,
              child: Text(
                distanceText,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            child: FloatingActionButton(
              onPressed: _resetMarks,
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    // Plane detection configuration
    arCoreController?.onPlaneTap = _handleOnPlaneTap;
  }

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    if (hits.isEmpty) return;
    final hit = hits.first;

    if (startNode == null) {
      // Pehla mark lagayein
      startNode = _createMark(hit.pose.translation, Colors.red);
      arCoreController?.addArCoreNode(startNode!);
      setState(() {
        distanceText = "First mark placed. Tap for second mark.";
      });
    } else if (endNode == null) {
      // Doosra mark lagayein
      endNode = _createMark(hit.pose.translation, Colors.blue);
      arCoreController?.addArCoreNode(endNode!);

      // Distance calculate karein
      _calculateDistance();
    }
  }

  ArCoreNode _createMark(vector.Vector3 position, Color color) {
    final material = ArCoreMaterial(color: color, metallic: 1.0);
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.03,
    ); // Chota sa mark
    return ArCoreNode(shape: sphere, position: position);
  }

  void _calculateDistance() {
    if (startNode == null || endNode == null) return;

    // .value lagana zaroori hai kyunki position ek ValueNotifier hai
    final startPos = startNode!.position!.value;
    final endPos = endNode!.position!.value;

    // Distance Formula implementation
    double dx = endPos.x - startPos.x;
    double dy = endPos.y - startPos.y;
    double dz = endPos.z - startPos.z;

    // math.sqrt use karein agar math as prefix imported hai
    double distance = math.sqrt(dx * dx + dy * dy + dz * dz);

    setState(() {
      distanceText = "Distance: ${(distance * 100).toStringAsFixed(2)} cm";
    });
  }

  void _resetMarks() {
    if (startNode != null)
      arCoreController?.removeNode(nodeName: startNode!.name);
    if (endNode != null) arCoreController?.removeNode(nodeName: endNode!.name);
    startNode = null;
    endNode = null;
    setState(() {
      distanceText = "Marks reset. Tap on floor again.";
    });
  }

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }
}

////-- Example 2 of showing 3d models of (mouse, cat, car) showing through glb model type
class AREmojiWorld extends StatefulWidget {
  const AREmojiWorld({super.key});

  @override
  State<AREmojiWorld> createState() => _AREmojiWorldState();
}

class _AREmojiWorldState extends State<AREmojiWorld> {
  ArCoreController? arCoreController;

  // Default Selected Model
  String selectedModel = "car.glb";

  final List<Map<String, String>> modelOptions = [
    {"name": "CAR", "icon": "🚗", "file": "car.glb"},
    {"name": "CAT", "icon": "🐱", "file": "cat.glb"},
    {"name": "TOM", "icon": "🐭", "file": "tom.glb"},
    {"name": "circle", "icon": "🟡", "file": "SHAPE_CIRCLE"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Multi-Model Placer'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          ArCoreView(
            onArCoreViewCreated: _onArCoreViewCreated,
            enableTapRecognizer: true,
            enablePlaneRenderer: true,
            planeColor: Colors.red,
          ),

          // Selection UI
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: modelOptions.length,
                itemBuilder: (context, index) {
                  bool isSelected =
                      selectedModel == modelOptions[index]['file'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedModel = modelOptions[index]['file']!;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 15),
                      width: 80,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blueAccent
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          const BoxShadow(color: Colors.black26, blurRadius: 5),
                        ],
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            modelOptions[index]['icon']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            modelOptions[index]['name']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController?.onPlaneTap = _handleOnPlaneTap;
  }

  // 2. Updated Tap Handler
  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    if (hits.isEmpty) return;
    final hit = hits.first;
    final String nodeName = "node_${DateTime.now().millisecondsSinceEpoch}";

    if (selectedModel == "SHAPE_CIRCLE") {
      // Agar circle selected hai toh Package ki apni shape use karein
      final material = ArCoreMaterial(color: Colors.yellow, metallic: 1.0);
      final sphere = ArCoreCylinder(
        //try different shapes
        materials: [material],
        // radius: 0.1, // 10cm radius
        // height: 0.1,
      );
      final node = ArCoreNode(
        name: nodeName,
        shape: sphere,
        position: hit.pose.translation,
        rotation: hit.pose.rotation,
      );
      arCoreController?.addArCoreNode(node);
    } else {
      // Warna .glb model load karein
      final node = ArCoreReferenceNode(
        name: nodeName,
        object3DFileName: selectedModel,
        position: hit.pose.translation,
        rotation: hit.pose.rotation,
        scale: vector.Vector3(0.2, 0.2, 0.2),
      );
      arCoreController?.addArCoreNode(node);
    }
  }

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }
}
