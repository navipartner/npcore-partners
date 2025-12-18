#if not BC17
codeunit 6248540 "NPR Spfy Send Customers"
{
    Access = Internal;
    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        Rec.TestField("Store Code");
        case Rec."Table No." of
            Database::Customer:
                SendCustomer(Rec);
        end;
    end;

    var
        _LastQueriedSpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        _SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        _JsonHelper: Codeunit "NPR Json Helper";
        _ShopifyCustomerID: Text[30];
        _QueryingShopifyLbl: Label 'Querying Shopify...';


    local procedure SendCustomer(var NcTask: Record "NPR Nc Task")
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        ShopifyCustomerID: Text[30];
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();

        PrepareCustomerUpdateRequest(NcTask, SpfyStoreCustomerLink);
        Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse);
        NcTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error('');  //The system will record Shopify response as the error message

#pragma warning disable AA0139
        case NcTask.Type of
            NcTask.Type::Insert:
                ShopifyCustomerID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyResponse, 'data.customerCreate.customer.id', true), '/');
            NcTask.Type::Modify:
                ShopifyCustomerID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyResponse, 'data.customerUpdate.customer.id', true), '/');
            NcTask.Type::Delete:
                ShopifyCustomerID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyResponse, 'data.customerDelete.deletedCustomerId', true), '/');
        end;
