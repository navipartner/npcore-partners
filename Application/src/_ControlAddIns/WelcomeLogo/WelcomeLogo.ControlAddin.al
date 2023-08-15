#if not (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC2200)
controladdin "NPR Welcome Logo"
{
    Images = 'src/_ControlAddins/WelcomeLogo/Images/NPLogo_NEW.png';
    Scripts = 'src/_ControlAddins/WelcomeLogo/Scripts/script.js';
    MaximumHeight = 1;
    MaximumWidth = 1;
    RequestedHeight = 0;
    RequestedWidth = 0;

    event InsertLogoEvent();
    procedure InsertLogoProcedure();
}
#endif