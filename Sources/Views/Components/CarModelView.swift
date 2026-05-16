import SwiftUI
import SceneKit
#if os(iOS)
import UIKit
#endif

enum CarDisplayMode {
    case groundEffect
    case wingAngle
    case aeroBalance
}

struct CarModelParameters {
    var mode: CarDisplayMode
    var rideHeight: Double = 25
    var downforce: Double = 0
    var drag: Double = 0
    var isStalled: Bool = false
    var frontWingAngle: Double = 0
    var rearWingAngle: Double = 0
    var copPosition: Double = 0
    var frontDownforce: Double = 0
    var rearDownforce: Double = 0
}

#if os(iOS)
struct CarModelView: View {

    var parameters: CarModelParameters
    @State private var streamPhase: CGFloat = 0
    
    init(mode: CarDisplayMode,
         rideHeight: Double = 25,
         downforce: Double = 0,
         drag: Double = 0,
         isStalled: Bool = false,
         frontWingAngle: Double = 0,
         rearWingAngle: Double = 0,
         copPosition: Double = 0,
         frontDownforce: Double = 0,
         rearDownforce: Double = 0) {
        self.parameters = CarModelParameters(
            mode: mode,
            rideHeight: rideHeight, downforce: downforce, drag: drag, isStalled: isStalled,
            frontWingAngle: frontWingAngle, rearWingAngle: rearWingAngle,
            copPosition: copPosition, frontDownforce: frontDownforce, rearDownforce: rearDownforce
        )
    }
    
    var body: some View {
        ZStack {
            SceneKitView(parameters: parameters)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
            CFDStreamlinesView(phase: streamPhase, parameters: parameters)
                .allowsHitTesting(false)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Downforce badge — ground effect & wing angle
            if parameters.mode == .groundEffect || parameters.mode == .wingAngle {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 2) {
                            Image(systemName: "arrow.down")
                                .font(Theme.Fonts.bodySemibold())
                                .foregroundColor(parameters.isStalled ? Theme.Colors.dataRed : Theme.Colors.dataGreen)
                            Text("\(Int(parameters.downforce)) N")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(parameters.isStalled ? Theme.Colors.dataRed : Theme.Colors.dataGreen)
                        }
                        .padding(6)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.6)))
                        .padding(8)
                    }
                }
            }
            
            // CoM / CoP legend — aero balance
            if parameters.mode == .aeroBalance {
                VStack {
                    HStack(spacing: 12) {
                        // CoM pill
                        HStack(spacing: 5) {
                            Circle().fill(Color.white)
                                .frame(width: 8, height: 8)
                            Text("CoM")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.65)))
                        
                        // CoP pill
                        HStack(spacing: 5) {
                            Circle().fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("CoP")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.65)))
                        
                        Spacer()
                    }
                    .padding(10)
                    Spacer()
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                streamPhase = .pi * 2
            }
        }
    }
}

struct SceneKitView: UIViewRepresentable {
    var parameters: CarModelParameters
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = UIColor(Theme.Colors.surfaceDark)
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = .multisampling4X
        
        let scene = SCNScene()
        
        let carNode = SCNNode()
        if let modelURL = Bundle.main.url(forResource: "f1_car", withExtension: "usdz") {
            do {
                let modelScene = try SCNScene(url: modelURL, options: [.checkConsistency: true])
                for child in modelScene.rootNode.childNodes {
                    carNode.addChildNode(child)
                }
                // Keep original material — do NOT override the blue livery
            } catch {
                let box = SCNBox(width: 1.5, height: 0.4, length: 4, chamferRadius: 0.1)
                box.firstMaterial?.diffuse.contents = UIColor.systemRed
                carNode.geometry = box
            }
        }
        
        // Fix model orientation so the car sits with wheels on the ground,
        // side profile facing the camera.
        carNode.eulerAngles = SCNVector3(Float.pi, 0, 0)
        
        // Scale up for better visibility
        carNode.scale = SCNVector3(1.8, 1.8, 1.8)
        
        // Raise car so it sits ON the ground, not submerged through it.
        // The model center is at origin; after scaling 1.8x we need to lift it
        // so the wheels touch Y=0.
        carNode.position.y = 0.7
        
