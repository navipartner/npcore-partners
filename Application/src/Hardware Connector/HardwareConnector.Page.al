page 6014627 "NPR Hardware Connector"
{
    Extensible = False;
    Caption = 'Hardware Connector';
    Editable = false;
    PageType = StandardDialog;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            field(PageCaption; PageCaption)
            {

                Caption = 'Page Caption';
                Style = Strong;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the PageCaption field';
                ApplicationArea = NPRRetail;
            }
            usercontrol(Bridge; "NPR Bridge")
            {
                ApplicationArea = NPRRetail;


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

    var
        JavaScriptBridgeManagement: Codeunit "NPR JavaScript Bridge Mgt.";
        AutoClosed: Boolean;
        contentGlobal: JsonObject;
        css: Text;
        html: Text;
        js: Text;
        methodGlobal: Text;
        PageCaption: Text;

    procedure SetModule(htmlIn: Text; cssIn: Text; jsIn: Text; caption: Text)
    begin
        html := htmlIn;
        css := cssIn;
        js := jsIn;
        PageCaption := caption;
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

