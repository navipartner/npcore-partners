controladdin "NPR Get Started Wizard"
{
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    Scripts = 'src/_ControlAddIns/Wizards/Scripts/GetStartedWizard.js';
    StyleSheets = 'src/_ControlAddIns/Wizards/StyleSheets/styleSheet.css';
    StartupScript = 'src/_ControlAddIns/Wizards/Scripts/StartUp.js';

    Images =
       'src/_ControlAddIns/Wizards/Images/npretaillogo_med.png',
        'src/_ControlAddIns/Wizards/Images/VideoButton.png',
        'src/_ControlAddIns/Wizards/Images/OutlookVideo.png',
        'src/_ControlAddIns/Wizards/Images/GetAssistanceVideo.png',
        'src/_ControlAddIns/Wizards/Images/NP-small-logo.png';

    event Ready()
    event ThumbnailClicked(selection: Integer)
    procedure createlayout(TitleTxt: Text; SubTitleTxt: Text; ExplanationTxt: Text; IntroTxt: Text; IntroDescTxt: Text; GetStartedTxt: Text; GetStartedDescTxt: Text; FindHelpTxt: Text; FindHelpDescTxt: Text)
}