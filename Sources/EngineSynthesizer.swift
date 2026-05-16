import AVFoundation

/// Synthesizes a dynamic F1 engine sound in real-time using AVAudioEngine and AVAudioSourceNode.
final class EngineSynthesizer {
    static let shared = EngineSynthesizer()
    
    private let audioEngine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    
    // Core parameters (read/written across threads)
    private var targetFrequency: Float = 150.0
    private var targetVolume: Float = 0.0
    
    // Core audio thread variables
    private var currentFreq: Float = 150.0
    private var currentVol: Float = 0.0
    
    // Phase accumulators for stable synthesis (prevents precision loss)
    private var mainPhase: Float = 0.0
    private var subPhase: Float = 0.0
    private var throbPhase: Float = 0.0
    
    private init() {
        setupEngine()
    }
    
    private func setupEngine() {
        let format = audioEngine.outputNode.inputFormat(forBus: 0)
        let sampleRate = Float(format.sampleRate > 0 ? format.sampleRate : 44100.0)
        
        sourceNode = AVAudioSourceNode { [unowned self] _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            
            // Note: capturing `self` without ARC safety in a render thread is a slight risk, 
            // but `unowned` is fine for this singleton pattern.
            
            let tVol = self.targetVolume
            let tFreq = self.targetFrequency
            
            // Interpolate smoothly
            self.currentFreq += (tFreq - self.currentFreq) * 0.02
            self.currentVol += (tVol - self.currentVol) * 0.05
            
            let cFreq = self.currentFreq
            let cVol = self.currentVol
            let dt = 1.0 / sampleRate
            
            for frame in 0..<Int(frameCount) {
                // A V6 engine fires 3 times per revolution. 
                // We use cFreq as the firing frequency, and revFreq as the physical revolution.
                let revFreq = cFreq / 3.0
                
                // Accumulate phases
                self.mainPhase += cFreq * dt
                if self.mainPhase > 1.0 { self.mainPhase -= 1.0 }
                
                self.subPhase += (cFreq * 0.5) * dt
                if self.subPhase > 1.0 { self.subPhase -= 1.0 }
                
                self.throbPhase += revFreq * dt
                if self.throbPhase > 1.0 { self.throbPhase -= 1.0 }
                
                // Sawtooth waves (-1 to 1) for a harsh, geometric exhaust tone
                let saw = 2.0 * self.mainPhase - 1.0
                let subSaw = 2.0 * self.subPhase - 1.0
                
                // Amplitude modulation: the engine physically "throbs" once per revolution
                let throb = (sin(2.0 * .pi * self.throbPhase) + 1.0) * 0.5 // 0 to 1
                
                // Minimal noise just to add some air rush (not static)
                let noise = Float.random(in: -1...1) * 0.03
                
                // Combine: main exhaust note + sub octave for body + engine throb pulse
                var sample = (saw * (0.5 + 0.4 * throb) + subSaw * 0.35 + noise) * cVol
                
                // Soft clipping (Saturation) to mimic exhaust overload
                // Using x / (1 + |x|) gives a thick, overdrive sound without snapping audio
                sample = sample * 3.0
                sample = sample / (1.0 + abs(sample))
                
                // Fill buffer for all channels
                for buffer in ablPointer {
                    if let ptr = buffer.mData?.assumingMemoryBound(to: Float.self) {
                        ptr[frame] = sample
                    }
                }
            }
            return noErr
        }
        
        guard let sourceNode = sourceNode else { return }
        
        audioEngine.attach(sourceNode)
        audioEngine.connect(sourceNode, to: audioEngine.mainMixerNode, format: format)
        
        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            #endif
            
            try audioEngine.start()
            self.targetVolume = 0.0
            self.currentVol = 0.0
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    // MARK: - Core Controls
    
    func startEngine() {
        targetVolume = 0.4 // Set base volume
        targetFrequency = 120.0 // Deeper idle
    }
    
    func stopEngine() {
        targetVolume = 0.0
    }
    
    func updateSpeed(_ speedKmh: Double) {
        let normalizedSpeed = max(0, min(1.0, Float(speedKmh) / 350.0))
        targetFrequency = 120.0 + (normalizedSpeed * 280.0) // 120Hz up to 400Hz (high scream)
        targetVolume = 0.4 + (normalizedSpeed * 0.3) // Gets louder at speed
    }
}

