#if not BC17
codeunit 6184820 "NPR Spfy Send Voucher"
{
    Access = Internal;
    TableNo = "NPR Nc Task";
    ObsoleteState = Pending;
    ObsoleteTag = '2026-08-26';
    ObsoleteReason = 'Replaced by codeunit "NPR Spfy Task Send Voucher" (the new Shopify Task List queue). This copy keeps serving environments that have not migrated yet. The two codeunits are maintained independently and may diverge: never copy changes blindly between them - apply a fix to each deliberately, only where it belongs.';

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
        _SpfySendCustomers: Codeunit "NPR Spfy Send Customers";
        _GraphQLClient: Interface "NPR Spfy IGraphQL Client";
        _GraphQLClientSet: Boolean;
        _VoucherNotFoundErr: Label 'Retail Voucher %1 could not be found or is not eligible for Shopify integration.', Comment = '%1 - Retail Voucher No.';

    internal procedure SetGraphQLClient(GraphQLClient: Interface "NPR Spfy IGraphQL Client")
    begin
        _GraphQLClient := GraphQLClient;
        _GraphQLClientSet := true;
        _SpfySendCustomers.SetGraphQLClient(GraphQLClient);  //customer resolution calls Shopify from inside the gift card request build
    end;

    local procedure GetGraphQLClient(): Interface "NPR Spfy IGraphQL Client"
    var
        DefaultGraphQLClient: Codeunit "NPR Spfy GraphQL Client";
    begin
        if not _GraphQLClientSet then begin
            _GraphQLClient := DefaultGraphQLClient;
            _GraphQLClientSet := true;
        end;
        exit(_GraphQLClient);
    end;

    local procedure SendVoucher(var NcTask: Record "NPR Nc Task")
    var
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
            Success := GetGraphQLClient().ExecuteRequest(NcTask, true, ShopifyResponse);
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
            Success := GetGraphQLClient().ExecuteRequest(NcTask, true, ShopifyResponse);
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
            Success := GetGraphQLClient().ExecuteRequest(NcTask, true, ShopifyResponse);
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
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        VoucherJson: JsonObject;
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

        if (ShopifyGiftCardID = '') and Voucher."Spfy Send from Shopify" then
            AddGiftCardCustomerAndRecipient(Voucher, ShopifyStoreCode, VoucherJson);

        VariablesJson.Add('input', VoucherJson);
        RequestJson.Add('variables', VariablesJson);
        RequestJson.WriteTo(QueryStream);
    end;

    /// <summary>
    /// Attaches the buyer (customerId) and, when there is a recipient notification to send, the recipient
    /// (recipientAttributes) to a gift card create request.
    /// Shopify notifies the customer named in customerId. The Admin API version we call describes that field
    /// as "The ID of the customer who will receive the gift card", and its giftCardSendNotificationToCustomer
    /// mutation exists to "resend the purchase confirmation", which presupposes one was already sent. A later
    /// schema than ours says it outright, with a notify field defaulting to true that governs "notifications
    /// to the customer and recipient". So the buyer's own id is what delivers the gift card to the buyer.
    /// recipientAttributes is a second notification, sent from a different Shopify template: the customerId
    /// mail reads as a purchase confirmation, the recipient mail as "you have received a gift card". It is
    /// attached in the two cases where the user asked for it, and naming the buyer in both fields is one of
    /// them rather than something to be prevented:
    ///  - the buyer nominated a recipient, whoever that turns out to be. A buyer who nominates their own
    ///    address wants the recipient mail too, typically to pass it on themselves rather than hand us the
    ///    real recipient's address.
    ///  - the buyer nominated nobody but wrote a message or set a send date. Shopify carries message and
    ///    sendNotificationAt only inside recipientAttributes, so there is nowhere else to put them.
    /// The gift card is what the buyer paid for, so resolving their id matters: with no customerId and no
    /// recipient, Shopify has nobody to notify and the card is created but never sent.
    /// </summary>
    local procedure AddGiftCardCustomerAndRecipient(Voucher: Record "NPR NpRv Voucher"; ShopifyStoreCode: Code[20]; var VoucherJson: JsonObject)
    var
        BuyerEmail: Text;
        BuyerName: Text;
        PersonalMessage: Text;
        RecipientEmail: Text;
        RecipientName: Text;
        ShopifyBillToCustGID: Text;
        ShopifyShipToCustGID: Text;
        NominationExists: Boolean;
        NomineeIsTheBuyer: Boolean;
        ScheduleTheSend: Boolean;
        RecipientGIDMissingErr: Label 'The gift card recipient for voucher %1 resolved to a blank Shopify customer id although the customer was to be created when missing. This is a programming bug.', Locked = true;
    begin
        // Trim everything: whitespace-only fields must not count as a nomination or a message.
        BuyerEmail := Voucher."E-mail".Trim();
        BuyerName := _SpfySendCustomers.GetFullName(Voucher.Name, Voucher."Name 2");  //GetFullName trims
        RecipientEmail := Voucher."Spfy Recipient E-mail".Trim();
        RecipientName := Voucher."Spfy Recipient Name".Trim();
        PersonalMessage := Voucher."Voucher Message".Trim();
        NominationExists := RecipientEmail <> '';
        // Read once; both decisions below must agree.
        ScheduleTheSend := ScheduledSendIsInTheFuture(Voucher);
        // Against the address the buyer resolves to, not the voucher's own field, which is only the last of
        // three candidates.
        if NominationExists then
            NomineeIsTheBuyer :=
                UpperCase(RecipientEmail) = UpperCase(_SpfySendCustomers.GetCustomerEmail(Voucher."Customer No.", ShopifyStoreCode, BuyerEmail));

        // Create the buyer only when they are the one being notified. When somebody else was nominated the
        // buyer's id earns nothing but a duplicate confirmation, and an address that matches nothing would
        // leave a stray Shopify customer behind, so an existing id is used and none is created.
        // Exception: if the nominee is the buyer, create them here, since the recipient pass would create
        // them anyway without a BC link.
        ShopifyBillToCustGID :=
            _SpfySendCustomers.GetShopifyCustomerGID(
                Voucher."Customer No.", ShopifyStoreCode, BuyerEmail, BuyerName, (not NominationExists) or NomineeIsTheBuyer);
        if ShopifyBillToCustGID <> '' then
            VoucherJson.Add('customerId', ShopifyBillToCustGID);

        if not NominationExists then begin
            // customerId alone delivers the gift card. Name the buyer a second time only for something
            // recipientAttributes is the sole carrier of, and only when there is an id to hang it on.
            if (ShopifyBillToCustGID <> '') and HasSendInstructions(PersonalMessage, ScheduleTheSend) then
                AddRecipientAttributes(Voucher, ShopifyBillToCustGID, BuyerName, PersonalMessage, ScheduleTheSend, VoucherJson);
            exit;
        end;

        // A nominee who is the buyer resolves to the id already in hand, so Shopify is not searched twice and
        // both fields carry the one id.
        if NomineeIsTheBuyer and (ShopifyBillToCustGID <> '') then begin
            ShopifyShipToCustGID := ShopifyBillToCustGID;
            // Fall back to the buyer's name when the nomination has none.
            if RecipientName = '' then
                RecipientName := BuyerName;
        end else
            ShopifyShipToCustGID := _SpfySendCustomers.GetShopifyCustomerGID('', ShopifyStoreCode, RecipientEmail, RecipientName, true);

        // Defensive: Shopify rejects a blank recipient id. Raises rather than exits because customerId is
        // already on the request, so a quiet exit would drop the recipient and still report success.
        if ShopifyShipToCustGID = '' then
            Error(RecipientGIDMissingErr, Voucher."No.");

        AddRecipientAttributes(Voucher, ShopifyShipToCustGID, RecipientName, PersonalMessage, ScheduleTheSend, VoucherJson);
    end;

    /// <summary>
    /// A message or a future send date needs recipientAttributes; a name alone does not.
    /// </summary>
    local procedure HasSendInstructions(PersonalMessage: Text; ScheduleTheSend: Boolean): Boolean
    begin
        exit((PersonalMessage <> '') or ScheduleTheSend);
    end;

    /// <summary>
    /// Whether "Spfy Send on" is far enough ahead for Shopify to act on it. A date already past, or within
    /// the next minute, would have Shopify send immediately, so it is not passed on at all.
    /// </summary>
    local procedure ScheduledSendIsInTheFuture(Voucher: Record "NPR NpRv Voucher"): Boolean
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        if Voucher."Spfy Send on" = 0DT then
            exit(false);
        exit(Voucher."Spfy Send on" > JobQueueMgt.NowWithDelayInSeconds(60));
    end;

    local procedure AddRecipientAttributes(Voucher: Record "NPR NpRv Voucher"; ShopifyShipToCustGID: Text; RecipientName: Text; PersonalMessage: Text; ScheduleTheSend: Boolean; var VoucherJson: JsonObject)
    var
        RecipientAttributesJson: JsonObject;
    begin
        RecipientAttributesJson.Add('id', ShopifyShipToCustGID);
        if PersonalMessage <> '' then
            RecipientAttributesJson.Add('message', PersonalMessage);
        if RecipientName <> '' then
            RecipientAttributesJson.Add('preferredName', RecipientName);
        if ScheduleTheSend then
            RecipientAttributesJson.Add('sendNotificationAt', Voucher."Spfy Send on");
        VoucherJson.Add('recipientAttributes', RecipientAttributesJson);
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
        if not GetGraphQLClient().ExecuteRequest(NcTask, true, ShopifyResponse) then
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