#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248370 "NPR API Customer" implements "NPR API Request Handler"
{
    Access = Internal;

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    var
        CustomerGDPRApiAgent: Codeunit "NPR Customer GDPR Api Agent";
    begin
        case true of
            Request.Match('GET', '/customer/:id'):
                exit(GetCustomer(Request));
            Request.Match('GET', '/customer'):
                exit(GetCustomer(Request));
            Request.Match('POST', '/customer'):
                exit(CreateCustomer(Request));
            Request.Match('POST', '/customer/requestAnonymize'):
                exit(CustomerGDPRApiAgent.AnonymizeCustomer(Request));
        end;
    end;

    procedure GetCustomer(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Customer: Record Customer;
        Fields: Dictionary of [Integer, Text];
        Id: Text;
    begin
        if Request.QueryParams().ContainsKey('customerNo') then begin
            Customer.SetFilter("No.", '=%1', Request.QueryParams().Get('customerNo'));
        end;

        if Request.QueryParams().ContainsKey('email') then begin
            Customer.SetFilter("E-Mail", '=%1', Request.QueryParams().Get('email'));
        end;

        Fields.Add(Customer.FieldNo("No."), 'no');
        Fields.Add(Customer.FieldNo(Name), 'name');
        Fields.Add(Customer.FieldNo(Address), 'address');
        Fields.Add(Customer.FieldNo("Post Code"), 'postCode');
        Fields.Add(Customer.FieldNo(City), 'city');
        Fields.Add(Customer.FieldNo("Address 2"), 'address2');
        Fields.Add(Customer.FieldNo(County), 'county');
        Fields.Add(Customer.FieldNo("Country/Region Code"), 'countryCode');
        Fields.Add(Customer.FieldNo(Contact), 'contact');
        Fields.Add(Customer.FieldNo("E-Mail"), 'email');
        Fields.Add(Customer.FieldNo("Phone No."), 'phone');
        Fields.Add(Customer.FieldNo("Mobile Phone No."), 'mobilePhone');
        Fields.Add(Customer.FieldNo("GLN"), 'ean');
        Fields.Add(Customer.FieldNo("VAT Registration No."), 'vatRegistrationNo');
        Fields.Add(Customer.FieldNo("Gen. Bus. Posting Group"), 'genBusPostingGroup');
        Fields.Add(Customer.FieldNo("VAT Bus. Posting Group"), 'vatBusPostingGroup');
        Fields.Add(Customer.FieldNo("Customer Posting Group"), 'customerPostingGroup');
        Fields.Add(Customer.FieldNo("Currency Code"), 'currencyCode');
        Fields.Add(Customer.FieldNo("Customer Price Group"), 'customerPriceGroup');
        Fields.Add(Customer.FieldNo("Invoice Disc. Code"), 'invoiceDiscCode');
        Fields.Add(Customer.FieldNo("Customer Disc. Group"), 'customerDiscGroup');
        Fields.Add(Customer.FieldNo("Allow Line Disc."), 'allowLineDisc');
        Fields.Add(Customer.FieldNo("Payment Terms Code"), 'paymentTermsCode');
        Fields.Add(Customer.FieldNo("Payment Method Code"), 'paymentMethodCode');
        Fields.Add(Customer.FieldNo("Shipment Method Code"), 'shipmentMethodCode');

        if Request.Paths().Count > 1 then begin
            Id := Request.Paths().Get(2);
            exit(Response.RespondOK(Request.GetData(Customer, Fields, Id)));
        end else begin
            exit(Response.RespondOK(Request.GetData(Customer, Fields)));
        end;
    end;

    procedure CreateCustomer(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        EcomSetup: Record "NPR Inc Ecom Sales Doc Setup";
        JsonHelper: Codeunit "NPR Json Helper";
        APICustomerEvents: Codeunit "NPR API Customer Events";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
        Body: JsonToken;
        RecRef: RecordRef;
        CustomerTemplateCode: Code[20];
        ConfigTemplateCode: Code[10];
        CustomerNo: Code[20];
        CustomerName: Text[100];
    begin
        Body := Request.BodyJson();

        CustomerNo := CopyStr(JsonHelper.GetJText(Body, 'no', false), 1, MaxStrLen(Customer."No."));
        CustomerName := CopyStr(JsonHelper.GetJText(Body, 'name', true), 1, MaxStrLen(Customer.Name));

        if not EcomSetup.Get() then
            EcomSetup.Init();

        // Check if customer already exists based on mapping setup
        if CheckCustomerExists(Body, Customer, EcomSetup) then
            exit(Response.RespondBadRequest(GetCustomerExistsErrorMessage(Body, Customer, EcomSetup)));

        CustomerTemplateCode := CopyStr(JsonHelper.GetJText(Body, 'customerTemplate', false), 1, MaxStrLen(CustomerTemplateCode));
        ConfigTemplateCode := CopyStr(JsonHelper.GetJText(Body, 'configurationTemplate', false), 1, MaxStrLen(ConfigTemplateCode));

        if CustomerTemplateCode <> '' then
            ConfigTemplateCode := '';

        if (CustomerTemplateCode = '') and (ConfigTemplateCode = '') then begin
            if EcomSetup.Get() then begin
                CustomerTemplateCode := EcomSetup."Def. Customer Template Code";
                if CustomerTemplateCode = '' then
                    ConfigTemplateCode := EcomSetup."Def Cust Config Template Code";
            end;
        end;

        // Allow third party extensions to override the template
        APICustomerEvents.OnBeforeGetCustomerTemplate(Body, CustomerTemplateCode, ConfigTemplateCode);

        Customer.Init();

        if CustomerNo <> '' then
            Customer."No." := CustomerNo
        else begin
            if CustomerTemplateCode <> '' then begin
                if CustomerTempl.Get(CustomerTemplateCode) and (CustomerTempl."No. Series" <> '') then begin
                    Customer."No. Series" := CustomerTempl."No. Series";
                end else begin
                    SetDefaultCustomerNoSeries(Customer);
                end;
            end else begin
                SetDefaultCustomerNoSeries(Customer);
            end;

            // Allow third party extensions to override the number series
            APICustomerEvents.OnBeforeGetCustomerNoSeries(Body, Customer);

#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            Customer."No." := NoSeriesMgt.GetNextNo(Customer."No. Series");
#ELSE
            NoSeriesMgt.InitSeries(Customer."No. Series", Customer."No. Series", Today(), Customer."No.", Customer."No. Series");
#ENDIF
        end;

        APICustomerEvents.OnBeforeInsertCustomer(Body, Customer);

        Customer.Insert(true);

        APICustomerEvents.OnAfterInsertCustomer(Body, Customer);

        if CustomerTemplateCode <> '' then begin
            if CustomerTempl.Get(CustomerTemplateCode) then begin
                Customer.CopyFromNewCustomerTemplate(CustomerTempl);
                Customer.Modify(true);
            end;
        end else if ConfigTemplateCode <> '' then begin
            if ConfigTemplateHeader.Get(ConfigTemplateCode) then begin
                RecRef.GetTable(Customer);
                ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
                RecRef.SetTable(Customer);
                Customer.Modify(true);
            end;
        end;

        Customer.Name := CustomerName;
        Customer.Address := CopyStr(JsonHelper.GetJText(Body, 'address', false), 1, MaxStrLen(Customer.Address));
        Customer."Post Code" := CopyStr(JsonHelper.GetJText(Body, 'postCode', false), 1, MaxStrLen(Customer."Post Code"));
        Customer.City := CopyStr(JsonHelper.GetJText(Body, 'city', false), 1, MaxStrLen(Customer.City));
        Customer."Address 2" := CopyStr(JsonHelper.GetJText(Body, 'address2', false), 1, MaxStrLen(Customer."Address 2"));
        Customer.County := CopyStr(JsonHelper.GetJText(Body, 'county', false), 1, MaxStrLen(Customer.County));
        Customer."Country/Region Code" := CopyStr(JsonHelper.GetJText(Body, 'countryCode', false), 1, MaxStrLen(Customer."Country/Region Code"));
        Customer.Contact := CopyStr(JsonHelper.GetJText(Body, 'contact', false), 1, MaxStrLen(Customer.Contact));
        Customer."E-Mail" := CopyStr(JsonHelper.GetJText(Body, 'email', false), 1, MaxStrLen(Customer."E-Mail"));
        Customer."Phone No." := CopyStr(JsonHelper.GetJText(Body, 'phone', false), 1, MaxStrLen(Customer."Phone No."));
        Customer."Mobile Phone No." := CopyStr(JsonHelper.GetJText(Body, 'mobilePhone', false), 1, MaxStrLen(Customer."Mobile Phone No."));
        Customer."GLN" := CopyStr(JsonHelper.GetJText(Body, 'ean', false), 1, MaxStrLen(Customer."GLN"));
        Customer."VAT Registration No." := CopyStr(JsonHelper.GetJText(Body, 'vatRegistrationNo', false), 1, MaxStrLen(Customer."VAT Registration No."));

        // Allow third party extensions to modify customer before final modification
        APICustomerEvents.OnBeforeModifyCustomer(Body, Customer);

        Customer.Modify(true);

        exit(Response.RespondCreated(CustomerToJson(Customer)));
    end;

    local procedure CustomerToJson(Customer: Record Customer) Json: JsonObject
    begin
        Json.Add('id', Format(Customer.SystemId, 0, 4).ToLower());
        Json.Add('no', Customer."No.");
        Json.Add('name', Customer.Name);
        Json.Add('address', Customer.Address);
        Json.Add('postCode', Customer."Post Code");
        Json.Add('city', Customer.City);
        Json.Add('address2', Customer."Address 2");
        Json.Add('county', Customer.County);
        Json.Add('countryCode', Customer."Country/Region Code");
        Json.Add('contact', Customer.Contact);
        Json.Add('email', Customer."E-Mail");
        Json.Add('phone', Customer."Phone No.");
        Json.Add('mobilePhone', Customer."Mobile Phone No.");
        Json.Add('ean', Customer."GLN");
        Json.Add('vatRegistrationNo', Customer."VAT Registration No.");
        Json.Add('genBusPostingGroup', Customer."Gen. Bus. Posting Group");
        Json.Add('vatBusPostingGroup', Customer."VAT Bus. Posting Group");
        Json.Add('customerPostingGroup', Customer."Customer Posting Group");
        Json.Add('currencyCode', Customer."Currency Code");
        Json.Add('customerPriceGroup', Customer."Customer Price Group");
        Json.Add('invoiceDiscCode', Customer."Invoice Disc. Code");
        Json.Add('customerDiscGroup', Customer."Customer Disc. Group");
        Json.Add('allowLineDisc', Customer."Allow Line Disc.");
        Json.Add('paymentTermsCode', Customer."Payment Terms Code");
        Json.Add('paymentMethodCode', Customer."Payment Method Code");
        Json.Add('shipmentMethodCode', Customer."Shipment Method Code");
        Json.Add('rowVersion', Customer.SystemRowVersion);
    end;

    local procedure SetDefaultCustomerNoSeries(var Customer: Record Customer)
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get();
        SalesSetup.TestField("Customer Nos.");
        Customer."No. Series" := SalesSetup."Customer Nos.";
    end;

    local procedure CheckCustomerExists(Body: JsonToken; var Customer: Record Customer; EcomSetup: Record "NPR Inc Ecom Sales Doc Setup") Found: Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Email: Text[80];
        PhoneNo: Text[30];
        CustomerNo: Code[20];
    begin
        Clear(Customer);

        Email := CopyStr(JsonHelper.GetJText(Body, 'email', false), 1, MaxStrLen(Customer."E-Mail"));
        PhoneNo := CopyStr(JsonHelper.GetJText(Body, 'phone', false), 1, MaxStrLen(Customer."Phone No."));
        CustomerNo := CopyStr(JsonHelper.GetJText(Body, 'no', false), 1, MaxStrLen(Customer."No."));

        case EcomSetup."Customer Mapping" of
            EcomSetup."Customer Mapping"::"E-mail":
                begin
                    if Email = '' then
                        exit(false);
                    Customer.SetRange("E-Mail", Email);
                    Found := Customer.FindFirst() and (Customer."E-Mail" <> '');
                end;
            EcomSetup."Customer Mapping"::"Phone No.":
                begin
                    if PhoneNo = '' then
                        exit(false);
                    Customer.SetRange("Phone No.", PhoneNo);
                    Found := Customer.FindFirst() and (Customer."Phone No." <> '');
                end;
            EcomSetup."Customer Mapping"::"E-mail AND Phone No.":
                begin
                    if (Email = '') or (PhoneNo = '') then
                        exit(false);
                    Customer.SetRange("E-Mail", Email);
                    Customer.SetRange("Phone No.", PhoneNo);
                    Found := Customer.FindFirst() and (Customer."E-Mail" <> '') and (Customer."Phone No." <> '');
                end;
            EcomSetup."Customer Mapping"::"E-mail OR Phone No.":
                begin
                    if Email <> '' then begin
                        Customer.SetRange("E-Mail", Email);
                        Found := Customer.FindFirst() and (Customer."E-Mail" <> '');
                        if Found then
                            exit(true);
                    end;

                    if PhoneNo <> '' then begin
                        Customer.SetRange("E-Mail");
                        Customer.SetRange("Phone No.", PhoneNo);
                        Found := Customer.FindFirst() and (Customer."Phone No." <> '');
                    end;
                end;
            EcomSetup."Customer Mapping"::"Customer No.":
                begin
                    if CustomerNo = '' then
                        exit(false);
                    Found := Customer.Get(CustomerNo);
                end;
            EcomSetup."Customer Mapping"::"Phone No. to Customer No.":
                begin
                    if PhoneNo = '' then
                        exit(false);
                    Found := Customer.Get(PhoneNo);
                end;
        end;
    end;

    local procedure GetCustomerExistsErrorMessage(Body: JsonToken; Customer: Record Customer; EcomSetup: Record "NPR Inc Ecom Sales Doc Setup") ErrorMessage: Text
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Email: Text[80];
        PhoneNo: Text[30];
        CustomerNo: Code[20];
    begin
        Email := CopyStr(JsonHelper.GetJText(Body, 'email', false), 1, MaxStrLen(Customer."E-Mail"));
        PhoneNo := CopyStr(JsonHelper.GetJText(Body, 'phone', false), 1, MaxStrLen(Customer."Phone No."));
        CustomerNo := CopyStr(JsonHelper.GetJText(Body, 'no', false), 1, MaxStrLen(Customer."No."));

        case EcomSetup."Customer Mapping" of
            EcomSetup."Customer Mapping"::"E-mail":
                ErrorMessage := StrSubstNo('Customer already exists with E-Mail: %1', Email);
            EcomSetup."Customer Mapping"::"Phone No.":
                ErrorMessage := StrSubstNo('Customer already exists with Phone No.: %1', PhoneNo);
            EcomSetup."Customer Mapping"::"E-mail AND Phone No.":
                ErrorMessage := StrSubstNo('Customer already exists with E-Mail: %1 and Phone No.: %2', Email, PhoneNo);
            EcomSetup."Customer Mapping"::"E-mail OR Phone No.":
                begin
                    if (Customer."E-Mail" <> '') and (Customer."E-Mail" = Email) then
                        ErrorMessage := StrSubstNo('Customer already exists with E-Mail: %1', Email)
                    else if (Customer."Phone No." <> '') and (Customer."Phone No." = PhoneNo) then
                        ErrorMessage := StrSubstNo('Customer already exists with Phone No.: %1', PhoneNo)
                    else
                        ErrorMessage := StrSubstNo('Customer already exists with No.: %1', Customer."No.");
                end;
            EcomSetup."Customer Mapping"::"Customer No.":
                ErrorMessage := StrSubstNo('Customer already exists with No.: %1', CustomerNo);
            EcomSetup."Customer Mapping"::"Phone No. to Customer No.":
                ErrorMessage := StrSubstNo('Customer already exists with No.: %1 (mapped from Phone No.: %2)', PhoneNo, PhoneNo);
            else
                ErrorMessage := StrSubstNo('Customer already exists with No.: %1', Customer."No.");
        end;
    end;
}
#endif
