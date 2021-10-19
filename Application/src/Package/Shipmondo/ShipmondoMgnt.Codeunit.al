codeunit 6014578 "NPR Shipmondo Mgnt."
{
    var
        PackageProviderSetup: Record "NPR Pacsoft Setup";
        ApiUser: Text;
        ApiKey: Text;
        RequestString: Text;
        RequestURL: Text;
        Text0001: Label 'Login Details Missing';
        ShipmondoErr: Label 'The following error occured while trying to create Shipmondo shipment:\\%1';

    local procedure SetProductAndServices(var PakkelabelsShipment: Record "NPR Pacsoft Shipment Document") services: Text;
    var
        ServicesCombination: Record "NPR Services Combination";
        Counter: Integer;
    begin
        ServicesCombination.SETRANGE("Shipping Agent", PakkelabelsShipment."Shipping Agent Code");
        ServicesCombination.SETRANGE("Shipping Service", PakkelabelsShipment."Shipping Agent Service Code");
        ServicesCombination.SETFILTER("Service Code", '<>%1', '');
        if ServicesCombination.FINDSET() then
            repeat
                if Counter = 0 then
                    services := ServicesCombination."Service Code"
                else
                    services += ',' + ServicesCombination."Service Code";
                Counter += 1;
            until ServicesCombination.NEXT() = 0;
    end;

    local procedure CreateShipment(var PakkelabelsShipment: Record "NPR Pacsoft Shipment Document"; Silent: Boolean);
    var
        ShipmentID: Code[20];
        ShipmentNumber: Code[50];
        Response: JsonToken;
    begin
        RequestURL := 'https://app.pakkelabels.dk/api/public/v3/shipments/';
        RequestString := BuildShipmentRequest(PakkelabelsShipment);
        if not ExecuteCall('POST', response, silent) then
            Exit;


        ShipmentID := CopyStr(GetJsonText(Response, 'id', 0), 1, 20);
        ShipmentNumber := CopyStr(GetJsonText(Response, 'pkg_no', 0), 1, 50);

        if ShipmentID <> '' then
            PakkelabelsShipment."Response Shipment ID" := ShipmentID;
        PakkelabelsShipment."Response Package No." := ShipmentNumber;
        PakkelabelsShipment."Creation Time" := CREATEDATETIME(TODAY, TIME);
        PakkelabelsShipment.MODIFY(true);
    end;

    procedure GetPrinters(_CurrentPage: Integer; silent: Boolean);
    var
        PakkelabelsPrinter: Record "NPR Package Printers";
        QueryParams: Text;
        PrinterName: Text;
        PrinterCount: Integer;
        i: Integer;
        Jarray: JsonArray;
        Jtoken: Jsontoken;
        QueryParamsLbl: Label 'page=%1&per_page=%2', Locked = true;
    begin
        RequestURL := 'https://app.pakkelabels.dk/api/public/v3/printers';
        QueryParams := '';

        if QueryParams <> '' then
            QueryParams += '&';
        QueryParams += STRSUBSTNO(QueryParamsLbl, _CurrentPage, 20);

        if QueryParams <> '' then
            RequestURL := RequestURL + '?' + QueryParams;

        if not ExecuteCall('GET', Jtoken, silent) then
            Exit;

        Jarray := Jtoken.AsArray();
        PrinterCount := GetArrayLength(Jarray);

        if PrinterCount > 0 then begin
            for i := 0 to PrinterCount do begin
                Jtoken := SetCurrentArrayIndex(i, Jarray);
                PrinterName := GetJsonText(JToken, 'name', 0);

                PakkelabelsPrinter.SETRANGE(Name, PrinterName);
                if not PakkelabelsPrinter.FINDFIRST() then begin
                    PakkelabelsPrinter.INIT();
                    PakkelabelsPrinter.Name := CopyStr(PrinterName, 1, 50);
                    PakkelabelsPrinter.INSERT(true);
                end;
                PakkelabelsPrinter."Host Name" := CopyStr(GetJsonText(JToken, 'hostname', 0), 1, 50);
                PakkelabelsPrinter.Printer := CopyStr(GetJsonText(JToken, 'printer', 0), 1, 50);
                PakkelabelsPrinter."Label Format" := CopyStr(GetJsonText(JToken, 'label_format', 0), 1, 30);
                PakkelabelsPrinter.MODIFY();
            end;
        end;
    end;

    local procedure BuildShipmentRequest(var PakkelabelsShipment: Record "NPR Pacsoft Shipment Document") Output: Text;
    var
        ShippingAgent: Record "NPR Package Shipping Agent";
        own_agreement: Text;
        test_mode: Text[10];
        QueryParamsLbl: Label '"test_mode": %1,', Locked = true;
        QueryParams2Lbl: Label '"own_agreement": %1,', Locked = true;
        QueryParams3Lbl: Label '"product_code": "%1",', Locked = true;
        QueryParams4Lbl: Label '"service_codes": "%1",', Locked = true;
        QueryParams5Lbl: Label '"automatic_select_service_point": true,', Locked = true;
        QueryParams6Lbl: Label '"sender": %1,', Locked = true;
        QueryParams7Lbl: Label '"receiver": %1,', Locked = true;
        QueryParams8Lbl: Label '"service_point": %1,', Locked = true;
        QueryParams9Lbl: Label '"parcels": %1,', Locked = true;
        QueryParams10Lbl: Label '"print_at": %1', Locked = true;
    begin
        if not InitPackageProvider() then
            exit;

        ShippingAgent.GET(PakkelabelsShipment."Shipping Agent Code");


        if ShippingAgent."Use own Agreement" then
            own_agreement := 'true'
        else
            own_agreement := 'false';


        if PackageProviderSetup."Pakkelable Test Mode" then
            test_mode := 'true'
        else
            test_mode := 'false';

        Output := '{';
        Output += STRSUBSTNO(QueryParamsLbl, test_mode);
        Output += '"replace_http_status_code": true,';

        Output += STRSUBSTNO(QueryParams2Lbl, own_agreement);

        Output += '"label_format": null,';
        Output += STRSUBSTNO(QueryParams3Lbl, PakkelabelsShipment."Shipping Agent Code");
        Output += STRSUBSTNO(QueryParams4Lbl, SetProductAndServices(PakkelabelsShipment));

        if (PakkelabelsShipment."Delivery Location" = '') and (ShippingAgent."Automatic Drop Point Service") then
            Output += STRSUBSTNO(QueryParams5Lbl);


        Output += STRSUBSTNO(QueryParams6Lbl, BuildSender());
        Output += STRSUBSTNO(QueryParams7Lbl, BuildReceiver(PakkelabelsShipment));

        if PakkelabelsShipment."Delivery Location" <> '' then
            Output += STRSUBSTNO(QueryParams8Lbl, BuildServicePoint(PakkelabelsShipment));

        Output += STRSUBSTNO(QueryParams9Lbl, BuildParcels(PakkelabelsShipment));

        if PrintAllowed(PakkelabelsShipment) then begin
            Output += '"print": true,';
            Output += STRSUBSTNO(QueryParams10Lbl, BuildPrintAt(PakkelabelsShipment));
        end else
            Output += '"print": false';

        Output += '}';
    end;

    local procedure BuildSender() Output: Text;
    var
        CompanyInformation: Record "Company Information";
        QueryParamsLbl: Label '"name": "%1",', Locked = true;
        QueryParams2Lbl: Label '"address1": "%1",', Locked = true;
        QueryParams3Lbl: Label '"address2": "%1",', Locked = true;
        QueryParams4Lbl: Label '"zipcode": "%1",', Locked = true;
        QueryParams5Lbl: Label '"city": "%1",', Locked = true;
        QueryParams6Lbl: Label '"country_code": "%1",', Locked = true;
        QueryParams7Lbl: Label '"mobile": "%1",', Locked = true;
        QueryParams8Lbl: Label '"telephone": "%1",', Locked = true;
        QueryParams9Lbl: Label '"email": "%1"', Locked = true;

    begin
        CompanyInformation.GET();
        Output := '{';
        Output += STRSUBSTNO(QueryParamsLbl, CompanyInformation.Name);
        Output += '"attention": null,';
        Output += STRSUBSTNO(QueryParams2Lbl, CompanyInformation.Address);
        Output += STRSUBSTNO(QueryParams3Lbl, CompanyInformation."Address 2");
        Output += STRSUBSTNO(QueryParams4Lbl, CompanyInformation."Post Code");
        Output += STRSUBSTNO(QueryParams5Lbl, CompanyInformation.City);
        Output += STRSUBSTNO(QueryParams6Lbl, CompanyInformation."Country/Region Code");
        Output += STRSUBSTNO(QueryParams7Lbl, CompanyInformation."Phone No.");
        Output += STRSUBSTNO(QueryParams8Lbl, CompanyInformation."Phone No.");
        Output += STRSUBSTNO(QueryParams9Lbl, CompanyInformation."E-Mail");
        Output += '}';
    end;

    local procedure BuildReceiver(var PakkelabelsShipment: Record "NPR Pacsoft Shipment Document") Output: Text;
    var
        QueryParamsLbl: Label '"name": "%1",', Locked = true;
        QueryParams2Lbl: Label '"attention": "%1",', Locked = true;
        QueryParams3Lbl: Label '"address1": "%1",', Locked = true;
        QueryParams4Lbl: Label '"address2": "%1",', Locked = true;
        QueryParams5Lbl: Label '"zipcode": "%1",', Locked = true;
        QueryParams6Lbl: Label '"city": "%1",', Locked = true;
        QueryParams7Lbl: Label '"country_code": "%1",', Locked = true;
        QueryParams8Lbl: Label '"email": "%1",', Locked = true;
        QueryParams9Lbl: Label '"mobile": "%1",', Locked = true;
        QueryParams10Lbl: Label '"telephone": "%1"', Locked = true;
        QueryParams11Lbl: Label ',"instruction":"%1",', Locked = true;
    begin
        Output := '{';
        Output += STRSUBSTNO(QueryParamsLbl, PakkelabelsShipment.Name);
        Output += STRSUBSTNO(QueryParams2Lbl, PakkelabelsShipment.Contact);
        Output += STRSUBSTNO(QueryParams3Lbl, PakkelabelsShipment.Address);
        if PakkelabelsShipment."Address 2" <> '' then
            Output += STRSUBSTNO(QueryParams4Lbl, PakkelabelsShipment."Address 2");

        Output += STRSUBSTNO(QueryParams5Lbl, PakkelabelsShipment."Post Code");
        Output += STRSUBSTNO(QueryParams6Lbl, PakkelabelsShipment.City);
        Output += STRSUBSTNO(QueryParams7Lbl, PakkelabelsShipment."Country/Region Code");
        Output += STRSUBSTNO(QueryParams8Lbl, PakkelabelsShipment."E-Mail");
        Output += STRSUBSTNO(QueryParams9Lbl, PakkelabelsShipment."SMS No.");
        Output += STRSUBSTNO(QueryParams10Lbl, PakkelabelsShipment."SMS No.");



        if (PackageProviderSetup."Send Delivery Instructions") and (PakkelabelsShipment."Delivery Instructions" <> '') then
            Output += STRSUBSTNO(QueryParams11Lbl, PakkelabelsShipment."Delivery Instructions");
        Output += '}';
    end;

    local procedure BuildServicePoint(var PakkelabelsShipment: Record "NPR Pacsoft Shipment Document") Output: Text;
    var
        QueryParamsLbl: Label '"id": "%1"', Locked = true;
    begin
        Output := '{';
        Output += STRSUBSTNO(QueryParamsLbl, PakkelabelsShipment."Delivery Location");
        Output += '}';
    end;

    local procedure BuildParcels(var PakkelabelsShipment: Record "NPR Pacsoft Shipment Document") Output: Text;
    var
        PakkeShippingAgent: Record "NPR Package Shipping Agent";
        QueryParamsLbl: Label '"weight":"%1"', Locked = true;
        QueryParams2Lbl: Label '"packaging":"%1"', Locked = true;
    begin
        PakkeShippingAgent.GET(PakkelabelsShipment."Shipping Agent Code");
        Output := '[';
        Output += '{';
        Output += STRSUBSTNO(QueryParamsLbl, FORMAT(PakkelabelsShipment."Total Weight", 0, 1));
        IF PakkeShippingAgent."Package Type Required" THEN BEGIN
            Output += ',';
            Output += STRSUBSTNO(QueryParams2Lbl, FORMAT(PakkelabelsShipment."Package Code", 0, 1));
        END;
        Output += '}';
        Output += ']';

    end;

    local procedure PrintAllowed(var PakkelabelsShipment: Record "NPR Pacsoft Shipment Document"): Boolean;
    var
        PakkelabelsPrinter: Record "NPR Package Printers";
    begin
        if not PackageProviderSetup."Use Pakkelable Printer API" then
            exit(false);

        PakkelabelsPrinter.SETRANGE("Location Code", PakkelabelsShipment."Location Code");
        if PakkelabelsPrinter.FINDFIRST() then
            exit(true)
        else
            exit(false);
    end;

    local procedure BuildPrintAt(var PakkelabelsShipment: Record "NPR Pacsoft Shipment Document") Output: Text;
    var
        PakkelabelsPrinter: Record "NPR Package Printers";
        QueryParamsLbl: Label '"host_name": "%1",', Locked = true;
        QueryParams2Lbl: Label '"printer_name": "%1",', Locked = true;
        QueryParams3Lbl: Label '"label_format": "%1"', Locked = true;
    begin
        PakkelabelsPrinter.SETRANGE("Location Code", PakkelabelsShipment."Location Code");
        if PakkelabelsPrinter.FINDFIRST() then begin
            Output := '{';
            Output += STRSUBSTNO(QueryParamsLbl, PakkelabelsPrinter."Host Name");
            Output += STRSUBSTNO(QueryParams2Lbl, PakkelabelsPrinter.Printer);
            Output += STRSUBSTNO(QueryParams3Lbl, PakkelabelsPrinter."Label Format");
            Output += '}';
        end;
    end;

    local procedure PrintJob(ShipmentDocument: Record "NPR Pacsoft Shipment Document") output: Text;
    var
        PakkelabelsPrinter: Record "NPR Package Printers";
        QueryParamsLbl: Label '"document_id":%1', Locked = true;
        QueryParams2Lbl: Label '"host_name": "%1",', Locked = true;
        QueryParams3Lbl: Label '"printer_name": "%1",', Locked = true;
        QueryParams4Lbl: Label '"label_format": "%1"', Locked = true;
    begin
        output := '{';
        output += STRSUBSTNO(QueryParamsLbl, ShipmentDocument."Response Shipment ID");
        output += '"document_type":"shipment"';
        PakkelabelsPrinter.SETRANGE("Location Code", ShipmentDocument."Location Code");
        if PakkelabelsPrinter.FINDFIRST() then;
        output += STRSUBSTNO(QueryParams2Lbl, PakkelabelsPrinter."Host Name");
        output += STRSUBSTNO(QueryParams3Lbl, PakkelabelsPrinter.Printer);
        output += STRSUBSTNO(QueryParams4Lbl, PakkelabelsPrinter."Label Format");
        output += '}';
    end;


    local procedure ExecuteCall(Method: Code[10]; Response: JsonToken; silent: boolean): Boolean;
    var

        Headers: HttpHeaders;
        Content: HttpContent;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;

    begin

        clear(RequestMessage);
        content.GetHeaders(Headers);
        Headers.clear();
        if Method in ['POST', 'PUT'] then begin
            Content.WriteFrom(RequestString);
            Content.GetHeaders(Headers);
            Headers.Remove('Content-Type');
            Headers.Add('Content-Type', 'application/json');
            RequestMessage.Content(Content);
        end;
        RequestMessage.SetRequestUri(RequestURL);
        RequestMessage.Method := Method;

        RequestMessage.GetHeaders(Headers);

        Headers.Remove('Authorization');
        Headers.Add('Authorization', 'Basic ' + HttpBasicAuthorization());
        if not SendHttpRequest(RequestMessage, ResponseText) then begin
            if silent then
                Message(GetLastErrorText())
            else
                error(GetLastErrorText());
            exit(false)
        end;

        Response.ReadFrom(ResponseText);

        exit(true);
    end;

    local procedure HttpBasicAuthorization() AuthText: Text;
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        if not InitPackageProvider() then
            exit;

        ApiUser := PackageProviderSetup."Api User";
        ApiKey := PackageProviderSetup."Api Key";

        AuthText := (Base64Convert.ToBase64(ApiUser + ':' + ApiKey, TextEncoding::UTF8));

    end;

    local procedure ValidateShipmentMethodCode(Rec: Record "Sales Header");
    var
        SalesLine: Record "Sales Line";
        PakkeShippingAgent: Record "NPR Package Shipping Agent";
    begin
        if not InitPackageProvider() then
            exit;
        if Rec."Shipment Method Code" = '' then exit;

        if PackageProviderSetup."Default Weight" <= 0 then
            exit;

        SalesLine.SETRANGE(SalesLine."Document Type", Rec."Document Type");
        SalesLine.SETRANGE("Document No.", Rec."No.");
        SalesLine.SETRANGE(Type, SalesLine.Type::Item);
        SalesLine.SETRANGE("Net Weight", 0);
        SalesLine.MODIFYALL("Net Weight", PackageProviderSetup."Default Weight");

        if not PakkeShippingAgent.GET(Rec."Shipping Agent Code") then
            exit;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Shipping Agent Service Code', false, false)]
    local procedure OnAfterModifyShippingAgentSerEventSalesHeader(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer);
    begin
        if Rec.ISTEMPORARY then
            exit;
        ValidateShipmentMethodCode(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure OnAfterModifyQtyEventSalesLine(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer);
    var
        SalesHeader: Record "Sales Header";
    begin

        if Rec.ISTEMPORARY then
            exit;

        if Rec.Quantity = 0 then
            exit;
        if not SalesHeader.GET(Rec."Document Type", Rec."Document No.") then
            exit;
        if SalesHeader."Shipment Method Code" = '' then
            exit;
        if not InitPackageProvider() then
            exit;

        if PackageProviderSetup."Default Weight" <= 0 then exit;

        if Rec."Net Weight" = 0 then begin
            Rec."Net Weight" := PackageProviderSetup."Default Weight";
            Rec.MODIFY();
        end;
    end;


    [EventSubscriber(ObjectType::Page, Page::"NPR Pacsoft Setup", 'GetPackageProvider', '', true, true)]
    local procedure IdentifyMe_GetPackageProvider(var Sender: Page "NPR Pacsoft Setup"; var tmpAllObjWithCaption: Record AllObjWithCaption temporary);
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if tmpAllObjWithCaption.ISTEMPORARY then begin
            AllObjWithCaption.GET(OBJECTTYPE::Codeunit, 6014578);
            tmpAllObjWithCaption.INIT();
            tmpAllObjWithCaption."Object Type" := AllObjWithCaption."Object Type";
            tmpAllObjWithCaption."Object ID" := AllObjWithCaption."Object ID";
            tmpAllObjWithCaption."Object Name" := AllObjWithCaption."Object Name";
            tmpAllObjWithCaption."Object Caption" := AllObjWithCaption."Object Caption";
            tmpAllObjWithCaption.INSERT();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', true, false)]
    local procedure C80OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header");
    var
        RecRefSalesHeader: RecordRef;
    begin
        if not InitPackageProvider() then
            exit;
        RecRefSalesHeader.GETTABLE(SalesHeader);
        TestFieldPakkelabels(RecRefSalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure C80OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]);
    var
        SalesShptHeader: Record "Sales Shipment Header";
        SalesSetup: Record "Sales & Receivables Setup";
        ShipmondoTryCreateShipment: Codeunit "NPR Shipmondo Try Create Shpt.";
    begin
        if not InitPackageProvider() then
            exit;

        if not SalesHeader.Ship then
            exit;

        if (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) or
            ((SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) and SalesSetup."Shipment on Invoice") then begin
            if SalesShptHeader.GET(SalesShptHdrNo) then begin
                if not ShipmondoTryCreateShipment.Run(SalesShptHeader) then // This will incur a commit
                    if GuiAllowed then
                        Message(ShipmondoErr, GetLastErrorText());
            end;
        end;
    end;

    local procedure InitPackageProvider(): Boolean;
    begin
        if not PackageProviderSetup.GET() then
            exit(false);

        if PackageProviderSetup."Package Service Codeunit ID" = 0 then
            exit(false);
        if (PackageProviderSetup."Package Service Codeunit ID" <> CODEUNIT::"NPR Shipmondo Mgnt.") then
            exit(false);

        if (PackageProviderSetup."Api User" = '') or (PackageProviderSetup."Api Key" = '') then
            ERROR(Text0001);

        exit(true);
    end;

    procedure TestFieldPakkelabels(RecRef: RecordRef);
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
        ShiptoAddress: Record "Ship-to Address";
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        PakkeShippingAgent: Record "NPR Package Shipping Agent";
    begin
        case RecRef.NUMBER of
            DATABASE::"Sales Header":
                begin
                    RecRef.SETTABLE(SalesHeader);
                    if SalesHeader.Find() then begin
                        if (SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) or (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) then begin

                            if SalesHeader."NPR Kolli" = 0 then
                                exit;
                            SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
                            SalesLine.SETRANGE("Document No.", SalesHeader."No.");
                            SalesLine.SETRANGE(Type, SalesLine.Type::Item);
                            SalesLine.SETFILTER("Net Weight", '<>0');
                            if SalesLine.IsEmpty() then
                                exit;


                            if not PakkeShippingAgent.GET(SalesHeader."Shipping Agent Code") then
                                exit;
                            if SalesHeader."Shipping Agent Service Code" = '' then
                                exit;

                            if PakkeShippingAgent."Package Type Required" then
                                SalesHeader.TESTFIELD("NPR Package Code");

                            if SalesHeader."Ship-to Code" <> '' then begin
                                ShiptoAddress.GET(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code");
                                if PakkeShippingAgent."Phone Mandatory" then
                                    ShiptoAddress.TESTFIELD("Phone No.");

                                if PakkeShippingAgent."Email Mandatory" then
                                    ShiptoAddress.TESTFIELD("E-Mail");

                            end else begin

                                Customer.GET(SalesHeader."Sell-to Customer No.");
                                if PakkeShippingAgent."Phone Mandatory" then
                                    Customer.TESTFIELD("Phone No.");

                                if PakkeShippingAgent."Email Mandatory" then
                                    Customer.TESTFIELD("E-Mail");
                            end;

                            SalesHeader.TESTFIELD("Ship-to Name");
                            SalesHeader.TESTFIELD("Ship-to Address");
                            SalesHeader.TESTFIELD("Ship-to Post Code");
                            SalesHeader.TESTFIELD("Ship-to City");

                            if PakkeShippingAgent."Ship to Contact Mandatory" then
                                SalesHeader.TESTFIELD("Ship-to Contact");
                        end;
                    end;
                end;
            DATABASE::"Sales Shipment Header":
                begin
                    RecRef.SETTABLE(SalesShipmentHeader);
                    IF SalesShipmentHeader.FIND() then begin

                        SalesShipmentHeader.TESTFIELD("Shipping Agent Code");
                        PakkeShippingAgent.GET(SalesShipmentHeader."Shipping Agent Code");

                        if PakkeShippingAgent."Package Type Required" then
                            SalesShipmentHeader.TESTFIELD("NPR Package Code");

                        SalesShipmentHeader.TESTFIELD("Shipping Agent Service Code");

                        PakkeShippingAgent.GET(SalesShipmentHeader."Shipping Agent Code", SalesShipmentHeader."Shipping Agent Service Code");
                        if SalesHeader."Ship-to Code" <> '' then begin
                            ShiptoAddress.GET(SalesShipmentHeader."Sell-to Customer No.", SalesShipmentHeader."Ship-to Code");
                            if PakkeShippingAgent."Phone Mandatory" then
                                ShiptoAddress.TESTFIELD("Phone No.");

                            if PakkeShippingAgent."Email Mandatory" then
                                ShiptoAddress.TESTFIELD("E-Mail");

                        end else begin

                            Customer.GET(SalesShipmentHeader."Sell-to Customer No.");
                            if PakkeShippingAgent."Phone Mandatory" then
                                Customer.TESTFIELD("Phone No.");

                            if PakkeShippingAgent."Email Mandatory" then
                                Customer.TESTFIELD("E-Mail");
                        end;

                        SalesShipmentHeader.TESTFIELD("Ship-to Name");
                        SalesShipmentHeader.TESTFIELD("Ship-to Address");
                        SalesShipmentHeader.TESTFIELD("Ship-to Post Code");
                        SalesShipmentHeader.TESTFIELD("Ship-to City");

                        if PakkeShippingAgent."Ship to Contact Mandatory" then
                            SalesShipmentHeader.TESTFIELD("Ship-to Contact");
                    end;
                end;
        end;
    end;

    local procedure CheckNetWeight(SalesShipmentHeader: Record "Sales Shipment Header"): Boolean;
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        SalesShipmentLine.SETRANGE("Document No.", SalesShipmentHeader."No.");
        SalesShipmentLine.SETFILTER("Net Weight", '<>%1', 0);
        exit(NOT SalesShipmentLine.IsEmpty());
    end;

    procedure AddEntry(RecRef: RecordRef; ShowWindow: Boolean; Silent: Boolean);
    var
        CompanyInfo: Record "Company Information";
        ShipmentDocument: Record "NPR Pacsoft Shipment Document";
        Customer: Record Customer;
        SalesShipmentHeader: Record "Sales Shipment Header";
        ShipToAddress: Record "Ship-to Address";
        SalesShipmentLine: Record "Sales Shipment Line";
        DocFound: Boolean;
    begin
        if not InitPackageProvider() then
            exit;

        ShipmentDocument.SETRANGE("Table No.", RecRef.NUMBER);
        ShipmentDocument.SETRANGE(RecordID, RecRef.RECORDID);
        if ShipmentDocument.FINDLAST() then
            DocFound := true
        else begin
            CLEAR(ShipmentDocument);
            ShipmentDocument.INIT();
            ShipmentDocument.VALIDATE("Entry No.", 0);
            ShipmentDocument.VALIDATE("Table No.", RecRef.NUMBER);
            ShipmentDocument.VALIDATE(RecordID, RecRef.RECORDID);
            ShipmentDocument.VALIDATE("Creation Time", CURRENTDATETIME);
        end;
        case RecRef.NUMBER of

            DATABASE::"Sales Shipment Header":
                begin
                    RecRef.SETTABLE(SalesShipmentHeader);
                    if SalesShipmentHeader.FIND() then begin

                        if SalesShipmentHeader."Shipment Method Code" = '' then exit;
                        if CheckNetWeight(SalesShipmentHeader) = false then exit;
                        if SalesShipmentHeader."NPR Kolli" = 0 then exit;
                        if not DocFound then
                            ShipmentDocument.INSERT(true);
                        Customer.GET(SalesShipmentHeader."Sell-to Customer No.");
                        CLEAR(ShipToAddress);
                        ShipmentDocument."Document No." := SalesShipmentHeader."No.";
                        ShipmentDocument."Document Type" := ShipmentDocument."Document Type"::"Posted Shipment";
                        ShipmentDocument."Location Code" := SalesShipmentHeader."Location Code";
                        if ShipToAddress.GET(SalesShipmentHeader."Sell-to Customer No.", SalesShipmentHeader."Ship-to Code") then begin
                            ShipmentDocument."Ship-to Code" := SalesShipmentHeader."Ship-to Code";
                            ShipmentDocument."E-Mail" := ShipToAddress."E-Mail";
                            ShipmentDocument."SMS No." := ShipToAddress."Phone No.";
                            ShipmentDocument."Phone No." := ShipToAddress."Phone No.";
                            ShipmentDocument."Fax No." := ShipToAddress."Fax No.";
                        end else begin
                            ShipmentDocument."E-Mail" := Customer."E-Mail";
                            ShipmentDocument."SMS No." := Customer."Phone No.";
                            ShipmentDocument."Phone No." := Customer."Phone No.";
                            ShipmentDocument."Fax No." := Customer."Fax No.";
                        end;

                        ShipmentDocument."Receiver ID" := SalesShipmentHeader."Sell-to Customer No.";
                        ShipmentDocument.Name := SalesShipmentHeader."Ship-to Name";
                        ShipmentDocument.Address := SalesShipmentHeader."Ship-to Address";
                        ShipmentDocument."Address 2" := SalesShipmentHeader."Ship-to Address 2";
                        ShipmentDocument."Post Code" := SalesShipmentHeader."Ship-to Post Code";
                        ShipmentDocument.City := SalesShipmentHeader."Ship-to City";
                        ShipmentDocument.County := SalesShipmentHeader."Ship-to County";
                        ShipmentDocument."Country/Region Code" := SalesShipmentHeader."Ship-to Country/Region Code";
                        ShipmentDocument.Contact := SalesShipmentHeader."Ship-to Contact";
                        ShipmentDocument.Reference := SalesShipmentHeader."Your Reference";
                        ShipmentDocument."Shipment Date" := SalesShipmentHeader."Shipment Date";
                        ShipmentDocument."VAT Registration No." := Customer."VAT Registration No.";


                        ShipmentDocument."Shipping Method Code" := SalesShipmentHeader."Shipment Method Code";
                        ShipmentDocument."Shipping Agent Code" := SalesShipmentHeader."Shipping Agent Code";
                        ShipmentDocument."Shipping Agent Service Code" := SalesShipmentHeader."Shipping Agent Service Code";
                        ShipmentDocument."Parcel Qty." := SalesShipmentHeader."NPR Kolli";
                        ShipmentDocument."Order No." := SalesShipmentHeader."Order No.";

                        ShipmentDocument."Package Code" := SalesShipmentHeader."NPR Package Code";

                        ShipmentDocument."Total Weight" := 0;
                        SalesShipmentLine.SETRANGE("Document No.", SalesShipmentHeader."No.");
                        SalesShipmentLine.SETRANGE(Type, SalesShipmentLine.Type::Item);
                        SalesShipmentLine.SETFILTER("Net Weight", '<>0');
                        if SalesShipmentLine.FINDSET() then
                            repeat
                                ShipmentDocument."Total Weight" += SalesShipmentLine."Net Weight" * SalesShipmentLine.Quantity;
                            until SalesShipmentLine.NEXT() = 0;
                        ShipmentDocument."Total Weight" := ROUND(ShipmentDocument."Total Weight", 1, '>') * 1000;
                        if SalesShipmentHeader."NPR Delivery Location" <> '' then begin
                            ShipmentDocument.Name := SalesShipmentHeader."Bill-to Name";
                            ShipmentDocument.Address := SalesShipmentHeader."Bill-to Address";
                            ShipmentDocument."Address 2" := SalesShipmentHeader."Bill-to Address 2";
                            ShipmentDocument."Post Code" := SalesShipmentHeader."Bill-to Post Code";
                            ShipmentDocument.City := SalesShipmentHeader."Bill-to City";
                            ShipmentDocument.County := SalesShipmentHeader."Bill-to County";
                            ShipmentDocument."Country/Region Code" := SalesShipmentHeader."Bill-to Country/Region Code";

                            ShipmentDocument."Delivery Location" := SalesShipmentHeader."NPR Delivery Location";
                            ShipmentDocument."Ship-to Name" := SalesShipmentHeader."Ship-to Name";
                            ShipmentDocument."Ship-to Address" := SalesShipmentHeader."Ship-to Address";
                            ShipmentDocument."Ship-to Address 2" := SalesShipmentHeader."Ship-to Address 2";
                            ShipmentDocument."Ship-to Post Code" := SalesShipmentHeader."Ship-to Post Code";
                            ShipmentDocument."Ship-to City" := SalesShipmentHeader."Ship-to City";
                            ShipmentDocument."Ship-to County" := SalesShipmentHeader."Ship-to County";
                            ShipmentDocument."Ship-to Country/Region Code" := SalesShipmentHeader."Ship-to Country/Region Code";
                            ShipmentDocument.Contact := SalesShipmentHeader."Ship-to Contact";
                        end;

                        if PackageProviderSetup."Order No. to Reference" then
                            if SalesShipmentHeader."Order No." <> '' then
                                ShipmentDocument.Reference := COPYSTR(SalesShipmentHeader."Order No.", 1,
                                                                      MAXSTRLEN(ShipmentDocument.Reference));

                        if (PackageProviderSetup."Order No. or Ext Doc No to ref") then begin
                            if SalesShipmentHeader."External Document No." <> '' then
                                ShipmentDocument.Reference := SalesShipmentHeader."External Document No."
                            else
                                ShipmentDocument.Reference := SalesShipmentHeader."Order No.";
                        end;
                        ShipmentDocument."External Document No." := SalesShipmentHeader."External Document No.";
                        ShipmentDocument."Delivery Instructions" := SalesShipmentHeader."NPR Delivery Instructions";
                        ShipmentDocument."Your Reference" := SalesShipmentHeader."Your Reference";

                    end;
                end;
        end;

        CompanyInfo.GET();
        ShipmentDocument."Sender VAT Reg. No" := CompanyInfo."VAT Registration No.";
        if ShipmentDocument."Country/Region Code" = '' then
            ShipmentDocument."Country/Region Code" := CompanyInfo."Country/Region Code";
        if ShipmentDocument."Shipment Date" < TODAY then
            ShipmentDocument."Shipment Date" := TODAY;

        ShipmentDocument.MODIFY(true);

        COMMIT();

        if PackageProviderSetup."Send Package Doc. Immediately" then
            CreateShipment(ShipmentDocument, Silent)
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Pacsoft Shipment Documents", 'OnAfterActionEvent', 'SendDocument', true, true)]
    local procedure P6014440OnAfterActionEventSendDoc(var Rec: Record "NPR Pacsoft Shipment Document");
    begin
        if not InitPackageProvider() then
            exit;
        CreateShipment(Rec, false)
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Sales Shipment", 'OnAfterActionEvent', 'NPR PrintShipmentDocument', true, true)]
    local procedure P130OnAfterActionEventCreatePackage(var Rec: Record "Sales Shipment Header");
    var
        SalesShptHeader: Record "Sales Shipment Header";
        ShipmentDocument: Record "NPR Pacsoft Shipment Document";
        RecRef: RecordRef;
        RecRefShipment: RecordRef;
        text000: Label 'Do you Want to create a Package entry ?';
        Text001: Label 'Do you want to print the Document?';
        Jtoken: JsonToken;

    begin
        if not InitPackageProvider() then
            exit;

        RecRef.GETTABLE(Rec);
        ShipmentDocument.SETRANGE("Table No.", RecRef.NUMBER);
        ShipmentDocument.SETRANGE(RecordID, RecRef.RECORDID);
        if ShipmentDocument.FINDLAST() then begin
            if CONFIRM(Text001, true) then
                if ShipmentDocument."Response Shipment ID" <> '' then begin
                    RequestURL := 'https://app.shipmondo.com/api/public/v3/print_jobs/';
                    RequestString := PrintJob(ShipmentDocument);
                    if ExecuteCall('POST', Jtoken, false) then
                        Exit;
                end
                else begin
                    AddEntry(RecRef, false, false);

                end;
        end
        else begin
            RecRefShipment.GETTABLE(SalesShptHeader);
            TestFieldPakkelabels(RecRefShipment);
            if CONFIRM(text000, true) then
                AddEntry(RecRefShipment, false, false);
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Pacsoft Shipment Documents", 'OnAfterActionEvent', 'PrintDocument', false, false)]
    local procedure P6014440OnAfterActionEventPrintDocument(var Rec: Record "NPR Pacsoft Shipment Document");
    var
        JToken: JsonToken;
    begin

        if not InitPackageProvider() then
            exit;

        if Rec."Response Shipment ID" <> '' then begin
            RequestURL := 'https://app.shipmondo.com/api/public/v3/print_jobs/';
            RequestString := PrintJob(Rec);
            if ExecuteCall('POST', JToken, false) then;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterModifyEvent', '', true, true)]
    local procedure T36OnAfterModifyEvent(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; RunTrigger: Boolean);
    var
        ForeignShipmentMapping: Record "NPR Pakke Foreign Shipm. Map.";
    begin
        if not RunTrigger then
            exit;
        if not InitPackageProvider() then
            exit;
        if (Rec."Shipment Method Code" = '') or (Rec."Shipping Agent Code" = '') then
            exit;
        ForeignShipmentMapping.SETRANGE("Shipment Method Code", Rec."Shipment Method Code");
        ForeignShipmentMapping.SETRANGE("Base Shipping Agent Code", Rec."Shipping Agent Code");
        ForeignShipmentMapping.SETRANGE("Country/Region Code", Rec."Ship-to Country/Region Code");
        if ForeignShipmentMapping.FINDFIRST() then begin
            Rec."Shipping Agent Code" := ForeignShipmentMapping."Shipping Agent Code";
            Rec."Shipping Agent Service Code" := ForeignShipmentMapping."Shipping Agent Service Code";
            Rec.MODIFY(true);
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Pacsoft Setup", 'OnAfterActionEvent', 'Check Balance', false, false)]
    local procedure GetBalance(var Rec: Record "NPR Pacsoft Setup");
    var
        Jtoken: JsonToken;
    begin
        if not InitPackageProvider() then
            exit;
        RequestURL := 'https://app.shipmondo.com/api/public/v3/account/balance';
        if not ExecuteCall('GET', Jtoken, False) then
            exit;
        message(GetJsonText(JToken, 'amount', 0));
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Package Printers", 'OnAfterActionEvent', 'GetPrinter', false, false)]
    local procedure FetchPrinters(var Rec: Record "NPR Package Printers");
    begin
        GetPrinters(1, false);
    end;

    procedure GetArrayLength(Jarray: JsonArray) ArrayLength: Integer;

    begin
        ArrayLength := jArray.Count;
    end;

    procedure SetCurrentArrayIndex(ArrayIndex: Integer; jArray: JsonArray) Jtoken: Jsontoken;
    begin

        if jArray.count = 0 then
            ERROR('NULL Array');
        if JArray.get(ArrayIndex, Jtoken) then;


    end;

    local procedure GetJsonText(JToken: JsonToken; Path: Text; MaxLen: Integer) Value: Text
    var
        Token2: JsonToken;
        Jvalue: JsonValue;
    begin

        if not JToken.SelectToken(Path, Token2) then
            exit('');
        Jvalue := token2.asValue();
        if Jvalue.IsNull then
            exit('');

        Value := Jvalue.AsText();

        if MaxLen > 0 then
            Value := CopyStr(Value, 1, MaxLen);

        exit(Value)
    end;

    [TryFunction]
    local procedure SendHttpRequest(Var RequestMessage: HttpRequestMessage; var ResponseText: Text);
    var
        Client: HttpClient;
        ErrorText: Text;
        ResponseMessage: HttpResponseMessage;
        Response: JsonToken;
    begin
        Clear(ResponseMessage);
        if not Client.Send(RequestMessage, ResponseMessage) then
            Error(GetLastErrorText);

        if not ResponseMessage.IsSuccessStatusCode() then begin
            ErrorText := Format(ResponseMessage.HttpStatusCode(), 0, 9) + ': ' + ResponseMessage.ReasonPhrase;
            if ResponseMessage.Content.ReadAs(ResponseText) then
                ErrorText += ':\' + ResponseText;
            Error(CopyStr(ErrorText, 1, 1000));
        end;


        ResponseMessage.Content.ReadAs(ResponseText);
        Response.ReadFrom(ResponseText);
        if (GetJsonText(Response, 'error', 0)) <> '' then
            error(ResponseText);
    end;

}

