import UIKit

// MARK: - Constants
enum Constants {
    static let bufferSize: Int = 64 * 1024
}

// MARK: - Constants for ViewControllers
enum SizeLayoutConstants {
    static let titleFontSize: CGFloat = 28
    static let instructionFontSize: CGFloat = 14
    
    static let textFieldFontSize: CGFloat = 16
    static let buttonFontSize: CGFloat = 16
    
    static let textTitleSize: CGFloat = 18
    static let cardLabelSize: CGFloat = 20
    
    static let editConstaintSize: CGFloat = 20
    static let editHeightAnchorSize: CGFloat = 44
    static let overlayLabelSize: CGFloat = 24
    
    static let testTextSize: CGFloat = 22
    
    static let reservedLayoutSize: CGFloat = 40
}

// MARK: - Constants for SetAct
enum SetActConstants {
    static let backButtonTopMargin: CGFloat = 10
    static let backButtonLeadingMargin: CGFloat = 16
    static let titleLabelTopMargin: CGFloat = 10
    static let termsLabelTopMargin: CGFloat = 30
    static let termsPickerTopMargin: CGFloat = 10
    static let definitionsLabelTopMargin: CGFloat = 20
    static let definitionsPickerTopMargin: CGFloat = 10
    static let horizontalInset: CGFloat = 20
    
    static let titleFontSize: CGFloat = 24
    static let labelFontSize: CGFloat = 18
}

// MARK: - Constants for Set Details
enum SetDetailsConstants {
    static let topSafeAreaMargin: CGFloat = 10
    static let backButtonLeading: CGFloat = 16
    static let titleUnderlineTop: CGFloat = 8
    static let contentHorizontalInset: CGFloat = 20
    
    static let progressContainerSize: CGFloat = 120
    static let progressContainerTopMargin: CGFloat = 20
    
    static let descriptionTopMargin: CGFloat = 20
    static let textOfSetTopMargin: CGFloat = 10
    
    static let flipContainerTopMargin: CGFloat = 20
    static let flipContainerHeight: CGFloat = 180
    static let flipContainerCornerRadius: CGFloat = 10
    static let flipContainerBorderWidth: CGFloat = 1
    static let flipSideInset: CGFloat = 20
    
    static let arrowButtonsTopMargin: CGFloat = 10
    static let prevButtonLeading: CGFloat = 40
    
    static let nextButtonTrailing: CGFloat = 40
    
    static let deleteCardButtonTopMargin: CGFloat = 10
    static let deleteCardButtonWidth: CGFloat = 120
    static let deleteCardButtonHeight: CGFloat = 40
    
    static let cardListTopMargin: CGFloat = 20
    static let cardListBottomMargin: CGFloat = 20
    
    static let bottomButtonsBottomMargin: CGFloat = 20
    static let bottomButtonsHorizontalSpacing: CGFloat = 10
    static let bottomButtonWidth: CGFloat = 100
    static let bottomButtonHeight: CGFloat = 40
    
    static let learnedButtonTrailing: CGFloat = 10
    static let learnedButtonBottom: CGFloat = 10
    static let learnedButtonHeight: CGFloat = 30
    
    static let progressCircleRadius: CGFloat = 50
    static let progressCircleLineWidth: CGFloat = 10
    
    static let underlineHeight: CGFloat = 1
    
    static let titleFontSize: CGFloat = 24
    static let progressFontSize: CGFloat = 18
    static let descriptionFontSize: CGFloat = 16
    static let cardFontSize: CGFloat = 16
    static let arrowButtonFontSize: CGFloat = 24
}

// MARK: - Constants for Reset Password
enum ResetPasswordConstants {
    static let titleTopPadding: CGFloat = 40
    
    static let codeInstructionTopPadding: CGFloat = 35
    static let codeTextFieldTopPadding: CGFloat = 8
    static let codeTextFieldHeight: CGFloat = 44
    
    static let passwordInstructionTopPadding: CGFloat = 20
    static let passwordTextFieldTopPadding: CGFloat = 8
    static let passwordTextFieldHeight: CGFloat = 44
    
    static let resetButtonTopPadding: CGFloat = 35
    static let resetButtonHeight: CGFloat = 44
    
    static let leadingTrailingInset: CGFloat = 32
    static let cornerRadius: CGFloat = 8
    
    static let titleFontSize: CGFloat = 28
    static let instructionFontSize: CGFloat = 16
    static let textFieldFontSize: CGFloat = 16
    static let buttonFontSize: CGFloat = 16
}

// MARK: - Constants for Memorization
enum MemorizationConstants {
    static let topBarHeight: CGFloat = 100
    
    static let closeButtonTop: CGFloat = 8
    static let closeButtonLeading: CGFloat = 16
    
    static let separatorHeight: CGFloat = 1
    static let separatorTopOffset: CGFloat = 8
    
