//
//  MTBAssessmentWrapper.swift
//

import UIKit
import AVFoundation
import BridgeClient
import BridgeClientUI
import JsonModel
import MobilePassiveData
import MobileToolboxKit
import MSSMobileKit
import Research
import ResearchUI
import WeatherRecorder


// These wrappers are intended to work around MTB subclasses that assume that their
// task view controller will be displayed and point directly at a their task view model.
// This does not work when wrapping the assessment in another assessment that is managing
// things like audio sessions. syoung 10/14/2020

let taskVendor = MSSTaskVender(taskConfigLoader: MTBStaticTaskConfigLoader.default)

public struct MTBAssessmentWrapper : RSDTask, RSDActiveTask, RSDOrientationTask {

    init(recorderConfig: AssessmentRecorderConfig, activityIdentifier: String, study: StudyObserver?) {
        let wrapper = MTBStepWrapper(identifier: activityIdentifier, recorderConfig: recorderConfig)
        self.identifier = activityIdentifier
        self.taskOrientation = wrapper.taskOrientation
        var stepNavigator = RSDConditionalStepNavigatorObject(with: [wrapper])
        stepNavigator.progressMarkers = []
        self.stepNavigator = stepNavigator
        let recorders = study?.studyConfig?.backgroundRecorders ?? [:]
        self.asyncActions = recorderConfig.recorders.filter {
            (recorderConfig.excludeMapping[$0.identifier]?.contains(activityIdentifier) != true) &&
            (recorders[$0.identifier] == true)
        }
    }

    // MARK: RSDTask
    
    public let identifier: String
    
    public let taskOrientation: UIInterfaceOrientationMask
    
    public var schemaInfo: RSDSchemaInfo? {
        nil
    }
    
    public let stepNavigator: RSDStepNavigator
    
    public let asyncActions: [AsyncActionConfiguration]?
    
    public func instantiateTaskResult() -> RSDTaskResult {
        RSDTaskResultObject(identifier: self.identifier)
    }
    
    public func validate() throws {
    }
    
    // MARK: RSDBackgroundTask
    
    public var audioSessionSettings: AudioSessionSettings? {
        .recordDBLevel
    }
    
    public var shouldEndOnInterrupt : Bool {
        false
    }
}

extension RSDStepType {
    static let wrapper: RSDStepType = "wrapper"
}

struct MTBStepWrapper : RSDStep, RSDStepViewControllerVendor {
    let identifier: String
    let recorderConfig: AssessmentRecorderConfig
    let taskVC: RSDTaskViewController
    var stepType : RSDStepType { .wrapper }
    
    var taskOrientation: UIInterfaceOrientationMask {
        (self.taskVC.task as? MSSAssessmentTaskObject)?.taskOrientation ?? .portrait
    }
    
    init(identifier: String, recorderConfig: AssessmentRecorderConfig) {
        self.identifier = identifier
        self.recorderConfig = recorderConfig
        do {
            self.taskVC = try taskVendor.taskViewController(for: self.identifier, scheduleIdentifier: nil)
        }
        catch let err {
            print("Failed to start \(self.identifier): \(err)")
            let step = InstructionStep("placeholder",
                                       title: "Cannot Run \(self.identifier)",
                                       detail: "This task is not currently included in the framework. It will be marked as completed and ignored.",
                                       hasImage: false)
            let task = AssessmentTaskObject(identifier: self.identifier, steps: [step])
            self.taskVC = RSDTaskViewController(task: task)
        }
    }
    
    func instantiateStepResult() -> ResultData {
        RSDTaskResultObject(identifier: identifier)
    }
    
    func validate() throws {
    }
    
    func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)? {
        guard let root = parent else { return nil }
        
        let taskViewModel = taskVC.taskViewModel!
        if let parentResult = parent?.rootPathComponent.taskResult as? AssessmentResult,
           let taskResult = taskViewModel.taskResult as? AssessmentResult {
            taskResult.taskRunUUID = parentResult.taskRunUUID
        }
        
        let taskWrapper = MTBTaskWrapper(step: self, taskViewController: taskVC, parent: root)
        return AssessmentWrapperStepViewController(wrapper: taskWrapper)
    }
}

class MTBTaskWrapper : RSDStepViewPathComponent {
    let step: RSDStep
    let taskViewController: RSDTaskViewController
    
    weak var parent: RSDPathComponent?
    
    init(step: RSDStep, taskViewController: RSDTaskViewController, parent: RSDPathComponent) {
        self.step = step
        self.parent = parent
        self.taskViewController = taskViewController
    }
    
    // MARK: RSDStepViewPathComponent
    
    var identifier: String {
        step.identifier
    }
    
    var currentChild: RSDNodePathComponent? {
        nil
    }
    
    func pathResult() -> ResultData {
        let result = self.taskViewController.taskViewModel.pathResult()
        let runResult = result as? AssessmentResult
        if let parentResult = parent?.rootPathComponent.taskResult as? AssessmentResult {
            runResult?.taskRunUUID = parentResult.taskRunUUID
        }
        return runResult ?? result
    }
    