#pragma warning restore AA0139
        RetrieveShopifyCustomerAndUpdateBCCustomerWithDataFromShopify(SpfyStoreCustomerLink, ShopifyCustomerID, NcTask.Type = NcTask.Type::Delete, false, false);
    end;

    local procedure PrepareCustomerUpdateRequest(var NcTask: Record "NPR Nc Task"; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    var
        Customer: Record Customer;
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        ShopifyCustomerID: Text[30];
        ShopifyCustomerIDEmptyErr: Label 'Shopify Customer Id must be specified for %1, %2 = %3', Comment = '%1 - Customer record id, %2 - Shopify store code field name, %3 - Shopify store code';
    begin
        RecRef.Get(NcTask."Record ID");
        RecRef.SetTable(Customer);

        GetStoreCustomerLink(Customer."No.", NcTask."Store Code", SpfyStoreCustomerLink);
        UpdateFromCustomer(Customer, SpfyStoreCustomerLink);

        ShopifyCustomerID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreCustomerLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyCustomerID = '' then
            ShopifyCustomerID := GetShopifyCustomerID(SpfyStoreCustomerLink, false);
        if ShopifyCustomerID = '' then begin
            case NcTask.Type of
                NcTask.Type::Modify:
                    NcTask.Type := NcTask.Type::Insert;
                NcTask.Type::Delete:
                    Error(ShopifyCustomerIDEmptyErr, Format(Customer.RecordId()), SpfyStoreCustomerLink.FieldCaption("Shopify Store Code"), SpfyStoreCustomerLink."Shopify Store Code");
            end;
        end else
            if NcTask.Type = NcTask.Type::Insert then
                NcTask.Type := NcTask.Type::Modify;

        PrepareCustomerUpdateRequest(NcTask, SpfyStoreCustomerLink, ShopifyCustomerID);
    end;

    local procedure PrepareCustomerUpdateRequest(var NcTask: Record "NPR Nc Task"; SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; ShopifyCustomerID: Text[30])
    var
        InputJson: JsonObject;
        Request: JsonObject;
        Variables: JsonObject;
        OStream: OutStream;
        EmailMarketingConsentIncluded: Boolean;
        CustomerCreate_QueryTok: Label 'mutation CreateCustomer($customerInput: CustomerInput!) {customerCreate(input: $customerInput) {customer{id} userErrors {message field}}}', Locked = true;
        CustomerDelete_QueryTok: Label 'mutation DeleteCustomer($customerInput: CustomerDeleteInput!) {customerDelete(input: $customerInput) {deletedCustomerId userErrors{field message}}}', Locked = true;
        CustomerUpdate_QueryTok: Label 'mutation UpdateCustomer(%1) {customerUpdate(input: $customerInput) {customer{id} userErrors{field message}}%2}', Locked = true;
        EmailMarketingConsentUpdate_QueryTok: Label 'customerEmailMarketingConsentUpdate(input: $emailMarketingConsentInput) {customer{id defaultEmailAddress{emailAddress marketingState marketingOptInLevel marketingUpdatedAt}} userErrors{field message}}', Locked = true;
    begin
        AddCustomerInfo(SpfyStoreCustomerLink, NcTask.Type, ShopifyCustomerID, InputJson);
        Variables.Add('customerInput', InputJson);
        if (ShopifyCustomerID <> '') and (NcTask.Type = NcTask.Type::Modify) then begin
            Clear(InputJson);
            EmailMarketingConsentIncluded := AddEmailMarketingConsentInfo(SpfyStoreCustomerLink, ShopifyCustomerID, InputJson);
            if EmailMarketingConsentIncluded then
                Variables.Add('emailMarketingConsentInput', InputJson);
        end;

        case NcTask.Type of
            NcTask.Type::Insert:
                Request.Add('query', CustomerCreate_QueryTok);
            NcTask.Type::Modify:
                begin
                    if EmailMarketingConsentIncluded then
                        Request.Add('query', StrSubstNo(CustomerUpdate_QueryTok, '$customerInput: CustomerInput!, $emailMarketingConsentInput: CustomerEmailMarketingConsentUpdateInput!', EmailMarketingConsentUpdate_QueryTok))
                    else
                        Request.Add('query', StrSubstNo(CustomerUpdate_QueryTok, '$customerInput: CustomerInput!', ''));
                end;
            NcTask.Type::Delete:
                Request.Add('query', CustomerDelete_QueryTok);
        end;
        Request.Add('variables', Variables);

        NcTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        Request.WriteTo(OStream);
    end;

    local procedure AddCustomerInfo(SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; NcTaskType: Integer; ShopifyCustomerID: Text[30]; var CustomerJson: JsonObject)
    var
        NcTask: Record "NPR Nc Task";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        RemoveMetafields: JsonArray;
        UpdateMetafields: JsonArray;
    begin
        if ShopifyCustomerID <> '' then
            CustomerJson.Add('id', 'gid://shopify/Customer/' + ShopifyCustomerID);
        if NcTaskType = NcTask.Type::Delete then
            exit;
        CustomerJson.Add('email', SpfyStoreCustomerLink."E-Mail");
        if SpfyStoreCustomerLink."Phone No." <> '' then
            if _SpfyIntegrationMgt.IsUpdateCustPhoneNoFromBC(SpfyStoreCustomerLink."Shopify Store Code") then
                CustomerJson.Add('phone', SpfyStoreCustomerLink."Phone No.");
        if SpfyStoreCustomerLink."First Name" <> '' then
            CustomerJson.Add('firstName', SpfyStoreCustomerLink."First Name");
        CustomerJson.Add('lastName', SpfyStoreCustomerLink."Last Name");

        if ShopifyCustomerID = '' then  // Marketing consent must be sent as a separate request when updating an existing customer
            AddEmailMarketingConsentInfo(SpfyStoreCustomerLink, ShopifyCustomerID, CustomerJson);

        SpfyMetafieldMgt.GenerateMetafieldUpdateArrays(SpfyStoreCustomerLink.RecordId(), "NPR Spfy Metafield Owner Type"::CUSTOMER, '', SpfyStoreCustomerLink."Shopify Store Code", UpdateMetafields, RemoveMetafields);
        if UpdateMetafields.Count() > 0 then
            CustomerJson.Add('metafields', UpdateMetafields);
    end;

    local procedure AddEmailMarketingConsentInfo(SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; ShopifyCustomerID: Text[30]; var InputJson: JsonObject): Boolean
    var
        SpfyCustomerMgt: Codeunit "NPR Spfy Customer Mgt.";
        EmailMarketingConsentJson: JsonObject;
    begin
        if SpfyStoreCustomerLink."E-mail Marketing State" = SpfyStoreCustomerLink."E-mail Marketing State"::UNKNOWN then
            SpfyCustomerMgt.UpdateMarketingConsentState(SpfyStoreCustomerLink);
        if SpfyStoreCustomerLink."Marketing State Updated in BC" and (SpfyStoreCustomerLink."E-mail Marketing State" <> SpfyStoreCustomerLink."E-mail Marketing State"::UNKNOWN) then begin
            if SpfyStoreCustomerLink."E-mail Marketing State" = SpfyStoreCustomerLink."E-mail Marketing State"::SUBSCRIBED then
                EmailMarketingConsentJson.Add('marketingOptInLevel', 'SINGLE_OPT_IN');  // Possible values: CONFIRMED_OPT_IN, SINGLE_OPT_IN, UNKNOWN
            EmailMarketingConsentJson.Add('marketingState', SpfyEmailMarketingStateEnumValueName(SpfyStoreCustomerLink."E-mail Marketing State"));
            if ShopifyCustomerID <> '' then
                InputJson.Add('customerId', 'gid://shopify/Customer/' + ShopifyCustomerID);
            InputJson.Add('emailMarketingConsent', EmailMarketingConsentJson);
            exit(true);
        end;
        exit(false);
    end;

    local procedure SpfyEmailMarketingStateEnumValueName(State: Enum "NPR Spfy EMail Marketing State") Result: Text
    begin
        State.Names().Get(State.Ordinals().IndexOf(State.AsInteger()), Result);
    end;

    internal procedure GetShopifyCustomerID(var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; WithDialog: Boolean): Text[30]
    var
        Window: Dialog;
        ShopifyCustomerGID: Text;
    begin
        if (SpfyStoreCustomerLink."No." = '') or (SpfyStoreCustomerLink."Shopify Store Code" = '') then
            exit('');
        if (SpfyStoreCustomerLink.Type = _LastQueriedSpfyStoreCustomerLink.Type) and
           (SpfyStoreCustomerLink."No." = _LastQueriedSpfyStoreCustomerLink."No.") and
           (SpfyStoreCustomerLink."Shopify Store Code" = _LastQueriedSpfyStoreCustomerLink."Shopify Store Code")
        then
            exit(_ShopifyCustomerID);
        if WithDialog then
            Window.Open(_QueryingShopifyLbl);

        ShopifyCustomerGID := GetCustomerGIDFromShopify(SpfyStoreCustomerLink, false);
#pragma warning disable AA0139
        _ShopifyCustomerID := _SpfyIntegrationMgt.RemoveUntil(ShopifyCustomerGID, '/');
#pragma warning restore AA0139
        _LastQueriedSpfyStoreCustomerLink := SpfyStoreCustomerLink;

        if WithDialog then
            Window.Close();
        exit(_ShopifyCustomerID);
    end;

    internal procedure GetCustomerGIDFromShopify(Customer: Record Customer; ShopifyStoreCode: Code[20]; CreateMissing: Boolean): Text
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        SpfyStoreCustomerLink.Type := SpfyStoreCustomerLink.Type::Customer;
        SpfyStoreCustomerLink."No." := Customer."No.";
        SpfyStoreCustomerLink."Shopify Store Code" := ShopifyStoreCode;
        if not SpfyStoreCustomerLink.Find() then
            SpfyStoreCustomerLink.Init();
        UpdateFromCustomer(Customer, SpfyStoreCustomerLink);
        exit(GetCustomerGIDFromShopify(SpfyStoreCustomerLink, CreateMissing));
    end;

    internal procedure GetCustomerGIDFromShopify(var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; CreateMissing: Boolean) ShopifyCustomerGID: Text
    var
        Customer: Record Customer;
        ShopifyResponse: JsonToken;
        ShopifyCustomerID: Text[30];
        CustomerCreateQueryErr: Label 'The system was unable to create a customer with email %1 in Shopify. The following error occurred:\%2', Comment = '%1 - customer email address, %2 - Shopify API call error details';
        CustomerSearchQueryErr: Label 'The system was unable to retrieve information from Shopify about the customer with email %1. The following error occurred:\%2', Comment = '%1 - customer email address, %2 - Shopify API call error details';
    begin
        //Find Shopify customer by email
        ClearLastError();
        SpfyStoreCustomerLink.TestField("Shopify Store Code");
        if SpfyStoreCustomerLink."E-Mail" = '' then begin
            SpfyStoreCustomerLink.TestField("No.");
            Customer.Get(SpfyStoreCustomerLink."No.");
            Customer.TestField("E-Mail");
            SpfyStoreCustomerLink."E-Mail" := Customer."E-Mail";
        end;
        if not FindShopifyCustomerByEmail(SpfyStoreCustomerLink."E-Mail", SpfyStoreCustomerLink."Shopify Store Code", ShopifyResponse) then
            Error(CustomerSearchQueryErr, SpfyStoreCustomerLink."E-Mail", GetLastErrorText());
        if ShopifyResponse.SelectToken('data.customers.edges', ShopifyResponse) and ShopifyResponse.IsArray() then
            if ShopifyResponse.AsArray().Count() > 0 then begin
                ShopifyResponse.AsArray().Get(0, ShopifyResponse);
                ShopifyCustomerGID := _JsonHelper.GetJText(ShopifyResponse, 'node.id', false);
                if ShopifyCustomerGID <> '' then
                    exit;
            end;

        //Create Shopify customer
        if not CreateMissing then
            exit;
        Clear(ShopifyResponse);
        if not CreateShopifyCustomer(SpfyStoreCustomerLink, ShopifyResponse) then
            Error(CustomerCreateQueryErr, SpfyStoreCustomerLink."E-Mail", GetLastErrorText());
        ShopifyCustomerGID := _JsonHelper.GetJText(ShopifyResponse, 'data.customerCreate.customer.id', true);

        If SpfyStoreCustomerLink."No." <> '' then begin
#pragma warning disable AA0139
            ShopifyCustomerID := _SpfyIntegrationMgt.RemoveUntil(ShopifyCustomerGID, '/');
#pragma warning restore AA0139
            RetrieveShopifyCustomerAndUpdateBCCustomerWithDataFromShopify(SpfyStoreCustomerLink, ShopifyCustomerID, false, false, false);
        end;
    end;

    local procedure FindShopifyCustomerByEmail(Email: Text; ShopifyStoreCode: Code[20]; var ShopifyResponse: JsonToken): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        QueryStream: OutStream;
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        QueryTok: Label 'query FindCustomerByEmail($searchCriteria: String!) {customers(first: 1, query: $searchCriteria) {edges{node{id}}}}', Locked = true;
    begin
        VariablesJson.Add('searchCriteria', 'email:' + Email);
        RequestJson.Add('query', QueryTok);
        RequestJson.Add('variables', VariablesJson);

        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        RequestJson.WriteTo(QueryStream);
        exit(SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse));
    end;

    local procedure CreateShopifyCustomer(SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; var ShopifyResponse: JsonToken): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
    begin
        NcTask."Store Code" := SpfyStoreCustomerLink."Shopify Store Code";
        NcTask.Type := NcTask.Type::Insert;
        PrepareCustomerUpdateRequest(NcTask, SpfyStoreCustomerLink, '');
        exit(SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse));
    end;

    local procedure UpdateFromCustomer(Customer: Record Customer; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    begin
        if SpfyStoreCustomerLink."First Name" + SpfyStoreCustomerLink."Last Name" = '' then
            ParseCustomerName(Customer, SpfyStoreCustomerLink);
        if SpfyStoreCustomerLink."E-Mail" = '' then
            SpfyStoreCustomerLink."E-Mail" := Customer."E-Mail";
        if SpfyStoreCustomerLink."Phone No." = '' then
            SpfyStoreCustomerLink."Phone No." := Customer."Phone No.";
    end;

    local procedure ParseCustomerName(Customer: Record Customer; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    var
        FullName: Text;
        LastSpacePosition: Integer;
    begin
        FullName := GetFullName(Customer.Name, Customer."Name 2");
        FullName := FullName.Trim();
        LastSpacePosition := FullName.LastIndexOf(' ');
        if LastSpacePosition > 1 then begin
            SpfyStoreCustomerLink."First Name" := CopyStr(FullName.Substring(1, LastSpacePosition - 1), 1, MaxStrLen(SpfyStoreCustomerLink."First Name"));
            SpfyStoreCustomerLink."Last Name" := CopyStr(FullName.Substring(LastSpacePosition + 1), 1, MaxStrLen(SpfyStoreCustomerLink."Last Name"));
        end else begin
            SpfyStoreCustomerLink."First Name" := CopyStr(FullName, 1, MaxStrLen(SpfyStoreCustomerLink."First Name"));
            SpfyStoreCustomerLink."Last Name" := CopyStr(FullName, MaxStrLen(SpfyStoreCustomerLink."First Name") + 1, MaxStrLen(SpfyStoreCustomerLink."Last Name"));
        end;
    end;

    internal procedure GetFullName(Name: Text; Name2: Text) FullName: Text
    begin
        FullName := Name;
        if Name2 = '' then
            exit;
        if Name2.StartsWith(Name2.Substring(1, 1).ToUpper()) then
            FullName += ' ';
        FullName += Name2;
    end;

    internal procedure GetStoreCustomerLink(CustomerNo: Code[20]; ShopifyStoreCode: Code[20]; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    begin
        GetStoreCustomerLink(CustomerNo, ShopifyStoreCode, true, SpfyStoreCustomerLink);
    end;

    internal procedure GetStoreCustomerLink(CustomerNo: Code[20]; ShopifyStoreCode: Code[20]; WithCheck: Boolean; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link") SyncEnabled: Boolean
    begin
        Clear(SpfyStoreCustomerLink);
        SpfyStoreCustomerLink.Type := SpfyStoreCustomerLink.Type::Customer;
        SpfyStoreCustomerLink."No." := CustomerNo;
        SpfyStoreCustomerLink."Shopify Store Code" := ShopifyStoreCode;
        if not WithCheck then begin
            if not SpfyStoreCustomerLink.Find() then
                exit;
        end else
            SpfyStoreCustomerLink.Find();
        SyncEnabled := SpfyStoreCustomerLink."Sync. to this Store" or SpfyStoreCustomerLink."Synchronization Is Enabled";
        if not SyncEnabled and WithCheck then
            SpfyStoreCustomerLink.TestField("Sync. to this Store");
    end;

    internal procedure RetrieveShopifyCustomerAndUpdateBCCustomerWithDataFromShopify(var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; ShopifyCustomerID: Text[30]; Removed: Boolean; TriggeredExternally: Boolean; WithDialog: Boolean)
    var
        Window: Dialog;
        CustomerJToken: JsonToken;
        ShopifyResponse: JsonToken;
        CouldNotGetCustomerErr: Label 'Could not get the customer from Shopify. The following error occured: %1', Comment = '%1 - Shopify returned error text.';
        QueryingShopifyLbl: Label 'Querying Shopify...';
    begin
        if WithDialog then
            WithDialog := GuiAllowed;
        if WithDialog then
            Window.Open(QueryingShopifyLbl);

        if Removed then
            ShopifyResponse.ReadFrom(StrSubstNo('{"data":{"customer":{"id":"gid://shopify/Customer/%1"}}}', ShopifyCustomerID))
        else
            if not GetCustomerDataFromShopify(ShopifyCustomerID, SpfyStoreCustomerLink."Shopify Store Code", ShopifyResponse) then
                Error(CouldNotGetCustomerErr, GetLastErrorText());
        if _JsonHelper.GetJsonToken(ShopifyResponse, 'data', CustomerJToken) then
            UpdateCustomerWithDataFromShopify(SpfyStoreCustomerLink, Removed, CustomerJToken, TriggeredExternally);

        if WithDialog then
            Window.Close();
    end;

    local procedure GetCustomerDataFromShopify(ShopifyCustomerID: Text[30]; ShopifyStoreCode: Code[20]; var ShopifyResponse: JsonToken): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        QueryStream: OutStream;
        Request: JsonObject;
        Variables: JsonObject;
        QueryTok: Label 'query GetCustomer($customerID: ID!) {customer(id: $customerID) {id firstName lastName defaultEmailAddress{emailAddress marketingOptInLevel marketingState marketingUpdatedAt} defaultPhoneNumber{phoneNumber}}}', Locked = true;
    begin
        NcTask."Store Code" := ShopifyStoreCode;
        Variables.Add('customerID', 'gid://shopify/Customer/' + ShopifyCustomerID);
        Request.Add('query', QueryTok);
        Request.Add('variables', Variables);
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        Request.WriteTo(QueryStream);

        exit(SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse));
    end;

    local procedure UpdateCustomerWithDataFromShopify(var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; Removed: Boolean; ShopifyResponse: JsonToken; TriggeredExternally: Boolean)
    var
        xSpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyCustomerMgt: Codeunit "NPR Spfy Customer Mgt.";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        EmailMarketingState: Text;
        ShopifyCustomerID: Text[30];
        LinkExists: Boolean;
    begin
#pragma warning disable AA0139
        ShopifyCustomerID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyResponse, 'customer.id', true), '/');
#pragma warning restore AA0139
        LinkExists := SpfyStoreCustomerLink.Find();
        if Removed then begin
            DisableIntegrationForCustomer(SpfyStoreCustomerLink);
            if LinkExists then
                ModifySpfyStoreCustomerLink(SpfyStoreCustomerLink, true);
            exit;
        end;

        if not LinkExists then begin
            SpfyStoreCustomerLink.Init();
            SpfyStoreCustomerLink.Insert();
        end;
        xSpfyStoreCustomerLink := SpfyStoreCustomerLink;
#pragma warning disable AA0139
        SpfyStoreCustomerLink."First Name" := _JsonHelper.GetJText(ShopifyResponse, 'customer.firstName', MaxStrLen(SpfyStoreCustomerLink."First Name"), false);
        SpfyStoreCustomerLink."Last Name" := _JsonHelper.GetJText(ShopifyResponse, 'customer.lastName', MaxStrLen(SpfyStoreCustomerLink."Last Name"), false);
        SpfyStoreCustomerLink."E-Mail" := _JsonHelper.GetJText(ShopifyResponse, 'customer.defaultEmailAddress.emailAddress', MaxStrLen(SpfyStoreCustomerLink."E-Mail"), false);
        SpfyStoreCustomerLink."Phone No." := _JsonHelper.GetJText(ShopifyResponse, 'customer.defaultPhoneNumber.phoneNumber', MaxStrLen(SpfyStoreCustomerLink."Phone No."), false);
#pragma warning restore AA0139
        EmailMarketingState := _JsonHelper.GetJText(ShopifyResponse, 'customer.defaultEmailAddress.marketingState', false);
        if EmailMarketingState <> '' then
            if Evaluate(SpfyStoreCustomerLink."E-mail Marketing State", UpperCase(EmailMarketingState)) then begin
                SpfyStoreCustomerLink."Marketing State Updated in BC" := false;
                SpfyCustomerMgt.UpdateMemberNewsletterSubscription(SpfyStoreCustomerLink);
            end;
        if TriggeredExternally then
            SpfyStoreCustomerLink."Sync. to this Store" := true;
        SpfyStoreCustomerLink."Synchronization Is Enabled" := SpfyStoreCustomerLink."Sync. to this Store";
        ModifySpfyStoreCustomerLink(SpfyStoreCustomerLink, true);
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreCustomerLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyCustomerID, false);
#if not (BC18 or BC19 or BC20)
        if SpfyStoreCustomerLink."Synchronization Is Enabled" and (SpfyStoreCustomerLink."Synchronization Is Enabled" <> xSpfyStoreCustomerLink."Synchronization Is Enabled") then
            SyncCustomerOfflineOrderHistory(SpfyStoreCustomerLink."No.", SpfyStoreCustomerLink."Shopify Store Code");
