controladdin "NPR Custom Message"
{
    Scripts = 'src/_ControlAddIns/CustomMessage/Scripts/CustomMessage.js';
    HorizontalStretch = true;
    RequestedHeight = 600;

    event Ready();
    event OKCliked();
    procedure Init(Title: Text; Message: Text);
}