    static let progressViewHeight: CGFloat = 8
    static let progressStackTopOffset: CGFloat = 8
    static let progressStackHeight: CGFloat = 24
    
    static let cardLabelSize: CGFloat = 24

    static let questionTopOffset: CGFloat = 130
    static let questionHorizontalPadding: CGFloat = 16

    static let optionsTopOffset: CGFloat = 40
    static let optionsHorizontalPadding: CGFloat = 20
    static let optionButtonHeight: CGFloat = 50
    static let optionButtonCornerRadius: CGFloat = 8
    static let optionButtonBorderWidth: CGFloat = 1
    static let optionButtonFontSize: CGFloat = 18

    static let titleFontSize: CGFloat = 17
    static let titleTopInset: CGFloat = 8
}

// MARK: - Constants for Forgot Password
enum ForgotPasswordConstants {
    static let titleTopOffset: CGFloat = 40
    static let sideOffset: CGFloat = 32
    static let instructionLabelTop: CGFloat = 35
    static let emailTextFieldTop: CGFloat = 5
    static let sendCodeButtonTop: CGFloat = 35
    static let underlineHeight: CGFloat = 1
    static let textFieldHeight: CGFloat = 44
    static let buttonCornerRadius: CGFloat = 8
}

// MARK: - Constants for Create Set
enum CreateSetConstants {
    static let topStackViewTop: CGFloat = 10
    static let topStackViewSide: CGFloat = 16
    
    static let fieldsStackViewTop: CGFloat = 45
    static let fieldsStackViewSide: CGFloat = 25
    
    static let textViewHeight: CGFloat = 300
    static let textFieldBottomLineHeight: CGFloat = 1
    
    static let stackViewRowSpacing: CGFloat = 10
    static let fieldsStackViewSpacing: CGFloat = 25
    static let textViewBorderWidth: CGFloat = 1
    
    static let labelFontSizeMedium: CGFloat = 14
    static let textFieldFontSize: CGFloat = 16
    static let textViewFontSize: CGFloat = 16
}

// MARK: - Constants for Games
enum GamesConstants {
    static let titletextSize: CGFloat = 22
    static let buttonSize: CGFloat = 30
    static let separatorSize: CGFloat = 20
    static let collectionSize: CGFloat = 10
}

// MARK: - Constants for Sign In
enum SignInLayoutConstants {
    static let titleFontSize: CGFloat = 28
    static let titleLabelSize: CGFloat = 14
    static let titleFieldSize: CGFloat = 16

    static let passwordIconSize: CGFloat = 24
    static let passwordIconX: CGFloat = 10
    static let passwordIconY: CGFloat = 10
    static let passwordIconContainerWidth: CGFloat = 50
    static let passwordIconContainerHeight: CGFloat = 44
    
    static let cornerRadius: CGFloat = 8
    static let underlineHeight: CGFloat = 1
    static let buttonHeight: CGFloat = 48
    static let bottomStackSpacing: CGFloat = 20
    
    static let topTitlePadding: CGFloat = 144
    static let sidePadding: CGFloat = 32
    static let subtitleTopSpacing: CGFloat = 15
    static let fieldLabelTopSpacing: CGFloat = 35
    static let textFieldTopSpacing: CGFloat = 12
    static let fieldToNextFieldSpacing: CGFloat = 24
    static let buttonTopSpacing: CGFloat = 32
    static let orLabelTopSpacing: CGFloat = 24
    static let bottomStackTopSpacing: CGFloat = 40
}

// MARK: - Constants for Avatar Selection
enum AvatarSelectionLayout {
    static let sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    static let minimumSpacing: CGFloat = 8
    static let cellCornerRadius: CGFloat = 8
    static let imageMultiplier: CGFloat = 0.8
    static let cameraGallerySpacing: CGFloat = 24
    static let selectedBorderWidth: CGFloat = 2
}

// MARK: - Constants for Profile
enum ProfileLayout {
    static let profileImageSize: CGFloat = 120
    static let profileImageTopSpacing: CGFloat = 30
    static let labelTopSpacing: CGFloat = 26
    static let horizontalPadding: CGFloat = 20
    static let dividerHeight: CGFloat = 0.5
    static let settingsButtonWidth: CGFloat = 360
    static let settingsButtonHeight: CGFloat = 50
    static let calendarHeight: CGFloat = 300
    static let tabBarHeight: CGFloat = 60
    static let tabBarSideInset: CGFloat = 50
}

// MARK: - Constants for Confirm Action
enum ConfirmActionLayout {
    static let sidePadding: CGFloat = 20
    static let topSpacing: CGFloat = 20
    static let buttonHeight: CGFloat = 44
    static let betweenButtonsSpacing: CGFloat = 10
    static let titleLabelSize: CGFloat = 18
    static let buttoncornerRadius: CGFloat = 8
}

