codeunit 6014578 "NPR Shipmondo Mgnt." implements "NPR IShipping Provider Interface"
{
    Access = Internal;

    var
        PackageProviderSetup: Record "NPR Shipping Provider Setup";
        PackageMgt: codeunit "NPR Package Management";
        ApiUser: Text;
        ApiKey: Text;
        RequestString: Text;
        RequestURL: Text;
        Text0001: label 'Shipmondo Login Details Missing';


    local procedure SetProductAndServices(var PakkelabelsShipment: Record "NPR Shipping Provider Document") services: Text;
    var
        ServicesCombination: Record "NPR Shipping Provider Services";
        Counter: Integer;
    begin
        ServicesCombination.SetRange("Shipping Agent", PakkelabelsShipment."Shipping Agent Code");
        ServicesCombination.SetRange("Shipping Service", PakkelabelsShipment."Shipping Agent Service Code");
        ServicesCombination.SetFilter("Service Code", '<>%1', '');
        if ServicesCombination.FindSet() then
            repeat
                if Counter = 0 then
                    services := ServicesCombination."Service Code"
                else
                    services += ',' + ServicesCombination."Service Code";
                Counter += 1;
            until ServicesCombination.Next() = 0;
    end;

    local procedure CreateShipment(var PakkelabelsShipment: Record "NPR Shipping Provider Document"; Silent: Boolean);
    var
        ShipmentID: Code[20];
        ShipmentNumber: Code[50];
        Response: JsonToken;
        NPRShippingAgent: Record "NPR Package Shipping Agent";
    begin
        if not NPRShippingAgent.Get(PakkelabelsShipment."Shipping Agent Code") then
            exit;
        RequestURL := BaseURL() + 'shipments/';
        RequestString := BuildShipmentRequest(PakkelabelsShipment);
        if not ExecuteCall('POST', Response, Silent) then begin
            SetShippingDocumentRequestAndResponseSource(PakkelabelsShipment, RequestString, Response);
            exit;
        end;


        ShipmentID := CopyStr(GetJsonText(Response, 'id', 0), 1, 20);
        ShipmentNumber := CopyStr(GetJsonText(Response, 'pkg_no', 0), 1, 50);

        if ShipmentID <> '' then
            PakkelabelsShipment."Response Shipment ID" := ShipmentID;
        PakkelabelsShipment."Response Package No." := ShipmentNumber;
        PakkelabelsShipment."Creation Time" := CreateDateTime(Today, Time);
        SetShippingDocumentRequestAndResponseSource(PakkelabelsShipment, RequestString, Response);
        PakkelabelsShipment.Modify(true);
    end;

    local procedure SetShippingDocumentRequestAndResponseSource(var ShippingProviderDocument: Record "NPR Shipping Provider Document"; RequestText: Text; var Response: JsonToken)
    var
        ResponseText: Text;
        OutStr: OutStream;
    begin
        ShippingProviderDocument."Request XML Name" := 'Request ' +
                                                Format(Today) +
                                                ' ' +
                                                Format(Time, 0, '<Hours24,2>-<Minutes,2>-<Seconds,2>') +
                                                ' ' +
                                                Format(ShippingProviderDocument."Entry No.") +
                                                '.json';
        Clear(ShippingProviderDocument."Request XML");
        ShippingProviderDocument."Request XML".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(RequestText);

        Clear(OutStr);
        if Response.WriteTo(ResponseText) then;
        ShippingProviderDocument."Response XML Name" := 'Response ' +
                                                      Format(Today) +
                                                      ' ' +
                                                      Format(Time, 0, '<Hours24,2>-<Minutes,2>-<Seconds,2>') +
                                                      ' ' +
                                                      Format(ShippingProviderDocument."Entry No.") +
                                                      '.json';
        Clear(ShippingProviderDocument."Response XML");
        ShippingProviderDocument."Response XML".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(ResponseText);
        if GetLastErrorText() <> '' then
            ShippingProviderDocument.Modify(true);
    end;

    procedure GetPrinters(_CurrentPage: Integer; silent: Boolean);
    var
        PakkelabelsPrinter: Record "NPR Package Printers";
        QueryParams: Text;
        PrinterName: Text;
        PrinterCount: Integer;
        i: Integer;
        Jarray: JsonArray;
        Jtoken: JsonToken;
        QueryParamsLbl: label 'page=%1&per_page=%2', Locked = true;
    begin
        RequestURL := BaseURL() + 'printers';
        QueryParams := '';

        if QueryParams <> '' then
            QueryParams += '&';
        QueryParams += StrSubstNo(QueryParamsLbl, _CurrentPage, 20);

        if QueryParams <> '' then
            RequestURL := RequestURL + '?' + QueryParams;

        if not ExecuteCall('GET', Jtoken, silent) then
            exit;

        Jarray := Jtoken.AsArray();
        PrinterCount := GetArrayLength(Jarray);

        if PrinterCount > 0 then begin
            for i := 0 to PrinterCount do begin
                Jtoken := SetCurrentArrayIndex(i, Jarray);
                PrinterName := GetJsonText(Jtoken, 'name', 0);

                PakkelabelsPrinter.SetRange(Name, PrinterName);
                if not PakkelabelsPrinter.FindFirst() then begin
                    PakkelabelsPrinter.Init();
                    PakkelabelsPrinter.Name := CopyStr(PrinterName, 1, 50);
                    PakkelabelsPrinter.Insert(true);
                end;
                PakkelabelsPrinter."Host Name" := CopyStr(GetJsonText(Jtoken, 'hostname', 0), 1, 50);
                PakkelabelsPrinter.Printer := CopyStr(GetJsonText(Jtoken, 'printer', 0), 1, 50);
                PakkelabelsPrinter."label Format" := CopyStr(GetJsonText(Jtoken, 'label_format', 0), 1, 30);
                PakkelabelsPrinter.Modify();
            end;
        end;
    end;

    local procedure BuildShipmentRequest(var PakkelabelsShipment: Record "NPR Shipping Provider Document") Output: Text;
    var
        ShippingAgent: Record "NPR Package Shipping Agent";
        ShipmondoEvents: Codeunit "NPR Shipmondo Events";
        own_agreement: Text;
        test_mode: Text[10];
        QueryParamsLbl: label '"test_mode": %1,', Locked = true;
        QueryParams2Lbl: label '"own_agreement": %1,', Locked = true;
        QueryParams3Lbl: label '"product_code": "%1",', Locked = true;
        QueryParams4Lbl: label '"service_codes": "%1",', Locked = true;
        QueryParams5Lbl: label '"automatic_select_service_point": true,', Locked = true;
        QueryParams6Lbl: label '"sender": %1,', Locked = true;
        QueryParams7Lbl: label '"receiver": %1,', Locked = true;
        QueryParams8Lbl: label '"service_point": %1,', Locked = true;
        QueryParams9Lbl: label '"parcels": %1,', Locked = true;
        QueryParams10Lbl: label '"print_at": %1', Locked = true;
        QueryParams11Lbl: label '"reference": "%1",', Locked = true;
    begin
        if not InitPackageProvider() then
            exit;

        ShippingAgent.Get(PakkelabelsShipment."Shipping Agent Code");


        if ShippingAgent."Use own Agreement" then
            own_agreement := 'true'
        else
            own_agreement := 'false';


        if PackageProviderSetup."Pakkelable Test Mode" then
            test_mode := 'true'
        else
            test_mode := 'false';

        Output := '{';
        Output += StrSubstNo(QueryParamsLbl, test_mode);
        Output += '"replace_http_status_code": true,';

        Output += StrSubstNo(QueryParams2Lbl, own_agreement);

        Output += '"label_format": null,';
        Output += StrSubstNo(QueryParams3Lbl, ShippingAgent."Shipping Provider Code");
        Output += StrSubstNo(QueryParams4Lbl, SetProductAndServices(PakkelabelsShipment));
        Output += StrSubstNo(QueryParams11Lbl, PakkelabelsShipment.Reference);

        if (PakkelabelsShipment."Delivery Location" = '') and (ShippingAgent."Automatic Drop Point Service") then
            Output += StrSubstNo(QueryParams5Lbl);


        Output += StrSubstNo(QueryParams6Lbl, BuildSender(PakkelabelsShipment));
        Output += StrSubstNo(QueryParams7Lbl, BuildReceiver(PakkelabelsShipment));

        if PakkelabelsShipment."Delivery Location" <> '' then
            Output += StrSubstNo(QueryParams8Lbl, BuildServicePoint(PakkelabelsShipment));

        Output += StrSubstNo(QueryParams9Lbl, BuildParcels(PakkelabelsShipment));
        Output += BuildCustoms((PakkelabelsShipment));

        if PrintAllowed(PakkelabelsShipment) then begin
            Output += '"print": true,';
            Output += StrSubstNo(QueryParams10Lbl, BuildPrintAt(PakkelabelsShipment));
        end else
            Output += '"print": false';

        ShipmondoEvents.OnBeforeEndShipmentBuild(PakkelabelsShipment, Output);

        Output += '}';

        ShipmondoEvents.OnAfterShipmentBuild(PakkelabelsShipment, Output);
    end;

    local procedure BuildSender(PakkelabelsShipment: Record "NPR Shipping Provider Document") Output: Text;
    var
        CompanyInformation: Record "Company Information";
        ShipProvPublicAccess: Codeunit "NPR Ship. Prov.Public Access";
        QueryParamsLbl: label '"name": "%1",', Locked = true;
        QueryParams2Lbl: label '"address1": "%1",', Locked = true;
        QueryParams3Lbl: label '"address2": "%1",', Locked = true;
        QueryParams4Lbl: label '"zipcode": "%1",', Locked = true;
        QueryParams5Lbl: label '"city": "%1",', Locked = true;
        QueryParams6Lbl: label '"country_code": "%1",', Locked = true;
        QueryParams7Lbl: label '"mobile": "%1",', Locked = true;
        QueryParams8Lbl: label '"telephone": "%1",', Locked = true;
        QueryParams9Lbl: label '"email": "%1"', Locked = true;
        Runtrigger: Boolean;
        SenderAddress1: Text;
        SenderAddress2: Text;
    begin
        ShipProvPublicAccess.OnBeforeAssignSender(PakkelabelsShipment, Output, Runtrigger);
        if Runtrigger then
            exit;
        CompanyInformation.Get();

        CreateAddressFields(CompanyInformation.Address, CompanyInformation."Address 2", SenderAddress1, SenderAddress2);

        Output := '{';
        Output += StrSubstNo(QueryParamsLbl, CompanyInformation.Name);
        Output += '"attention": null,';
        Output += StrSubstNo(QueryParams2Lbl, SenderAddress1);
        Output += StrSubstNo(QueryParams3Lbl, SenderAddress2);
        Output += StrSubstNo(QueryParams4Lbl, CompanyInformation."Post Code");
        Output += StrSubstNo(QueryParams5Lbl, CompanyInformation.City);
        Output += StrSubstNo(QueryParams6Lbl, CompanyInformation."Country/Region Code");
        Output += StrSubstNo(QueryParams7Lbl, CompanyInformation."Phone No.");
        Output += StrSubstNo(QueryParams8Lbl, CompanyInformation."Phone No.");
        Output += StrSubstNo(QueryParams9Lbl, CompanyInformation."E-Mail");
        Output += '}';
    end;

    local procedure BuildReceiver(var PakkelabelsShipment: Record "NPR Shipping Provider Document") Output: Text;
    var
        QueryParamsLbl: label '"name": "%1",', Locked = true;
        QueryParams2Lbl: label '"attention": "%1",', Locked = true;
        QueryParams3Lbl: label '"address1": "%1",', Locked = true;
        QueryParams4Lbl: label '"address2": "%1",', Locked = true;
        QueryParams5Lbl: label '"zipcode": "%1",', Locked = true;
        QueryParams6Lbl: label '"city": "%1",', Locked = true;
        QueryParams7Lbl: label '"country_code": "%1",', Locked = true;
        QueryParams8Lbl: label '"email": "%1",', Locked = true;
        QueryParams9Lbl: label '"mobile": "%1",', Locked = true;
        QueryParams10Lbl: label '"telephone": "%1"', Locked = true;
        QueryParams11Lbl: label ',"instruction":"%1"', Locked = true;
        ReceiverAddress1: Text;
        ReceiverAddress2: Text;
    begin
        if PakkelabelsShipment."Ship-to Address" <> '' then
            CreateAddressFields(PakkelabelsShipment."Ship-to Address", PakkelabelsShipment."Ship-to Address 2", ReceiverAddress1, ReceiverAddress2)
        else
            CreateAddressFields(PakkelabelsShipment.Address, PakkelabelsShipment."Address 2", ReceiverAddress1, ReceiverAddress2);

        Output := '{';
        Output += StrSubstNo(QueryParamsLbl, PakkelabelsShipment.Name);
        Output += StrSubstNo(QueryParams2Lbl, PakkelabelsShipment.Contact);
        Output += StrSubstNo(QueryParams3Lbl, ReceiverAddress1);
        if ReceiverAddress2 <> '' then
            Output += StrSubstNo(QueryParams4Lbl, ReceiverAddress2);
        Output += StrSubstNo(QueryParams5Lbl, PakkelabelsShipment."Post Code");
        Output += StrSubstNo(QueryParams6Lbl, PakkelabelsShipment.City);
        Output += StrSubstNo(QueryParams7Lbl, PakkelabelsShipment."Country/Region Code");
        Output += StrSubstNo(QueryParams8Lbl, PakkelabelsShipment."E-Mail");
        Output += StrSubstNo(QueryParams9Lbl, PakkelabelsShipment."SMS No.");
        Output += StrSubstNo(QueryParams10Lbl, PakkelabelsShipment."SMS No.");

        if (PackageProviderSetup."Send Delivery Instructions") and (PakkelabelsShipment."Delivery Instructions" <> '') then
            Output += StrSubstNo(QueryParams11Lbl, PakkelabelsShipment."Delivery Instructions");
        Output += '}';
    end;


    local procedure BuildServicePoint(var PakkelabelsShipment: Record "NPR Shipping Provider Document") Output: Text;
    var
        QueryParamsLbl: label '"id": "%1"', Locked = true;
    begin
        Output := '{';
        Output += StrSubstNo(QueryParamsLbl, PakkelabelsShipment."Delivery Location");
        Output += '}';
    end;

    local procedure BuildParcels(var PakkelabelsShipment: Record "NPR Shipping Provider Document") Output: Text;
    var
        PakkeShippingAgent: Record "NPR Package Shipping Agent";
        ShippingPackageCode: Record "NPR Package Code";
        PackageDimension: Record "NPR Package Dimension";
        i: Integer;
        J: Integer;
        QueryParamsLbl: label '"weight":"%1"', Locked = true;
        QueryParams2Lbl: label '"packaging":"%1"', Locked = true;
        QueryParams3Lbl: label '"quantity":"%1",', Locked = true;
        QueryParams5Lbl: label '"length":"%1",', Locked = true;
        QueryParams6Lbl: label '"width":"%1",', Locked = true;
        QueryParams7Lbl: label '"height":"%1"', Locked = true;
        QueryParams8Lbl: label '"volume":"%1"', Locked = true;
        QueryParams9Lbl: label '"running_metre":"%1"', Locked = true;
        QueryParams10Lbl: label '"description":"%1"', Locked = true;
        QueryParams11Lbl: label '"declared_value":%1', Locked = true;

    begin
        PakkeShippingAgent.Get(PakkelabelsShipment."Shipping Agent Code");

        Output := '[';
        PackageDimension.SetRange("Document Type", PackageDimension."Document Type"::Shipment);
        PackageDimension.SetRange("Document No.", PakkelabelsShipment."Document No.");
        J := PackageDimension.Count;
        if PackageDimension.FindSet() then
            repeat
                i += 1;
                Output += '{';
                Output += StrSubstNo(QueryParams3Lbl, Format(PackageDimension.Quantity, 0, 1));
                if PackageDimension.Weight_KG <> 0 then
                    Output += StrSubstNo(QueryParamsLbl, Format(PackageDimension.Weight_KG * 1000, 0, 1))
                else
                    Output += StrSubstNo(QueryParamsLbl, Format(PakkelabelsShipment."Total Weight", 0, 1));

                if PakkeShippingAgent."LxWxH Dimensions Required" then begin
                    Output += ',';
                    Output += StrSubstNo(QueryParams5Lbl, Format(PackageDimension.Length, 0, 1));
                    Output += StrSubstNo(QueryParams6Lbl, Format(PackageDimension.Width, 0, 1));
                    Output += StrSubstNo(QueryParams7Lbl, Format(PackageDimension.Height, 0, 1));
                end;
                if PakkeShippingAgent."Volume Required" then begin
                    Output += ',';
                    Output += StrSubstNo(QueryParams8Lbl, Format(PackageDimension.Volume, 0, 1));
                end;
                if PakkeShippingAgent."running_metre required" then begin
                    Output += ',';
                    Output += StrSubstNo(QueryParams9Lbl, Format(PackageDimension.running_metre, 0, 1));
                end;

                if PackageDimension.Description <> '' then begin
                    Output += ',';
                    Output += StrSubstNo(QueryParams10Lbl, Format(PackageDimension.Description, 0, 1));
                end;

                if PakkeShippingAgent."Package Type Required" then begin
                    ShippingPackageCode.Get(PakkelabelsShipment."Shipping Agent Code", PackageDimension."Package Code");
                    Output += ',';
                    Output += StrSubstNo(QueryParams2Lbl, Format(ShippingPackageCode.Description, 0, 1));
                end;
                if PakkeShippingAgent."Declared Value Required" then begin
                    Output += ',';
                    Output += StrSubstNo(QueryParams11Lbl, BuildDeclaredValue(PackageDimension, PakkeShippingAgent, PakkelabelsShipment."Currency Code"));
                end;
                if i <> J then
                    Output += '},'
                else
                    Output += '}';

            until PackageDimension.Next() = 0;
        Output += ']';

    end;

    local procedure BuildDeclaredValue(PackageDimension: Record "NPR Package Dimension"; PackageShippingAgent: Record "NPR Package Shipping Agent"; PackageCurrencyCode: Code[20]) DeclaredValueJsonObject: JsonObject;
    var
    begin
        if PackageDimension."Package Amount Incl. VAT" > PackageShippingAgent."Declared Max Amount Value" then
            DeclaredValueJsonObject.Add('amount', PackageShippingAgent."Declared Max Amount Value")
        else
            DeclaredValueJsonObject.Add('amount', PackageDimension."Package Amount Incl. VAT");

        if PackageShippingAgent."Declared Value Currency Code" <> '' then
            DeclaredValueJsonObject.Add('currency_code', PackageShippingAgent."Declared Value Currency Code")
        else
            DeclaredValueJsonObject.Add('currency_code', PackageCurrencyCode);
    end;

    local procedure PrintAllowed(var PakkelabelsShipment: Record "NPR Shipping Provider Document") Found: Boolean;
    var
        PakkelabelsPrinter: Record "NPR Package Printers";
    begin
        if not PackageProviderSetup."Use Pakkelable Printer API" then
            exit(false);

        Found := FindPackagePrinterLocationAndUserFilters(PakkelabelsPrinter, PakkelabelsShipment."Location Code");
    end;

    local procedure BuildPrintAt(var PakkelabelsShipment: Record "NPR Shipping Provider Document") Output: Text;
    var
        PakkelabelsPrinter: Record "NPR Package Printers";
        QueryParamsLbl: label '"host_name": "%1",', Locked = true;
        QueryParams2Lbl: label '"printer_name": "%1",', Locked = true;
        QueryParams3Lbl: label '"label_format": "%1"', Locked = true;
    begin
        if FindPackagePrinterLocationAndUserFilters(PakkelabelsPrinter, PakkelabelsShipment."Location Code") then begin
            Output := '{';
            Output += StrSubstNo(QueryParamsLbl, PakkelabelsPrinter."Host Name");
            Output += StrSubstNo(QueryParams2Lbl, PakkelabelsPrinter.Printer);
            Output += StrSubstNo(QueryParams3Lbl, PakkelabelsPrinter."label Format");
            Output += '}';
        end;
    end;

    local procedure BuildCustoms(PakkelabelsShipment: Record "NPR Shipping Provider Document") Output: Text
    var
        CompanyInformation: Record "Company Information";
        PakkeForeignShipmentMapping: Record "NPR Package Foreign Countries";
        SalesShipmentLine: Record "Sales Shipment Line";
        Item: Record Item;
        i: Integer;
        J: Integer;
        QueryParamsLbl: label '"currency_code": "%1",', Locked = true;
        QueryParams2Lbl: label '"quantity": "%1",', Locked = true;
        QueryParams3Lbl: label '"content":"%1",', Locked = true;
        QueryParams4Lbl: label '"commodity_code": "%1",', Locked = true;
        QueryParams5Lbl: label '"unit_value": "%1",', Locked = true;
        QueryParams6Lbl: label '"unit_weight": "%1"', Locked = true;
        QueryParams7Lbl: label '"country_code": "%1"', Locked = true;


    begin
        CompanyInformation.Get();

        if PakkelabelsShipment."Country/Region Code" = CompanyInformation."Country/Region Code" then
            exit;

        PakkeForeignShipmentMapping.SetRange("Country/Region Code", PakkelabelsShipment."Country/Region Code");
        if PakkeForeignShipmentMapping.FindFirst() then begin
            Output := '"customs": ';
            Output += '{';
            Output += StrSubstNo(QueryParamsLbl, Format(PakkelabelsShipment."Currency Code", 0, 1));

            Output += '"goods": ';
            Output += '[';

            SalesShipmentLine.SetRange("Document No.", PakkelabelsShipment."Document No.");
            SalesShipmentLine.SetFilter("Net Weight", '<>0');
            SalesShipmentLine.SetFilter(Quantity, '<>0');
            SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
            J := SalesShipmentLine.Count;
            if SalesShipmentLine.FindSet() then
                repeat
                    i += 1;
                    Output += '{';
                    Item.Get(SalesShipmentLine."No.");
                    Output += StrSubstNo(QueryParams2Lbl, Format(SalesShipmentLine.Quantity, 0, 1));
                    Output += StrSubstNo(QueryParams7Lbl, Format(PakkelabelsShipment."Country/Region Code", 0, 1));
                    Output += StrSubstNo(QueryParams3Lbl, Format(SalesShipmentLine.Description, 0, 1));
                    Output += StrSubstNo(QueryParams4Lbl, Format(Item."Tariff No.", 0, 1));
                    Output += StrSubstNo(QueryParams5Lbl, Format(SalesShipmentLine."Unit Price", 0, 1));
                    Output += StrSubstNo(QueryParams6Lbl, Format(Round(SalesShipmentLine."Net Weight", 1, '>') * 1000, 0, 1));
                    if J <> i then
                        Output += '},'
                    else
                        Output += '}';
                until SalesShipmentLine.Next() = 0;

            Output += ']';
            Output += '},';
        end;
    end;

    local procedure CreateAddressFields(ShippingProviderDocumentAddress1: Text; ShippingProviderDocumentAddress2: Text; var ShipmondoAddress1: Text; var ShipmondoAddress2: Text)
    var
        FullAddress: Text;
    begin
        FullAddress := ShippingProviderDocumentAddress1;
        if ShippingProviderDocumentAddress2 <> '' then
            FullAddress += ' ' + ShippingProviderDocumentAddress2;
        FullAddress := DelChr(FullAddress, '=', '.');

        ShipmondoAddress1 := CopyStr(FullAddress, 1, 32);
        if StrLen(FullAddress) > 32 then
            ShipmondoAddress2 := CopyStr(FullAddress, 33);
    end;

    local procedure PrintJob(ShipmentDocument: Record "NPR Shipping Provider Document") output: Text;
    var
        PakkelabelsPrinter: Record "NPR Package Printers";
        QueryParamsLbl: label '"document_id": %1,', Locked = true;
        QueryParams2Lbl: label '"host_name": "%1",', Locked = true;
        QueryParams3Lbl: label '"printer_name": "%1",', Locked = true;
        QueryParams4Lbl: label '"label_format": "%1"', Locked = true;
    begin
        output := '{';
        output += StrSubstNo(QueryParamsLbl, ShipmentDocument."Response Shipment ID");
        output += '"document_type":"shipment",';

        FindPackagePrinterLocationAndUserFilters(PakkelabelsPrinter, ShipmentDocument."Location Code");

        output += StrSubstNo(QueryParams2Lbl, PakkelabelsPrinter."Host Name");
        output += StrSubstNo(QueryParams3Lbl, PakkelabelsPrinter.Printer);
        output += StrSubstNo(QueryParams4Lbl, PakkelabelsPrinter."label Format");
        output += '}';
    end;

    local procedure ExecuteCall(Method: Code[10]; Response: JsonToken; silent: Boolean): Boolean;
    var

        Headers: HttpHeaders;
        Content: HttpContent;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;

    begin

        Clear(RequestMessage);
        Content.GetHeaders(Headers);
        Headers.Clear();
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
                Error(GetLastErrorText());
            Response.ReadFrom(ResponseText);
            exit(false)
        end;

        Response.ReadFrom(ResponseText);

        exit(true);
    end;

    local procedure HttpBasicAuthorization() AuthText: Text;
    var
        Base64Convert: codeunit "Base64 Convert";
    begin
        if not InitPackageProvider() then
            exit;

        ApiUser := PackageProviderSetup."Api User";
        ApiKey := PackageProviderSetup."Api Key";

        AuthText := (Base64Convert.ToBase64(ApiUser + ':' + ApiKey, TextEncoding::UTF8));

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', true, false)]
    local procedure C80OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header");
    var
        RecRefSalesHeader: RecordRef;
    begin
        if not InitPackageProvider() then
            exit;
        RecRefSalesHeader.GetTable(SalesHeader);
        PackageMgt.TestFieldPakkelabels(RecRefSalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure C80OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]);
    var
        SalesShptHeader: Record "Sales Shipment Header";
        SalesSetup: Record "Sales & Receivables Setup";
        ShipmentDocument: Record "NPR Shipping Provider Document";
        RecRef: RecordRef;
    begin
        if not InitPackageProvider() then
            exit;

        if not SalesHeader.Ship then
            exit;

        if (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) or
            ((SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) and SalesSetup."Shipment on Invoice") then begin
            if SalesShptHeader.Get(SalesShptHdrNo) then begin
                RecRef.GetTable(SalesShptHeader);
                PackageMgt.PostDimension(RecRef);
                if not PackageMgt.AddEntry(RecRef, GuiAllowed, false, ShipmentDocument) then
                    exit;
                if PackageProviderSetup."Send Package Doc. Immediately" then
                    CreateShipment(ShipmentDocument, true);
            end;
        end;
    end;

    local procedure InitPackageProvider(): Boolean;
    begin
        if not PackageProviderSetup.Get() then
            exit(false);

        if not PackageProviderSetup."Enable Shipping" then
            exit(false);

        if PackageProviderSetup."Shipping Provider" <> PackageProviderSetup."Shipping Provider"::Shipmondo then
            exit(false);

        if (PackageProviderSetup."Api User" = '') or (PackageProviderSetup."Api Key" = '') then
            Error(Text0001);

        exit(true);
    end;

    procedure SendDocument(var PacsoftShipmentDocument: Record "NPR Shipping Provider Document")
    begin
        if not InitPackageProvider() then
            exit;
        CreateShipment(PacsoftShipmentDocument, true)
    end;


    procedure GetArrayLength(Jarray: JsonArray) ArrayLength: Integer;

    begin
        ArrayLength := Jarray.Count;
    end;

    procedure SetCurrentArrayIndex(ArrayIndex: Integer; jArray: JsonArray) Jtoken: JsonToken;
    begin

        if jArray.Count = 0 then
            Error('NULL Array');
        if jArray.Get(ArrayIndex, Jtoken) then;


    end;

    local procedure GetJsonText(JToken: JsonToken; Path: Text; MaxLen: Integer) Value: Text
    var
        Token2: JsonToken;
        Jvalue: JsonValue;
    begin

        if not JToken.SelectToken(Path, Token2) then
            exit('');
        Jvalue := Token2.AsValue();
        if Jvalue.IsNull then
            exit('');

        Value := Jvalue.AsText();

        if MaxLen > 0 then
            Value := CopyStr(Value, 1, MaxLen);

        exit(Value)
    end;

    [TryFunction]
    local procedure SendHttpRequest(var RequestMessage: HttpRequestMessage; var ResponseText: Text);
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
            Error(ResponseText);
    end;

    procedure PrintDocument(var ShipmentDocument: Record "NPR Shipping Provider Document")
    var
        JToken: JsonToken;
    begin
        if not InitPackageProvider() then
            exit;

        if ShipmentDocument."Response Shipment ID" <> '' then begin
            RequestURL := BaseURL() + 'print_jobs/';
            RequestString := PrintJob(ShipmentDocument);
            if ExecuteCall('POST', JToken, false) then;
        end;
    end;

    procedure CheckBalance()
    var
        Jtoken: JsonToken;
    begin
        if not InitPackageProvider() then
            exit;
        RequestURL := BaseURL() + 'account/balance';
        if not ExecuteCall('GET', Jtoken, false) then
            exit;
        Message(GetJsonText(Jtoken, 'amount', 0));
    end;

    procedure PrintShipmentDocument(var SalesShipmentHeader: Record "Sales Shipment Header")
    var
        ShipmentDocument: Record "NPR Shipping Provider Document";
        RecRef: RecordRef;
        text000: label 'Do you Want to create a Package entry ?';
        Text001: label 'Do you want to print the Document?';
        Jtoken: JsonToken;
    begin
        if not InitPackageProvider() then
            exit;

        RecRef.GetTable(SalesShipmentHeader);
        ShipmentDocument.SetRange("Table No.", RecRef.Number);
        ShipmentDocument.SetRange(RecordID, RecRef.RecordId);
        if ShipmentDocument.FindLast() then begin
            if Confirm(Text001, true) then
                if ShipmentDocument."Response Shipment ID" <> '' then begin
                    RequestURL := BaseURL() + 'print_jobs/';
                    RequestString := PrintJob(ShipmentDocument);
                    if ExecuteCall('POST', Jtoken, false) then
                        exit;
                end;
        end else begin
            PackageMgt.TestFieldPakkelabels(RecRef);
            if Confirm(text000, true) then begin
                PackageMgt.PostDimension(RecRef);
                if not PackageMgt.AddEntry(RecRef, GuiAllowed, false, ShipmentDocument) then
                    exit;
                if PackageProviderSetup."Send Package Doc. Immediately" then
                    CreateShipment(ShipmentDocument, true);
            end;
        end;
    end;

    local procedure FindPackagePrinterLocationAndUserFilters(var PackagePrinters: Record "NPR Package Printers"; ShippingDocumentLocationCode: Code[20]) Found: Boolean
    begin
        PackagePrinters.SetRange("Location Code", ShippingDocumentLocationCode);
        PackagePrinters.SetRange("User ID", UserSecurityId());
        Found := PackagePrinters.FindFirst();
        if not Found then begin
            PackagePrinters.SetRange("User ID");
            Found := PackagePrinters.FindFirst();
        end;
        if not Found then begin
            PackagePrinters.SetRange("Location Code");
            PackagePrinters.SetRange("User ID", UserSecurityId());
            Found := PackagePrinters.FindFirst();
        end;
        if not Found then begin
            PackagePrinters.SetRange("User ID");
            Found := PackagePrinters.FindFirst();
        end;
    end;

    local procedure BaseURL(): Text[250]
    var
        ShippingProviderSetup: Record "NPR Shipping Provider Setup";
    begin
        if ShippingProviderSetup.Get() and (ShippingProviderSetup."Shipping Provider" = ShippingProviderSetup."Shipping Provider"::Shipmondo) then begin
            case ShippingProviderSetup."Shipmondo API Environment" of
                ShippingProviderSetup."Shipmondo API Environment"::Production:
                    exit('https://app.shipmondo.com/api/public/v3/');
                ShippingProviderSetup."Shipmondo API Environment"::Sandbox:
                    exit('https://sandbox.shipmondo.com/api/public/v3/');
            end;
        end else
            exit('https://app.shipmondo.com/api/public/v3/')
    end;
}

