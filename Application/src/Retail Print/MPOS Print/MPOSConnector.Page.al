page 6059863 "NPR MPOS Connector"
{
    Extensible = false;
    Caption = 'MPOS Connector';
    Editable = false;
    PageType = StandardDialog;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            field(PageCaption; _Caption)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Page Caption';
                Style = Strong;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the PageCaption field';
            }
            usercontrol(MPOSConnector; "NPR MPOS Connector")
            {
                ApplicationArea = NPRRetail;

                trigger ControlAddInReady()
                begin
                    CurrPage.MPOSConnector.CallNativeFunction(_Payload);
                end;

                trigger RequestSendFailed(Error: Text)
                begin
                    _AutoClosed := true;
                    CurrPage.Close();
                    Message(Error);
                end;

                trigger RequestSendSuccessfully()
                begin
                    _AutoClosed := true;
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        _Caption: Text;
        _Payload: JsonObject;
        _AutoClosed: Boolean;

    procedure SetInput(Caption: Text; Payload: JsonObject)
    begin
        _Caption := Caption;
        _Payload := Payload;
    end;

    procedure GetOutput(var AutoClosedOut: Boolean)
    begin
        AutoClosedOut := _AutoClosed;
    end;
}