#endif
        if TriggeredExternally and not xSpfyStoreCustomerLink."Sync. to this Store" then
            SpfyMetafieldMgt.InitStoreCustomerLinkMetafields(SpfyStoreCustomerLink);
        UpdateMetafieldsFromShopify(SpfyStoreCustomerLink, ShopifyCustomerID);
    end;

    local procedure UpdateMetafieldsFromShopify(SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; ShopifyOwnerID: Text[30])
    var
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type";
    begin
        case SpfyStoreCustomerLink.Type of
            SpfyStoreCustomerLink.Type::Customer:
                ShopifyOwnerType := ShopifyOwnerType::CUSTOMER;
            else
                exit;
        end;
        SpfyMetafieldMgt.RequestMetafieldValuesFromShopifyAndUpdateBCData(SpfyStoreCustomerLink.RecordId(), ShopifyOwnerType, ShopifyOwnerID, SpfyStoreCustomerLink."Shopify Store Code");
    end;

    procedure EnableIntegrationForCustomersAlreadyOnShopify(ShopifyStoreCode: Code[20]; WithDialog: Boolean)
    var
        CustomerResyncOptions: Report "NPR Spfy Cust. Re-sync Options";
    begin
        Clear(CustomerResyncOptions);
        CustomerResyncOptions.SetOptions(ShopifyStoreCode, WithDialog);
        CustomerResyncOptions.UseRequestPage(WithDialog);
        CustomerResyncOptions.Run();
    end;

    procedure MarkCustomerAlreadyOnShopify(Customer: Record Customer; var ShopifyStore: Record "NPR Spfy Store"; DisableDataLog: Boolean; CreateAtShopify: Boolean; WithDialog: Boolean)
    begin
        if CreateAtShopify then
            DisableDataLog := false;

        if ShopifyStore.FindSet() then
            repeat
                UpdateIntegrationStatusForCustomer(ShopifyStore.Code, Customer, DisableDataLog, CreateAtShopify, WithDialog);
            until ShopifyStore.Next() = 0;
    end;

    local procedure UpdateIntegrationStatusForCustomer(ShopifyStoreCode: Code[20]; Customer: Record Customer; DisableDataLog: Boolean; CreateAtShopify: Boolean; WithDialog: Boolean)
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
        ShopifyCustomerID: Text[30];
        CustomerIntegrIsEnabled: Boolean;
        LinkExists: Boolean;
    begin
        SpfyStoreCustomerLink.Type := SpfyStoreCustomerLink.Type::Customer;
        SpfyStoreCustomerLink."No." := Customer."No.";
        SpfyStoreCustomerLink."Shopify Store Code" := ShopifyStoreCode;
        LinkExists := SpfyStoreCustomerLink.Find();
        if not LinkExists then
            SpfyStoreCustomerLink.Init();
        CustomerIntegrIsEnabled := _SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders", SpfyStoreCustomerLink."Shopify Store Code");
        if not CustomerIntegrIsEnabled then
            CreateAtShopify := false;

        ShopifyCustomerID := GetShopifyCustomerID(SpfyStoreCustomerLink, WithDialog);
        if ShopifyCustomerID = '' then begin
            if not LinkExists and CreateAtShopify then begin
                SpfyStoreLinkMgt.UpdateStoreCustomerLinks(Customer);
                LinkExists := SpfyStoreCustomerLink.Find();
            end;
            if LinkExists and (SpfyStoreCustomerLink."Sync. to this Store" or SpfyStoreCustomerLink."Synchronization Is Enabled" or CreateAtShopify) then begin
                if SpfyStoreCustomerLink."Sync. to this Store" or SpfyStoreCustomerLink."Synchronization Is Enabled" then begin
                    DisableIntegrationForCustomer(SpfyStoreCustomerLink);
                    ModifySpfyStoreCustomerLink(SpfyStoreCustomerLink, DisableDataLog or CreateAtShopify);
                end;
                if CreateAtShopify then begin
                    SpfyStoreCustomerLink."Sync. to this Store" := true;
                    ModifySpfyStoreCustomerLink(SpfyStoreCustomerLink, false);
                    SpfyMetafieldMgt.InitStoreCustomerLinkMetafields(SpfyStoreCustomerLink);
                end;
            end;
            exit;
        end;

        SpfyStoreLinkMgt.UpdateStoreCustomerLinks(Customer);
        SpfyStoreCustomerLink.Find();
        RetrieveShopifyCustomerAndUpdateBCCustomerWithDataFromShopify(SpfyStoreCustomerLink, ShopifyCustomerID, false, true, false);
    end;

    local procedure ModifySpfyStoreCustomerLink(var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; DisableDataLog: Boolean)
    var
        DataLogMgt: Codeunit "NPR Data Log Management";
    begin
        if DisableDataLog then
            DataLogMgt.DisableDataLog(true);
        SpfyStoreCustomerLink.Modify(true);
        if DisableDataLog then
            DataLogMgt.DisableDataLog(false);
    end;

    local procedure DisableIntegrationForCustomer(var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAssignedIDMgt.RemoveAssignedShopifyID(SpfyStoreCustomerLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");

        SpfyStoreCustomerLink."Sync. to this Store" := false;
        SpfyStoreCustomerLink."Synchronization Is Enabled" := false;
    end;

#if not (BC18 or BC19 or BC20)
    local procedure SyncCustomerOfflineOrderHistory(CustomerNo: Code[20]; ShopifyStoreCode: Code[20])
    var
        POSEntry: Record "NPR POS Entry";
        TempSpfyExportPointerBuffer: Record "NPR Spfy Export Pointer Buffer" temporary;
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
        CutOffDate: Date;
    begin
        if not _SpfyIntegrationMgt.IsAutoSendHistBCOrders(ShopifyStoreCode, CutOffDate) then
            exit;

        TempSpfyExportPointerBuffer.Add(ShopifyStoreCode, CutOffDate, 0);
        POSEntry.SetCurrentKey("Customer No.");
        POSEntry.SetRange("Customer No.", CustomerNo);
        SpfyPOSEntryExportMgt.ProcessOutstandingPOSEntries(POSEntry, TempSpfyExportPointerBuffer);
    end;
#endif

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Task Mgt.", 'RunSourceCardEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Task Mgt.", RunSourceCardEvent, '', false, false)]
#endif
    local procedure OpenRelatedPage(var RecRef: RecordRef; var RunCardExecuted: Boolean)
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        if RunCardExecuted or (RecRef.Number() <> Database::"NPR Spfy Store-Customer Link") then
            exit;
        RunCardExecuted := true;

        RecRef.SetTable(SpfyStoreCustomerLink);
        case SpfyStoreCustomerLink.Type of
            SpfyStoreCustomerLink.Type::Customer:
                begin
                    Customer.Get(SpfyStoreCustomerLink."No.");
                    Customer.SetRecFilter();
                    Page.Run(Page::"Customer Card", Customer);
                end;
        end;
    end;
}
#endif