        // --- Add Physics Field for Turbulence ---
        // Creates more organic, curving lines around the chassis
        let vortex = SCNPhysicsField.vortex()
        vortex.strength = 1.5
        vortex.categoryBitMask = 1
        let vortexNode = SCNNode()
        vortexNode.physicsField = vortex
        vortexNode.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(vortexNode)
        
        // Add a bit of noise for randomness
        let noise = SCNPhysicsField.noiseField(smoothness: 0.5, animationSpeed: 1.0)
        noise.strength = 0.4
        noise.categoryBitMask = 1
        let noiseNode = SCNNode()
        noiseNode.physicsField = noise
        scene.rootNode.addChildNode(noiseNode)
        
        scene.rootNode.addChildNode(carNode)
        
        // Ground plane — dark, NO reflection (removes mirror effect)
        let ground = SCNFloor()
        ground.reflectivity = 0
        ground.firstMaterial?.diffuse.contents = UIColor(white: 0.06, alpha: 1.0)
        let groundNode = SCNNode(geometry: ground)
        scene.rootNode.addChildNode(groundNode)
        
        let camera = SCNCamera()
        camera.fieldOfView = 30
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        scene.rootNode.addChildNode(cameraNode)
        
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor(white: 0.5, alpha: 1.0)
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        
        let dirLight = SCNLight()
        dirLight.type = .directional
        dirLight.color = UIColor(white: 0.8, alpha: 1.0)
        dirLight.castsShadow = true
        dirLight.shadowRadius = 4
        dirLight.shadowSampleCount = 8
        let dirNode = SCNNode()
        dirNode.light = dirLight
        dirNode.position = SCNVector3(x: 5, y: 10, z: 5)
        dirNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(dirNode)
        
        // Setup Forces/Arrows container
        let forcesNode = SCNNode()
        scene.rootNode.addChildNode(forcesNode)
        
        scnView.scene = scene
        scnView.pointOfView = cameraNode
        
        context.coordinator.carNode = carNode
        context.coordinator.cameraNode = cameraNode
        context.coordinator.forcesNode = forcesNode
        
        setupCamera(for: parameters.mode, in: context.coordinator)
        
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        let coord = context.coordinator
        let carZSize: Float = 4.0 // approximate length of F1 car if 0 is center
        
        // Ground Effect visualization
        if parameters.mode == .groundEffect {
            let baseY: Float = 0.7
            let offset = Float((parameters.rideHeight - 10) / 40.0) * 0.06
            coord.carNode?.position.y = baseY + offset
            coord.forcesNode?.childNodes.forEach { $0.removeFromParentNode() }
            
            // Downforce arrow under floor scaled to force magnitude
            let dfNorm = Float(max(0, parameters.downforce) / 8000.0)
            if dfNorm > 0.03 {
                let dfArrow = createArrow(color: UIColor.systemGreen)
                dfArrow.scale = SCNVector3(dfNorm * 0.8, dfNorm * 0.8, dfNorm * 0.8)
                dfArrow.eulerAngles.z = Float.pi // pointing down
                dfArrow.position = SCNVector3(0, 0.3, 0)
                coord.forcesNode?.addChildNode(dfArrow)
            }
        }
        
        // Wing Angle visualization
        if parameters.mode == .wingAngle {
            coord.forcesNode?.childNodes.forEach { $0.removeFromParentNode() }
            
            let rearWingZ: Float = -1.8
            let rearWingY: Float = 1.2
            
            // Downforce arrow — green, pointing down, scaled to magnitude
            let dfNorm = Float(max(0, parameters.downforce) / 5000.0)
            if dfNorm > 0.05 {
                let dfArrow = createArrow(color: UIColor.systemGreen)
                dfArrow.scale = SCNVector3(dfNorm, dfNorm, dfNorm)
                dfArrow.eulerAngles.z = Float.pi
                dfArrow.position = SCNVector3(0, rearWingY, rearWingZ)
                coord.forcesNode?.addChildNode(dfArrow)
            }
            
            // Drag arrow — orange, pointing backward
            let dragNorm = Float(max(0, parameters.drag) / 2000.0)
            if dragNorm > 0.05 {
                let dragArrow = createArrow(color: UIColor.systemOrange)
                dragArrow.scale = SCNVector3(dragNorm * 0.7, dragNorm * 0.7, dragNorm * 0.7)
                dragArrow.eulerAngles.x = Float.pi / 2
                dragArrow.position = SCNVector3(0, rearWingY, rearWingZ)
                coord.forcesNode?.addChildNode(dragArrow)
            }
        }
        
