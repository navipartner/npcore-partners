page 6014627 "NPR Hardware Connector"
{
    Extensible = False;
    Caption = 'Hardware Connector';
    Editable = false;
    PageType = StandardDialog;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            usercontrol(HardwareConnector; "NPR HardwareConnector")
            {
                ApplicationArea = NPRRetail;


                trigger ControlAddInReady()
                begin
                    CurrPage.HardwareConnector.SendRequest(_Handler, _Request, _Caption);
                end;

                trigger ExceptionCaught(ErrorMessage: Text)
                begin
                    _AutoClosed := true;
                    _ErrorMessage := ErrorMessage;
                    _ExceptionCaught := true;
                    CurrPage.Close();
                end;

                trigger ResponseReceived(Response: JsonObject)
                begin
                    _AutoClosed := true;
                    _Response := Response;
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        _AutoClosed: Boolean;
        _Response: JsonObject;
        _Caption: Text;
        _Handler: Text;
        _Request: JsonObject;
        _ErrorMessage: Text;
        _ExceptionCaught: Boolean;

    procedure SetInput(Caption: Text; Handler: Text; Request: JsonObject)
    begin
        _Handler := Handler;
        _Request := Request;
        _Caption := Caption;
    end;

    procedure GetOutput(var ErrorMessageOut: Text; var ExceptionCaughtOut: Boolean; var ResponseOut: JsonObject; var DidAutoCloseOut: Boolean)
    begin
        ResponseOut := _Response;
        DidAutoCloseOut := _AutoClosed;
        ErrorMessageOut := _ErrorMessage;
        ExceptionCaughtOut := _ExceptionCaught;
    end;
}

