#if not (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22)
controladdin "NPR Welcome Logo"
{
    Images = 'src/_ControlAddIns/WelcomeLogo/Images/NPLogo_NEW.png';
    Scripts = 'src/_ControlAddIns/WelcomeLogo/Scripts/script.js';
    MaximumHeight = 1;
    MaximumWidth = 1;
    RequestedHeight = 0;
    RequestedWidth = 0;

    event InsertLogoEvent();
    procedure InsertLogoProcedure();
}
#endif