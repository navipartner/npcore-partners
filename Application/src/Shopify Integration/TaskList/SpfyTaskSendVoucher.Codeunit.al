// Native sibling of frozen codeunit "NPR Spfy Send Voucher": only sanctioned legacy defect fixes are dual-applied, new-queue behavior changes are not.
codeunit 6151469 "NPR Spfy Task Send Voucher"
{
    Access = Internal;
    TableNo = "NPR Spfy Task";

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
        _SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        _VoucherNotFoundErr: Label 'Retail Voucher %1 could not be found or is not eligible for Shopify integration.', Comment = '%1 - Retail Voucher No.';

    local procedure SendVoucher(var SpfyTask: Record "NPR Spfy Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        SendToShopify: Boolean;
        Success: Boolean;
    begin
        Clear(SpfyTask."Data Output");
        Clear(SpfyTask.Response);
        ClearLastError();
        Success := true;

        SendToShopify := PrepareVoucherUpdateRequest(SpfyTask);
        if SendToShopify then
            Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(SpfyTask, true, ShopifyResponse);
        SpfyTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
        if SendToShopify then
            UpdateVoucherWithDataFromShopify(SpfyTask, ShopifyResponse);
    end;

    local procedure SendVoucherAmtUpdate(var SpfyTask: Record "NPR Spfy Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        SendToShopify: Boolean;
        Success: Boolean;
    begin
        Clear(SpfyTask."Data Output");
        Clear(SpfyTask.Response);
        ClearLastError();
        Success := true;

        SendToShopify := PrepareGiftCardBalanceAdjustmentRequest(SpfyTask);
        if SendToShopify then
            Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(SpfyTask, true, ShopifyResponse);
        SpfyTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
        if SendToShopify then
            if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
                Error('');  //The system will record Shopify response as the error message
    end;

    local procedure SendVoucherDisableReq(var SpfyTask: Record "NPR Spfy Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        DeactivatedAt: DateTime;
        SendToShopify: Boolean;
        Success: Boolean;
    begin
        Clear(SpfyTask."Data Output");
        Clear(SpfyTask.Response);
        ClearLastError();
        Success := true;

        SendToShopify := PrepareGiftCardDisableRequest(SpfyTask, DeactivatedAt);
        if SendToShopify then
            Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(SpfyTask, true, ShopifyResponse);
        SpfyTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
        if SendToShopify then begin
            if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
                Error('');  //The system will record Shopify response as the error message
            DeactivatedAt := _JsonHelper.GetJDT(ShopifyResponse, 'data.giftCardDeactivate.giftCard.deactivatedAt', false);
        end;
        MarkVoucherAsDeactivated(SpfyTask, DeactivatedAt)
    end;

    local procedure PrepareVoucherUpdateRequest(var SpfyTask: Record "NPR Spfy Task") SendToShopify: Boolean
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
        if not SpfyRetailVoucherMgt.FindVoucher(SpfyTask, VoucherRecRef, Voucher, ShopifyStoreCode) then
            Error(_VoucherNotFoundErr, SpfyTask."Record Value");

        ShopifyGiftCardID := SpfyAssignedIDMgt.GetAssignedShopifyID(VoucherRecRef.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyGiftCardID = '' then begin
            if VoucherRecRef.Number = Database::"NPR NpRv Arch. Voucher" then begin
                _SpfyIntegrationMgt.SetResponse(SpfyTask, StrSubstNo(VoucherArchivedErr, SpfyTask."Record Value"));
                exit;
            end;
            case SpfyTask.Type of
                SpfyTask.Type::Modify:
                    SpfyTask.Type := SpfyTask.Type::Insert;
                SpfyTask.Type::Delete:
                    Error(ShopifyGiftCardIdEmptyErr, Format(VoucherRecRef.RecordId()));
            end;
        end else
            if SpfyTask.Type = SpfyTask.Type::Insert then
                SpfyTask.Type := SpfyTask.Type::Modify;

        SpfyTask."Record ID" := VoucherRecRef.RecordId();
        SpfyTask."Store Code" := ShopifyStoreCode;

        SpfyTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        ShopifyGiftCardUpsertQuery(Voucher, ShopifyGiftCardID, ShopifyStoreCode, OStream);
        SendToShopify := true;
    end;

    local procedure PrepareGiftCardBalanceAdjustmentRequest(var SpfyTask: Record "NPR Spfy Task") SendToShopify: Boolean
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
        if not SpfyRetailVoucherMgt.FindVoucher(SpfyTask, VoucherRecRef, Voucher, ShopifyStoreCode) then
            Error(_VoucherNotFoundErr, SpfyTask."Record Value");

        ShopifyGiftCardID := SpfyAssignedIDMgt.GetAssignedShopifyID(VoucherRecRef.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyGiftCardID = '' then begin
            if VoucherRecRef.Number = Database::"NPR NpRv Arch. Voucher" then
                if not _SpfyTaskQueue.OutstandingTasksExist(Database::"NPR NpRv Voucher", SpfyTask."Record Value", SpfyTask."Store Code") then begin
                    _SpfyIntegrationMgt.SetResponse(SpfyTask, StrSubstNo(VoucherArchivedErr, Voucher."No."));
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
            _SpfyIntegrationMgt.SetResponse(SpfyTask, BalanceUpToDateErr);
            exit;
        end;

        SpfyTask."Store Code" := ShopifyStoreCode;
        SpfyTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        ShopifyGiftCardBalanceUpdateQuery(ShopifyGiftCardID, NewBalance - CurrentShopifyBalance, GiftCardCurrCode, CurrentDateTime(), OStream);
        SendToShopify := true;
    end;

    local procedure PrepareGiftCardDisableRequest(var SpfyTask: Record "NPR Spfy Task"; var DeactivatedAt: DateTime) SendToShopify: Boolean
    var
        Voucher: Record "NPR NpRv Voucher";
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
        if _SpfyTaskQueue.OutstandingTasksExist(Database::"NPR NpRv Voucher Entry", SpfyTask."Record Value", SpfyTask."Store Code") then
            Error(PostponedErr);

        if not SpfyRetailVoucherMgt.FindVoucher(SpfyTask, VoucherRecRef, Voucher, ShopifyStoreCode) then
            Error(_VoucherNotFoundErr, SpfyTask."Record Value");
        ShopifyGiftCardID := SpfyAssignedIDMgt.GetAssignedShopifyID(VoucherRecRef.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyGiftCardID = '' then begin
            _SpfyTaskQueue.CancelOutstandingTasks(Database::"NPR NpRv Voucher", SpfyTask."Record Value", SpfyTask."Store Code", StrSubstNo(VoucherArchivedErr, Voucher."No."));
            _SpfyIntegrationMgt.SetResponse(SpfyTask, StrSubstNo(VoucherArchivedErr, Voucher."No."));
            exit;
        end;

        DeactivatedAt := GetShopifyGiftCardDeactivatedAt(Voucher."No.", ShopifyGiftCardID, ShopifyStoreCode);
        if DeactivatedAt <> 0DT then begin
            _SpfyIntegrationMgt.SetResponse(SpfyTask, AlreadyDeactivatedErr);
            exit;
        end;

        SpfyTask."Store Code" := ShopifyStoreCode;
        SpfyTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        ShopifyGiftCardDeactivateRequestQuery(ShopifyGiftCardID, OStream);
        SendToShopify := true;
    end;

    local procedure ShopifyGiftCardUpsertQuery(Voucher: Record "NPR NpRv Voucher"; ShopifyGiftCardID: Text[30]; ShopifyStoreCode: Code[20]; var QueryStream: OutStream)
    var
        Customer: Record Customer;
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyTaskSendCustomers: Codeunit "NPR Spfy Task Send Customers";
        RecipientAttributesJson: JsonObject;
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        VoucherJson: JsonObject;
        RecipientPreferredName: Text;
        ShopifyBillToCustGID: Text;
        ShopifyShipToCustGID: Text;
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

        if (ShopifyGiftCardID = '') and Voucher."Spfy Send from Shopify" then begin
            if Voucher."Customer No." <> '' then
                if Customer.Get(Voucher."Customer No.") then begin
                    ShopifyBillToCustGID := SpfyAssignedIDMgt.GetAssignedShopifyID(Customer.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                    if ShopifyBillToCustGID <> '' then
                        ShopifyBillToCustGID := StrSubstNo('gid://shopify/Customer/%1', ShopifyBillToCustGID)
                    else begin
                        If Customer."E-Mail" = '' then
                            Customer."E-Mail" := Voucher."E-mail";
                        If Customer."E-Mail" <> '' then
                            ShopifyBillToCustGID := SpfyTaskSendCustomers.GetCustomerGIDFromShopify(Customer, ShopifyStoreCode, true);
                    end;
                    if ShopifyBillToCustGID <> '' then
                        VoucherJson.Add('customerId', ShopifyBillToCustGID);
                end;

            if Voucher."Spfy Recipient E-mail" <> '' then begin
                Clear(Customer);
                Customer."E-Mail" := Voucher."Spfy Recipient E-mail";
                Customer.Name := CopyStr(Voucher."Spfy Recipient Name", 1, MaxStrLen(Customer.Name));
                Customer."Name 2" := CopyStr(Voucher."Spfy Recipient Name", MaxStrLen(Customer.Name) + 1, MaxStrLen(Customer."Name 2"));

                ShopifyShipToCustGID := SpfyTaskSendCustomers.GetCustomerGIDFromShopify(Customer, ShopifyStoreCode, true);

                RecipientAttributesJson.Add('id', ShopifyShipToCustGID);
                if Voucher."Voucher Message" <> '' then
                    RecipientAttributesJson.Add('message', Voucher."Voucher Message");
                RecipientPreferredName := SpfyTaskSendCustomers.GetFullName(Customer.Name, Customer."Name 2");
                if RecipientPreferredName <> '' then
                    RecipientAttributesJson.Add('preferredName', RecipientPreferredName);
                if Voucher."Spfy Send on" <> 0DT then
                    if Voucher."Spfy Send on" > JobQueueMgt.NowWithDelayInSeconds(60) then
                        RecipientAttributesJson.Add('sendNotificationAt', Voucher."Spfy Send on");
                VoucherJson.Add('recipientAttributes', RecipientAttributesJson);
            end;
        end;

        VariablesJson.Add('input', VoucherJson);
        RequestJson.Add('variables', VariablesJson);
        RequestJson.WriteTo(QueryStream);
    end;

    local procedure UpdateVoucherWithDataFromShopify(SpfyTask: Record "NPR Spfy Task"; ShopifyResponse: JsonToken)
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        FullShopifyGiftCardID: Text;
        ShopifyGiftCardID: Text[30];
    begin
        if not (SpfyTask.Type in [SpfyTask.Type::Insert, SpfyTask.Type::Modify]) then
            exit;
        case SpfyTask.Type of
            SpfyTask.Type::Insert:
                FullShopifyGiftCardID := _JsonHelper.GetJText(ShopifyResponse, 'data.giftCardCreate.giftCard.id', MaxStrLen(FullShopifyGiftCardID), false);
            SpfyTask.Type::Modify:
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

        SpfyAssignedIDMgt.AssignShopifyID(SpfyTask."Record ID", "NPR Spfy ID Type"::"Entry ID", ShopifyGiftCardID, false);
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
        SpfyTask: Record "NPR Spfy Task";
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

        SpfyTask."Store Code" := ShopifyStoreCode;
        SpfyTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        RequestJson.WriteTo(QueryStream);

        ClearLastError();
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(SpfyTask, true, ShopifyResponse) then
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

    local procedure MarkVoucherAsDeactivated(SpfyTask: Record "NPR Spfy Task"; DeactivatedAt: DateTime)
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        xArchVoucher: Record "NPR NpRv Arch. Voucher";
        RecRef: RecordRef;
    begin
        if SpfyTask."Record ID".TableNo() <> Database::"NPR NpRv Arch. Voucher" then
            exit;
        if not RecRef.Get(SpfyTask."Record ID") then
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

    local procedure SalesOrderReservedAmount(Voucher: Record "NPR NpRv Voucher") ReservedAmountLCY: Decimal
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal;
    begin
        MagentoPaymentLine.SetRange("Payment Type", MagentoPaymentLine."Payment Type"::Voucher);
        MagentoPaymentLine.SetRange("No.", Voucher."Reference No.");
        MagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        MagentoPaymentLine.SetRange("Document Type", MagentoPaymentLine."Document Type"::Order);
        MagentoPaymentLine.SetRange(Posted, false);
        // The voucher balance is in LCY, so each reservation must be converted from its document currency before summing (FCY sales orders carry document-currency amounts).
        if MagentoPaymentLine.FindSet() then
            repeat
                MagentoPaymentLine.TransactionCurrencyCodeAndFactor(true, CurrencyCode, CurrencyFactor);
                ReservedAmountLCY += MagentoPaymentLine.AmountLCY(CurrencyCode, CurrencyFactor);
            until MagentoPaymentLine.Next() = 0;
    end;
}