        if parameters.mode == .aeroBalance {
            coord.forcesNode?.childNodes.forEach { $0.removeFromParentNode() }
            
            let comZ = Float(0.5)
            let copZ = Float(parameters.copPosition * 2.0)
            
            // Marker for CoM — white sphere
            let comSphere = SCNSphere(radius: 0.1)
            comSphere.firstMaterial?.diffuse.contents = UIColor.white
            let comNode = SCNNode(geometry: comSphere)
            comNode.position = SCNVector3(0, 0.6, comZ)
            coord.forcesNode?.addChildNode(comNode)
            
            // Marker for CoP — green sphere
            let copSphere = SCNSphere(radius: 0.12)
            copSphere.firstMaterial?.diffuse.contents = UIColor.systemGreen
            let copNode = SCNNode(geometry: copSphere)
            copNode.position = SCNVector3(0, 0.6, copZ)
            coord.forcesNode?.addChildNode(copNode)
            
            // Thin line connecting CoM ↔ CoP
            let dist = abs(comZ - copZ)
            if dist > 0.01 {
                let lineGeo = SCNCylinder(radius: 0.018, height: CGFloat(dist))
                lineGeo.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
                let lineNode = SCNNode(geometry: lineGeo)
                lineNode.eulerAngles.x = Float.pi / 2
                lineNode.position = SCNVector3(0, 0.6, (comZ + copZ) / 2)
                coord.forcesNode?.addChildNode(lineNode)
            }
        }
    }
    
    private func setupCamera(for mode: CarDisplayMode, in coord: Coordinator) {
        guard let cameraNode = coord.cameraNode else { return }
        switch mode {
        case .groundEffect:
            // Perfect side profile — like the Ferrari reference photo
            // Camera level with the car, directly to the side, slightly above wheel height
            cameraNode.position = SCNVector3(x: 0, y: 0.8, z: 8)
            cameraNode.look(at: SCNVector3(0, 0.3, 0))
        case .wingAngle:
            // Rear-quarter angle to focus on wing
            cameraNode.position = SCNVector3(x: 2, y: 1.5, z: -6)
            cameraNode.look(at: SCNVector3(0, 0.5, 0))
        case .aeroBalance:
            // High three-quarter view
            cameraNode.position = SCNVector3(x: 3, y: 6, z: 5)
            cameraNode.look(at: SCNVector3(0, 0, 0))
        }
    }
    
    private func createArrow(color: UIColor) -> SCNNode {
        let node = SCNNode()
        let cyl = SCNCylinder(radius: 0.04, height: 1.0)
        cyl.firstMaterial?.diffuse.contents = color
        let shaft = SCNNode(geometry: cyl)
        shaft.position = SCNVector3(0, 0.5, 0)
        node.addChildNode(shaft)
        
        let cone = SCNCone(topRadius: 0, bottomRadius: 0.1, height: 0.25)
        cone.firstMaterial?.diffuse.contents = color
        let head = SCNNode(geometry: cone)
        head.position = SCNVector3(0, 1.125, 0)
        node.addChildNode(head)
        
        return node
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var carNode: SCNNode?
        var cameraNode: SCNNode?
        var forcesNode: SCNNode?
        // Removed spotlight references — no longer used
    }
}

// Helpers for CFD generation
private func createWindParticleImage() -> UIImage {
    let size = CGSize(width: 16, height: 16)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    let context = UIGraphicsGetCurrentContext()!
    let colors = [UIColor.white.withAlphaComponent(0.8).cgColor, UIColor.clear.cgColor] as CFArray
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0])!
    let center = CGPoint(x: 8, y: 8)
    context.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: 8, options: [])
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
}

