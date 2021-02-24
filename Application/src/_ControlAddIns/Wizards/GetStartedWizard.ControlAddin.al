controladdin "NPR Get Started Wizard"
{
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    Scripts = 'src/_ControlAddins/Wizards/Scripts/GetStartedWizard.js';
    StyleSheets = 'src/_ControlAddins/Wizards/StyleSheets/styleSheet.css';
    StartupScript = 'src/_ControlAddins/Wizards/Scripts/StartUp.js';

    Images = 
       'src/_ControlAddins/Wizards/Images/npretaillogo_med.png',
        'src/_ControlAddins/Wizards/Images/VideoButton.png',
        'src/_ControlAddins/Wizards/Images/OutlookVideo.png',
        'src/_ControlAddins/Wizards/Images/GetAssistanceVideo.png',
        'src/_ControlAddins/Wizards/Images/NP-small-logo.png';
    
    event Ready()
    event ThumbnailClicked(selection: Integer)
    procedure createlayout(TitleTxt:Text;SubTitleTxt:Text;ExplanationTxt:Text;IntroTxt:Text;IntroDescTxt:Text;GetStartedTxt:Text;GetStartedDescTxt:Text;FindHelpTxt:Text;FindHelpDescTxt:Text)
}