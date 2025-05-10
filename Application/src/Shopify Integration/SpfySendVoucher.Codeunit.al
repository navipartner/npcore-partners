#if not BC17
codeunit 6184820 "NPR Spfy Send Voucher"
{
    Access = Internal;
    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        Rec.TestField("Table No.", Rec."Record ID".TableNo);
        Rec.TestField("Store Code");
        case Rec."Table No." of
            Database::"NPR NpRv Voucher":
                SendVoucher(Rec);
            Database::"NPR NpRv Voucher Entry":
                SendVoucherAmtUpdate(Rec);
            Database::"NPR NpRv Arch. Voucher":
                SendVoucherDisableReq(Rec);
        end;
    end;

    var
        _JsonHelper: Codeunit "NPR Json Helper";
        _SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        _VoucherNotFoundErr: Label 'Retail Voucher %1 could not be found or is not eligible for Shopify integration.', Comment = '%1 - Retail Voucher No.';

    local procedure SendVoucher(var NcTask: Record "NPR Nc Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        SendToShopify: Boolean;
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := true;

        SendToShopify := PrepareVoucherUpdateRequest(NcTask);
        if SendToShopify then
            Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse);
        NcTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
        if SendToShopify then
            UpdateVoucherWithDataFromShopify(NcTask, ShopifyResponse);
    end;

    local procedure SendVoucherAmtUpdate(var NcTask: Record "NPR Nc Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        SendToShopify: Boolean;
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := true;

        SendToShopify := PrepareGiftCardBalanceAdjustmentRequest(NcTask);
        if SendToShopify then
            Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse);
        NcTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
        if SendToShopify then
            if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
                Error('');  //The system will record Shopify response as the error message
    end;

    local procedure SendVoucherDisableReq(var NcTask: Record "NPR Nc Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        DeactivatedAt: DateTime;
        SendToShopify: Boolean;
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := true;

        SendToShopify := PrepareGiftCardDisableRequest(NcTask, DeactivatedAt);
        if SendToShopify then
            Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse);
        NcTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
        if SendToShopify then begin
            if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
                Error('');  //The system will record Shopify response as the error message
            DeactivatedAt := _JsonHelper.GetJDT(ShopifyResponse, 'data.giftCardDeactivate.giftCard.deactivatedAt', false);
        end;
        MarkVoucherAsDeactivated(NcTask, DeactivatedAt)
    end;

    local procedure PrepareVoucherUpdateRequest(var NcTask: Record "NPR Nc Task") SendToShopify: Boolean
    var
        Voucher: Record "NPR NpRv Voucher";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyRetailVoucherMgt: Codeunit "NPR Spfy Retail Voucher Mgt.";
        VoucherRecRef: RecordRef;
        OStream: OutStream;
        ShopifyStoreCode: Code[20];
        ShopifyGiftCardID: Text[30];
        ShopifyGiftCardIdEmptyErr: Label 'Shopify gift card Id must be specified for %1', Comment = '%1 - Retail voucher record id';
        VoucherArchivedErr: Label 'Retail Voucher %1 has already been archived. No need to send the create request to Shopify', Comment = '%1 - Retail Voucher No.';
    begin
        if not SpfyRetailVoucherMgt.FindVoucher(NcTask, VoucherRecRef, Voucher, ShopifyStoreCode) then
            Error(_VoucherNotFoundErr, NcTask."Record Value");

        ShopifyGiftCardID := SpfyAssignedIDMgt.GetAssignedShopifyID(VoucherRecRef.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyGiftCardID = '' then begin
            if VoucherRecRef.Number = Database::"NPR NpRv Arch. Voucher" then begin
                _SpfyIntegrationMgt.SetResponse(NcTask, StrSubstNo(VoucherArchivedErr, NcTask."Record Value"));
                exit;
            end;
            case NcTask.Type of
                NcTask.Type::Modify:
                    NcTask.Type := NcTask.Type::Insert;
                NcTask.Type::Delete:
                    Error(ShopifyGiftCardIdEmptyErr, Format(VoucherRecRef.RecordId()));
            end;
        end else
            if NcTask.Type = NcTask.Type::Insert then
                NcTask.Type := NcTask.Type::Modify;

        NcTask."Record ID" := VoucherRecRef.RecordId();
        NcTask."Store Code" := ShopifyStoreCode;

        NcTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        ShopifyGiftCardUpsertQuery(Voucher, ShopifyGiftCardID, ShopifyStoreCode, OStream);
        SendToShopify := true;
    end;

    local procedure PrepareGiftCardBalanceAdjustmentRequest(var NcTask: Record "NPR Nc Task") SendToShopify: Boolean
    var
        Voucher: Record "NPR NpRv Voucher";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyRetailVoucherMgt: Codeunit "NPR Spfy Retail Voucher Mgt.";
        VoucherRecRef: RecordRef;
        OStream: OutStream;
        GiftCardCurrCode: Code[10];
        ShopifyStoreCode: Code[20];
        ShopifyGiftCardID: Text[30];
        CurrentShopifyBalance: Decimal;
        NewBalance: Decimal;
        BalanceUpToDateErr: Label 'Balance is up to date. No update needed.';
        MissingShopifyIdErr: Label 'Retail voucher %1 does not have a Shopify gift card ID assigned. It has probably not been synchronised with Shopify yet.', Comment = '%1 - Retail Voucher No.';
        VoucherArchivedErr: Label 'Retail voucher %1 has been archived but never sent to Shopify. No need to send balance update requests to Shopify.', Comment = '%1 - Retail Voucher No.';
    begin
        if not SpfyRetailVoucherMgt.FindVoucher(NcTask, VoucherRecRef, Voucher, ShopifyStoreCode) then
            Error(_VoucherNotFoundErr, NcTask."Record Value");

        ShopifyGiftCardID := SpfyAssignedIDMgt.GetAssignedShopifyID(VoucherRecRef.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyGiftCardID = '' then begin
            if VoucherRecRef.Number = Database::"NPR NpRv Arch. Voucher" then
                if not OutstandingVoucherRequestsExist(NcTask, Database::"NPR NpRv Voucher") then begin
                    _SpfyIntegrationMgt.SetResponse(NcTask, StrSubstNo(VoucherArchivedErr, Voucher."No."));
                    exit;
                end;
            Error(MissingShopifyIdErr, Voucher."No.");
        end;

        GetShopifyGiftCardBalance(Voucher."No.", ShopifyGiftCardID, ShopifyStoreCode, CurrentShopifyBalance, GiftCardCurrCode);

        case VoucherRecRef.Number of
            Database::"NPR NpRv Voucher":
                begin
                    Voucher.CalcFields(Amount);
                    NewBalance := Voucher.Amount - SalesOrderReservedAmount(Voucher);
                    if NewBalance < 0 then
                        NewBalance := 0;
                end;
            Database::"NPR NpRv Arch. Voucher":
                NewBalance := 0;
        end;

        if CurrentShopifyBalance = NewBalance then begin
            _SpfyIntegrationMgt.SetResponse(NcTask, BalanceUpToDateErr);
            exit;
        end;

        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        ShopifyGiftCardBalanceUpdateQuery(ShopifyGiftCardID, NewBalance - CurrentShopifyBalance, GiftCardCurrCode, CurrentDateTime(), OStream);
        SendToShopify := true;
    end;

    local procedure PrepareGiftCardDisableRequest(var NcTask: Record "NPR Nc Task"; var DeactivatedAt: DateTime) SendToShopify: Boolean
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherCreateNcTask: Record "NPR Nc Task";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyRetailVoucherMgt: Codeunit "NPR Spfy Retail Voucher Mgt.";
        VoucherRecRef: RecordRef;
        OStream: OutStream;
        ShopifyStoreCode: Code[20];
        ShopifyGiftCardID: Text[30];
        AlreadyDeactivatedErr: Label 'The gift card has already been deactivated in Shopify. No update required.';
        PostponedErr: Label 'Processing has been delayed as there are outstanding requests to update the Shopify gift card amount for the voucher.';
        VoucherArchivedErr: Label 'Retail voucher %1 has been archived but never sent to Shopify. No need to send it now.', Comment = '%1 - Retail Voucher No.';
    begin
        if OutstandingVoucherRequestsExist(NcTask, Database::"NPR NpRv Voucher Entry") then
            Error(PostponedErr);

        if not SpfyRetailVoucherMgt.FindVoucher(NcTask, VoucherRecRef, Voucher, ShopifyStoreCode) then
            Error(_VoucherNotFoundErr, NcTask."Record Value");
        ShopifyGiftCardID := SpfyAssignedIDMgt.GetAssignedShopifyID(VoucherRecRef.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyGiftCardID = '' then begin
            if OutstandingVoucherRequestsExist(NcTask, Database::"NPR NpRv Voucher", VoucherCreateNcTask) then
                CancelOutstandingNcTasks(VoucherCreateNcTask, StrSubstNo(VoucherArchivedErr, Voucher."No."));
            _SpfyIntegrationMgt.SetResponse(NcTask, StrSubstNo(VoucherArchivedErr, Voucher."No."));
            exit;
        end;

        DeactivatedAt := GetShopifyGiftCardDeactivatedAt(Voucher."No.", ShopifyGiftCardID, ShopifyStoreCode);
        if DeactivatedAt <> 0DT then begin
            _SpfyIntegrationMgt.SetResponse(NcTask, AlreadyDeactivatedErr);
            exit;
        end;

        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        ShopifyGiftCardDeactivateRequestQuery(ShopifyGiftCardID, OStream);
        SendToShopify := true;
    end;

    local procedure ShopifyGiftCardUpsertQuery(Voucher: Record "NPR NpRv Voucher"; ShopifyGiftCardID: Text[30]; ShopifyStoreCode: Code[20]; var QueryStream: OutStream)
    var
        Customer: Record Customer;
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        RecipientAttributesJson: JsonObject;
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        VoucherJson: JsonObject;
        RecipientShopifyCustomerGID: Text;
        CreateQueryTok: Label 'mutation CreateGiftCard($input: GiftCardCreateInput!) {giftCardCreate(input: $input) {giftCard {id} userErrors {message field code}}}', Locked = true;
        UpdateQueryTok: Label 'mutation UpdateGiftCard($id: ID!, $input: GiftCardUpdateInput!) {giftCardUpdate(id: $id, input: $input) {giftCard {id} userErrors {message field}}}', Locked = true;
    begin
        if ShopifyGiftCardID <> '' then begin
            RequestJson.Add('query', UpdateQueryTok);
            VariablesJson.Add('id', 'gid://shopify/GiftCard/' + ShopifyGiftCardID);
        end else begin
            RequestJson.Add('query', CreateQueryTok);
            Voucher.CalcFields("Initial Amount");
            VoucherJson.Add('initialValue', Format(Voucher."Initial Amount", 0, 9));
            VoucherJson.Add('code', Voucher."Reference No.");
            if Voucher."Spfy Liquid Template Suffix" <> '' then
                VoucherJson.Add('templateSuffix', Voucher."Spfy Liquid Template Suffix");
            VoucherJson.Add('note', CreatedFromNPRetailNote());
        end;
        if Voucher."Ending Date" <> 0DT then
            VoucherJson.Add('expiresOn', Format(DT2Date(Voucher."Ending Date"), 0, 9));

        if ShopifyGiftCardID = '' then begin
            if Voucher."Customer No." <> '' then
                if not Customer.Get(Voucher."Customer No.") then
                    Customer.Init();
            if (Customer."E-Mail" <> '') or (Voucher."E-mail" <> '') or (Voucher."Spfy Recipient E-mail" <> '') then begin
                if Voucher."Spfy Recipient E-mail" <> '' then
                    Customer."E-Mail" := Voucher."Spfy Recipient E-mail"
                else
                    if Voucher."E-mail" <> '' then
                        Customer."E-Mail" := Voucher."E-mail";
                if Voucher."Spfy Recipient Name" <> '' then begin
                    Customer.Name := CopyStr(Voucher."Spfy Recipient Name", 1, MaxStrLen(Customer.Name));
                    Customer."Name 2" := CopyStr(Voucher."Spfy Recipient Name", MaxStrLen(Customer.Name) + 1, MaxStrLen(Customer."Name 2"));
                end else
                    if Voucher.Name + Voucher."Name 2" <> '' then begin
                        Customer.Name := Voucher.Name;
                        Customer."Name 2" := Voucher."Name 2";
                    end;

                RecipientShopifyCustomerGID := RecipientCustomerGID(Customer, ShopifyStoreCode);
                VoucherJson.Add('customerId', RecipientShopifyCustomerGID);

                if Voucher."Spfy Send from Shopify" then begin
                    RecipientAttributesJson.Add('id', RecipientShopifyCustomerGID);
                    if Voucher."Voucher Message" <> '' then
                        RecipientAttributesJson.Add('message', Voucher."Voucher Message");
                    RecipientAttributesJson.Add('preferredName', GetFullName(Voucher.Name, Voucher."Name 2"));
                    if Voucher."Spfy Send on" <> 0DT then
                        if Voucher."Spfy Send on" > JobQueueMgt.NowWithDelayInSeconds(60) then
                            RecipientAttributesJson.Add('sendNotificationAt', Voucher."Spfy Send on");
                    VoucherJson.Add('recipientAttributes', RecipientAttributesJson);
                end;
            end;
        end;

        VariablesJson.Add('input', VoucherJson);
        RequestJson.Add('variables', VariablesJson);
        RequestJson.WriteTo(QueryStream);
    end;

    local procedure RecipientCustomerGID(Customer: Record Customer; ShopifyStoreCode: Code[20]) ShopifyCustomerGID: Text
    var
        ShopifyResponse: JsonToken;
        CustomerCreateQueryErr: Label 'The system was unable to create a customer with email %1 in Shopify. The following error occurred:\%2', Comment = '%1 - customer email address, %2 - Shopify API call error details';
        CustomerSearchQueryErr: Label 'The system was unable to retrieve information from Shopify about the customer with email %1. The following error occurred:\%2', Comment = '%1 - customer email address, %2 - Shopify API call error details';
    begin
        //Find Shopify customer by email
        ClearLastError();
        if not FindShopifyCustomerByEmail(Customer."E-Mail", ShopifyStoreCode, ShopifyResponse) then
            Error(CustomerSearchQueryErr, Customer."E-Mail", GetLastErrorText());
        if ShopifyResponse.SelectToken('data.customers.edges', ShopifyResponse) and ShopifyResponse.IsArray() then
            if ShopifyResponse.AsArray().Count() > 0 then begin
                ShopifyResponse.AsArray().Get(0, ShopifyResponse);
                ShopifyCustomerGID := _JsonHelper.GetJText(ShopifyResponse, 'node.id', false);
                if ShopifyCustomerGID <> '' then
                    exit;
            end;

        //Create Shopify customer
        Clear(ShopifyResponse);
        if not CreateShopifyCustomer(Customer, ShopifyStoreCode, ShopifyResponse) then
            Error(CustomerCreateQueryErr, Customer."E-Mail", GetLastErrorText());
        ShopifyCustomerGID := _JsonHelper.GetJText(ShopifyResponse, 'data.customerCreate.customer.id', true);
    end;

    local procedure FindShopifyCustomerByEmail(Email: Text; ShopifyStoreCode: Code[20]; var ShopifyResponse: JsonToken): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        QueryStream: OutStream;
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        QueryTok: Label 'query FindCustomerByEmail($searchCriteria: String!) {customers(first: 1, query: $searchCriteria) {edges{node{id email verifiedEmail}}}}', Locked = true;
    begin
        VariablesJson.Add('searchCriteria', 'email:' + Email);
        RequestJson.Add('query', QueryTok);
        RequestJson.Add('variables', VariablesJson);

        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        RequestJson.WriteTo(QueryStream);
        exit(SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse));
    end;

    local procedure CreateShopifyCustomer(Customer: Record Customer; ShopifyStoreCode: Code[20]; var ShopifyResponse: JsonToken): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        QueryStream: OutStream;
        CustomerJson: JsonObject;
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        QueryTok: Label 'mutation CreateCustomer($input: CustomerInput!) {customerCreate(input: $input) {customer {id email firstName lastName} userErrors {message field}}}', Locked = true;
    begin
        CustomerJson.Add('email', Customer."E-Mail");
        AddCustomerName(Customer, CustomerJson);
        VariablesJson.Add('input', CustomerJson);
        RequestJson.Add('query', QueryTok);
        RequestJson.Add('variables', VariablesJson);

        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        RequestJson.WriteTo(QueryStream);
        exit(SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse));
    end;

    local procedure AddCustomerName(Customer: Record Customer; var CustomerJson: JsonObject)
    var
        FullName: Text;
        LastSpacePosition: Integer;
    begin
        FullName := GetFullName(Customer.Name, Customer."Name 2");
        FullName := FullName.Trim();
        LastSpacePosition := FullName.LastIndexOf(' ');
        if LastSpacePosition > 1 then begin
            CustomerJson.Add('firstName', FullName.Substring(1, LastSpacePosition - 1));
            CustomerJson.Add('lastName', FullName.Substring(LastSpacePosition + 1));
        end else
            CustomerJson.Add('firstName', FullName);
    end;

    local procedure GetFullName(Name: Text; Name2: Text) FullName: Text
    begin
        FullName := Name;
        if Name2 = '' then
            exit;
        if Name2.StartsWith(Name2.Substring(1, 1).ToUpper()) then
            FullName += ' ';
        FullName += Name2;
    end;

    local procedure UpdateVoucherWithDataFromShopify(NcTask: Record "NPR Nc Task"; ShopifyResponse: JsonToken)
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        FullShopifyGiftCardID: Text;
        ShopifyGiftCardID: Text[30];
    begin
        if not (NcTask.Type in [NcTask.Type::Insert, NcTask.Type::Modify]) then
            exit;
        case NcTask.Type of
            NcTask.Type::Insert:
                FullShopifyGiftCardID := _JsonHelper.GetJText(ShopifyResponse, 'data.giftCardCreate.giftCard.id', MaxStrLen(FullShopifyGiftCardID), false);
            NcTask.Type::Modify:
                FullShopifyGiftCardID := _JsonHelper.GetJText(ShopifyResponse, 'data.giftCardUpdate.giftCard.id', MaxStrLen(FullShopifyGiftCardID), false);
        end;
#pragma warning disable AA0139
        if FullShopifyGiftCardID.LastIndexOf('/') > 0 then
            ShopifyGiftCardID := CopyStr(FullShopifyGiftCardID, FullShopifyGiftCardID.LastIndexOf('/') + 1)
        else
            ShopifyGiftCardID := FullShopifyGiftCardID;
#pragma warning restore AA0139
        if ShopifyGiftCardID = '' then
            Error('');  //The system will record Shopify response as the error message

        SpfyAssignedIDMgt.AssignShopifyID(NcTask."Record ID", "NPR Spfy ID Type"::"Entry ID", ShopifyGiftCardID, false);
    end;

    local procedure GetShopifyGiftCardBalance(VoucherNo: Code[20]; ShopifyGiftCardID: Text[30]; ShopifyStoreCode: Code[20]; var Amount: Decimal; var CurrencyCode: Code[10])
    var
        ShopifyResponse: JsonToken;
    begin
        GetShopifyGiftCard(VoucherNo, ShopifyGiftCardID, ShopifyStoreCode, ShopifyResponse);
        Amount := _JsonHelper.GetJDecimal(ShopifyResponse, 'data.giftCard.balance.amount', true);
#pragma warning disable AA0139        
        CurrencyCode := _JsonHelper.GetJText(ShopifyResponse, 'data.giftCard.balance.currencyCode', false);
#pragma warning restore AA0139        
    end;

    local procedure GetShopifyGiftCardDeactivatedAt(VoucherNo: Code[20]; ShopifyGiftCardID: Text[30]; ShopifyStoreCode: Code[20]): DateTime
    var
        ShopifyResponse: JsonToken;
    begin
        GetShopifyGiftCard(VoucherNo, ShopifyGiftCardID, ShopifyStoreCode, ShopifyResponse);
        exit(_JsonHelper.GetJDT(ShopifyResponse, 'data.giftCard.deactivatedAt', false));
    end;

    local procedure GetShopifyGiftCard(VoucherNo: Code[20]; ShopifyGiftCardID: Text[30]; ShopifyStoreCode: Code[20]; var ShopifyResponse: JsonToken)
    var
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        QueryStream: OutStream;
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        GiftCardQueryFailedErr: Label 'The system was unable to retrieve information about the associated gift card from Shopify for retail voucher %1. The following error occurred:\%2', Comment = '%1 - Retail Voucher No., %2 - Shopify API call error details';
        QueryTok: Label 'query GetGiftCard($id: ID!) {giftCard(id: $id) {id balance {amount currencyCode} deactivatedAt}}', Locked = true;
    begin
        VariablesJson.Add('id', 'gid://shopify/GiftCard/' + ShopifyGiftCardID);
        RequestJson.Add('query', QueryTok);
        RequestJson.Add('variables', VariablesJson);

        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        RequestJson.WriteTo(QueryStream);

        ClearLastError();
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse) then
            Error(GiftCardQueryFailedErr, VoucherNo, GetLastErrorText());
    end;

    local procedure ShopifyGiftCardBalanceUpdateQuery(ShopifyGiftCardID: Text[30]; Amount: Decimal; CurrencyCode: Code[10]; TransactionDateTime: DateTime; var QueryStream: OutStream)
    var
        AmountJson: JsonObject;
        RequestJson: JsonObject;
        TransactionJson: JsonObject;
        VariablesJson: JsonObject;
        CreditTransQueryTok: Label 'mutation GiftCardCreditTrans($id: ID!, $transaction: GiftCardCreditInput!) {giftCardCredit(id: $id, creditInput : $transaction) {giftCardCreditTransaction {id amount {amount currencyCode} processedAt note giftCard {id balance {amount currencyCode}}} userErrors {message field code}}}', Locked = true;
        DebitTransQueryTok: Label 'mutation GiftCardDebitTrans($id: ID!, $transaction: GiftCardDebitInput!) {giftCardDebit(id: $id, debitInput : $transaction) {giftCardDebitTransaction {id amount {amount currencyCode} processedAt note giftCard {id balance {amount currencyCode}}} userErrors {message field code}}}', Locked = true;
    begin
        AmountJson.Add('amount', Format(Abs(Amount), 0, 9));
        AmountJson.Add('currencyCode', CurrencyCode);
        if Amount < 0 then begin
            RequestJson.Add('query', DebitTransQueryTok);
            TransactionJson.Add('debitAmount', AmountJson);
        end else begin
            RequestJson.Add('query', CreditTransQueryTok);
            TransactionJson.Add('creditAmount', AmountJson);
        end;
        TransactionJson.Add('processedAt', TransactionDateTime);
        TransactionJson.Add('note', CreatedFromNPRetailNote());
        VariablesJson.Add('id', 'gid://shopify/GiftCard/' + ShopifyGiftCardID);
        VariablesJson.Add('transaction', TransactionJson);

        RequestJson.Add('variables', VariablesJson);
        RequestJson.WriteTo(QueryStream);
    end;

    local procedure ShopifyGiftCardDeactivateRequestQuery(ShopifyGiftCardID: Text[30]; var QueryStream: OutStream)
    var
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        QueryTok: Label 'mutation DeactivateGiftCard($id: ID!) {giftCardDeactivate(id: $id) {giftCard {id deactivatedAt} userErrors {message field code}}}', Locked = true;
    begin
        VariablesJson.Add('id', 'gid://shopify/GiftCard/' + ShopifyGiftCardID);
        RequestJson.Add('query', QueryTok);
        RequestJson.Add('variables', VariablesJson);
        RequestJson.WriteTo(QueryStream);
    end;

    local procedure MarkVoucherAsDeactivated(NcTask: Record "NPR Nc Task"; DeactivatedAt: DateTime)
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        xArchVoucher: Record "NPR NpRv Arch. Voucher";
        RecRef: RecordRef;
    begin
        if NcTask."Record ID".TableNo() <> Database::"NPR NpRv Arch. Voucher" then
            exit;
        if not RecRef.Get(NcTask."Record ID") then
            exit;
        RecRef.SetTable(ArchVoucher);
        xArchVoucher := ArchVoucher;
        ArchVoucher."Disabled at Shopify" := DeactivatedAt <> 0DT;
        if ArchVoucher."Disabled at Shopify" <> xArchVoucher."Disabled at Shopify" then
            ArchVoucher.Modify();
    end;

    local procedure CreatedFromNPRetailNote(): Text[50]
    var
        NoteLbl: Label 'Created from NP Retail (Business Central)', MaxLength = 50;
    begin
        exit(NoteLbl);
    end;

    local procedure SalesOrderReservedAmount(Voucher: Record "NPR NpRv Voucher"): Decimal
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
    begin
        MagentoPaymentLine.SetRange("Payment Type", MagentoPaymentLine."Payment Type"::Voucher);
        MagentoPaymentLine.SetRange("No.", Voucher."Reference No.");
        MagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        MagentoPaymentLine.SetRange("Document Type", MagentoPaymentLine."Document Type"::Order);
        MagentoPaymentLine.SetRange(Posted, false);
        MagentoPaymentLine.CalcSums(Amount);
        exit(MagentoPaymentLine.Amount);
    end;

    local procedure OutstandingVoucherRequestsExist(NcTask: Record "NPR Nc Task"; TableNo: Integer): Boolean
    var
        NcTask2: Record "NPR Nc Task";
    begin
        exit(OutstandingVoucherRequestsExist(NcTask, TableNo, NcTask2));
    end;

    local procedure OutstandingVoucherRequestsExist(NcTask: Record "NPR Nc Task"; TableNo: Integer; var OutstandingNcTask: Record "NPR Nc Task"): Boolean
    begin
        Clear(OutstandingNcTask);
        OutstandingNcTask.SetRange(Processed, false);
        OutstandingNcTask.SetRange("Table No.", TableNo);
        OutstandingNcTask.SetRange("Company Name", NcTask."Company Name");
        OutstandingNcTask.SetRange("Record Value", NcTask."Record Value");
        OutstandingNcTask.SetRange("Task Processor Code", NcTask."Task Processor Code");
        OutstandingNcTask.SetRange("Store Code", NcTask."Store Code");
        exit(not OutstandingNcTask.IsEmpty);
    end;

    local procedure CancelOutstandingNcTasks(var NcTask: Record "NPR Nc Task"; ReasonTxt: Text)
    var
        NcTask2: Record "NPR Nc Task";
        OutStr: OutStream;
    begin
        if NcTask.FindSet(true) then
            repeat
                if not NcTask.Processed then begin
                    NcTask2 := NcTask;
                    NcTask2.Processed := true;
                    NcTask2."Process Error" := false;
                    NcTask2."Last Processing Started at" := 0DT;
                    NcTask2."Last Processing Completed at" := CurrentDateTime();
                    NcTask2."Last Processing Duration" := 0;
                    NcTask2.Response.CreateOutStream(OutStr, TextEncoding::UTF8);
                    OutStr.WriteText(ReasonTxt);
                    NcTask2.Modify();
                end;
            until NcTask.Next() = 0;
    end;
}
#endif