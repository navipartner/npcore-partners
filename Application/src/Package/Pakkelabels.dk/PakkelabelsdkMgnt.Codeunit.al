codeunit 6014490 "NPR Pakkelabels.dk Mgnt"
{
    trigger OnRun()
    var
        ShipmentDocument: Record "NPR Pacsoft Shipment Document";
    begin
        TQSendPakkeLabel();
    end;

    var
        PackageProviderSetup: Record "NPR Pacsoft Setup";
        ResponseMsg: Label 'Pakkelabels Return the following  error: %1';
        ConnectionSuccessfulMsg: Label 'Test Connection successful.';
        LoginDetailsMissingErr: Label 'Login Details Missing';
        DocAlreadySentErr: Label 'The document has already sent to Pakkelabels.';
        ErrorTextFound: Text;
        RequestString: Text;
        RequestURL: Text;
        ResponseString: Text;

    procedure Login(var Token: Text; Silent: Boolean)
    var
        ReasonPhrase: Text;
    begin
        if not InitPackageProvider() then
            exit;
        ErrorTextFound := '';
        RequestString := StrSubstNo('{"api_user":"%1","api_key":"%2"}', PackageProviderSetup."Api User", PackageProviderSetup."Api Key");
        RequestURL := 'https://app.pakkelabels.dk/api/public/v2/users/login';

        if not SendRequest('POST', ReasonPhrase) then begin
            GetExceptionMessageFromReasonPhrase(Silent, ReasonPhrase);
        end;

        if ErrorTextFound <> '' then
            exit;
        GetValue('expired_at', ResponseString);
        Token := GetValue('token', ResponseString);
    end;

    procedure GetBalance(Silent: Boolean)
    var
        Token: Text;
        ReasonPhrase: Text;
        BalanceMsg: Label 'Balance: %1';
    begin
        Login(Token, Silent);
        if ErrorTextFound <> '' then
            exit;
        RequestURL := StrSubstNo('https://app.pakkelabels.dk/api/public/v2/users/balance?token=%1', Token);
        RequestString := '';

        if not SendRequest('GET', ReasonPhrase) then begin
            GetExceptionMessageFromReasonPhrase(Silent, ReasonPhrase);
        end;

        if ErrorTextFound <> '' then
            exit;

        Message(BalanceMsg, GetValue('balance', ResponseString));
    end;

    procedure GetFreightRates(Silent: Boolean)
    var
        Token: Text;
        ReasonPhrase: Text;
    begin
        Login(Token, Silent);
        if ErrorTextFound <> '' then
            exit;

        RequestURL := StrSubstNo('https://app.pakkelabels.dk/api/public/v2/shipments/freight_rates?token=%1&country=%2', Token, 'DK');
        RequestString := '';

        if not SendRequest('GET', ReasonPhrase) then begin
            GetExceptionMessageFromReasonPhrase(Silent, ReasonPhrase);
        end;
        Message(GetValue('services', ResponseString));
    end;

    procedure CreateShipment(var ShipmentDocument: Record "NPR Pacsoft Shipment Document"; Silent: Boolean)
    var
        CompanyInformation: Record "Company Information";
        ShippingAgent: Record "Shipping Agent";
        AutoDropPoint: Text;
        ServicePointIDPDK: Text;
        ServicePointIDGLS: Text;
        ReasonPhrase: Text;
        Token: Text;
        LabelType: Option Post,Return;
    begin
        if not InitPackageProvider() then
            exit;
        if not CompanyInformation.Get() then exit;

        if not ShipmentDocument."Print Return Label" then begin
            if ShipmentDocument."Response Shipment ID" <> '' then begin
                if Silent then
                    ErrorTextFound := DocAlreadySentErr
                else
                    Error(DocAlreadySentErr);
            end;
        end else
            if ShipmentDocument."Response Shipment ID" <> '' then
                exit;

        Login(Token, Silent);
        if ErrorTextFound <> '' then
            exit;

        ShippingAgent.Get(ShipmentDocument."Shipping Agent Code");

        if ShippingAgent."NPR Shipping Method" = ShippingAgent."NPR Shipping Method"::" " then
            exit;

        if ShippingAgent."NPR Drop Point Service" then begin
            case ShippingAgent."NPR Shipping Method" of
                ShippingAgent."NPR Shipping Method"::GLS:
                    begin
                        if ShipmentDocument."Delivery Location" = '' then
                            AutoDropPoint := '"true"'
                        else begin
                            ServicePointIDGLS := ShipmentDocument."Ship-to Address 2";
                            ShipmentDocument."Address 2" := '';
                        end;
                    end;
                ShippingAgent."NPR Shipping Method"::PDK:
                    begin
                        if ShipmentDocument."Delivery Location" <> '' then begin
                            ServicePointIDPDK := ShipmentDocument."Delivery Location";
                        end;
                    end;
            end;
        end;


        RequestURL := 'https://app.pakkelabels.dk/api/public/v2/shipments/shipment';
        RequestString := '{';
        RequestString += StrSubstNo('"token":"%1",', Token);
        RequestString += StrSubstNo('"shipping_agent":"%1",', LowerCase(Format(ShipmentDocument."Shipping Method Code")));
        RequestString += StrSubstNo('"weight":"%1",', Format(ShipmentDocument."Total Weight", 0, 1));
        RequestString += StrSubstNo('"receiver_name":"%1",', ShipmentDocument.Name);
        RequestString += StrSubstNo('"receiver_attention":"%1",', ShipmentDocument.Contact);
        RequestString += StrSubstNo('"receiver_address1":"%1",', ShipmentDocument.Address + ' ' + ShipmentDocument."Address 2");
        if ServicePointIDGLS <> '' then
            RequestString += StrSubstNo('"receiver_address2":"%1",', ServicePointIDGLS);
        RequestString += StrSubstNo('"receiver_zipcode":"%1",', ShipmentDocument."Post Code");
        RequestString += StrSubstNo('"receiver_city":"%1",', ShipmentDocument.City);
        RequestString += StrSubstNo('"receiver_country":"%1",', ShipmentDocument."Country/Region Code");
        RequestString += StrSubstNo('"receiver_email":"%1",', ShipmentDocument."E-Mail");
        RequestString += StrSubstNo('"receiver_mobile":"%1",', ShipmentDocument."SMS No.");
        RequestString += StrSubstNo('"sender_name":"%1",', CompanyInformation.Name);
        RequestString += StrSubstNo('"sender_address1":"%1",', CompanyInformation.Address);
        RequestString += StrSubstNo('"sender_zipcode":"%1",', CompanyInformation."Post Code");
        RequestString += StrSubstNo('"sender_city":"%1",', CompanyInformation.City);
        RequestString += StrSubstNo('"sender_country":"%1",', CompanyInformation."Country/Region Code");
        RequestString += StrSubstNo('"shipping_product_id":"%1",', ShipmentDocument."Shipping Agent Code");
        RequestString += StrSubstNo('"services":"%1",', ShipmentDocument."Shipping Agent Service Code");
        if AutoDropPoint <> '' then
            RequestString += StrSubstNo('"auto_select_droppoint":"true",');
        RequestString += StrSubstNo('"order_id":"%1",', ShipmentDocument."Order No.");
        RequestString += StrSubstNo('"reference":"%1",', ShipmentDocument.Reference);
        RequestString += StrSubstNo('"label_format":"a5",');
        RequestString += StrSubstNo('"number_of_collis":"%1",', Format(ShipmentDocument."Parcel Qty."));

        if ServicePointIDPDK <> '' then begin
            RequestString += StrSubstNo('"custom_delivery":"true",');
            RequestString += StrSubstNo('"service_point_id":"%1",', ServicePointIDPDK);
        end;
        if PackageProviderSetup."Use Pakkelable Printer API" then
            RequestString += StrSubstNo('"add_to_print_queue":"true",');

        if (PackageProviderSetup."Send Delivery Instructions") and (ShipmentDocument."Delivery Instructions" <> '') then
            RequestString += StrSubstNo('"delivery_instruction":"%1",', ShipmentDocument."Delivery Instructions");

        if PackageProviderSetup."Pakkelable Test Mode" then
            RequestString += '"test":"true"'
        else
            RequestString += '"test":"false"';

        RequestString += '}';

        if not SendRequest('POST', ReasonPhrase) then begin
            GetExceptionMessageFromReasonPhrase(Silent, ReasonPhrase);
        end;
        if ErrorTextFound <> '' then
            exit;
        ShipmentDocument."Response Shipment ID" := GetValue('shipment_id', ResponseString);
        ShipmentDocument."Response Package No." := GetValue('pkg_no', ResponseString);
        ShipmentDocument.Modify();

        GetPDFByShipmentId(ShipmentDocument, Silent, LabelType::Post);
    end;

    procedure CreateShipmentOwnCustomerNo(var ShipmentDocument: Record "NPR Pacsoft Shipment Document"; Silent: Boolean)
    var
        CompanyInformation: Record "Company Information";
        ShippingAgent: Record "Shipping Agent";
        AutoDropPoint: Text;
        ServicePointIDPDK: Text;
        ServicePointIDGLS: Text;
        ReasonPhrase: Text;
        Token: Text;
        LabelType: Option Post,Return;
    begin
        if not InitPackageProvider() then
            exit;
        if not CompanyInformation.Get() then
            exit;

        if not ShipmentDocument."Print Return Label" then begin
            if ShipmentDocument."Response Shipment ID" <> '' then begin
                if Silent then
                    ErrorTextFound := DocAlreadySentErr
                else
                    Error(DocAlreadySentErr);
            end;

        end else
            if ShipmentDocument."Response Shipment ID" <> '' then
                exit;

        Login(Token, Silent);
        if ErrorTextFound <> '' then
            exit;

        ShippingAgent.Get(ShipmentDocument."Shipping Agent Code");

        if ShippingAgent."NPR Shipping Method" = ShippingAgent."NPR Shipping Method"::" " then
            exit;

        if ShippingAgent."NPR Drop Point Service" then begin
            case ShippingAgent."NPR Shipping Method" of
                ShippingAgent."NPR Shipping Method"::GLS:
                    begin
                        if ShipmentDocument."Delivery Location" = '' then
                            AutoDropPoint := '"true"'
                        else begin
                            ServicePointIDGLS := ShipmentDocument."Ship-to Address 2";
                            ShipmentDocument."Address 2" := '';
                        end;
                    end;
                ShippingAgent."NPR Shipping Method"::PDK:
                    begin
                        if ShipmentDocument."Delivery Location" <> '' then begin
                            ServicePointIDPDK := ShipmentDocument."Delivery Location";
                        end;
                    end;
            end;
        end;

        RequestURL := 'https://app.pakkelabels.dk/api/public/v2/shipments/shipment_own_customer_number';
        RequestString := '{';
        RequestString += StrSubstNo('"token":"%1",', Token);

        RequestString += StrSubstNo('"shipping_agent":"%1",', LowerCase(Format(ShipmentDocument."Shipping Method Code")));

        RequestString += StrSubstNo('"weight":"%1",', Format(ShipmentDocument."Total Weight", 0, 1)); //from where to get
        RequestString += StrSubstNo('"receiver_name":"%1",', ShipmentDocument.Name);
        RequestString += StrSubstNo('"receiver_attention":"%1",', ShipmentDocument.Contact);
        RequestString += StrSubstNo('"receiver_address1":"%1",', ShipmentDocument.Address + ' ' + ShipmentDocument."Address 2");

        if ServicePointIDGLS <> '' then
            RequestString += StrSubstNo('"receiver_address2":"%1",', ServicePointIDGLS);

        RequestString += StrSubstNo('"receiver_zipcode":"%1",', ShipmentDocument."Post Code");
        RequestString += StrSubstNo('"receiver_city":"%1",', ShipmentDocument.City);
        RequestString += StrSubstNo('"receiver_country":"%1",', ShipmentDocument."Country/Region Code");
        RequestString += StrSubstNo('"receiver_email":"%1",', ShipmentDocument."E-Mail");
        RequestString += StrSubstNo('"receiver_mobile":"%1",', ShipmentDocument."SMS No.");
        RequestString += StrSubstNo('"sender_name":"%1",', CompanyInformation.Name);
        RequestString += StrSubstNo('"sender_address1":"%1",', CompanyInformation.Address);
        RequestString += StrSubstNo('"sender_zipcode":"%1",', CompanyInformation."Post Code");
        RequestString += StrSubstNo('"sender_city":"%1",', CompanyInformation.City);
        RequestString += StrSubstNo('"sender_country":"%1",', CompanyInformation."Country/Region Code");
        RequestString += StrSubstNo('"shipping_product_id":"%1",', ShipmentDocument."Shipping Agent Code");
        RequestString += StrSubstNo('"services":"%1",', ShipmentDocument."Shipping Agent Service Code");
        if AutoDropPoint <> '' then
            RequestString += StrSubstNo('"auto_select_droppoint":"true",');

        RequestString += StrSubstNo('"order_id":"%1",', ShipmentDocument."Order No.");
        RequestString += StrSubstNo('"reference":"%1",', ShipmentDocument.Reference);
        RequestString += StrSubstNo('"label_format":"a5",');
        RequestString += StrSubstNo('"number_of_collis":"%1",', Format(ShipmentDocument."Parcel Qty."));

        if ServicePointIDPDK <> '' then begin
            RequestString += StrSubstNo('"custom_delivery":"true",');
            RequestString += StrSubstNo('"service_point_id":"%1",', ServicePointIDPDK);
        end;

        if PackageProviderSetup."Use Pakkelable Printer API" then
            RequestString += StrSubstNo('"add_to_print_queue":"true",');

        if (PackageProviderSetup."Send Delivery Instructions") and (ShipmentDocument."Delivery Instructions" <> '') then
            RequestString += StrSubstNo('"delivery_instruction":"%1",', ShipmentDocument."Delivery Instructions");

        if PackageProviderSetup."Pakkelable Test Mode" then
            RequestString += '"test":"true"'
        else
            RequestString += '"test":"false"';
        RequestString += '}';

        if not SendRequest('POST', ReasonPhrase) then begin
            GetExceptionMessageFromReasonPhrase(Silent, ReasonPhrase);
        end;

        if ErrorTextFound <> '' then
            exit;

        ShipmentDocument."Response Shipment ID" := GetValue('shipment_id', ResponseString);
        ShipmentDocument."Response Package No." := GetValue('pkg_no', ResponseString);
        ShipmentDocument.Modify();

        GetPDFByShipmentId(ShipmentDocument, Silent, LabelType::Post);
    end;

    procedure CreateReturnShipmentOwnCustomerNo(var ShipmentDocument: Record "NPR Pacsoft Shipment Document"; Silent: Boolean)
    var
        CompanyInformation: Record "Company Information";
        ShippingAgent: Record "Shipping Agent";
        Token: Text;
        ReasonPhrase: Text;
        LabelType: Option Post,Return;
    begin
        if not CompanyInformation.Get() then
            exit;
        if not ShipmentDocument."Print Return Label" then
            exit;
        if ShipmentDocument."Response Shipment ID" = '' then
            exit;

        if ShipmentDocument."Return Response Shipment ID" <> '' then begin
            if Silent then
                ErrorTextFound := DocAlreadySentErr
            else
                Error(DocAlreadySentErr);
        end;

        Login(Token, Silent);
        if ErrorTextFound <> '' then
            exit;

        RequestURL := 'https://app.pakkelabels.dk/api/public/v2/shipments/shipment_own_customer_number';
        RequestString := '{';
        RequestString += StrSubstNo('"token":"%1",', Token);
        RequestString += StrSubstNo('"shipping_agent":"%1",', LowerCase(ShipmentDocument."Shipping Method Code"));
        RequestString += StrSubstNo('"weight":"%1",', Format(ShipmentDocument."Total Weight", 0, 1)); //from where to get

        RequestString += StrSubstNo('"receiver_name":"%1",', CompanyInformation.Name);
        RequestString += StrSubstNo('"receiver_attention":"%1",', CompanyInformation.Name);
        RequestString += StrSubstNo('"receiver_address1":"%1",', CompanyInformation.Address);
        RequestString += StrSubstNo('"receiver_zipcode":"%1",', CompanyInformation."Post Code");
        RequestString += StrSubstNo('"receiver_city":"%1",', CompanyInformation.City);
        RequestString += StrSubstNo('"receiver_country":"%1",', CompanyInformation."Country/Region Code");
        RequestString += StrSubstNo('"receiver_email":"%1",', CompanyInformation."E-Mail");
        RequestString += StrSubstNo('"receiver_mobile":"%1",', CompanyInformation."Phone No.");

        RequestString += StrSubstNo('"sender_name":"%1",', ShipmentDocument.Name);
        RequestString += StrSubstNo('"sender_address1":"%1",', ShipmentDocument.Address + ' ' + ShipmentDocument."Address 2");
        RequestString += StrSubstNo('"sender_zipcode":"%1",', ShipmentDocument."Post Code");
        RequestString += StrSubstNo('"sender_city":"%1",', ShipmentDocument.City);
        RequestString += StrSubstNo('"sender_country":"%1",', ShipmentDocument."Country/Region Code");

        RequestString += StrSubstNo('"shipping_product_id":"%1",', ShipmentDocument."Return Shipping Agent Code");

        RequestString += StrSubstNo('"order_id":"%1",', ShipmentDocument."Order No.");
        RequestString += StrSubstNo('"reference":"%1",', ShipmentDocument.Reference);
        RequestString += StrSubstNo('"label_format":"a5",');
        RequestString += StrSubstNo('"number_of_collis":"%1",', Format(ShipmentDocument."Parcel Qty."));
        if PackageProviderSetup."Use Pakkelable Printer API" then
            RequestString += StrSubstNo('"add_to_print_queue":"true",');
        RequestString += '"test":"false"';
        RequestString += '}';

        if not SendRequest('POST', ReasonPhrase) then begin
            GetExceptionMessageFromReasonPhrase(Silent, ReasonPhrase);
        end;

        if ErrorTextFound <> '' then
            exit;

        ShipmentDocument."Return Response Shipment ID" := GetValue('shipment_id', ResponseString);
        ShipmentDocument."Return Response Package No." := GetValue('pkg_no', ResponseString);
        ShipmentDocument.Modify();

        GetPDFByShipmentId(ShipmentDocument, Silent, LabelType::Return);
    end;

    procedure GetShipmentByShipmentId(ShipmentDocument: Record "NPR Pacsoft Shipment Document"; Silent: Boolean)
    var
        ShipmentID: Code[10];
        Token: Text;
        ReasonPhrase: Text;
    begin
        Login(Token, Silent);
        if ErrorTextFound <> '' then exit;

        ShipmentID := ShipmentDocument."Response Shipment ID";
        RequestURL := StrSubstNo('https://app.pakkelabels.dk/api/public/v2/shipments/shipment?token=%1&id=%2', Token, ShipmentID);
        RequestString := '';

        if not SendRequest('GET', ReasonPhrase) then begin
            GetExceptionMessageFromReasonPhrase(Silent, ReasonPhrase);
        end;
        Message(ResponseString);
    end;

    procedure GetPDFByShipmentId(var ShipmentDocument: Record "NPR Pacsoft Shipment Document"; Silent: Boolean; LabelType: Option Post,Return)
    var
        ShipmentID: Code[10];
        Base64Text: Text;
        Token: Text;
        ReasonPhrase: Text;
    begin
        if not InitPackageProvider() then
            exit;
        if PackageProviderSetup."Use Pakkelable Printer API" then
            exit;

        if PackageProviderSetup."Pakkelable Test Mode" then
            exit;

        Login(Token, Silent);
        if ErrorTextFound <> '' then exit;

        case LabelType of
            LabelType::Post:
                ShipmentID := ShipmentDocument."Response Shipment ID";
            LabelType::Return:
                ShipmentID := ShipmentDocument."Return Response Shipment ID";
        end;

        RequestURL := StrSubstNo('https://app.pakkelabels.dk/api/public/v2/shipments/pdf?token=%1&id=%2', Token, ShipmentID);
        RequestString := '';

        if not SendRequest('GET', ReasonPhrase) then begin
            GetExceptionMessageFromReasonPhrase(Silent, ReasonPhrase);
        end;
        if ErrorTextFound <> '' then
            exit;
        Base64Text := GetValue('base64', ResponseString);
        PrintDocument(Base64Text);
    end;

    procedure GetShipmentsByOrderId(var ShipmentDocument: Record "NPR Pacsoft Shipment Document"; Silent: Boolean)
    var
        NAVOrderID: Code[20];
        Token: Text;
        ReasonPhrase: Text;
    begin
        Login(Token, Silent);
        if ErrorTextFound <> '' then exit;

        NAVOrderID := ShipmentDocument."Order No.";
        RequestURL := StrSubstNo('https://app.pakkelabels.dk/api/public/v2/shipments/shipments?token=%1&order_id=%2', Token, NAVOrderID);
        RequestString := '';

        if not SendRequest('GET', ReasonPhrase) then begin
            GetExceptionMessageFromReasonPhrase(Silent, ReasonPhrase);
        end;
        Message(ResponseString);
    end;

    local procedure AddToPrintQueue(var ShipmentDocument: Record "NPR Pacsoft Shipment Document"; Silent: Boolean; LabelType: Option Post,Return)
    var
        ShipmentID: Code[10];
        Token: Text;
        ReasonPhrase: Text;
    begin
        if not InitPackageProvider() then
            exit;
        if not PackageProviderSetup."Use Pakkelable Printer API" then
            exit;

        Login(Token, Silent);
        if ErrorTextFound <> '' then exit;

        case LabelType of
            LabelType::Post:
                ShipmentID := ShipmentDocument."Response Shipment ID";
            LabelType::Return:
                ShipmentID := ShipmentDocument."Return Response Shipment ID";
        end;

        RequestURL := 'https://app.pakkelabels.dk/api/public/v2/shipments/add_to_print_queue';
        RequestString := StrSubstNo('{"token":"%1","ids":"%2"}', Token, ShipmentID);

        if not SendRequest('POST', ReasonPhrase) then begin
            GetExceptionMessageFromReasonPhrase(Silent, ReasonPhrase);
        end;
    end;

    local procedure GetValue("Key": Text; Input: Text) Value: Text
    var
        KeyPos: Integer;
        KeyWithQuotes: Text;
        ColonPos: Integer;
        QuotePos: Integer;
        EndPos: Integer;
    begin
        if StrPos(Input, '"[\') <> 0 then
            Input := DelStr(Input, StrPos(Input, '"[\'), 3);

        if Key = '' then
            exit('');
        KeyWithQuotes := StrSubstNo('"%1"', Key);
        KeyPos := StrPos(Input, KeyWithQuotes);
        Value := CopyStr(Input, KeyPos + StrLen(KeyWithQuotes));
        ColonPos := StrPos(Value, ':');
        Value := CopyStr(Value, ColonPos + StrLen(':'));
        if CopyStr(Value, 1, 1) = '"' then begin
            Value := CopyStr(Value, 2);
            QuotePos := StrPos(Value, '"');
            if QuotePos > 1 then
                Value := CopyStr(Value, 1, QuotePos - 1)
            else
                Value := '';
        end else begin
            EndPos := StrPos(Value, ',');
            if EndPos > 0 then begin
                Value := CopyStr(Value, 1, EndPos - 1)
            end else begin
                EndPos := StrPos(Value, '}');
                if EndPos > 0 then
                    Value := CopyStr(Value, 1, EndPos - 1)
                else
                    Value := '';
            end;
        end;
    end;

    local procedure SendRequest(Method: Code[10]; var ReasonPhrase: Text): Boolean
    var
        Headers: HttpHeaders;
        Content: HttpContent;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Client: HttpClient;
    begin
        Clear(ReasonPhrase);
        if Method = 'POST' then begin
            Content.WriteFrom(RequestString);
            Content.GetHeaders(Headers);
            Headers.Remove('Content-Type');
            Headers.Add('Content-Type', 'application/json');
            RequestMessage.Content(Content);
        end;
        RequestMessage.SetRequestUri(RequestURL);
        RequestMessage.Method := Method;
        if not Client.Send(RequestMessage, ResponseMessage) then
            exit;

        if not ResponseMessage.IsSuccessStatusCode() then begin
            ReasonPhrase := ResponseMessage.ReasonPhrase();
            exit;
        end else
            exit(ResponseMessage.Content().ReadAs(ResponseString));
    end;

    local procedure GetExceptionMessageFromReasonPhrase(Silent: Boolean; ReasonPhrase: Text)
    begin
        ErrorTextFound := GetValue('message', ReasonPhrase);
        if ErrorTextFound = '' then
            ErrorTextFound := ReasonPhrase;
        if not Silent then
            Error(ErrorTextFound);
    end;

    local procedure ValidateShipmentMethodCode(Rec: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        if not InitPackageProvider then
            exit;
        if Rec."Shipment Method Code" = '' then exit;

        if PackageProviderSetup."Default Weight" <= 0 then exit;

        SalesLine.SetRange(SalesLine."Document Type", Rec."Document Type");
        SalesLine.SetRange("Document No.", Rec."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("Net Weight", 0);
        SalesLine.ModifyAll("Net Weight", PackageProviderSetup."Default Weight");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterValidateEvent', 'Shipping Agent Service Code', false, false)]
    local procedure OnAfterModifyShippingAgentSerEventSalesHeader(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        ValidateShipmentMethodCode(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure OnAfterModifyQtyEventSalesLine(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        SalesHeader: Record "Sales Header";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec.Quantity = 0 then
            exit;
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;
        if SalesHeader."Shipment Method Code" = '' then
            exit;
        if not InitPackageProvider() then
            exit;

        if PackageProviderSetup."Default Weight" <= 0 then exit;

        if Rec."Net Weight" = 0 then begin
            Rec."Net Weight" := PackageProviderSetup."Default Weight";
            Rec.Modify();
        end;
    end;

    procedure PrintDocument(Base64Text: Text)
    var
        DummyObjectOutputSelection: Record "NPR Object Output Selection";
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        PrintMethodMgt: Codeunit "NPR Print Method Mgt.";
        Output: Text;
        OutputType: Integer;
        MissingPrintSetupErr: Label 'Not able to print. Missing object output setup';
    begin
        Output := ObjectOutputMgt.GetCodeunitOutputPath(CODEUNIT::"NPR Pakkelabels.dk Mgnt");
        OutputType := ObjectOutputMgt.GetCodeunitOutputType(CODEUNIT::"NPR Pakkelabels.dk Mgnt");

        if Output = '' then
            Error(MissingPrintSetupErr);
        case OutputType of
            DummyObjectOutputSelection."Output Type"::"Printer Name":
                PrintMethodMgt.PrintBytesLocal(Output, Base64Text, 'pdf');
            else
                Error(MissingPrintSetupErr);
        end;
    end;

    [EventSubscriber(ObjectType::Page, 6014574, 'GetPackageProvider', '', true, true)]
    local procedure IdentifyMe_GetPackageProvider(var Sender: Page "NPR Pacsoft Setup";

    var
        tmpAllObjWithCaption: Record AllObjWithCaption temporary)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if tmpAllObjWithCaption.IsTemporary() then begin
            AllObjWithCaption.Get(OBJECTTYPE::Codeunit, Codeunit::"NPR Pakkelabels.dk Mgnt");
            tmpAllObjWithCaption.Init();
            tmpAllObjWithCaption."Object Type" := AllObjWithCaption."Object Type";
            tmpAllObjWithCaption."Object ID" := AllObjWithCaption."Object ID";
            tmpAllObjWithCaption."Object Name" := AllObjWithCaption."Object Name";
            tmpAllObjWithCaption."Object Caption" := AllObjWithCaption."Object Caption";
            tmpAllObjWithCaption.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostSalesDoc', '', true, false)]
    local procedure C80OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header")
    var
        ShipmentDocument: Record "NPR Pacsoft Shipment Document";
        RecRefSalesHeader: RecordRef;
    begin
        if not InitPackageProvider() then
            exit;
        RecRefSalesHeader.GetTable(SalesHeader);
        TestFieldPakkelabels(RecRefSalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', false, false)]
    local procedure C80OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        SalesShptHeader: Record "Sales Shipment Header";
        SalesSetup: Record "Sales & Receivables Setup";
        Args: Record "NPR AF Arguments - Notific.Hub" temporary;
        RecRefShipment: RecordRef;
        ResponseMessage, LastErrorText : Text;
        IsAssertError: Boolean;
    begin
        if not InitPackageProvider() then
            exit;
        ClearLastError();
        WriteArgsForShipmentDocumentAddEntryDocPakkelabelsDKMgnt(Args, SalesHeader.Ship, SalesHeader."Document Type".AsInteger(), SalesShptHdrNo);
        Commit();
        if not Codeunit.Run(Codeunit::"NPR Package Assert Error", Args) then begin
            ReadArgsForShipmentDocumentAddEntryDocPakkelabelsDKMgnt(Args, IsAssertError, ResponseMessage);
            if ResponseMessage <> '' then
                Message(ResponseMessage);
        end;
        if not IsAssertError then begin
            LastErrorText := GetLastErrorText();
            if LastErrorText <> '' then
                Message(LastErrorText);
        end;
    end;

    local procedure WriteArgsForShipmentDocumentAddEntryDocPakkelabelsDKMgnt(var Args: Record "NPR AF Arguments - Notific.Hub"; IsShipment: Boolean; DocType: Integer; SalesShipmentNo: Code[20])
    var
        JObject: JsonObject;
        OutStr: OutStream;
        Arguments: Text;
    begin
        JObject.Add('Method', 'C80OnAfterPostSalesDocPakkelabelsDKMgnt');
        JObject.Add('IsShipment', IsShipment);
        JObject.Add('DocType', DocType);
        JObject.Add('SalesShipmentNo', SalesShipmentNo);
        JObject.WriteTo(Arguments);

        Args."Request Data".CreateOutStream(OutStr);
        OutStr.WriteText(Arguments);
    end;

    local procedure ReadArgsForShipmentDocumentAddEntryDocPakkelabelsDKMgnt(var Args: Record "NPR AF Arguments - Notific.Hub"; var IsAssertError: Boolean; var ResponseMessage: Text)
    var
        JObject: JsonObject;
        InStr: InStream;
        Arguments: Text;
    begin
        Args."Request Data".CreateInStream(InStr);
        InStr.ReadText(Arguments);

        if JObject.ReadFrom(Arguments) then begin
            GetJValueFromArg(JObject, 'AssertError', IsAssertError);
            GetJValueFromArg(JObject, 'ResponseMesage', ResponseMessage);
        end;
    end;

    local procedure GetJValueFromArg(JObject: JsonObject; ParameterName: Text; var ParameterValue: Text)
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if JObject.Get(ParameterName, JToken) then begin
            JValue := JToken.AsValue();
            if (not JValue.IsNull()) and (not JValue.IsUndefined()) then
                ParameterValue := JValue.AsText();
        end;
    end;

    local procedure GetJValueFromArg(JObject: JsonObject; ParameterName: Text; var ParameterValue: Boolean)
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if JObject.Get(ParameterName, JToken) then begin
            JValue := JToken.AsValue();
            if (not JValue.IsNull()) and (not JValue.IsUndefined()) then
                ParameterValue := JValue.AsBoolean();
        end;
    end;


    local procedure InitPackageProvider(): Boolean
    begin
        if not PackageProviderSetup.Get() then
            exit(false);

        if PackageProviderSetup."Package Service Codeunit ID" = 0 then
            exit(false);
        if (PackageProviderSetup."Package Service Codeunit ID" <> CODEUNIT::"NPR Pakkelabels.dk Mgnt") then
            exit(false);

        if (PackageProviderSetup."Api User" = '') or (PackageProviderSetup."Api Key" = '') then
            Error(LoginDetailsMissingErr);

        exit(true);
    end;

    procedure TestFieldPakkelabels(RecRef: RecordRef)
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
        ShippingAgentServices: Record "Shipping Agent Services";
        ShippingAgent: Record "Shipping Agent";
        ShiptoAddress: Record "Ship-to Address";
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        case RecRef.Number of
            DATABASE::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    if (SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) or (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) then begin

                        if SalesHeader."Ship-to Country/Region Code" <> 'DK' then
                            exit;
                        if SalesHeader."NPR Kolli" = 0 then
                            exit;
                        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                        SalesLine.SetRange("Document No.", SalesHeader."No.");
                        SalesLine.SetRange(Type, SalesLine.Type::Item);
                        SalesLine.SetFilter("Net Weight", '<>0');
                        if not SalesLine.FindFirst() then
                            exit;

                        SalesHeader.TestField("Shipment Method Code");
                        SalesHeader.TestField("Shipping Agent Code");
                        ShippingAgent.Get(SalesHeader."Shipping Agent Code");
                        if ShippingAgent."NPR Shipping Method" <> ShippingAgent."NPR Shipping Method"::" " then
                            SalesHeader.TestField("Shipping Agent Service Code");

                        ShippingAgentServices.Get(SalesHeader."Shipping Agent Code", SalesHeader."Shipping Agent Service Code");
                        if SalesHeader."Ship-to Code" <> '' then begin
                            ShiptoAddress.Get(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code");
                            if ShippingAgentServices."NPR Phone Mandatory" then
                                ShiptoAddress.TestField("Phone No.");

                            if ShippingAgentServices."NPR Email Mandatory" then
                                ShiptoAddress.TestField("E-Mail");
                        end else begin
                            Customer.Get(SalesHeader."Sell-to Customer No.");
                            if ShippingAgentServices."NPR Phone Mandatory" then
                                Customer.TestField("Phone No.");

                            if ShippingAgentServices."NPR Email Mandatory" then
                                Customer.TestField("E-Mail");
                        end;

                        SalesHeader.TestField("Ship-to Name");
                        SalesHeader.TestField("Ship-to Address");
                        SalesHeader.TestField("Ship-to Post Code");
                        SalesHeader.TestField("Ship-to City");

                        ShippingAgent.Get(SalesHeader."Shipping Agent Code");
                        if ShippingAgent."NPR Ship to Contact Mandatory" then
                            SalesHeader.TestField("Ship-to Contact");
                    end;

                end;
            DATABASE::"Sales Shipment Header":
                begin
                    RecRef.SetTable(SalesShipmentHeader);
                    SalesShipmentHeader.TestField("Shipment Method Code");
                    SalesShipmentHeader.TestField("Shipping Agent Code");
                    ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code");
                    if ShippingAgent."NPR Shipping Method" <> ShippingAgent."NPR Shipping Method"::" " then
                        SalesShipmentHeader.TestField("Shipping Agent Service Code");

                    ShippingAgentServices.Get(SalesShipmentHeader."Shipping Agent Code", SalesShipmentHeader."Shipping Agent Service Code");
                    if SalesHeader."Ship-to Code" <> '' then begin
                        ShiptoAddress.Get(SalesShipmentHeader."Sell-to Customer No.", SalesShipmentHeader."Ship-to Code");
                        if ShippingAgentServices."NPR Phone Mandatory" then
                            ShiptoAddress.TestField("Phone No.");

                        if ShippingAgentServices."NPR Email Mandatory" then
                            ShiptoAddress.TestField("E-Mail");

                    end else begin

                        Customer.Get(SalesShipmentHeader."Sell-to Customer No.");
                        if ShippingAgentServices."NPR Phone Mandatory" then
                            Customer.TestField("Phone No.");

                        if ShippingAgentServices."NPR Email Mandatory" then
                            Customer.TestField("E-Mail");
                    end;

                    SalesShipmentHeader.TestField("Ship-to Name");
                    SalesShipmentHeader.TestField("Ship-to Address");
                    SalesShipmentHeader.TestField("Ship-to Post Code");
                    SalesShipmentHeader.TestField("Ship-to City");

                    ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code");
                    if ShippingAgent."NPR Ship to Contact Mandatory" then
                        SalesShipmentHeader.TestField("Ship-to Contact");
                end;
        end;
    end;

    local procedure CheckNetWeight(SalesShipmentHeader: Record "Sales Shipment Header"): Boolean
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
        SalesShipmentLine.SetFilter("Net Weight", '<>%1', 0);
        exit(SalesShipmentLine.FindSet());
    end;

    procedure AddEntry(RecRef: RecordRef; ShowWindow: Boolean; Silent: Boolean; var ResponseMessage: Text)
    var
        CompanyInfo: Record "Company Information";
        ShipmentDocument: Record "NPR Pacsoft Shipment Document";
        ShipmentDocument2: Record "NPR Pacsoft Shipment Document";
        ShipmentDocServices: Record "NPR Pacsoft Shipm. Doc. Serv.";
        CustomsItemRows: Record "NPR Pacsoft Customs Item Rows";
        Customer: Record Customer;
        SalesShipmentHeader: Record "Sales Shipment Header";
        ShipToAddress: Record "Ship-to Address";
        ShippingAgentServices: Record "Shipping Agent Services";
        ShippingAgent: Record "Shipping Agent";
        ReturnShippingAgent: Record "Shipping Agent";
        SalesShipmentLine: Record "Sales Shipment Line";
        CreateShipmentDocument: Page "NPR Pacsoft Shipment Document";
        TextNotActivated: Label 'The Pacsoft integration is not activated.';
        ShippingAgentServicesCode: Code[10];
        DocFound: Boolean;
    begin

        if not InitPackageProvider() then
            exit;
        ResponseMessage := '';

        ShipmentDocument.SetRange("Table No.", RecRef.Number());
        ShipmentDocument.SetRange(RecordID, RecRef.RecordId());
        if ShipmentDocument.FindLast() then
            DocFound := true
        else begin
            Clear(ShipmentDocument);
            ShipmentDocument.Init();
            ShipmentDocument.Validate("Entry No.", 0);
            ShipmentDocument.Validate("Table No.", RecRef.Number);
            ShipmentDocument.Validate(RecordID, RecRef.RecordId);
            ShipmentDocument.Validate("Creation Time", CurrentDateTime);
        end;
        case RecRef.Number of
            DATABASE::"Sales Shipment Header":
                begin
                    RecRef.SetTable(SalesShipmentHeader);
                    if SalesShipmentHeader.Find() then begin
                        if SalesShipmentHeader."Shipment Method Code" = '' then exit;
                        if CheckNetWeight(SalesShipmentHeader) = false then exit;
                        if SalesShipmentHeader."NPR Kolli" = 0 then exit;
                        if not DocFound then
                            ShipmentDocument.Insert(true);
                        Customer.Get(SalesShipmentHeader."Sell-to Customer No.");
                        Clear(ShipToAddress);
                        if ShipToAddress.Get(SalesShipmentHeader."Sell-to Customer No.", SalesShipmentHeader."Ship-to Code") then begin
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
                        ShippingAgentServicesCode := SalesShipmentHeader."Shipping Agent Service Code";
                        if ShipmentDocument."Shipping Agent Service Code" = '' then begin
                            ShippingAgentServicesCode := SalesShipmentHeader."Shipping Agent Service Code";
                        end;
                        ShipmentDocument."Order No." := SalesShipmentHeader."Order No.";
                        ShipmentDocument."Total Weight" := 0;
                        SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
                        SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
                        SalesShipmentLine.SetFilter("Net Weight", '<>0');
                        if SalesShipmentLine.FindSet() then
                            repeat
                                ShipmentDocument."Total Weight" += SalesShipmentLine."Net Weight" * SalesShipmentLine.Quantity;
                            until SalesShipmentLine.Next() = 0;

                        ShipmentDocument."Total Weight" := Round(ShipmentDocument."Total Weight", 1, '>') * 1000;

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
                                ShipmentDocument.Reference := CopyStr(SalesShipmentHeader."Order No.", 1,
                                                                      MaxStrLen(ShipmentDocument.Reference));

                        if (PackageProviderSetup."Order No. or Ext Doc No to ref") then begin
                            if SalesShipmentHeader."External Document No." <> '' then
                                ShipmentDocument.Reference := SalesShipmentHeader."External Document No."
                            else
                                ShipmentDocument.Reference := SalesShipmentHeader."Order No.";
                        end;

                        ShipmentDocument."External Document No." := SalesShipmentHeader."External Document No.";
                        ShipmentDocument."Delivery Instructions" := SalesShipmentHeader."NPR Delivery Instructions";
                        ShipmentDocument."Your Reference" := SalesShipmentHeader."Your Reference";

                        if PackageProviderSetup."Print Return Label" then begin
                            ShipmentDocument."Print Return Label" := PackageProviderSetup."Print Return Label";
                            ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code");

                            ReturnShippingAgent.SetRange("NPR Return Shipping agent", true);
                            ReturnShippingAgent.SetRange("NPR Shipping Method", ShippingAgent."NPR Shipping Method");
                            if ReturnShippingAgent.FindFirst then
                                ShipmentDocument."Return Shipping Agent Code" := ReturnShippingAgent.Code;
                        end;
                    end;
                end;
        end;

        CompanyInfo.Get();
        ShipmentDocument."Sender VAT Reg. No" := CompanyInfo."VAT Registration No.";
        if ShipmentDocument."Country/Region Code" = '' then
            ShipmentDocument."Country/Region Code" := CompanyInfo."Country/Region Code";
        if ShipmentDocument."Shipment Date" < Today then
            ShipmentDocument."Shipment Date" := Today();

        ShipmentDocument.Modify(true);

        if ShipmentDocument."Shipping Agent Code" <> '' then begin
            Clear(ShippingAgentServices);
            ShippingAgentServices.SetCurrentKey("Shipping Agent Code");
            ShippingAgentServices.SetRange("Shipping Agent Code", ShipmentDocument."Shipping Agent Code");
            ShippingAgentServices.SetRange("NPR Default Option", true);
            if ShippingAgentServices.FindSet() then begin
                repeat
                    Clear(ShipmentDocServices);
                    ShipmentDocServices.Validate("Entry No.", ShipmentDocument."Entry No.");
                    ShipmentDocServices.Validate("Shipping Agent Code", ShippingAgentServices."Shipping Agent Code");
                    ShipmentDocServices.Validate("Shipping Agent Service Code", ShippingAgentServices.Code);
                    if not DocFound then
                        ShipmentDocServices.Insert(true);
                until ShippingAgentServices.Next() = 0;
            end
            else begin
                if (ShippingAgentServicesCode <> '') and (PackageProviderSetup."Create Shipping Services Line") then begin
                    Clear(ShippingAgentServices);
                    ShippingAgentServices.SetCurrentKey("Shipping Agent Code");
                    ShippingAgentServices.SetRange("Shipping Agent Code", ShipmentDocument."Shipping Agent Code");
                    ShippingAgentServices.SetRange(Code, ShippingAgentServicesCode);
                    ShippingAgentServices.SetRange("NPR Default Option", false);
                    if ShippingAgentServices.FindSet() then
                        repeat
                            Clear(ShipmentDocServices);
                            ShipmentDocServices.Validate("Entry No.", ShipmentDocument."Entry No.");
                            ShipmentDocServices.Validate("Shipping Agent Code", ShippingAgentServices."Shipping Agent Code");
                            ShipmentDocServices.Validate("Shipping Agent Service Code", ShippingAgentServices.Code);
                            if not DocFound then
                                ShipmentDocServices.Insert(true);
                        until ShippingAgentServices.Next() = 0;
                end;
            end;
        end;
        Commit();

        if PackageProviderSetup."Send Package Doc. Immediately" then begin
            if PackageProviderSetup."Skip Own Agreement" then
                CreateShipment(ShipmentDocument, Silent)
            else
                CreateShipmentOwnCustomerNo(ShipmentDocument, Silent);
        end;
        if PackageProviderSetup."Print Return Label" then
            CreateReturnShipmentOwnCustomerNo(ShipmentDocument, Silent);

        if ErrorTextFound <> '' then
            ResponseMessage := strsubstno(ResponseMsg, ErrorTextFound);
    end;

    [EventSubscriber(ObjectType::Page, 6014440, 'OnAfterActionEvent', 'SendDocument', true, true)]
    local procedure P6014440OnAfterActionEventSendDoc(var Rec: Record "NPR Pacsoft Shipment Document")
    begin
        if not InitPackageProvider() then
            exit;
        if PackageProviderSetup."Skip Own Agreement" then
            CreateShipment(Rec, false)
        else
            CreateShipmentOwnCustomerNo(Rec, false);
        CreateReturnShipmentOwnCustomerNo(Rec, false);
    end;

    [EventSubscriber(ObjectType::Page, 130, 'OnAfterActionEvent', 'NPR PrintShipmentDocument', true, true)]
    local procedure P130OnAfterActionEventCreatePackage(var Rec: Record "Sales Shipment Header")
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesSetup: Record "Sales & Receivables Setup";
        ShipmentDocument: Record "NPR Pacsoft Shipment Document";
        RecRefShipment: RecordRef;
        RecRef: RecordRef;
        CreatePackageEntryQst: Label 'Do you Want to create a Package entry ?';
        PrintDocumentQst: Label 'Do you want to print the Document?';
        LabelType: Option Post,Return;
        DummyResponseMessage: Text;
    begin
        if not InitPackageProvider() then
            exit;

        RecRef.GetTable(Rec);
        ShipmentDocument.SetRange("Table No.", RecRef.Number);
        ShipmentDocument.SetRange(RecordID, RecRef.RecordId);
        if ShipmentDocument.FindLast() then begin
            if Confirm(PrintDocumentQst, true) then
                if ShipmentDocument."Response Shipment ID" <> '' then begin
                    GetPDFByShipmentId(ShipmentDocument, false, LabelType::Post);
                    if ShipmentDocument."Return Response Shipment ID" <> '' then
                        GetPDFByShipmentId(ShipmentDocument, false, LabelType::Return);
                end else begin
                    AddEntry(RecRef, false, false, DummyResponseMessage);
                    if PackageProviderSetup."Skip Own Agreement" then
                        CreateShipment(ShipmentDocument, false)
                    else
                        CreateShipmentOwnCustomerNo(ShipmentDocument, false);
                    CreateReturnShipmentOwnCustomerNo(ShipmentDocument, false);
                end;
        end else begin
            RecRefShipment.GetTable(SalesShptHeader);
            TestFieldPakkelabels(RecRefShipment);
            if Confirm(CreatePackageEntryQst, true) then
                AddEntry(RecRefShipment, false, false, DummyResponseMessage);
        end;
    end;

    [EventSubscriber(ObjectType::Page, 6014440, 'OnAfterActionEvent', 'PrintDocument', false, false)]
    local procedure P6014440OnAfterActionEventPrintDocument(var Rec: Record "NPR Pacsoft Shipment Document")
    var
        LabelType: Option Post,Return;
    begin
        if not InitPackageProvider() then
            exit;
        if Rec."Response Shipment ID" <> '' then
            GetPDFByShipmentId(Rec, false, LabelType::Post);
        if Rec."Return Response Shipment ID" <> '' then
            GetPDFByShipmentId(Rec, false, LabelType::Return);
        if Rec."Response Shipment ID" <> '' then
            AddToPrintQueue(Rec, false, LabelType::Post);

        if Rec."Return Response Shipment ID" <> '' then
            AddToPrintQueue(Rec, false, LabelType::Return);
    end;

    local procedure TQSendPakkeLabel()
    var
        ShipmentDocument: Record "NPR Pacsoft Shipment Document";
    begin
        ShipmentDocument.SetFilter(ShipmentDocument."Shipping Method Code", '<>%1', '');
        ShipmentDocument.SetFilter("Shipping Agent Code", '<>%1', '');
        ShipmentDocument.SetFilter("Shipping Agent Service Code", '<>%1', '');
        ShipmentDocument.SetFilter("Response Shipment ID", '');
        if ShipmentDocument.FindSet() then
            repeat
                if PackageProviderSetup."Skip Own Agreement" then
                    CreateShipment(ShipmentDocument, true)
                else
                    CreateShipmentOwnCustomerNo(ShipmentDocument, true);
                CreateReturnShipmentOwnCustomerNo(ShipmentDocument, true);
            until ShipmentDocument.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Page, 6014574, 'OnAfterActionEvent', 'Test Connection', false, false)]
    local procedure TestConnection(var Rec: Record "NPR Pacsoft Setup")
    var
        Token: Text;
    begin
        Login(Token, false);
        Message(ConnectionSuccessfulMsg);
    end;

    [EventSubscriber(ObjectType::Page, 6014574, 'OnAfterActionEvent', 'Check Balance', false, false)]
    local procedure CheckBalance(var Rec: Record "NPR Pacsoft Setup")
    begin
        GetBalance(false);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterModifyEvent', '', true, true)]
    local procedure T36OnAfterModifyEvent(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; RunTrigger: Boolean)
    var
        ForeignShipmentMapping: Record "NPR Pakke Foreign Shipm. Map.";
    begin
        if not RunTrigger then
            exit;
        if not InitPackageProvider() then
            exit;
        if (Rec."Shipment Method Code" = '') or (Rec."Shipping Agent Code" = '') then
            exit;
        ForeignShipmentMapping.SetRange("Shipment Method Code", Rec."Shipment Method Code");
        ForeignShipmentMapping.SetRange("Base Shipping Agent Code", Rec."Shipping Agent Code");
        ForeignShipmentMapping.SetRange("Country/Region Code", Rec."Ship-to Country/Region Code");
        if ForeignShipmentMapping.FindFirst() then begin
            Rec."Shipping Agent Code" := ForeignShipmentMapping."Shipping Agent Code";
            Rec."Shipping Agent Service Code" := ForeignShipmentMapping."Shipping Agent Service Code";
            Rec.Modify(true);
        end;
    end;
}

