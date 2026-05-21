# 🏎️ AeroLab

**Interactive F1 Aerodynamics Education Playground**

[![Swift Student Challenge 2026](https://img.shields.io/badge/SSC-Distinguished%20Winner%202026-blue.svg)](https://developer.apple.com/swift-student-challenge/)
[![Platform](https://img.shields.io/badge/platform-iPadOS%2017.0%2B-lightgrey.svg)](https://www.apple.com/ipados/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-All%20Rights%20Reserved-red.svg)](#license)

---

## 🏆 Swift Student Challenge 2026 Distinguished Winner

AeroLab was recognized by Apple as a **Swift Student Challenge 2026 Distinguished Winner** — one of the top student-developed apps globally, selected from thousands of submissions.

---

## 📱 About AeroLab

AeroLab is an interactive iPad playground that transforms complex Formula 1 aerodynamics into hands-on, real-time experiments. Built for visual learners, it makes abstract physics concepts tangible and accessible.

### The Problem

65% of students are visual learners, yet traditional STEM education relies heavily on text-heavy textbooks and abstract formulas. Students who could excel in engineering fields struggle not because they lack ability, but because teaching methods don't match how they naturally learn.

### The Solution

AeroLab bridges this gap by transforming aerodynamics education into an interactive experience where:
- Students manipulate 3D F1 car models in real-time
- Physics calculations update instantly as parameters change
- Live charts visualize the relationships between variables
- Color-coded feedback provides immediate understanding
- Gamified challenges reinforce learning through consequence and reward

---

## ✨ Features

### 🎮 Interactive Learning Modules

#### Ground Effect Lab
- Real-time 3D F1 car visualization
- Interactive sliders for ride height (10-50mm) and velocity (20-100 m/s)
- Live downforce calculations using real aerodynamic formulas
- Dynamic pressure zone visualizations
- Instant stall warnings with visual feedback
- Animated streamlines showing airflow patterns

#### Educational Content
- Dual-panel layout: experimentation (left) + theory (right)
- Live Swift Charts showing downforce curves
- Real-world F1 engineering examples
- Formula breakdowns with visual explanations
- Integrated glossary for quick definitions

### 🎨 Design Philosophy

Built with Apple's Human Interface Guidelines at its core:
- **Native iOS design language** - feels at home on iPad
- **Clean, minimal interface** - purposeful, not cluttered
- **Thoughtful spacing and typography** - using SF Pro and SF Symbols
- **Dark mode optimized** - reduces eye strain for extended learning
- **Accessibility-first** - large touch targets, color-coded feedback, multiple sensory inputs

---

## 🛠️ Technical Stack

### Core Technologies
- **SwiftUI** - Declarative UI framework for modern, responsive interfaces
- **SceneKit** - 3D rendering engine for F1 car model visualization
- **Swift Charts** - Real-time data visualization and live graph updates
- **Core Animation** - Smooth airflow streamlines and pressure zone effects
- **Core Haptics** - Tactile feedback for immersive learning experience
- **AVFoundation** - Procedural sound synthesis (future feature)

### Architecture
- **MVVM Pattern** - Clean separation of concerns
- **Custom Physics Engine** - Implements real aerodynamic formulas
- **Reactive State Management** - @State, @Binding for real-time UI updates
- **Modular Design** - Reusable components and views

### Physics Implementation
```swift
// Real aerodynamic formula implementation
F = ½ * ρ * v² * CL * A

Where:
- ρ = air density (1.225 kg/m³)
- v = velocity (m/s)
- CL = lift coefficient (varies with ride height)
- A = frontal area (1.5 m²)
```

---

## 🎯 Target Users

### Primary Audience
- **Visual learners** struggling with traditional physics education
- **Aspiring motorsport engineers** (ages 12-18)
- **STEM students** seeking interactive learning tools
- **Educators** demonstrating aerodynamics concepts

### Educational Impact
- Makes complex physics accessible through visualization
- Reduces cognitive load through clean, purposeful design
- Encourages experimentation over memorization
- Bridges theory and real-world application

---

## 📸 Screenshots

### Learning Path
<img width="1180" height="820" alt="LEARNING_PATH" src="https://github.com/user-attachments/assets/6ca11580-c403-4242-a5fd-e9b41de4b9c8" />

*Modular structure with 5 interactive learning modules*

### Ground Effect Lab
<img width="1180" height="820" alt="GROUND_EFFECT" src="https://github.com/user-attachments/assets/91fedacc-aaf3-4e46-b03e-99ad59c66606" />


*Dual-panel layout: 3D experimentation (left) + educational content (right)*

### Live Physics Visualization

*Real-time chart updates as students adjust parameters*

---

## 🚀 Getting Started

### Requirements
- macOS 14.0+ with Xcode 15.0+
- iPad running iPadOS 17.0+ (for deployment)
- Swift 5.9+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/AeroLab.git
cd AeroLab
```

2. Open in Xcode:
```bash
open AeroLab.swiftpm
```

3. Build and run:
- Select iPad simulator or connected iPad device
- Press `Cmd + R` to build and run
- Recommended: iPad Pro 12.9" or iPad Air for optimal experience

### Project Structure
AeroLab.swiftpm/
├── MyApp.swift                 # App entry point
├── ContentView.swift            # Main navigation
├── Views/
│   ├── WelcomeView.swift       # Landing screen
│   ├── LearningPathView.swift  # Module selection
│   └── GroundEffectView.swift  # Main interactive module
├── Components/
│   ├── SharedComponents.swift  # Reusable UI elements
│   └── UIComponents.swift      # Custom controls
├── Models/
│   └── AeroPhysicsEngine.swift # Physics calculations
└── Resources/
└── Car.usdc                # 3D car model

---

## 💡 Design Decisions

### Why iPad-Only?
The dual-panel educational experience requires screen real estate to show 3D models, interactive controls, theory content, and live charts simultaneously without cognitive overload.

### Why Dark Mode?
Designed specifically for extended learning sessions with young users. Dark backgrounds with cyan accents reduce eye strain while maintaining high contrast for readability.

### Why Native iOS Design?
Respecting platform conventions ensures the app feels familiar and intuitive. Students focus on learning physics, not learning the interface.

### Why SceneKit vs RealityKit?
SceneKit provided more accessible documentation for educational 3D rendering. The goal was teaching aerodynamics, not showcasing cutting-edge AR (though future versions may explore this).

---

## 🎓 Educational Philosophy

AeroLab is built on three core principles:

### 1. Learning Through Discovery
Students experiment freely with parameters and discover relationships themselves rather than being told what to think.

### 2. Immediate Feedback
Real-time visual, numerical, and graphical feedback creates tight learning loops. Students see cause and effect instantly.

### 3. Multiple Representations
Concepts are presented through 3D models, numerical values, charts, diagrams, and text—supporting different learning styles simultaneously.

---

## 🌟 Awards & Recognition

- 🏆 **Swift Student Challenge 2026 Distinguished Winner**
- 🍎 **Featured by Apple** in SSC 2026 showcase
- 🎓 **Invited to WWDC 2026** in California
- 📰 **Press coverage** from [media outlets]

---

## 👥 About the Developer

**Shloka Shetty** is a third-year student at MIT World Peace University, Pune, India, with a dual passion for art and technology. She leads iOS development workshops, mentors female developers, and advocates for design-first thinking in app development.

AeroLab was inspired by her 13-year-old brother Sharan, who dreams of becoming an F1 race engineer but struggled with traditional physics textbooks. As a visual learner herself, Shloka understands the power of well-crafted interfaces in making complex concepts accessible.

### Connect
- 📧 Email: shloka.shetty@mitwpu.edu.in
- 💼 LinkedIn: https://www.linkedin.com/in/shloka-g-shetty/
- 🐙 GitHub: https://github.com/sagusoky

---

## 🙏 Acknowledgments

AeroLab wouldn't exist without incredible support:

- **Sharan** - My inspiration and most honest tester
- **My Parents** - For believing education should be engaging, not exhausting
- **MIT-WPU iOS Development Community** - 40+ classmates who tested and refined every iteration
- **STEM Friends** - Who validated physics accuracy and educational effectiveness
- **Swift Student Challenge Community** - Previous winners who generously shared guidance
- **Apple** - For creating tools that empower students to build meaningful projects

---

## 📋 Future Roadmap

### Planned Features
- [ ] Wing Angle Lab - Explore lift vs drag tradeoffs
- [ ] Aerodynamic Balance - Understand center of pressure
- [ ] Perfect Lap Challenge - Gamified circuit with setup optimization
- [ ] Track Terminology - Learn racing line, apex, braking zones
- [ ] Multi-language support - Make accessible globally
- [ ] Teacher dashboard - Track student progress and understanding

### Technical Improvements
- [ ] RealityKit integration for enhanced 3D rendering
- [ ] ARKit support for spatial circuit placement
- [ ] Vision framework for gesture-based controls
- [ ] CoreML model for exercise recognition (future interactive features)
- [ ] iCloud sync for cross-device progress

---

## 🐛 Known Issues

- Swift Playgrounds may require rebuild before proper initialization
- Animation timing differs slightly between Xcode and Swift Playgrounds
- iPad Pro M4 landscape camera position requires rotation unlock

*These are platform quirks, not app bugs. Workarounds documented in code comments.*

---

## 📄 License

**Copyright © 2026 Shloka Shetty. All Rights Reserved.**

This project and all associated files are protected by copyright. No part of this software may be reproduced, distributed, or transmitted in any form or by any means, including photocopying, recording, or other electronic or mechanical methods, without prior written permission from the author.

See [LICENSE.md](LICENSE.md) for full terms.

**Note:** This project was created as an educational submission for Apple's Swift Student Challenge 2026. While the code is visible for educational reference and portfolio purposes, it may not be copied, modified, or redistributed without explicit written permission.

---

## 📞 Contact & Support

For press inquiries, collaboration opportunities, or educational licensing:
- 📧 Email: shloka.shetty@mitwpu.edu.in
- 💼 LinkedIn: https://www.linkedin.com/in/shloka-g-shetty/

For technical questions about the codebase (educational purposes only):
- Open an issue in this repository (viewing only, no contributions accepted)

---

## 🎨 Credits

### 3D Model
- F1 Car Model: Modified from [Gumroad source] under Creative Commons license
- Extensive modifications made for educational use
- All other 3D work, textures, and positioning: Original

### Design Tools
- UI/UX Design: Figma
- 3D Model Preparation: Reality Composer Pro
- Icon Design: SF Symbols (Apple)

### Technologies
- Built with Swift 5.9 and SwiftUI
- Powered by Apple's native frameworks
- Developed in Xcode 15.0+

---

<p align="center">
  <strong>Built with 💙 for visual learners everywhere</strong><br>
  <em>For Sharan, and every student who learns by seeing</em>
</p>

<p align="center">
  <sub>Swift Student Challenge 2026 Distinguished Winner</sub><br>
  <sub>© 2026 Shloka Shetty. All Rights Reserved.</sub>
</p>
