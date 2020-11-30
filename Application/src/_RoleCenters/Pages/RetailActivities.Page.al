page 6059812 "NPR Retail Activities"
{
    Caption = 'Retail Activities';
    PageType = CardPart;
    UsageCategory = Administration;
    SourceTable = "NPR Retail Sales Cue";

    layout
    {
        area(content)
        {
            cuegroup(Control6150623)
            {
                ShowCaption = false;
                field("Sales Orders"; "Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    Image = "Document";
                }
                field("Daily Sales Orders"; "Daily Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    Image = "Document";
                }
                field("Import Pending"; "Import Pending")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Nc Import List";
                    Image = "Document";
                }

                actions
                {
                    action("New Sales Order")
                    {
                        Caption = 'New Sales Order';
                        RunObject = Page "Sales Order";
                        RunPageMode = Create;
                        ApplicationArea = All;
                    }
                    action("New Sales Quote")
                    {
                        Caption = 'New Sales Quote';
                        RunObject = Page "Sales Quote";
                        RunPageMode = Create;
                        ApplicationArea = All;
                    }
                }
            }
            cuegroup(Control6150622)
            {
                ShowCaption = false;
                field("Pending Inc. Documents"; "Pending Inc. Documents")
                {
                    ApplicationArea = All;
                    Image = "Document";
                }
                field("Processed Error Tasks"; "Processed Error Tasks")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Nc Task List";
                    Image = "Document";
                }
                field("Failed Webshop Payments"; "Failed Webshop Payments")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Magento Payment Line List";
                    Image = "Document";
                }
            }
            cuegroup(Depreciated)
            {
                Caption = 'Depreciated';
                Visible = false;
                field("Sales Quotes"; "Sales Quotes")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Quotes";
                    Image = "Document";
                    Visible = false;
                }
                field("Sales Return Orders"; "Sales Return Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Return Order List";
                    Image = "Document";
                    Visible = false;
                }
                field("Magento Orders"; "Magento Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    Image = "Document";
                    Visible = false;
                }
                field("Daily Sales Invoices"; "Daily Sales Invoices")
                {
                    ApplicationArea = All;
                    Caption = 'Daily Sales Invoices';
                    DrillDownPageID = "Posted Sales Invoices";
                    Image = "Document";
                    Visible = false;
                }
                field("Tasks Unprocessed"; "Tasks Unprocessed")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Nc Task List";
                    Image = "Document";
                    Visible = false;
                }
            }
            usercontrol(Bridge; "NPR Bridge")
            {
                ApplicationArea = All;

                trigger OnFrameworkReady()
                begin
                    Initialize();
                end;

                trigger OnInvokeMethod(method: Text; eventContent: JsonObject)
                begin
                    InvokeMethod(method, eventContent);
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Action Items")
            {
                Caption = 'Action Items';
                ApplicationArea = All;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
        SetFilter("Date Filter", '=%1', WorkDate);
    end;

    var
        PING: Label '''';
        NPRetailSetup: Record "NPR NP Retail Setup";

    local procedure Initialize()
    var
        POSGeolocation: Codeunit "NPR POS Geolocation";
    begin
        if POSGeolocation.SkipGeolocationTracking() then
            exit;

        SetSize('0px', '0px');
        RegisterGeoLocationScript();
    end;

    local procedure SetSize(Width: Text; Height: Text)
    var
        SetSizeRequest: JsonObject;
    begin
        InitializeRequest('SetSize', SetSizeRequest);
        if Width <> '' then
            SetSizeRequest.Add('width', Width);
        if Height <> '' then
            SetSizeRequest.Add('height', Height);
        InvokeFrontEndAsync(SetSizeRequest);
    end;

    local procedure InitializeRequest(Method: Text; var Request: JsonObject)
    begin
        Request.Add('Method', Method);
    end;

    local procedure InvokeFrontEndAsync(Request: JsonObject)
    begin
        CurrPage.Bridge.InvokeFrontEndAsync(Request);
    end;

    local procedure RegisterGeoLocationScript()
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        RegisterModuleRequest: JsonObject;
        ScriptString: Text;
    begin
        InitializeRequest('RegisterModule', RegisterModuleRequest);

        RegisterModuleRequest.Add('Name', 'GeoLocationByIP');

        ScriptString := '(function() {' +
        '$("#controlAddIn").append("' +
        '<div />");' +
        ' var geolocation = new n$.Event.Method("GeoLocationMethod"); ' +
        ' $.ajax({' +
        '   url: "https://api.ipstack.com/check?access_key=' + AzureKeyVaultMgt.GetSecret('IPStackApiKey') + '",' +
        '   success: function (result) {' +
        '     geolocation.raise(result);' +
        '   },' +
        '   error: function (xhr, ajaxOptions, thrownError) {' +
        '     geolocation.raise(xhr.responseText);' +
        '   }' +
        '});' +
        '})()';

        RegisterModuleRequest.Add('Script', ScriptString);

        RegisterModuleRequest.Add('Requires', 'jQuery');
        InvokeFrontEndAsync(RegisterModuleRequest);
    end;

    local procedure InvokeMethod(Method: Text; EventContent: JsonObject)
    begin
        case Method of
            'RequestModule':
                Method_RequestModule(EventContent);
            'GeoLocationMethod':
                Method_GeoLocationMethod(EventContent);
        end;
    end;

    local procedure Method_RequestModule(EventContent: JsonObject)
    var
        Web: Record "NPR Web Client Dependency";
        JSON: Codeunit "NPR POS JSON Management";
        FrontEnd: Codeunit "NPR POS Front End Management";
        RegisterModuleRequest: JsonObject;
        Module: Text;
        Script: Text;
    begin
        JSON.InitializeJObjectParser(EventContent, FrontEnd);
        Module := JSON.GetString('module', true);

        Script := Web.GetJavaScript(Module);
        if Script = '' then
            Error('');

        InitializeRequest('RegisterModule', RegisterModuleRequest);
        RegisterModuleRequest.Add('Name', Module);
        RegisterModuleRequest.Add('Script', Script);
        InvokeFrontEndAsync(RegisterModuleRequest);
    end;

    local procedure Method_GeoLocationMethod(EventContent: JsonObject)
    var
        POSGeolocation: Codeunit "NPR POS Geolocation";
        JsonText: Text;
    begin
        EventContent.WriteTo(JsonText);
        POSGeolocation.TrackGeoLocationByIP(JsonText);
    end;
}