    func perform(actionType: RSDUIActionType) {
        self.parent?.perform(actionType: actionType)
    }
    
    var outputDirectory: URL! {
        self.taskViewController.taskViewModel.outputDirectory
    }
    
    // not used
    
    var taskResult: RSDTaskResult {
        get {
            return parent?.taskResult ?? RSDTaskResultObject(identifier: self.identifier)
        }
        set {
            assertionFailure("Not implemented")
        }
    }
    
    var isForwardEnabled: Bool {
        true
    }
    
    var canNavigateBackward: Bool {
        false
    }
    
    func progress() -> (current: Int, total: Int, isEstimated: Bool)? {
        nil
    }
    
    func sectionIdentifier() -> String {
        ""
    }
    
    func findStepResult() -> ResultData? {
        nil
    }
    
    func action(for actionType: RSDUIActionType) -> RSDUIAction? {
        nil
    }
    
    func shouldHideAction(for actionType: RSDUIActionType) -> Bool {
        false
    }
}

class AssessmentWrapperStepViewController : UIViewController, RSDStepController, RSDTaskViewControllerDelegate {
    
    override public var prefersStatusBarHidden: Bool {
        self.wrapper.taskViewController.prefersStatusBarHidden
    }
    
    public override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        self.wrapper.taskViewController.preferredScreenEdgesDeferringSystemGestures
    }

    let wrapper: MTBTaskWrapper
    
    init(wrapper: MTBTaskWrapper) {
        self.wrapper = wrapper
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var audioSession: AVAudioSession?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let step = wrapper.step as? MTBStepWrapper,
           step.recorderConfig.excludeMapping["microphone"]?.contains(wrapper.identifier) == true {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .spokenAudio, options: [])
                try session.setActive(true)
                audioSession = session
            }
            catch let err {
                debugPrint("Failed to start AV session. \(err)")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Recorders assume that the async actions *only* start when the step is ready for them
        // but if the step doesn't *know* that they are there, then it won't start them.
        // this is a work-around for not being able to fix the bug in SageResearch b/c this is
        // pinned to an older version of that framework.
        self.taskController?.startAsyncActionsIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Release the session
        if audioSession != nil {
            do {
                audioSession = nil
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch let err {
                debugPrint("Failed to stop AV session. \(err)")
            }
        }
    }
    
    // MARK: View management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wrapper.taskViewController.delegate = self
        self.addChild(wrapper.taskViewController)
        wrapper.taskViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        wrapper.taskViewController.view.frame = self.view.bounds
        self.view.addSubview(wrapper.taskViewController.view)
        wrapper.taskViewController.didMove(toParent: self)
    }
    
    // MARK: RSDTaskControllerDelegate
    
    func taskController(_ taskController: RSDTaskController, didFinishWith reason: RSDTaskFinishReason, error: Error?) {
        let didAbandon = taskController.taskViewModel.didAbandon
        if reason == .completed && !didAbandon {
            wrapper.perform(actionType: .navigation(.goForward))
        }
        else {
            stopAllAsyncActions {
                if didAbandon {
                    self.wrapper.rootPathComponent.perform(actionType: .navigation(.abandonAssessment))
                }
                else {
                    self.wrapper.rootPathComponent.cancel(shouldSave: reason == .saved)
                }
            }
        }
    }
    
    func taskController(_ taskController: RSDTaskController, readyToSave taskViewModel: RSDTaskViewModel) {
        self.wrapper.rootPathComponent.taskResult.stepHistory = [taskViewModel.taskResult]
        stopAllAsyncActions {
        }
    }
    
    func stopAllAsyncActions(_ completion:@escaping (() -> Void)) {
        guard let taskController = wrapper.rootPathComponent.taskController
            else {
            completion()
            return
        }
        let controllers = taskController.currentAsyncControllers
        taskController.stopAsyncActions(for: controllers,
                                        showLoading: false,
                                        completion: completion)
    }
    
    // MARK: RSDStepController
    
    var stepViewModel: RSDStepViewPathComponent! {
        get { wrapper }
        set { } // do nothing
    }
    
    func didFinishLoading() {
        wrapper.taskViewController.currentStepViewController?.didFinishLoading()
    }
    
    func goForward() {
        wrapper.taskViewController.currentStepViewController?.goForward()
    }
    
    func goBack() {
        wrapper.taskViewController.currentStepViewController?.goBack()
    }
}

class AssessmentWrapperTaskViewController : RSDTaskViewController {
    
    public override var prefersStatusBarHidden: Bool {
        self.currentStepViewController?.prefersStatusBarHidden ?? true
    }
    
    public override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        self.currentStepViewController?.preferredScreenEdgesDeferringSystemGestures ?? super.preferredScreenEdgesDeferringSystemGestures
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        (self.task as? MTBAssessmentWrapper)?.taskOrientation ?? .portrait
    }
}

