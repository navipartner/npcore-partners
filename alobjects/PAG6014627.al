page 6014627 "Hardware Connector"
{
    // NPR5.51/MMV /20190731 CASE 360975 Created object
    // NPR5.53/MMV /20191111 CASE 375532 Added caption

    Caption = 'Hardware Connector';
    Editable = false;
    PageType = StandardDialog;

    // TODO: MMV - NaviPartner.Retail.Controls.Bridge can't be used or missing reference.
    /*

    layout
    {
        area(content)
        {
            field(PageCaption;PageCaption)
            {
ApplicationArea = All;
                Style = Strong;
                StyleExpr = TRUE;
            }
            usercontrol(Bridge;"NaviPartner.Retail.Controls.Bridge")
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
    */

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
        PageCaption: Text;

    procedure SetModule(htmlIn: Text; cssIn: Text; jsIn: Text; caption: Text)
    begin
        html := htmlIn;
        css := cssIn;
        js := jsIn;
        //-NPR5.53 [375532]
        PageCaption := caption;
        //+NPR5.53 [375532]
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

