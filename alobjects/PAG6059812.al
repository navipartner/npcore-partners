page 6059812 "Retail Activities"
{
    // NC1.17 /MHA /20150423  CASE 212263 Created NaviConnect Role Center
    // NC1.17 /BHR /20150428  CASE 212069 Added the following cues
    //                                               "Sales Orders"
    //                                               "Sales Quotes"
    //                                               "Sales Return Orders"
    //                                               "Internet orders"
    // NC1.17 /MHA /20150514  CASE 213393 Removed custom caption of "Dailey Sales Orders"
    // NC1.22 /MHA /20160213  CASE 234030 Added wrapper groups around cuegroups in order to achieve three rows
    // NPR5.23.03/MHA/20160726  CASE 242557 Object renamed and re-versioned from NC1.17 to NPR5.23.03
    // NPR5.26/20160830       CASE 250405 Field  Processed error tasks
    // NPR5.30/MHA /20170130  CASE 264958 Field added: 40 Pending Inc. Documents
    // NPR5.30/BHR /20170207  CASE 264863 Field added: 45 "Failed Magento Payments"
    // NPR5.33/LS  /20170605  CASE 279274 Re-ordered Cues + made some Visible = False + Deleted control action "Page Sales Return Order"
    // NPR5.40/MHA /20180328  CASE 308907 Added Non-visible Bridge Part for Geolocation Tracking
    // NPR5.42/CLVA/20180508 CASE 313575 Combined the collection of client ip address and geolocation in a single api.ipstack.com request
    // NPR5.55/ZESO/20200730 CASE 416669 Change Image Property on field "Sales Orders" from Stack to None.
    // NPR5.55/YAHA/20200731 CASE 416999 Image Property on all cues set to None

    Caption = 'Retail Activities';
    PageType = CardPart;
    SourceTable = "Retail Sales Cue";

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
                    Image = "None";
                }
                field("Daily Sales Orders"; "Daily Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    Image = "None";
                }
                field("Import Pending"; "Import Pending")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Nc Import List";
                    Image = "None";
                }

                actions
                {
                    action("New Sales Order")
                    {
                        Caption = 'New Sales Order';
                        RunObject = Page "Sales Order";
                        RunPageMode = Create;
                    }
                    action("New Sales Quote")
                    {
                        Caption = 'New Sales Quote';
                        RunObject = Page "Sales Quote";
                        RunPageMode = Create;
                    }
                }
            }
            cuegroup(Control6150622)
            {
                ShowCaption = false;
                field("Pending Inc. Documents"; "Pending Inc. Documents")
                {
                    ApplicationArea = All;
                    Image = "None";
                }
                field("Processed Error Tasks"; "Processed Error Tasks")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Nc Task List";
                    Image = "None";
                }
                field("Failed Webshop Payments"; "Failed Webshop Payments")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Magento Payment Line List";
                    Image = "None";
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
                    Image = "None";
                    Visible = false;
                }
                field("Sales Return Orders"; "Sales Return Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Return Order List";
                    Image = "None";
                    Visible = false;
                }
                field("Magento Orders"; "Magento Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    Image = "None";
                    Visible = false;
                }
                field("Daily Sales Invoices"; "Daily Sales Invoices")
                {
                    ApplicationArea = All;
                    Caption = 'Daily Sales Invoices';
                    DrillDownPageID = "Posted Sales Invoices";
                    Image = "None";
                    Visible = false;
                }
                field("Tasks Unprocessed"; "Tasks Unprocessed")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Nc Task List";
                    Image = "None";
                    Visible = false;
                }
            }
            usercontrol(Bridge; Bridge)
            {

                trigger OnFrameworkReady()
                begin
                    //-NPR5.40 [308907]
                    Initialize();
                    //+NPR5.40 [308907]
                end;

                trigger OnInvokeMethod(method: Text; eventContent: JsonObject)
                begin
                    //-NPR5.40 [308907]
                    InvokeMethod(method, eventContent);
                    //+NPR5.40 [308907]
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
        NPRetailSetup: Record "NP Retail Setup";

    local procedure Initialize()
    var
        POSGeolocation: Codeunit "POS Geolocation";
    begin
        //-NPR5.40 [308907]
        if POSGeolocation.SkipGeolocationTracking() then
            exit;

        SetSize('0px', '0px');
        RegisterGeoLocationScript();
        //+NPR5.40 [308907]
    end;

    local procedure SetSize(Width: Text; Height: Text)
    var
        SetSizeRequest: JsonObject;
    begin
        //-NPR5.40 [308907]
        InitializeRequest('SetSize', SetSizeRequest);
        if Width <> '' then
            SetSizeRequest.Add('width', Width);
        if Height <> '' then
            SetSizeRequest.Add('height', Height);
        InvokeFrontEndAsync(SetSizeRequest);
        //+NPR5.40 [308907]
    end;

    local procedure InitializeRequest(Method: Text; var Request: JsonObject)
    begin
        //-NPR5.40 [308907]
        Request.Add('Method', Method);
        //-NPR5.40 [308907]
    end;

    local procedure InvokeFrontEndAsync(Request: JsonObject)
    begin
        //-NPR5.40 [308907]
        CurrPage.Bridge.InvokeFrontEndAsync(Request);
        //+NPR5.40 [308907]
    end;

    local procedure RegisterGeoLocationScript()
    var
        RegisterModuleRequest: JsonObject;
        ScriptString: Text;
    begin
        //-NPR5.40 [308907]
        InitializeRequest('RegisterModule', RegisterModuleRequest);

        RegisterModuleRequest.Add('Name', 'GeoLocationByIP');

        ScriptString := '(function() {' +
        '$("#controlAddIn").append("' +
        '<div />");' +
        ' var geolocation = new n$.Event.Method("GeoLocationMethod"); ' +
        ' $.ajax({' +
        //-NPR5.42 [313575]
        //'   url: "https://navipartnerfa.azurewebsites.net/api/GetClientIPAddress?code=eavZjqJdKVynQxzsYPnsYpBGmSm61nxavel2VGulz6R5CrAxqhi6JA==",' +
        '   url: "https://api.ipstack.com/check?access_key=b29d29cb640d98bf01c320640e432f59",' +
        //+NPR5.42 [313575]
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
        //+NPR5.40 [308907]
    end;

    local procedure InvokeMethod(Method: Text; EventContent: JsonObject)
    begin
        //-NPR5.40 [308907]
        case Method of
            'RequestModule':
                Method_RequestModule(EventContent);
            'GeoLocationMethod':
                Method_GeoLocationMethod(EventContent);
        end;
        //+NPR5.40 [308907]
    end;

    local procedure Method_RequestModule(EventContent: JsonObject)
    var
        Web: Record "Web Client Dependency";
        JSON: Codeunit "POS JSON Management";
        FrontEnd: Codeunit "POS Front End Management";
        RegisterModuleRequest: JsonObject;
        Module: Text;
        Script: Text;
    begin
        //-NPR5.40 [308907]
        JSON.InitializeJObjectParser(EventContent, FrontEnd);
        Module := JSON.GetString('module', true);

        Script := Web.GetJavaScript(Module);
        if Script = '' then
            Error('');

        InitializeRequest('RegisterModule', RegisterModuleRequest);
        RegisterModuleRequest.Add('Name', Module);
        RegisterModuleRequest.Add('Script', Script);
        InvokeFrontEndAsync(RegisterModuleRequest);
        //+NPR5.40 [308907]
    end;

    local procedure Method_GeoLocationMethod(EventContent: JsonObject)
    var
        POSGeolocation: Codeunit "POS Geolocation";
        JsonText: Text;
    begin
        //-NPR5.40 [308907]
        EventContent.WriteTo(JsonText);
        POSGeolocation.TrackGeoLocationByIP(JsonText);
        //+NPR5.40 [308907]
    end;
}

