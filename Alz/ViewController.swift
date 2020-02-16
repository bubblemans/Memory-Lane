//
//  ViewController.swift
//  Alz
//
//  Created by Alvin Lin on 2/14/20.
//  Copyright © 2020 Alvin Lin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision
import RxSwift
import Async
import HoundifySDK

class ViewController: UIViewController, ARSCNViewDelegate, HoundVoiceSearchQueryDelegate {
    private var query: HoundVoiceSearchQuery?
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var menuBar: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var listeningButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    let node = SCNNode()
    let textView = UITextView()
    let remindLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
   
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var medImage: UIImageView!
    
    @IBAction func swipeMenu(_ sender: UIPanGestureRecognizer) {
        node.scale = SCNVector3(0, 0, 0)
        if sender.state == .began || sender.state == .changed {

            let translation = sender.translation(in: self.view).x
            // swipe right
            if translation > 0{
                // swipe to the certain position
                if menuBar.frame.minX < 0{
                    UIView.animate(withDuration: 0.2, animations: {
                        self.menuBar.frame.origin.x += translation / 5
                        self.view.layoutIfNeeded()
                    })
                }
            }

            // swipe left
            else{
                // swipe to the certain position
                if menuBar.frame.minX > -333{
                    UIView.animate(withDuration: 0.2, animations: {
                        self.menuBar.frame.origin.x += translation / 5
                        self.view.layoutIfNeeded()
                    })
                }
            }
        }

        // when the user is done with swiping
        else if sender.state == .ended{
            print("end")
            // When the user swipe to left, make it to be swiped to the very left even though it's not be swiped enough.
            if menuBar.frame.minX < -100{
                UIView.animate(withDuration: 0.2, animations: {
                    self.menuBar.frame.origin.x = -333
                    self.view.layoutIfNeeded()
                })
            }

            // When the user swipe to right, make it to be swiped to clip to the margin even though it's not be swiped enough.
            else{
                UIView.animate(withDuration: 0.2, animations: {
                    self.menuBar.frame.origin.x = 0
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    let model: VNCoreMLModel = try! VNCoreMLModel(for: advanced().model)
    var bounds: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var faces: [Face] = []
    var 👜 = DisposeBag()
    var db = DBInterface()
    var voiceInterface = VoiceInterface()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // hard code to get the contact info first
        
        db.retrieveContactInfo()
        voiceInterface.textToSpeech()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        searchButton.layer.cornerRadius = 10
//        searchButton.backgroundColor = .blue
        searchButton.setTitle("Speak", for: .normal)
        searchButton.setTitleColor(.white, for: .normal)
        
        listeningButton.layer.cornerRadius = 10
//        listeningButton.backgroundColor = .blue
        listeningButton.setTitle("Enable", for: .normal)
        listeningButton.setTitleColor(.white, for: .normal)
        
        
        let text = SCNText(string: "Click \"Enable\" first, and click \"Speak\" to speak", extrusionDepth: 1)
       let material = SCNMaterial()
       material.diffuse.contents = UIColor.orange
       text.materials = [material]
       text.flatness = 0
       text.font = .boldSystemFont(ofSize: 12)

       let width = Double(view.frame.width)
       let height = Double(view.frame.height)
       node.position = SCNVector3(-1, -1, -4)
       node.scale = SCNVector3(0.01, 0.01, 0.01)

       node.geometry = text

       sceneView.scene.rootNode.addChildNode(node)
       sceneView.automaticallyUpdatesLighting = true
        
        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        bounds = sceneView.bounds
        
        // menu initial position
        self.menuBar.frame.origin.x = -333
        self.menuBar.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        // menu buttons
        userImage.image = UIImage(named: "user")
        userImage.isUserInteractionEnabled = true
//        userImage.target(forAction: #selector(handleUser), withSender: self)
//        userImage.add
//        userButton.setTitle("User", for: .normal)
//        userButton.setTitleColor(.white, for: .normal)
//        userButton.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
//        userButton.layer.cornerRadius = 15

        medImage.image = UIImage(named: "drug")
        medImage.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        medImage.addGestureRecognizer(tapGestureRecognizer)
//        medButton.setTitle("Medicine", for: .normal)
//        medButton.setTitleColor(.white, for: .normal)
//        medButton.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
//        medButton.layer.cornerRadius = 15
        
        instructionLabel.textAlignment = .left
        instructionLabel.lineBreakMode = .byWordWrapping
        instructionLabel.numberOfLines = 0
        instructionLabel.text = """
        Instruction:
        First, click \"Enable\" first, and click \"Speak\"to speak
        say the name you see to find out more.
        ex: say \"Alvin\"
        """
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        // And some actions
        print("med")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
        
        Observable<Int>.interval(0.6, scheduler: SerialDispatchQueueScheduler(qos: .default))
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .concatMap{ _ in  self.faceObservation() }
            .flatMap{ Observable.from($0)}
            .flatMap{ self.faceClassification(face: $0.observation, image: $0.image, frame: $0.frame) }
            .subscribe { [unowned self] event in
                guard let element = event.element else {
                    print("No element available")
                    return
                }
                self.updateNode(classes: element.classes, position: element.position, frame: element.frame)
            }.disposed(by: 👜)
        
        
        Observable<Int>.interval(1.0, scheduler: SerialDispatchQueueScheduler(qos: .default))
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .subscribe { [unowned self] _ in
                
                self.faces.filter{ $0.updated.isAfter(seconds: 1.5) && !$0.hidden }.forEach{ face in
                    print("Hide node: \(face.name)")
                    Async.main { face.node.hide() }
                }
            }.disposed(by: 👜)
        
        NotificationCenter.default.addObserver(self, selector: #selector(listeningStateChanged(_:)), name: .HoundVoiceSearchDidBeginListening, object: nil)
               NotificationCenter.default.addObserver(self, selector: #selector(listeningStateChanged(_:)), name: .HoundVoiceSearchWillStopListening, object: nil)

               // Observe HoundVoiceSearchAudioLevel to visualize audio input
               NotificationCenter.default.addObserver(self, selector: #selector(audioLevel), name: .HoundVoiceSearchAudioLevel, object: nil)
               
               // Observe HoundVoiceSearchHotPhrase to be notified of when the hot phrase is detected.
               NotificationCenter.default.addObserver(self, selector: #selector(hotPhrase), name: .HoundVoiceSearchHotPhrase, object: nil)
    }
    
    private func refreshUI() {

        // Search button
        if let state = query?.state, state != .finished {
            searchButton.setTitle("Stop", for: .normal)
            searchButton.isEnabled = true
        } else {
            searchButton.setTitle("Speak", for: .normal)
            searchButton.isEnabled = HoundVoiceSearch.instance().isListening
        }
        
        if !HoundVoiceSearch.instance().isListening {
            searchButton.backgroundColor = self.view.tintColor.withAlphaComponent(0.5)
        } else if query?.state == .speaking {
            searchButton.backgroundColor = .red
        } else {
            searchButton.backgroundColor = self.view.tintColor
        }
        
        // Listening Button
        listeningButton.isSelected = HoundVoiceSearch.instance().isListening

        // Status Text
        var status: String
            
        if (!HoundVoiceSearch.instance().isListening) {
            status = "Not Ready"
        } else if let state = query?.state {
            switch state {
            case .recording: status = "Recording"
            case .searching: status = "Searching"
            case .speaking: status = "Speaking"
            default: status = "Ready"
            }
        } else {
            status = "Ready"
        }
        
//        update(status: status)
    }
    
    // MARK: UIStatusBar
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - HoundVoiceSearch Lifecycle.
    
    private func startListening() {
        
        // If you are allowing the HoundifySDK to manage audio for you, call startListening(completionHandler:)
        // before making voice search available in your app. This configures and activates the AVAudioSession
        // as well as initiating listening for the hot phrase, if you are using it.
        
        HoundVoiceSearch.instance().startListening(completionHandler: { (error: Error?) in
            if let error = error {
//                self.updateText = error.localizedDescription
                self.listeningButton.isEnabled = false
                self.listeningButton.setTitleColor(.gray, for: .normal)
            } else {
                self.listeningButton.isEnabled = true
                self.listeningButton.setTitleColor(.white, for: .normal)
            }
        })
    }
    
    private func stopListening() {
        
        // If you need to deactivate the HoundSDK AVAudioSession, call stopListening(completionHandler:)
        
        HoundVoiceSearch.instance().stopListening(completionHandler: { (error: Error?) in
            self.listeningButton.isEnabled = !HoundVoiceSearch.instance().isListening

            if let error = error {
//                self.updateText = error.localizedDescription
            }
        })
    }
    
    func startSearch() {
        guard !(query?.isActive == true) && HoundVoiceSearch.instance().isListening else { return }
        
        // To perform a voice search, create an instance of HoundVoiceSearchQuery
        // Configure it, including setting its delegate
        // And call start()

        query = HoundVoiceSearch.instance().newVoiceSearch()
        query?.delegate = self
        
        // An example of how to use RequestInfo: set the location to SoundHound HQ.
        // a real application, of course, one would use location services to determine
        // the device's location.
        
        query?.requestInfoBuilder.latitude = 37.4089054
        query?.requestInfoBuilder.longitude = -121.9849621
        query?.requestInfoBuilder.positionTime = Int(Date().timeIntervalSince1970)
        query?.requestInfoBuilder.positionHorizontalAccuracy = 10
        
        query?.start()
    }
    
    // MARK: - HoundVoiceSearchQueryDelegate
    
    public func houndVoiceSearchQuery(_ query: HoundVoiceSearchQuery, changedStateFrom oldState: HoundVoiceSearchQueryState, to newState: HoundVoiceSearchQueryState) {
        refreshUI()
        
        if newState == .finished {
            refreshTextView()
        }
    }
    
    public func houndVoiceSearchQuery(_ query: HoundVoiceSearchQuery, didReceivePartialTranscription partialTranscript: HoundDataPartialTranscript) {
        // While a voice query is being recorded, the HoundSDK will provide ongoing transcription
        // updates which can be displayed to the user.
        if query == self.query {
//            self.updateText = partialTranscript.partialTranscript
        }
    }
    
    public func houndVoiceSearchQuery(_ query: HoundVoiceSearchQuery, didReceiveSearchResult houndServer: HoundDataHoundServer, dictionary: [AnyHashable : Any]) {
        guard query == self.query else { return }
        
        // Domains that work with client features often return incomplete results that need
        // to be completed by the application before they are ready to use. See this method for
        // an example
        tryUpdateQueryResponse(query)
        
        let commandResult = houndServer.allResults?.first
        
        // This sample app includes more detailed examples of how to use a CommandResult
        // for some queries. See HoundDataCommandResult-Extras.swift
        if let exampleText = commandResult?.exampleResultText() {
//            responseText = exampleText
        } else {
//            responseText = JSONAttributedFormatter.attributedString(from: dictionary, style: nil)
        }
        
        if let nativeData = commandResult?["NativeData"]
        {
            print("NativeData: \(nativeData)")
        }
        
        // It is the application's responsibility to initiate text-to-speech for the response
        // if it is desired.
        // The SDK provides the speakResponse() method on HoundVoiceSearchQuery, or the
        // the application may use its own TTS support.
        query.speakResponse()
    }
    
    public func houndVoiceSearchQuery(_ query: HoundVoiceSearchQuery, didFailWithError error: Error) {
        guard query == self.query else { return }
        
        let nserror = error as NSError
//        self.updateText = "\(nserror.domain) \(nserror.code) \(nserror.localizedDescription)"
    }
    
    public func houndVoiceSearchQueryDidCancel(_ query: HoundVoiceSearchQuery) {
        guard query == self.query else { return }

//        self.updateText = "Canceled"
    }
    
    // MARK: - Client Integration Example
    
    public func tryUpdateQueryResponse(_ query: HoundVoiceSearchQuery) {
        // Some HoundServer responses need information from the client before they are "complete"
        // For more general information, start here: https://www.houndify.com/docs#dynamic-responses
        
        // In this example, let's look at ClientClearScreenCommand. Make sure the "Client Control"
        // domain is enabled in your Houndify Dashboard while you try this example, and say
        // "Clear the screen" to try it.
        
        // First, let's make sure we've got a ClientClearScreenCommand to work with.
        let commandResult📦 = query.response?.allResults?.first
        
        // See HoundDataCommandResult-Extras.swift for the implementation of isClientClearScreenCommand
        guard let commandResult = commandResult📦, commandResult.isClientClearScreenCommand else {
            return
        }
        
        // ClientClearScreenCommand arrives from the server with a spoken response of
        // "This client does not support clearing the screen." by default.
        // This is because houndify does not know whether your application can clear
        // the screen when the command is received.
        
        // Let us suppose for the sake of this example that we'll only consider it a success
        // if the screen has contents to clear. (In this view controller, that will always be
        // true. Try clearing the screen twice in row in the Text Search example to see the
        // negative case.)
        
        if textView.text?.isEmpty == false {
            
            // CommandResult comes with a DynamicResponse in the clientActionSucceededResult
            // field which contains updates for the success case.
            
            if let clientActionSucceededResult = commandResult.clientActionSucceededResult {
                // Use Hound.handleDynamicResponse to copy values from clientActionSucceeded
                // to the command result, and to update the conversation state.
                Hound.handleDynamicResponse(clientActionSucceededResult, andUpdate: commandResult)
                
                // Now the spoken response is "Screen is now cleared."
            }
        } else if let clientActionFailedResult = commandResult.clientActionFailedResult {
            Hound.handleDynamicResponse(clientActionFailedResult, andUpdate: commandResult)
            
            // Now the spoken response is, "I couldn't clear the screen."
            // Just for fun, let's add our own explanation.
            commandResult.spokenResponse += " There was nothing to clear."
        }
    }
    
    // MARK: - Notifications
    @objc func listeningStateChanged(_ notification: Notification) {
        switch notification.name {
        case .HoundVoiceSearchWillStopListening:
            // Don't update UI when audio is disabled for backgrounding.
            if UIApplication.shared.applicationState == .active {
                refreshUI()
                resetTextView()
            }
            
        case .HoundVoiceSearchDidBeginListening:
            if !(query?.isActive == true) {
                refreshUI()
                refreshTextView()
            }
        default:
            break
        }
    }
    
    @objc func audioLevel(_ notification: Notification) {
        // The HoundVoiceSearchAudioLevel notification delivers the the audio level as an NSNumber between 0 and 1.0
        // in the object property of the notification. In Swift, this can be cast directly to CGFloat.
        
        guard let audioLevel = notification.object as? CGFloat else { return }
        
        UIView.animate(withDuration: 0.05, delay: 0.0, options: [.curveLinear, .beginFromCurrentState], animations: {
//            self.levelView.frame = CGRect(x: 0, y: self.levelView.frame.minY, width: audioLevel * self.view.bounds.width, height: self.levelView.bounds.height)
        }, completion: nil)
    }
    
    @objc func hotPhrase(_ notification: Notification) {
        blankTextView()
        
        // When the hot phrase is detected, it is the responsibility of the application to
        // begin a voice search in the style of its choosing.
        self.startSearch()
    }
    
    // MARK: - Action Handlers
    
    @IBAction func didTapListeningButton(_ sender: AnyObject) {
        self.listeningButton.isEnabled = false

//        tabBarController?.disableAllVoiceSearchControllers(except: self)
        
        if HoundVoiceSearch.instance().isListening {
            stopListening()
        } else {
            startListening()
        }
    }
    
    @IBAction func didTapStartButton(_ sender: AnyObject) {
        guard let query👍 = query else {
            blankTextView()
            startSearch()
            return
        }
        
        // The button performs different actions, depending on the state of the current query

        switch query👍.state {
            case .finished:
                blankTextView()
                startSearch()
            
            case .recording:
                query👍.finishRecording()
                resetTextView()
            
            case .searching:
                query👍.cancel()
                resetTextView()
            
            case .speaking:
                query👍.stopSpeaking()
            
            default:
                break
        }
    }
    
    
    // MARK: - Displayed Text
    
    private var explanatoryText: String? {
        guard !(query?.isActive == true) else { return nil }
        
        let beginning = "HoundVoiceSearch.h offers voice search APIs with greater control."
        
        if HoundVoiceSearch.instance().isListening {
            return beginning + "\n\nTap \"Search\" to begin a search with startSearch(requestInfo:...)\n\nTap \"Listen\" to deactivate the Hound audio session with stopListening(completionHandler:)"
        } else {
            return beginning + "\n\nIf you would like Houndify to manage audio, you must activate the audio session with startListening(completionHandler:)\n\nTap \"Listen\""
        }
    }
    
    private var updateText: String? {
        didSet {
            refreshTextView()
        }
    }

    private var responseText: NSAttributedString?{
        didSet {
            refreshTextView()
        }
    }
    
    private func blankTextView() {
        updateText = ""
        responseText = nil
    }

    private func resetTextView() {
        updateText = nil
        responseText = nil
    }
    
    private func refreshTextView() {
//        textView.font = originalTextViewFont
//        textView.textColor = originalTextViewColor

        if let responseText = responseText {
            textView.attributedText = responseText
        } else if let updateText = updateText {
            textView.text = updateText
        } else {
            textView.text = explanatoryText
        }
    }
    
//    private func update(status: String?) {
//        statusLabel.text = status
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func faceObservation() -> Observable<[(observation: VNFaceObservation, image: CIImage, frame: ARFrame)]> {
            return Observable<[(observation: VNFaceObservation, image: CIImage, frame: ARFrame)]>.create{ observer in
                print("face0bservation")
                guard let frame = self.sceneView.session.currentFrame else {
                    print("No frame available")
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                
                // Verify tracking state and abort
    //            guard case .normal = frame.camera.trackingState else {
    //                print("Tracking not available: \(frame.camera.trackingState)")
    //                observer.onCompleted()
    //                return Disposables.create()
    //            }
                
                // Create and rotate image
                let image = CIImage.init(cvPixelBuffer: frame.capturedImage).rotate
                
                let facesRequest = VNDetectFaceRectanglesRequest { request, error in
                    guard error == nil else {
                        print("Face request error: \(error!.localizedDescription)")
                        observer.onCompleted()
                        return
                    }
                    
                    guard let observations = request.results as? [VNFaceObservation] else {
                        print("No face observations")
                        observer.onCompleted()
                        return
                    }
                    
                    // Map response
                    let response = observations.map({ (face) -> (observation: VNFaceObservation, image: CIImage, frame: ARFrame) in
                        return (observation: face, image: image, frame: frame)
                    })
                    observer.onNext(response)
                    observer.onCompleted()
                    
                }
                try? VNImageRequestHandler(ciImage: image).perform([facesRequest])
                
                return Disposables.create()
            }
        }
        
        private func faceClassification(face: VNFaceObservation, image: CIImage, frame: ARFrame) -> Observable<(classes: [VNClassificationObservation], position: SCNVector3, frame: ARFrame)> {
            print("faceClassifiaction")
            return Observable<(classes: [VNClassificationObservation], position: SCNVector3, frame: ARFrame)>.create{ observer in
                
                // Determine position of the face
                let boundingBox = self.transformBoundingBox(face.boundingBox)
                guard let worldCoord = self.normalizeWorldCoord(boundingBox) else {
                    print("No feature point found")
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                // Create Classification request
                let request = VNCoreMLRequest(model: self.model, completionHandler: { request, error in
                    guard error == nil else {
                        print("ML request error: \(error!.localizedDescription)")
                        observer.onCompleted()
                        return
                    }
                    
                    guard let classifications = request.results as? [VNClassificationObservation] else {
                        print("No classifications")
                        observer.onCompleted()
                        return
                    }
                    
                    observer.onNext((classes: classifications, position: worldCoord, frame: frame))
                    observer.onCompleted()
                })
                request.imageCropAndScaleOption = .scaleFit
                
                do {
                    let pixel = image.cropImage(toFace: face)
                    try VNImageRequestHandler(ciImage: pixel, options: [:]).perform([request])
                } catch {
                    print("ML request handler error: \(error.localizedDescription)")
                    observer.onCompleted()
                }
                return Disposables.create()
            }
        }
        
        private func updateNode(classes: [VNClassificationObservation], position: SCNVector3, frame: ARFrame) {
            print("updateNode")
            
            guard let person = classes.first else {
                print("No classification found")
                return
            }
            
            let second = classes[1]
            let name = person.identifier
            
//            // get the relationship from the db
//            db.retrieveContactInfo()
            
            
            print("""
                FIRST
                confidence: \(person.confidence) for \(person.identifier)
                SECOND
                confidence: \(second.confidence) for \(second.identifier)
                
                """)
            if person.confidence < 0.5 || person.identifier == "unknown" {
                print("not so sure")
                return
            }
            
            // Filter for existent face
            let results = self.faces.filter{ $0.name == name && $0.timestamp != frame.timestamp }
                .sorted{ $0.node.position.distance(toVector: position) < $1.node.position.distance(toVector: position) }
            
            // Create new face
            guard let existentFace = results.first else {
                let node = SCNNode.init(withText: name, position: position)
                
                Async.main {
                    self.sceneView.scene.rootNode.addChildNode(node)
                    node.show()
                    
                }
                let face = Face.init(name: name, node: node, timestamp: frame.timestamp)
                self.faces.append(face)
                return
            }
            
            // Update existent face
            Async.main {
                
                // Filter for face that's already displayed
                if let displayFace = results.filter({ !$0.hidden }).first  {
                    
                    let distance = displayFace.node.position.distance(toVector: position)
                    if(distance >= 0.03 ) {
                        displayFace.node.move(position)
                    }
                    displayFace.timestamp = frame.timestamp
                    
                } else {
                    existentFace.node.position = position
                    existentFace.node.show()
                    existentFace.timestamp = frame.timestamp
                }
            }
        }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    /// In order to get stable vectors, we determine multiple coordinates within an interval.
    ///
    /// - Parameters:
    ///   - boundingBox: Rect of the face on the screen
    /// - Returns: the normalized vector
    private func normalizeWorldCoord(_ boundingBox: CGRect) -> SCNVector3? {
        
        var array: [SCNVector3] = []
        Array(0...2).forEach{_ in
            if let position = determineWorldCoord(boundingBox) {
                array.append(position)
            }
            usleep(12000) // .012 seconds
        }

        if array.isEmpty {
            return nil
        }
        
        return SCNVector3.center(array)
    }
    
    
    /// Determine the vector from the position on the screen.
    ///
    /// - Parameter boundingBox: Rect of the face on the screen
    /// - Returns: the vector in the sceneView
    private func determineWorldCoord(_ boundingBox: CGRect) -> SCNVector3? {
        let arHitTestResults = sceneView.hitTest(CGPoint(x: boundingBox.midX, y: boundingBox.midY), types: [.featurePoint])
        
        // Filter results that are to close
        if let closestResult = arHitTestResults.filter({ $0.distance > 0.10 }).first {
//            print("vector distance: \(closestResult.distance)")
            return SCNVector3.positionFromTransform(closestResult.worldTransform)
        }
        return nil
    }
    
    
    /// Transform bounding box according to device orientation
    ///
    /// - Parameter boundingBox: of the face
    /// - Returns: transformed bounding box
    private func transformBoundingBox(_ boundingBox: CGRect) -> CGRect {
        var size: CGSize
        var origin: CGPoint
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            size = CGSize(width: boundingBox.width * bounds.height,
                          height: boundingBox.height * bounds.width)
        default:
            size = CGSize(width: boundingBox.width * bounds.width,
                          height: boundingBox.height * bounds.height)
        }
        
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            origin = CGPoint(x: boundingBox.minY * bounds.width,
                             y: boundingBox.minX * bounds.height)
        case .landscapeRight:
            origin = CGPoint(x: (1 - boundingBox.maxY) * bounds.width,
                             y: (1 - boundingBox.maxX) * bounds.height)
        case .portraitUpsideDown:
            origin = CGPoint(x: (1 - boundingBox.maxX) * bounds.width,
                             y: boundingBox.minY * bounds.height)
        default:
            origin = CGPoint(x: boundingBox.minX * bounds.width,
                             y: (1 - boundingBox.maxY) * bounds.height)
        }
        
        return CGRect(origin: origin, size: size)
    }
}
