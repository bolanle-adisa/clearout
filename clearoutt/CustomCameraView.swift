//
//  CustomCameraView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 2/1/24.
//

import SwiftUI
import AVFoundation

struct CustomCameraView: View {
    @Binding var image: Image?
    @Binding var inputImage: UIImage?
    @Binding var showingConfirmationView: Bool
    @State private var showPhotoLibrary = false
    @Environment(\.presentationMode) var presentationMode

    let cameraController = CameraController()

    var body: some View {
        ZStack {
            CameraPreview(cameraController: cameraController)

            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .padding()
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {
                        self.showingConfirmationView = true // Show photo library or picker here if needed
                    }) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.title)
                            .padding()
                            .foregroundColor(.white)
                    }
                }
                Spacer()
                HStack {
                    Button(action: {
                        cameraController.switchCamera()
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.title)
                            .padding()
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {
                        cameraController.takePhoto { uiImage in
                            if let uiImage = uiImage {
                                self.inputImage = uiImage
                                self.showingConfirmationView = true // Trigger review step here
                            }
                        }
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            cameraController.setup()
        }
        .onDisappear {
            cameraController.tearDown()
        }
    
        .sheet(isPresented: $showPhotoLibrary) {
            ImagePickerView(image: $image, inputImage: $inputImage, sourceType: .photoLibrary)
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraController: CameraController
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        cameraController.previewLayer.frame = view.bounds
        view.layer.addSublayer(cameraController.previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

class CameraController: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    private var captureSession: AVCaptureSession?
    private var frontCamera: AVCaptureDevice?
    private var rearCamera: AVCaptureDevice?
    private var currentCameraPosition: CameraPosition?
    private var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer

    override init() {
        let session = AVCaptureSession()
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        super.init()
        self.captureSession = session
        self.previewLayer.videoGravity = .resizeAspectFill
    }
    
    func checkCameraAuthorization(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                completion(true) // Already authorized
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
            case .denied, .restricted:
                completion(false) // User has denied or cannot grant access
            @unknown default:
                completion(false) // Handle any future cases
        }
    }
    
    func setup() {
        checkCameraAuthorization { [weak self] authorized in
            guard let self = self, authorized else {
                print("Camera access was denied or restricted.")
                return
            }
            
            // This must be done on the main thread because AVCaptureSession setup alters the UI layout.
            DispatchQueue.main.async {
                self.configureCaptureSession()
            }
        }
    }
    
    func configureCaptureSession() {
        guard let captureSession = captureSession else { return }
        
        captureSession.beginConfiguration()
        
        // Setup devices
        let videoDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                            mediaType: .video,
                                                            position: .unspecified).devices
        
        guard !videoDevices.isEmpty else {
            print("No cameras on the device or you are running on the Simulator (which isn't supported)")
            return
        }
        
        frontCamera = videoDevices.first(where: { $0.position == .front })
        rearCamera = videoDevices.first(where: { $0.position == .back })
        
        // Set the initial camera position
        currentCameraPosition = .rear
        
        // Add rear camera input
        if let rearCamera = rearCamera, let rearCameraInput = try? AVCaptureDeviceInput(device: rearCamera),
           captureSession.canAddInput(rearCameraInput) {
            captureSession.addInput(rearCameraInput)
        }
        
        // Setup photo output
        let photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            self.photoOutput = photoOutput
        }
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    func tearDown() {
        captureSession?.stopRunning()
        for input in captureSession?.inputs ?? [] {
            captureSession?.removeInput(input)
        }
        for output in captureSession?.outputs ?? [] {
            captureSession?.removeOutput(output)
        }
    }
    
    func switchCamera() {
        guard let captureSession = captureSession, let currentCameraPosition = currentCameraPosition else { return }
        
        captureSession.beginConfiguration()
        
        func switchToCamera(position: AVCaptureDevice.Position) {
            let newDevice = (position == .back) ? rearCamera : frontCamera
            for input in captureSession.inputs {
                captureSession.removeInput(input)
            }
            
            if let newDevice = newDevice {
                do {
                    let newInput = try AVCaptureDeviceInput(device: newDevice)
                    if captureSession.canAddInput(newInput) {
                        captureSession.addInput(newInput)
                        self.currentCameraPosition = position == .back ? .rear : .front
                    }
                } catch let error {
                    print("Error switching to \(position == .back ? "rear" : "front") camera: \(error)")
                }
            }
        }
        
        switchToCamera(position: currentCameraPosition == .rear ? .front : .back)
        
        captureSession.commitConfiguration()
    }
    
    func takePhoto(completion: @escaping (UIImage?) -> Void) {
        guard let photoOutput = self.photoOutput else { return }
        
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        
        self.photoCaptureCompletionBlock = completion
    }
    
    private var photoCaptureCompletionBlock: ((UIImage?) -> Void)?
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            self.photoCaptureCompletionBlock?(nil)
        } else if let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) {
            self.photoCaptureCompletionBlock?(image)
        } else {
            print("Error capturing photo: No image data found.")
            self.photoCaptureCompletionBlock?(nil)
        }
    }
    
    enum CameraPosition {
        case front
        case rear
    }
    
    
}

struct CustomCameraView_Previews: PreviewProvider {
    @State static var image: Image? = nil
    @State static var inputImage: UIImage? = nil
    @State static var showingConfirmationView = false

    static var previews: some View {
        CustomCameraView(image: $image, inputImage: $inputImage, showingConfirmationView: $showingConfirmationView)
    }
}
