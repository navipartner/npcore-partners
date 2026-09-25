#if not BC17
codeunit 85469 "NPR Library - Spfy Voucher"
{
    // Test helpers for the Shopify "Retail Vouchers" flow: seeds the minimal records the gift card
    // sender reads (Shopify setup + store, a Shopify integrated voucher type, a voucher and its
    // issue entry, the store-customer link and its assigned Shopify id, and the NC task) and builds
    // the canned Shopify GraphQL responses those requests expect.

    var
        _SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";

    #region BC record fixtures

    /// <summary>Enables the Shopify integration and creates a store with Retail Voucher sync turned on.</summary>
    procedure CreateShopifyStore(StoreCode: Code[20])
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyStore: Record "NPR Spfy Store";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        if not SpfyIntegrationSetup.Get() then begin
            SpfyIntegrationSetup.Init();
            SpfyIntegrationSetup.Insert();
        end;
        SpfyIntegrationSetup."Enable Integration" := true;
        if SpfyIntegrationSetup."Shopify Api Version" = '' then
            SpfyIntegrationSetup."Shopify Api Version" := '2026-04';
        SpfyIntegrationSetup.Modify();

        if not SpfyStore.Get(StoreCode) then begin
            SpfyStore.Init();
            SpfyStore.Code := StoreCode;
            SpfyStore.Insert();
        end;
        SpfyStore.Enabled := true;
        SpfyStore."Retail Voucher Integration" := true;
        SpfyStore."Shopify Url" := 'https://npr-test.myshopify.com';
        SpfyStore.Modify();

        // "NPR Spfy Integration Mgt." is SingleInstance and caches both the setup row and the last store it
        // read, so anything earlier in the session that asked whether the integration was enabled has already
        // cached "off" - GetRecordOnce even inserts the row disabled on a first read. Without this the writes
        // above are invisible and the suite passes alone but fails behind any other Shopify test.
        SpfyIntegrationMgt.SetRereadSetup();
    end;

    /// <summary>Creates a voucher type that syncs to the given Shopify store.</summary>
    procedure CreateVoucherType(VoucherTypeCode: Code[20]; StoreCode: Code[20]; var VoucherType: Record "NPR NpRv Voucher Type")
    begin
        if not VoucherType.Get(VoucherTypeCode) then begin
            VoucherType.Init();
            VoucherType.Code := VoucherTypeCode;
            VoucherType.Insert();
        end;
        VoucherType.Description := 'Shopify gift card';
        VoucherType."Integrate with Shopify" := true;
        VoucherType.Modify();
        _SpfyAssignedIDMgt.AssignShopifyID(VoucherType.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
    end;

    /// <summary>
    /// Creates a voucher that has not been synced to Shopify yet, together with the issue entry that
    /// gives it its initial amount. Reference No. follows the 8-20 alphanumeric rule Shopify vouchers must obey.
    /// </summary>
    procedure CreateVoucher(VoucherNo: Code[20]; VoucherTypeCode: Code[20]; ReferenceNo: Text[50]; InitialAmount: Decimal; var Voucher: Record "NPR NpRv Voucher")
    begin
        Voucher.Init();
        Voucher."No." := VoucherNo;
        Voucher."Voucher Type" := VoucherTypeCode;
        Voucher."Reference No." := ReferenceNo;
        Voucher.Description := ReferenceNo;
        Voucher."Spfy Send from Shopify" := true;
        Voucher.Insert();
        CreateIssueEntry(Voucher, InitialAmount);
    end;

    /// <summary>Sets the buyer side of the voucher: the BC customer and the e-mail/name held on the voucher itself.</summary>
    procedure SetVoucherBuyer(var Voucher: Record "NPR NpRv Voucher"; CustomerNo: Code[20]; Email: Text[80]; Name: Text[100])
    begin
        Voucher."Customer No." := CustomerNo;
        Voucher."E-mail" := Email;
        Voucher.Name := Name;
        Voucher.Modify();
    end;

    /// <summary>Sets the alternative recipient the buyer nominated in the webshop.</summary>
    procedure SetVoucherRecipient(var Voucher: Record "NPR NpRv Voucher"; RecipientEmail: Text[80]; RecipientName: Text[150])
    begin
        Voucher."Spfy Recipient E-mail" := RecipientEmail;
        Voucher."Spfy Recipient Name" := RecipientName;
        Voucher.Modify();
    end;

    /// <summary>Turns the "Send from Shopify" flag on or off; CreateVoucher leaves it on.</summary>
    procedure SetVoucherSendFromShopify(var Voucher: Record "NPR NpRv Voucher"; SendFromShopify: Boolean)
    begin
        Voucher."Spfy Send from Shopify" := SendFromShopify;
        Voucher.Modify();
    end;

    /// <summary>Sets the date and time the buyer asked Shopify to send the gift card on.</summary>
    procedure SetVoucherSendOn(var Voucher: Record "NPR NpRv Voucher"; SendOn: DateTime)
    begin
        Voucher."Spfy Send on" := SendOn;
        Voucher.Modify();
    end;

    /// <summary>Sets the personal message the buyer wrote to go with the gift card.</summary>
    procedure SetVoucherMessage(var Voucher: Record "NPR NpRv Voucher"; VoucherMessage: Text[250])
    begin
        Voucher."Voucher Message" := VoucherMessage;
        Voucher.Modify();
    end;

    local procedure CreateIssueEntry(Voucher: Record "NPR NpRv Voucher"; Amount: Decimal)
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Issue Voucher";
        VoucherEntry.Amount := Amount;
        VoucherEntry."Remaining Amount" := Amount;
        VoucherEntry.Positive := Amount > 0;
        VoucherEntry.Open := Amount <> 0;
        VoucherEntry."Posting Date" := WorkDate();
        VoucherEntry.Insert();
    end;

    /// <summary>Creates a customer and its store-customer link, optionally already carrying a Shopify customer id.</summary>
    procedure CreateCustomerWithStoreLink(CustomerNo: Code[20]; StoreCode: Code[20]; Email: Text[80]; Name: Text[100]; ShopifyCustomerID: Text[30]; var Customer: Record Customer)
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        if not Customer.Get(CustomerNo) then begin
            Customer.Init();
            Customer."No." := CustomerNo;
            Customer.Insert();
        end;
        Customer.Name := Name;
        Customer."E-Mail" := Email;
        Customer.Modify();

        SpfyStoreCustomerLink.Type := SpfyStoreCustomerLink.Type::Customer;
        SpfyStoreCustomerLink."No." := CustomerNo;
        SpfyStoreCustomerLink."Shopify Store Code" := StoreCode;
        if not SpfyStoreCustomerLink.Find() then begin
            SpfyStoreCustomerLink.Init();
            SpfyStoreCustomerLink.Type := SpfyStoreCustomerLink.Type::Customer;
            SpfyStoreCustomerLink."No." := CustomerNo;
            SpfyStoreCustomerLink."Shopify Store Code" := StoreCode;
            SpfyStoreCustomerLink.Insert();
        end;
        SpfyStoreCustomerLink."E-Mail" := Email;
        SpfyStoreCustomerLink."Sync. to this Store" := true;
        SpfyStoreCustomerLink.Modify();

        if ShopifyCustomerID <> '' then
            _SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreCustomerLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyCustomerID, false);
    end;

    /// <summary>
    /// Overwrites the e-mail on the store-customer link alone, so it can differ from the customer card's.
    /// The two drift apart in practice, and which one wins decides what reaches Shopify.
    /// </summary>
    procedure SetStoreCustomerLinkEmail(CustomerNo: Code[20]; StoreCode: Code[20]; Email: Text[100])
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        SpfyStoreCustomerLink.Get(SpfyStoreCustomerLink.Type::Customer, CustomerNo, StoreCode);
        SpfyStoreCustomerLink."E-Mail" := Email;
        SpfyStoreCustomerLink.Modify();
    end;

    /// <summary>Builds the NC task the gift card sender runs, pointing at the voucher.</summary>
    procedure CreateVoucherNcTask(StoreCode: Code[20]; Voucher: Record "NPR NpRv Voucher"; var NcTask: Record "NPR Nc Task")
    begin
        NcTask.Init();
        NcTask."Table No." := Database::"NPR NpRv Voucher";
        NcTask."Record ID" := Voucher.RecordId();
        NcTask."Record Value" := Voucher."No.";
        NcTask."Store Code" := StoreCode;
        NcTask.Type := NcTask.Type::Insert;
        NcTask.Insert(true);
    end;

    #endregion

    #region Reading a recorded gift card request

    /// <summary>
    /// Reads one leaf value out of the GiftCardCreateInput of a recorded GraphQL request, addressed by its
    /// path below `variables.input` (for instance 'customerId' or 'recipientAttributes.id'). Returns '' when
    /// the field is absent, so an assertion pins the value to the field it belongs to rather than just
    /// checking that the value appears somewhere in the request.
    /// </summary>
    procedure GiftCardInputValue(RequestText: Text; FieldPath: Text): Text
    var
        Field: JsonToken;
    begin
        if not SelectGiftCardInputField(RequestText, FieldPath, Field) then
            exit('');
        exit(Field.AsValue().AsText());
    end;

    /// <summary>Whether the GiftCardCreateInput of a recorded request carries the given field at all.</summary>
    procedure GiftCardInputHasField(RequestText: Text; FieldPath: Text): Boolean
    var
        Field: JsonToken;
    begin
        exit(SelectGiftCardInputField(RequestText, FieldPath, Field));
    end;

    local procedure SelectGiftCardInputField(RequestText: Text; FieldPath: Text; var Field: JsonToken): Boolean
    var
        Request: JsonToken;
    begin
        if RequestText = '' then
            exit(false);
        Request.ReadFrom(RequestText);
        exit(Request.SelectToken('variables.input.' + FieldPath, Field));
    end;

    /// <summary>
    /// The value of a field in the CustomerInput of a recorded customer mutation, so a test can assert on the
    /// address and name a created Shopify customer really carries rather than on a substring of the request.
    /// </summary>
    procedure CustomerInputValue(RequestText: Text; FieldPath: Text): Text
    var
        Field: JsonToken;
        Request: JsonToken;
    begin
        if RequestText = '' then
            exit('');
        Request.ReadFrom(RequestText);
        if not Request.SelectToken('variables.customerInput.' + FieldPath, Field) then
            exit('');
        exit(Field.AsValue().AsText());
    end;

    /// <summary>The Shopify customer GID for a numeric customer id, in the form the gift card request carries.</summary>
    procedure CustomerGID(ShopifyCustomerID: Text): Text
    begin
        exit('gid://shopify/Customer/' + ShopifyCustomerID);
    end;

    /// <summary>
    /// The exact search string a recorded customer-lookup request carried, so a test can assert on the address
    /// that was really sent rather than on a substring of it.
    /// </summary>
    procedure CustomerSearchCriteria(RequestText: Text): Text
    var
        Request: JsonToken;
        Criteria: JsonToken;
    begin
        if RequestText = '' then
            exit('');
        Request.ReadFrom(RequestText);
        if not Request.SelectToken('variables.searchCriteria', Criteria) then
            exit('');
        exit(Criteria.AsValue().AsText());
    end;

    #endregion

    #region Canned Shopify GraphQL responses

    /// <summary>Response for the "FindCustomerByEmail" query: one matching customer.</summary>
    procedure ResponseCustomerSearchHit(ShopifyCustomerID: Text) ResponseText: Text
    var
        Root, DataObj, CustomersObj, EdgeObj, NodeObj : JsonObject;
        Edges: JsonArray;
    begin
        NodeObj.Add('id', 'gid://shopify/Customer/' + ShopifyCustomerID);
        EdgeObj.Add('node', NodeObj);
        Edges.Add(EdgeObj);
        CustomersObj.Add('edges', Edges);
        DataObj.Add('customers', CustomersObj);
        Root.Add('data', DataObj);
        Root.WriteTo(ResponseText);
    end;

    /// <summary>Response for the "FindCustomerByEmail" query: nobody with that e-mail.</summary>
    procedure ResponseCustomerSearchMiss() ResponseText: Text
    var
        Root, DataObj, CustomersObj : JsonObject;
        Edges: JsonArray;
    begin
        CustomersObj.Add('edges', Edges);
        DataObj.Add('customers', CustomersObj);
        Root.Add('data', DataObj);
        Root.WriteTo(ResponseText);
    end;

    /// <summary>
    /// Response for the metafield definitions query: the store defines none. Creating a customer asks for
    /// these before it builds its request, so a test that reaches the create path has to answer it.
    /// </summary>
    procedure ResponseNoMetafieldDefinitions() ResponseText: Text
    var
        Root, DataObj, DefinitionsObj, PageInfoObj : JsonObject;
        Edges: JsonArray;
    begin
        PageInfoObj.Add('hasNextPage', false);
        PageInfoObj.Add('endCursor', '');
        DefinitionsObj.Add('edges', Edges);
        DefinitionsObj.Add('pageInfo', PageInfoObj);
        DataObj.Add('metafieldDefinitions', DefinitionsObj);
        Root.Add('data', DataObj);
        Root.WriteTo(ResponseText);
    end;

    /// <summary>Response for the "customerCreate" mutation: the customer Shopify created.</summary>
    procedure ResponseCustomerCreated(ShopifyCustomerID: Text) ResponseText: Text
    var
        Root, DataObj, CustomerCreateObj, CustomerObj : JsonObject;
        UserErrors: JsonArray;
    begin
        CustomerObj.Add('id', 'gid://shopify/Customer/' + ShopifyCustomerID);
        CustomerCreateObj.Add('customer', CustomerObj);
        CustomerCreateObj.Add('userErrors', UserErrors);
        DataObj.Add('customerCreate', CustomerCreateObj);
        Root.Add('data', DataObj);
        Root.WriteTo(ResponseText);
    end;

    /// <summary>Response for the "giftCardCreate" mutation.</summary>
    procedure ResponseGiftCardCreated(ShopifyGiftCardID: Text) ResponseText: Text
    var
        Root, DataObj, GiftCardCreateObj, GiftCardObj : JsonObject;
        UserErrors: JsonArray;
    begin
        GiftCardObj.Add('id', 'gid://shopify/GiftCard/' + ShopifyGiftCardID);
        GiftCardCreateObj.Add('giftCard', GiftCardObj);
        GiftCardCreateObj.Add('userErrors', UserErrors);
        DataObj.Add('giftCardCreate', GiftCardCreateObj);
        Root.Add('data', DataObj);
        Root.WriteTo(ResponseText);
    end;

    #endregion
}
#endif
