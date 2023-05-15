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
import MSSMobileKit
import AssessmentModelUI

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

final class MTBTaskDelegate : SageResearchTaskDelegate {
    var taskVC: RSDTaskViewController!
    
    init(_ assessmentManager: TodayTimelineViewModel) {
        super.init(assessmentManager)
        self.taskVC = {
            do {
                let taskVC = try buildTaskViewController()
                taskVC.delegate = self
                return taskVC
            }
            catch let err {
                assertionFailure("Failed to create the task view controller: \(err)")
                return RSDTaskViewController(task: AssessmentTaskObject(identifier: "empty", steps: []))
            }
        }()
    }
        
    override var sageResearchArchiveManager: SageResearchArchiveManager {
        _sageResearchArchiveManager
    }
    lazy private var _sageResearchArchiveManager: SageResearchArchiveManager = {
        let manager = MobileToolboxArchiveManager()
        manager.load(bridgeManager: assessmentManager.bridgeManager)
        return manager
    }()
    
    func buildTaskViewController() throws -> RSDTaskViewController {
        guard let schedule = scheduledAssessment
        else {
            throw RSDValidationError.unexpectedNullObject("taskIdentifier")
        }
        let taskIdentifier = assessmentToTaskIdentifierMap(schedule.assessmentInfo.identifier)
        
        if let config = assessmentManager.bridgeManager?.appConfig.decodeRecorderConfig() {
            let wrapperTask = MTBAssessmentWrapper(recorderConfig: config, activityIdentifier: taskIdentifier, study: assessmentManager.bridgeManager?.study)
            let taskViewModel = RSDTaskViewModel(task: wrapperTask)
            taskViewModel.scheduleIdentifier = scheduleIdentifier
            // syoung 09/14/2021 Need to set the task orientation *before* presenting the view
            // (and calling `makeUIViewController()`) or else it will crash b/c its trying to
            // rotate to an unsupported orientation.
            let lock = wrapperTask.taskOrientation.union(AppOrientationLockUtility.defaultOrientationLock)
            AppOrientationLockUtility.setOrientationLock(lock, rotateIfNeeded: false)
            return AssessmentWrapperTaskViewController(taskViewModel: taskViewModel)
        }
        else {
            return try taskVendor.taskViewController(for: taskIdentifier, scheduleIdentifier: scheduleIdentifier)
        }
    }
}

struct MTBAssessmentView : UIViewControllerRepresentable {
    typealias UIViewControllerType = RSDTaskViewController
    
    let assessmentManager: TodayTimelineViewModel
    
    init(_ assessmentManager: TodayTimelineViewModel) {
        self.assessmentManager = assessmentManager
        
    }

    func makeUIViewController(context: Context) -> RSDTaskViewController {
        context.coordinator.taskVC
    }
    
    func updateUIViewController(_ uiViewController: RSDTaskViewController, context: Context) {
    }
    
    func makeCoordinator() -> MTBTaskDelegate {
        .init(assessmentManager)
    }
}

class MobileToolboxArchiveManager : SageResearchArchiveManager {
    override func instantiateArchive(_ archiveIdentifier: String, for schedule: AssessmentScheduleInfo?, with schema: RSDSchemaInfo?) -> SageResearchResultArchive? {
        MobileToolboxArchive(identifier: archiveIdentifier,
                             schemaIdentifier: schema?.schemaIdentifier,
                             schemaRevision: schema?.schemaVersion,
                             dataGroups: dataGroups(),
                             schedule: schedule,
                             isPlaceholder: false)
    }
}

class MobileToolboxArchive : SageResearchResultArchive {
    
    override func shouldInsertData(for filename: RSDReservedFilename) -> Bool {
        false   // Do not include "answers.json" or "taskResult.json"
    }
    
    override func archivableData(for result: ResultData, sectionIdentifier: String?, stepPath: String?) -> RSDArchivable? {
        (result as? FileArchivable).map { RSDArchivableWrapper(result: $0) }
    }
}

struct RSDArchivableWrapper : RSDArchivable {
    let result: FileArchivable
    
    func buildArchiveData(at stepPath: String?) throws -> (manifest: Research.RSDFileManifest, data: Data)? {
        guard let ret = try result.buildArchivableFileData(at: stepPath)
        else {
            return nil
        }
        let filename = (ret.fileInfo.filename == "taskData") ? "taskData.json" : ret.fileInfo.filename
        #if DEBUG
        if filename == "taskData.json", let schema = ret.fileInfo.jsonSchema {
            print("---\n\n\(schema)\n\(String(data: ret.data, encoding: .utf8)!)\n\n---")
        }
        #endif
        let m = RSDFileManifest(filename: filename,
                                timestamp: ret.fileInfo.timestamp,
                                contentType: ret.fileInfo.contentType,
                                identifier: ret.fileInfo.identifier,
                                stepPath: ret.fileInfo.stepPath,
                                jsonSchema: ret.fileInfo.jsonSchema,
                                metadata: ret.fileInfo.metadata)
        return (m, ret.data)
    }
}

