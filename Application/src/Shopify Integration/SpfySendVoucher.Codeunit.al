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
        JsonHelper: Codeunit "NPR Json Helper";
        VoucherNotFoundErr: Label 'Retail Voucher %1 could not be found or is not eligible for Shopify integration.', Comment = '%1 - Retail Voucher No.';

    local procedure SendVoucher(var NcTask: Record "NPR Nc Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        OutStr: OutStream;
        SendToShopify: Boolean;
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := false;

        Success := PrepareVoucherUpdateRequest(NcTask, SendToShopify);
        if SendToShopify then
            Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse);
        if Success and not SendToShopify then begin
            NcTask.Response.CreateOutStream(OutStr, TextEncoding::UTF8);
            OutStr.WriteText(GetLastErrorText());
        end;
        NcTask.Modify();
        Commit();

        if Success then begin
            if SendToShopify then
                UpdateVoucherWithDataFromShopify(NcTask, ShopifyResponse);
        end else
            Error(GetLastErrorText());
    end;

    local procedure SendVoucherAmtUpdate(var NcTask: Record "NPR Nc Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        OutStr: OutStream;
        ShopifyGiftCardID: Text[30];
        SendToShopify: Boolean;
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := false;

        Success := PrepareGiftCardBalanceAdjustmentRequest(NcTask, ShopifyGiftCardID, SendToShopify);
        if SendToShopify then
            Success := SpfyCommunicationHandler.SendGiftCardBalanceAdjustmentRequest(NcTask, ShopifyGiftCardID);
        if Success and not SendToShopify then begin
            NcTask.Response.CreateOutStream(OutStr, TextEncoding::UTF8);
            OutStr.WriteText(GetLastErrorText());
        end;
        NcTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
    end;

    local procedure SendVoucherDisableReq(var NcTask: Record "NPR Nc Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        OutStr: OutStream;
        ShopifyResponse: JsonToken;
        ShopifyGiftCardID: Text[30];
        SendToShopify: Boolean;
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := false;

        Success := PrepareGiftCardDisableRequest(NcTask, ShopifyGiftCardID, SendToShopify);
        if Success then begin
            if SendToShopify then begin
                Success := SpfyCommunicationHandler.SendGiftCardDisableRequest(NcTask, ShopifyGiftCardID, ShopifyResponse);
                if Success then
                    MarkVoucherAsDisabled(NcTask, ShopifyResponse)
            end else begin
                NcTask.Response.CreateOutStream(OutStr, TextEncoding::UTF8);
                OutStr.WriteText(GetLastErrorText());
            end;
            NcTask.Modify();
            Commit();
        end;

        if not Success then
            Error(GetLastErrorText());
    end;

    [TryFunction]
    local procedure PrepareVoucherUpdateRequest(var NcTask: Record "NPR Nc Task"; var SendToShopify: Boolean)
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
            Error(VoucherNotFoundErr, NcTask."Record Value");

        ShopifyGiftCardID := SpfyAssignedIDMgt.GetAssignedShopifyID(VoucherRecRef.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyGiftCardID = '' then begin
            if VoucherRecRef.Number = Database::"NPR NpRv Arch. Voucher" then begin
                if ThrowNoNeedToUpdateErr(StrSubstNo(VoucherArchivedErr, NcTask."Record Value")) then;
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

    [TryFunction]
    local procedure PrepareGiftCardBalanceAdjustmentRequest(var NcTask: Record "NPR Nc Task"; var ShopifyGiftCardID: Text[30]; var SendToShopify: Boolean)
    var
        Voucher: Record "NPR NpRv Voucher";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyRetailVoucherMgt: Codeunit "NPR Spfy Retail Voucher Mgt.";
        VoucherRecRef: RecordRef;
        AdjmtJObject: JsonObject;
        RequestJObject: JsonObject;
        ResponseJToken: JsonToken;
        OStream: OutStream;
        ShopifyStoreCode: Code[20];
        CurrentShopifyBalance: Decimal;
        NewBalance: Decimal;
        BalanceQueryFailedErr: Label 'System was not able to retrieve current balance for Retail Voucher %1. The following error occured:\%2', Comment = '%1 - Retail Voucher No., %2 - Shopify API call error details';
        BalanceUpToDateErr: Label 'Balance is up to date. No update needed.';
        MissingShopifyIdErr: Label 'Retail Voucher %1 does not have Shopify gift card ID assigned. Probably it hasn''t been synchronized to Shopify yet.', Comment = '%1 - Retail Voucher No.';
        VoucherArchivedErr: Label 'Retail Voucher %1 has been archived but never sent to Shopify. No need to send balance update requests to Shopify.', Comment = '%1 - Retail Voucher No.';
    begin
        if not SpfyRetailVoucherMgt.FindVoucher(NcTask, VoucherRecRef, Voucher, ShopifyStoreCode) then
            Error(VoucherNotFoundErr, NcTask."Record Value");
        ShopifyGiftCardID := SpfyAssignedIDMgt.GetAssignedShopifyID(VoucherRecRef.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyGiftCardID = '' then begin
            if VoucherRecRef.Number = Database::"NPR NpRv Arch. Voucher" then
                if not OutstandingVoucherRequestsExist(NcTask, Database::"NPR NpRv Voucher") then begin
                    if ThrowNoNeedToUpdateErr(StrSubstNo(VoucherArchivedErr, Voucher."No.")) then;
                    exit;
                end;
            Error(MissingShopifyIdErr, Voucher."No.");
        end;

        ClearLastError();
        if not SpfyCommunicationHandler.RetrieveGiftCardInfoFromShopify(ShopifyStoreCode, ShopifyGiftCardID, ResponseJToken) then
            Error(BalanceQueryFailedErr, Voucher."No.", GetLastErrorText());
        CurrentShopifyBalance := JsonHelper.GetJDecimal(ResponseJToken, 'gift_card.balance', true);

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
            if ThrowNoNeedToUpdateErr(BalanceUpToDateErr) then;
            exit;
        end;

        SendToShopify := true;

        AdjmtJObject.Add('amount', Format(NewBalance - CurrentShopifyBalance, 0, 9));
        AdjmtJObject.Add('note', UpdatedFromBCNote());
        RequestJObject.Add('adjustment', AdjmtJObject);

        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        RequestJObject.WriteTo(OStream);
    end;

    [TryFunction]
    local procedure PrepareGiftCardDisableRequest(var NcTask: Record "NPR Nc Task"; var ShopifyGiftCardID: Text[30]; var SendToShopify: Boolean)
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherCreateNcTask: Record "NPR Nc Task";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyRetailVoucherMgt: Codeunit "NPR Spfy Retail Voucher Mgt.";
        VoucherRecRef: RecordRef;
        ResponseJToken: JsonToken;
        ShopifyStoreCode: Code[20];
        AlreadyDisabledErr: Label 'Gift card already disabled. No update needed.';
        GiftCardQueryFailedErr: Label 'System was not able to retrieve Shopify gift card info for Retail Voucher %1. The following error occured:\%2', Comment = '%1 - Retail Voucher No., %2 - Shopify API call error details';
        PostponedErr: Label 'Processing postponed as outstanding Shopify gift card amount update requests still exist for the voucher.';
        VoucherArchivedErr: Label 'Retail Voucher %1 has been archived but never sent to Shopify. No need to send it now.', Comment = '%1 - Retail Voucher No.';
    begin
        if OutstandingVoucherRequestsExist(NcTask, Database::"NPR NpRv Voucher Entry") then
            Error(PostponedErr);

        if not SpfyRetailVoucherMgt.FindVoucher(NcTask, VoucherRecRef, Voucher, ShopifyStoreCode) then
            Error(VoucherNotFoundErr, NcTask."Record Value");
        ShopifyGiftCardID := SpfyAssignedIDMgt.GetAssignedShopifyID(VoucherRecRef.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyGiftCardID = '' then begin
            if OutstandingVoucherRequestsExist2(NcTask, Database::"NPR NpRv Voucher", VoucherCreateNcTask) then
                CancelOutstandingNcTasks(VoucherCreateNcTask, StrSubstNo(VoucherArchivedErr, Voucher."No."));
            if ThrowNoNeedToUpdateErr(StrSubstNo(VoucherArchivedErr, Voucher."No.")) then;
            exit;
        end;

        if not SpfyCommunicationHandler.RetrieveGiftCardInfoFromShopify(ShopifyStoreCode, ShopifyGiftCardID, ResponseJToken) then
            Error(GiftCardQueryFailedErr, Voucher."No.", GetLastErrorText());

        if JsonHelper.GetJDate(ResponseJToken, 'gift_card.disabled_at', false) <> 0D then begin
            if ThrowNoNeedToUpdateErr(AlreadyDisabledErr) then;
            exit;
        end;

        NcTask."Store Code" := ShopifyStoreCode;
        SendToShopify := true;
    end;

    [TryFunction]
    local procedure ThrowNoNeedToUpdateErr(ErrorText: Text)
    begin
        Error(ErrorText);
    end;

    internal procedure ShopifyGiftCardUpsertQuery(Voucher: Record "NPR NpRv Voucher"; ShopifyGiftCardID: Text[30]; ShopifyStoreCode: Code[20]; var QueryStream: OutStream)
    var
        Customer: Record Customer;
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        RecipientAttributesJson: JsonObject;
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
        end;
        VoucherJson.Add('expiresOn', Format(DT2Date(Voucher."Ending Date"), 0, 9));
        VoucherJson.Add('note', UpdatedFromBCNote());

        if (ShopifyGiftCardID = '') and (Voucher."Spfy Send from Shopify") and (Voucher."E-mail" <> '') then begin
            Customer."E-Mail" := Voucher."E-mail";
            Customer.Name := Voucher.Name;
            Customer."Name 2" := Voucher."Name 2";

            RecipientAttributesJson.Add('id', RecipientCustomerID(Customer, ShopifyStoreCode));
            RecipientAttributesJson.Add('message', Voucher."Voucher Message");
            RecipientAttributesJson.Add('preferredName', Voucher.Name + Voucher."Name 2");
            if Voucher."Spfy Send on" <> 0DT then
                if Voucher."Spfy Send on" > JobQueueMgt.NowWithDelayInSeconds(60) then
                    RecipientAttributesJson.Add('sendNotificationAt', Voucher."Spfy Send on");
            VoucherJson.Add('recipientAttributes', RecipientAttributesJson);
        end;

        VariablesJson.Add('input', VoucherJson);
        RequestJson.Add('variables', VariablesJson);
        RequestJson.WriteTo(QueryStream);
    end;

    local procedure RecipientCustomerID(Customer: Record Customer; ShopifyStoreCode: Code[20]) ShopifyCustomerID: Text
    var
        ShopifyResponse: JsonToken;
    begin
        //Find Shopify customer by email
        ClearLastError();
        if not FindShopifyCustomerByEmail(Customer."E-Mail", ShopifyStoreCode, ShopifyResponse) then
            Error(GetLastErrorText());
        if ShopifyResponse.SelectToken('data.customers.edges', ShopifyResponse) and ShopifyResponse.IsArray() then
            if ShopifyResponse.AsArray().Count() > 0 then begin
                ShopifyResponse.AsArray().Get(0, ShopifyResponse);
                ShopifyCustomerID := JsonHelper.GetJText(ShopifyResponse, 'node.id', false);
                if ShopifyCustomerID <> '' then
                    exit;
            end;

        //Create Shopify customer
        Clear(ShopifyResponse);
        if not CreateShopifyCustomer(Customer, ShopifyStoreCode, ShopifyResponse) then
            Error(GetLastErrorText());
        ShopifyCustomerID := JsonHelper.GetJText(ShopifyResponse, 'data.customerCreate.customer.id', true);
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
        FullName := Customer.Name + Customer."Name 2";
        FullName := FullName.Trim();
        LastSpacePosition := FullName.LastIndexOf(' ');
        if LastSpacePosition > 1 then begin
            CustomerJson.Add('firstName', FullName.Substring(1, LastSpacePosition - 1));
            CustomerJson.Add('lastName', FullName.Substring(LastSpacePosition + 1));
        end else
            CustomerJson.Add('firstName', FullName);
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
                FullShopifyGiftCardID := JsonHelper.GetJText(ShopifyResponse, 'data.giftCardCreate.giftCard.id', MaxStrLen(FullShopifyGiftCardID), false);
            NcTask.Type::Modify:
                FullShopifyGiftCardID := JsonHelper.GetJText(ShopifyResponse, 'data.giftCardUpdate.giftCard.id', MaxStrLen(FullShopifyGiftCardID), false);
        end;
#pragma warning disable AA0139        
        if FullShopifyGiftCardID.LastIndexOf('/') > 0 then
            ShopifyGiftCardID := CopyStr(FullShopifyGiftCardID, FullShopifyGiftCardID.LastIndexOf('/') + 1)
        else
            ShopifyGiftCardID := FullShopifyGiftCardID;
#pragma warning restore AA0139        
        if ShopifyGiftCardID = '' then
            Error('');  //The system will record shopify response as the error message

        SpfyAssignedIDMgt.AssignShopifyID(NcTask."Record ID", "NPR Spfy ID Type"::"Entry ID", ShopifyGiftCardID, false);
    end;

    local procedure MarkVoucherAsDisabled(NcTask: Record "NPR Nc Task"; ShopifyResponse: JsonToken)
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
        ArchVoucher."Disabled at Shopify" := JsonHelper.GetJDate(ShopifyResponse, 'gift_card.disabled_at', false) <> 0D;
        if ArchVoucher."Disabled at Shopify" <> xArchVoucher."Disabled at Shopify" then
            ArchVoucher.Modify();
    end;

    local procedure UpdatedFromBCNote(): Text[30]
    var
        NoteLbl: Label 'Updated from Business Central', MaxLength = 30;
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
        exit(OutstandingVoucherRequestsExist2(NcTask, TableNo, NcTask2));
    end;

    local procedure OutstandingVoucherRequestsExist2(NcTask: Record "NPR Nc Task"; TableNo: Integer; var OutstandingNcTask: Record "NPR Nc Task"): Boolean
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