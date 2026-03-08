import 'package:arcore_flutter_plus/arcore_flutter_plus.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
// import 'dart:async';
// import 'dart:math' as math;

//--Example 4 to place emojis in the enviornment

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: AREmojiWorld()),
);

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






































//Example 3 to calculate distance b/w 2 marks on floor 
// void main() {
//   runApp(const MaterialApp(home: ARDistanceMeasurer()));
// }

// class ARDistanceMeasurer extends StatefulWidget {
//   const ARDistanceMeasurer({super.key});

//   @override
//   State<ARDistanceMeasurer> createState() => _ARDistanceMeasurerState();
// }

// class _ARDistanceMeasurerState extends State<ARDistanceMeasurer> {
//   ArCoreController? arCoreController;
  
//   // Do points ko store karne ke liye
//   ArCoreNode? startNode;
//   ArCoreNode? endNode;
//   String distanceText = "Tap on floor to place marks";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('AR Distance Meter')),
//       body: Stack(
//         children: [
//           ArCoreView(
//             onArCoreViewCreated: _onArCoreViewCreated,
//             enableTapRecognizer: true,
//           enablePlaneRenderer: true, // ZAROORI: Isse dots nazar ayenge
//           // debugOptions: ArCoreDebugOptions(showFeaturePoints: true), // Tracking dekhne ke li
//           ),
//           // Distance display karne ke liye UI
//           Positioned(
//             top: 50,
//             left: 20,
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               color: Colors.black54,
//               child: Text(
//                 distanceText,
//                 style: const TextStyle(color: Colors.white, fontSize: 18),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 30,
//             left: 20,
//             child: FloatingActionButton(
//               onPressed: _resetMarks,
//               child: const Icon(Icons.refresh),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   void _onArCoreViewCreated(ArCoreController controller) {
//     arCoreController = controller;
//     // Plane detection configuration
//     arCoreController?.onPlaneTap = _handleOnPlaneTap;

//   }

//   void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
//     if (hits.isEmpty) return;
//     final hit = hits.first;

//     if (startNode == null) {
//       // Pehla mark lagayein
//       startNode = _createMark(hit.pose.translation, Colors.red);
//       arCoreController?.addArCoreNode(startNode!);
//       setState(() {
//         distanceText = "First mark placed. Tap for second mark.";
//       });
//     } else if (endNode == null) {
//       // Doosra mark lagayein
//       endNode = _createMark(hit.pose.translation, Colors.blue);
//       arCoreController?.addArCoreNode(endNode!);
      
//       // Distance calculate karein
//       _calculateDistance();
//     }
//   }

//   ArCoreNode _createMark(vector.Vector3 position, Color color) {
//     final material = ArCoreMaterial(color: color, metallic: 1.0);
//     final sphere = ArCoreSphere(materials: [material], radius: 0.03); // Chota sa mark
//     return ArCoreNode(
//       shape: sphere,
//       position: position,
//     );
//   }


//   void _calculateDistance() {
//   if (startNode == null || endNode == null) return;

//   // .value lagana zaroori hai kyunki position ek ValueNotifier hai
//   final startPos = startNode!.position!.value; 
//   final endPos = endNode!.position!.value;

//   // Distance Formula implementation
//   double dx = endPos.x - startPos.x;
//   double dy = endPos.y - startPos.y;
//   double dz = endPos.z - startPos.z;

//   // math.sqrt use karein agar math as prefix imported hai
//   double distance = math.sqrt(dx * dx + dy * dy + dz * dz);
  
//   setState(() {
//     distanceText = "Distance: ${(distance * 100).toStringAsFixed(2)} cm";
//   });
// }

//   void _resetMarks() {
//     if (startNode != null) arCoreController?.removeNode(nodeName: startNode!.name);
//     if (endNode != null) arCoreController?.removeNode(nodeName: endNode!.name);
//     startNode = null;
//     endNode = null;
//     setState(() {
//       distanceText = "Marks reset. Tap on floor again.";
//     });
//   }

//   @override
//   void dispose() {
//     arCoreController?.dispose();
//     super.dispose();
//   }
// }






















