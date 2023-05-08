//
//  MTBAssessmentView.swift
//

import SwiftUI
import UIKit
import BridgeClient
import BridgeClientExtension
import BridgeClientUI
import ResearchUI
import Research
import JsonModel
import ResultModel
import MobileToolboxKit
import MSSMobileKit
import AssessmentModelUI

let taskVendor = MSSTaskVender(taskConfigLoader: MTBStaticTaskConfigLoader.default)

public enum MTBIdentifier : String, CaseIterable {
    case numberMatch="number-match",
         mfs="memory-for-sequences",
         dccs="dccs",
         fnamea="fnamea",
         flanker="flanker",
         fnameb="fnameb",
         psm="psm",
         spelling="spelling",
         vocabulary="vocabulary",
         
         eggs="JOVIV1",
         colorChange="ChangeLocalizationV1",
         
         blockRotation="3DRotationV1",
         citiesAndMountains="GradualOnsetV1",
         facesAndFeelings="FaceEmotionV1",
         lettersAndNumbers="LetterNumberSeriesV1",
         numberGuessingForm1="ProbabilisticRewardForm1V1",
         numberGuessingForm2="ProbabilisticRewardForm2V1",
         puzzleCompletion="ProgressiveMatricesV1",
         wordProblems="VerbalReasoningV1"
}

extension MTBIdentifier : AssessmentInfoExtension {
    
    public var assessmentIdentifier: String { self.rawValue }
    
    public func title() -> Text {
        switch self {
        case .numberMatch:
            return Text("Number-Symbol Match", bundle: .module)
        case .mfs:
            return Text("Sequences", bundle: .module)
        case .dccs:
            return Text("Shape-Color Sorting", bundle: .module)
        case .fnamea:
            return Text("Faces & Names A", bundle: .module)
        case .fnameb:
            return Text("Faces & Names B", bundle: .module)
        case .flanker:
            return Text("Arrow Matching", bundle: .module)
        case .psm:
            return Text("Arranging Pictures", bundle: .module)
        case .spelling:
            return Text("Spelling", bundle: .module)
        case .vocabulary:
            return Text("Word Meaning", bundle: .module)
        default:
            return Text(self.rawValue)
        }
    }
    
    public func icon() -> ContentImage {
        switch self {
        case .numberMatch:
            return .init("Number-Symbol Match", bundle: .module)
        case .mfs:
            return .init("Sequences", bundle: .module)
        case .dccs:
            return .init("Shape-Color Sorting", bundle: .module)
        case .fnamea:
            return .init("Faces & Names A", bundle: .module)
        case .fnameb:
            return .init("Faces & Names B", bundle: .module)
        case .flanker:
            return .init("Arrow Matching", bundle: .module)
        case .psm:
            return .init("Arranging Pictures", bundle: .module)
        case .spelling:
            return .init("Spelling", bundle: .module)
        case .vocabulary:
            return .init("Word Meaning", bundle: .module)
        case .eggs:
            return .init("Eggs", bundle: .module)
        case .colorChange:
            return .init("Color Change", bundle: .module)
        case .blockRotation:
            return .init("BlockRotation", bundle: .module)
        case .citiesAndMountains:
            return .init("CitiesAndMountains", bundle: .module)
        case .facesAndFeelings:
            return .init("FacesAndFeelings", bundle: .module)
        case .lettersAndNumbers:
            return .init("LettersAndNumbers", bundle: .module)
        case .numberGuessingForm1, .numberGuessingForm2:
            return .init("NumberGuessing", bundle: .module)
        case .puzzleCompletion:
            return .init("PuzzleCompletion", bundle: .module)
        case .wordProblems:
            return .init("WordProblems", bundle: .module)
        }
    }
    
    public func color() -> Color {
        switch self {
        case .numberMatch:
            return .appLavender
        case .mfs:
            return .appPeriwinkle
        case .dccs:
            return .appOrange
        case .fnamea:
            return .appGreen
        case .fnameb:
            return .appGreen
        case .flanker:
            return .appOrange
        case .psm:
            return .appGreen
        case .spelling:
            return .appBlue
        case .vocabulary:
            return .appBlue
        default:
            return Self.defaultColor
        }
    }
    
    public static var defaultColor : Color {
        return .appBlue
    }
    
    public func taskIdentifier() -> String {
        switch self {
        case .numberMatch:
            return "Number Match"
        case .mfs:
            return "MFS pilot 2"
        case .dccs:
            return "Dimensional Change Card Sort"
        case .fnamea:
            return "FNAME Learning Form 1"
        case .fnameb:
            return "FNAME Test Form 1"
        case .flanker:
            return "Flanker Inhibitory Control"
        case .psm:
            return "Picture Sequence MemoryV1"
        case .spelling:
            return "MTB Spelling Form 1"
        case .vocabulary:
            return "Vocabulary Form 1"
        default:
            return self.rawValue
        }
    }
}

fileprivate func assessmentToTaskIdentifierMap(_ identifier: String) -> String {
    MTBIdentifier(rawValue: identifier)?.taskIdentifier() ?? identifier
}

struct MTBAssessmentView : UIViewControllerRepresentable {
    typealias UIViewControllerType = RSDTaskViewController
    
    let taskVC: RSDTaskViewController
    let handler: ScheduledAssessmentHandler
    let schedule: AssessmentScheduleInfo
    
    init(_ assessmentInfo: AssessmentScheduleInfo, handler: ScheduledAssessmentHandler) {
        self.handler = handler
        self.schedule = assessmentInfo
        do {
            self.taskVC = try Self.buildTaskViewController(assessmentInfo)
        }
        catch let err {
            assertionFailure("Failed to create the task view controller: \(err)")
            self.taskVC = RSDTaskViewController(task: AssessmentTaskObject(identifier: "empty", steps: []))
        }
    }