private func applyCFDMatteMaterial(to node: SCNNode) {
    if let geometry = node.geometry {
        for material in geometry.materials {
            material.diffuse.contents = UIColor(white: 0.8, alpha: 1.0)
            material.specular.contents = UIColor(white: 0.1, alpha: 1.0)
            material.emission.contents = UIColor.black
            material.reflective.contents = UIColor.black
            material.lightingModel = .lambert
        }
    }
    for child in node.childNodes {
        applyCFDMatteMaterial(to: child)
    }
}

#else
// Fallback for macOS
struct CarModelView: View {
    var parameters: CarModelParameters
    
    init(mode: CarDisplayMode,
         rideHeight: Double = 25,
         downforce: Double = 0,
         drag: Double = 0,
         isStalled: Bool = false,
         frontWingAngle: Double = 0,
         rearWingAngle: Double = 0,
         copPosition: Double = 0,
         frontDownforce: Double = 0,
         rearDownforce: Double = 0) {
        self.parameters = CarModelParameters(
            mode: mode,
            rideHeight: rideHeight, downforce: downforce, drag: drag, isStalled: isStalled,
            frontWingAngle: frontWingAngle, rearWingAngle: rearWingAngle,
            copPosition: copPosition, frontDownforce: frontDownforce, rearDownforce: rearDownforce
        )
    }
    
    var body: some View {
        Text("3D Car Model requires iOS Simulator")
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.3))
            .cornerRadius(8)
    }
}
#endif

// MARK: - Animated CFD Streamlines Over Car
struct CFDStreamlinesView: View {
    var phase: CGFloat
    var parameters: CarModelParameters
    
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let midY = h * 0.55
            
            // Calculate dynamic turbulence based on parameters
            // Wing Angle adds turbulence to the top/middle lines
            let wingTurbulence = CGFloat(parameters.frontWingAngle + parameters.rearWingAngle) / 20.0 
            
            for i in 0..<8 {
                var streamPath = Path()
                // Stagger lines vertically
                let yOffset = (CGFloat(i) - 3.5) * (h * 0.08)
                
                // Base amplitude
                var amplitude: CGFloat = (i == 3 || i == 4) ? h * 0.15 : h * 0.05 
                
                // Top lines (i < 3) get disturbed by wing angle
                if i < 3 {
                    amplitude += wingTurbulence * h * 0.08
                }
                
                // Bottom lines (i > 5) get disturbed by ride height/stall
                if i > 5 {
                    if parameters.isStalled {
                        amplitude += h * 0.15
                    } else if parameters.rideHeight < 20 {
                        amplitude += h * 0.05 // increased suction under car
                    }
                }
                
                let frequency: CGFloat = parameters.isStalled ? 8 : 4
                let waveSpeed = phase * (parameters.isStalled ? 2.0 : 1.0)
                
                streamPath.move(to: CGPoint(x: -50, y: midY + yOffset))
                
                for x in stride(from: -50, to: w + 50, by: 10) {
                    let normalizedX = x / w
                    let disturbance = sin(normalizedX * .pi) * amplitude
                    
                    let isDisturbedBottom = parameters.isStalled && i > 4 && normalizedX > 0.4
                    let waveSize: CGFloat = isDisturbedBottom ? 30.0 : 10.0
                    
                    let waveAngle = normalizedX * .pi * frequency - waveSpeed + CGFloat(i) * 0.5
                    let wave = sin(waveAngle) * waveSize
                    
                    let finalY = midY + yOffset - disturbance + wave
                    streamPath.addLine(to: CGPoint(x: x, y: finalY))
                }
                
                let color: Color
                if i < 3 {
                    color = Theme.Colors.accentBlue
                } else if i > 5 {
                    color = parameters.isStalled ? Theme.Colors.dataRed : Theme.Colors.moduleGreen
                } else {
                    color = Theme.Colors.moduleYellow
                }
                
                let opacityValue = parameters.isStalled ? 0.6 : 0.35
                
                context.stroke(
                    streamPath,
                    with: .color(color.opacity(opacityValue)),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )
            }
        }
    }
}
