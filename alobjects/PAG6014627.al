page 6014627 "Hardware Connector"
{
    // NPR5.51/MMV /20190731 CASE 360975 Created object

    Caption = 'Hardware Connector';
    Editable = false;
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            usercontrol(Bridge; Bridge)
            {

                trigger OnFrameworkReady()
                begin
                    JavaScriptBridgeManagement.Initialize(CurrPage.Bridge);
                    JavaScriptBridgeManagement.SetSize('100%', '100%');
                    JavaScriptBridgeManagement.RegisterAdHocModule('HardwareConnector', html, css, js);
                end;

                trigger OnInvokeMethod(method: Text; eventContent: JsonObject)
                begin
                    if not (method in ['error', 'result']) then
                        exit;

                    methodGlobal := method;
                    contentGlobal := eventContent;
                    AutoClosed := true;
                    CurrPage.Close();
                end;
            }
        }
    }

    actions
    {
    }

    var
        JavaScriptBridgeManagement: Codeunit "JavaScript Bridge Management";
        html: Text;
        css: Text;
        js: Text;
        methodGlobal: Text;
        contentGlobal: JsonObject;
        AutoClosed: Boolean;

    procedure SetModule(htmlIn: Text; cssIn: Text; jsIn: Text)
    begin
        html := htmlIn;
        css := cssIn;
        js := jsIn;
    end;

    procedure GetResponse(var methodOut: Text; var contentOut: JsonObject)
    begin
        methodOut := methodGlobal;
        contentOut := contentGlobal;
    end;

    procedure DidAutoClose(): Boolean
    begin
        exit(AutoClosed);
    end;
}