    func makeUIViewController(context: Context) -> RSDTaskViewController {
        taskVC.delegate = context.coordinator
        return taskVC
    }
    
    func updateUIViewController(_ uiViewController: RSDTaskViewController, context: Context) {
    }
    
    func makeCoordinator() -> MTBTaskDelegate {
        MTBTaskDelegate(schedule, handler: handler)
    }
    
    static func buildTaskViewController(_ schedule: AssessmentScheduleInfo) throws -> RSDTaskViewController {
        let scheduleIdentifier = "\(schedule.session.instanceGuid)|\(schedule.instanceGuid)"
        let taskIdentifier = assessmentToTaskIdentifierMap(schedule.assessmentInfo.identifier)
        let taskVC = try taskVendor.taskViewController(for: taskIdentifier, scheduleIdentifier: scheduleIdentifier)
        
        // syoung 09/14/2021 Need to set the task orientation *before* presenting the view
        // (and calling `makeUIViewController()`) or else it will crash b/c its trying to
        // rotate to an unsupported orientation.
        let taskOrientation: UIInterfaceOrientationMask = (taskVC.task as? MSSAssessmentTaskObject)?.taskOrientation ?? .portrait
        let lock = taskOrientation.union(AppOrientationLockUtility.defaultOrientationLock)
        AppOrientationLockUtility.setOrientationLock(lock, rotateIfNeeded: false)
        
        return taskVC
    }
    
    final class MTBTaskDelegate : NSObject, RSDTaskViewControllerDelegate {
        
        let handler: ScheduledAssessmentHandler
        let schedule: AssessmentScheduleInfo
        
        init(_ schedule: AssessmentScheduleInfo, handler: ScheduledAssessmentHandler) {
            self.handler = handler
            self.schedule = schedule
        }
        
        /// A flag used to track whether or not "ready to save" was called by the assessment.
        public private(set) var didCallReadyToSave: Bool = false
        
        func taskController(_ taskController: RSDTaskController, readyToSave taskViewModel: RSDTaskViewModel) {
            guard let builder = self.createBuilder(taskViewModel) else { return }
            
            self.didCallReadyToSave = true
            
            Task {
                await handler.updateAssessmentStatus(schedule, status: .readyToSave(builder))
            }
        }

        func taskController(_ taskController: RSDTaskController, didFinishWith reason: RSDTaskFinishReason, error: Error?) {
            if reason != .completed && !self.didCallReadyToSave {
                // If the task finished with an error or discarded results, then delete the output directory.
                taskController.taskViewModel.deleteOutputDirectory(error: error)
                if let err = error {
                    debugPrint("WARNING! Task failed: \(err)")
                }
            }
            
            Task {
                await dismissAssessment(taskController.taskViewModel, reason: reason, error: error)
            }
        }
        
        @MainActor
        func dismissAssessment(_ taskViewModel: RSDTaskViewModel, reason: RSDTaskFinishReason, error: Error?) {
            if taskViewModel.didAbandon {
                handler.updateAssessmentStatus(schedule, status: .declined(taskViewModel.taskResult.startDate))
            }
            else if (reason == .failed), let err = error {
                handler.updateAssessmentStatus(schedule, status: .error(err))
            }
            else if (reason == .completed) {
                if !self.didCallReadyToSave, let builder = self.createBuilder(taskViewModel) {
                    handler.updateAssessmentStatus(schedule, status: .saveAndFinish(builder))
                }
                else {
                    handler.updateAssessmentStatus(schedule, status: .finished)
                }
            }
            else if (reason == .saved), let result = taskViewModel.taskResult as? AssessmentResult {
                handler.updateAssessmentStatus(schedule, status: .saveForLater(result))
            }
            else {
                handler.updateAssessmentStatus(schedule, status: .restartLater)
            }
        }
        
        func createBuilder(_ taskViewModel: RSDTaskViewModel) -> ResultArchiveBuilder? {
            guard let result = taskViewModel.taskResult as? AssessmentResult,
                  let builder = MTBArchiveBuilder(result, schedule: schedule, outputDirectory: taskViewModel.outputDirectory)
            else {
                Logger.log(tag: .upload, error: AppUnexpectedNullError(message: "Could not build archive for \(taskViewModel.taskResult)"))
                return nil
            }
            return builder
        }
    }
}

class MTBArchiveBuilder : AssessmentArchiveBuilder {

    override func manifestFileInfo(for result: FileArchivable, fileInfo: FileInfo) -> FileInfo? {
        if fileInfo.filename == "taskData" {
            return FileInfo(filename: "taskData.json",
                            timestamp: fileInfo.timestamp,
                            contentType: fileInfo.contentType,
                            identifier: fileInfo.identifier,
                            stepPath: fileInfo.stepPath,
                            jsonSchema: fileInfo.jsonSchema,
                            metadata: fileInfo.metadata)
        }
        else {
            return fileInfo
        }
    }
    
    override func assessmentResultFile() throws -> (Data, FileInfo)? {
        nil // Do not include the assessment file
    }
}

struct AppUnexpectedNullError : Error, CustomNSError {
    static var errorDomain: String { "MobileToolboxApp.UnexpectedNullError" }
    
    let message: String
    
    var errorCode: Int {
        -1
    }
    
    var errorUserInfo: [String : Any] {
        [NSLocalizedFailureReasonErrorKey: message]
    }
}