//-- Example 2 of tom rotating in circular motion
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const MaterialApp(
//     debugShowCheckedModeBanner: false, 
//     home: UniqueMovingTom()
//   ));
// }

// class UniqueMovingTom extends StatefulWidget {
//   const UniqueMovingTom({super.key});

//   @override
//   State<UniqueMovingTom> createState() => _UniqueMovingTomState();
// }

// class _UniqueMovingTomState extends State<UniqueMovingTom> {
//   ArCoreController? arCoreController;
//   ArCoreNode? tomNode;
  
//   // Animation variables
//   Timer? timer;
//   double angle = 0.0;
//   vector.Vector3 centerPosition = vector.Vector3(0, 0, -1.5);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('AR Patrol Tom'),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: ArCoreView(
//         onArCoreViewCreated: _onArCoreViewCreated,
//         enableTapRecognizer: true, // Floor tap enable karne ke liye
//       ),
//     );
//   }

//   void _onArCoreViewCreated(ArCoreController controller) {
//     arCoreController = controller;
    
//     // Jab user floor par tap kare toh Tom wahan move ho jaye
//     arCoreController?.onPlaneTap = _handleOnPlaneTap;
    
//     // Initial Tom add karein
//     _spawnTom(centerPosition);
//     _startUniqueAnimation();
//   }

//   void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
//     final hit = hits.first;
//     // Tap wali jagah ko naya center bana dein
//     centerPosition = hit.pose.translation;
//     _spawnTom(centerPosition);
//   }

//   void _spawnTom(vector.Vector3 position) {
//     // Agar pehle se node hai toh remove karein
//     if (tomNode != null) {
//       arCoreController?.removeNode(nodeName: "tom_patrol");
//     }

//     tomNode = ArCoreReferenceNode(
//       name: "tom_patrol",
//       object3DFileName: "tom.glb", // Make sure file is in android/assets
//       position: position,
//       scale: vector.Vector3(0.5, 0.5, 0.5),
//     );

//     arCoreController?.addArCoreNode(tomNode!);
//   }

//   // Unique Circular Animation Logic
//   void _startUniqueAnimation() {
//     timer?.cancel();
//     timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
//       if (tomNode == null || arCoreController == null) return;

//       angle += 0.05; // Speed of rotation
//       double radius = 0.6; // Kitni door tak ghoomega

//       // Calculate new X and Z for circular movement
//       double newX = centerPosition.x + radius * math.cos(angle);
//       double newZ = centerPosition.z + radius * math.sin(angle);
      
//       vector.Vector3 newPos = vector.Vector3(newX, centerPosition.y, newZ);

//       // Unique Feature: Moving with Rotation 
//       // Tom ka face movement ki taraf karne ke liye y-axis rotation
//       double rotationY = -angle + (math.pi / 2);

//       // Update Node (Re-adding for smooth position in this specific plugin)
//       _updateNodePosition(newPos, rotationY);
//     });
//   }

//   void _updateNodePosition(vector.Vector3 pos, double rotationY) {
//     arCoreController?.removeNode(nodeName: "tom_patrol");
    
//     tomNode = ArCoreReferenceNode(
//       name: "tom_patrol",
//       object3DFileName: "tom.glb",
//       position: pos,
//       // Quaternion use hota hai rotation ke liye
//       rotation: vector.Vector4(0, 1, 0, rotationY), 
//       scale: vector.Vector3(0.5, 0.5, 0.5),
//     );

//     arCoreController?.addArCoreNode(tomNode!);
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     arCoreController?.dispose();
//     super.dispose();
//   }
// }




























// //-- Example 1 of tom jerry showing through glb model type

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp( MovingTom());
// }



// class MovingTom extends StatefulWidget {
//   const MovingTom({super.key});

//   @override
//   State<MovingTom> createState() => _MovingTomState();
// }

// class _MovingTomState extends State<MovingTom> {
//   late ArCoreController arCoreController;
//   ArCoreNode? carNode;
//   double tomZ = -1.5;

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(title: const Text('AR Moving Tom')),
//         body: ArCoreView(
//           onArCoreViewCreated: _onArCoreViewCreated,
//         ),
//       ),
//     );
//   }

//   void _onArCoreViewCreated(ArCoreController controller) {
//     arCoreController = controller;

//     _addTom(tomZ);

//     _startTomAnimation();
//   }


// void _addTom(double zPosition) async {
//   // Remove previous node if exists
//   if (carNode != null) {
//     arCoreController.removeNode(nodeName: "car");
//   }

//   carNode = ArCoreReferenceNode(
//     // Just the filename as it appears in android/app/src/main/assets
//     object3DFileName: "tom.glb", 
//     name: "car",
//     position: vector.Vector3(0, 0, zPosition),
//     scale: vector.Vector3(0.3, 0.3, 0.3),
//   );

//   arCoreController.addArCoreNode(carNode!);
// }


//   void _startTomAnimation() {
//     const duration = Duration(milliseconds: 50);
//     Timer.periodic(duration, (timer) {
//       tomZ -= 0.02;

//       if (tomZ < -3.0) tomZ = -1.5;

//       // Re-add node at new position
//       _addTom(tomZ);
//     });
//   }

//   @override
//   void dispose() {
//     arCoreController.dispose();
//     super.dispose();
//   }
// }