// MARK: - Constants for Answer
enum AnswerLayout {
    static let containerWidthMultiplier: CGFloat = 0.8
    static let containerCornerRadius: CGFloat = 16
    static let labelHorizontalPadding: CGFloat = 16
    static let questionTopPadding: CGFloat = 25
    static let labelVerticalSpacing: CGFloat = 20
    
    static let buttonTopPadding: CGFloat = 16
    static let buttonWidth: CGFloat = 200
    static let buttonHeight: CGFloat = 50
    
    static let containerBottomPadding: CGFloat = 20
    static let buttonCornerRadius: CGFloat = 12
    static let questionFontSize: CGFloat = 22
    static let answerFontSize: CGFloat = 20
    static let correctnessFontSize: CGFloat = 24
    static let buttonFontSize: CGFloat = 18
}

// MARK: - Constants for Results
enum ResultsLayout {
    static let containerWidthMultiplier: CGFloat = 0.79
    static let containerHeight: CGFloat = 520
    
    static let sidePadding: CGFloat = 16
    static let topTitleSpacing: CGFloat = 80
    static let topResultSpacing: CGFloat = 80
    static let bottomButtonSpacing: CGFloat = 48
    
    static let buttonWidth: CGFloat = 240
    static let buttonHeight: CGFloat = 50
    
    static let transitionDuration: TimeInterval = 0.6
    static let containerRadius: CGFloat = 12
    static let buttonRadius: CGFloat = 8
}

// MARK: - Constants for Edit CardSet
enum EditCardSetLayoutConstants {
    static let textFieldTop: CGFloat = 20
    static let horizontalInset: CGFloat = 16
    
    static let textFieldHeight: CGFloat = 40
    static let textViewTop: CGFloat = 16
    static let textViewHeight: CGFloat = 100
    
    static let buttonTop: CGFloat = 20
    static let buttonWidth: CGFloat = 100
    static let buttonHeight: CGFloat = 44
    
    static let cornerRadius: CGFloat = 5
}

// MARK: - Constants for Edit Card
enum EditCardLayoutConstants {
    static let horizontalInset: CGFloat = 20
    static let verticalSpacing: CGFloat = 20
    static let textViewHeight: CGFloat = 80
    static let buttonHeight: CGFloat = 44
    static let cornerRadius: CGFloat = 8
}

// MARK: - Constants for Loading
enum LoadingLayoutConstants {
    static let containerWidth: CGFloat = 360
    static let containerHeight: CGFloat = 232
    
    static let indicatorTop: CGFloat = 60
    static let labelTopSpacing: CGFloat = 16
    static let labelHorizontalInset: CGFloat = 8
    
    static let buttonTopSpacing: CGFloat = 24
    static let buttonWidth: CGFloat = 200
    static let buttonHeight: CGFloat = 48
    static let buttonBottomSpacing: CGFloat = -24
    static let buttonCornerRadius: CGFloat = 8
}

// MARK: - Constants for Splash
enum SplashLayoutConstants {
    static let iconYOffset: CGFloat = -40
    static let iconSize: CGFloat = 200
}

// MARK: - Constants for Sets
enum SetsLayoutConstants {
    static let titleFontSize: CGFloat = 24
    static let backButtonTop: CGFloat = 10
    static let sideInset: CGFloat = 16
    static let searchTopSpacing: CGFloat = 20
    static let scrollBottomInset: CGFloat = -20
    static let stackSpacing: CGFloat = 10
    static let buttonHeight: CGFloat = 48
    static let buttonCornerRadius: CGFloat = 8

    static let progressLow: Int = 33
    static let progressMedium: Int = 66
}

// MARK: - Constants for Cards
enum CardsLayoutConstants {
    static let closeButtonSize: CGFloat = 30
    static let closeButtonTop: CGFloat = 8
    static let closeButtonLeading: CGFloat = 16
    
    static let radiusScore: CGFloat = 16
    static let separatorHeight: CGFloat = 1
    
    static let scoreLabelWidth: CGFloat = 40
    static let scoreLabelHeight: CGFloat = 32
    
    static let cardViewWidthMultiplier: CGFloat = 0.75
    static let cardViewHeightMultiplier: CGFloat = 0.55
    static let cardLabelHorizontalPadding: CGFloat = 20
    
    static let panFadeDuration: TimeInterval = 0.1
    static let exitAnimationDuration: TimeInterval = 0.3
    static let flipAnimationDuration: TimeInterval = 0.4
    static let swipeThreshold: CGFloat = 100
    static let overlayThreshold: CGFloat = 120
}

// MARK: - Constants for Sign Up
enum SignUpLayoutConstants {
    static let horizontalPadding: CGFloat = 32
    static let topAnchorSize: CGFloat = 12
    static let topAnchor2Size: CGFloat = 24
    static let topAnchor4Size: CGFloat = 48
    static let upperSize: CGFloat = 144
    static let topMiniSize: CGFloat = 8
}
