controladdin "NPR TimerControl"
{
    Scripts = 'src/_ControlAddIns/TimerControl/Scripts/TimerControl.js';

    MinimumHeight = 1;
    MinimumWidth = 1;
    RequestedHeight = 1;
    RequestedWidth = 1;

    HorizontalShrink = true;
    HorizontalStretch = true;
    VerticalShrink = true;
    VerticalStretch = true;

    procedure StartTimer(milliSeconds: Integer);
    procedure StopTimer();
    event ControlAddInReady();
    event RefreshPage();
}