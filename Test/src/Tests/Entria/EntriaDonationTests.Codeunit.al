codeunit 85362 "NPR Entria Donation Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _MemberModuleLib: Codeunit "NPR Library - Member Module";
        _Initialized: Boolean;
        _StoreCodeLbl: Label 'NPRENT-DON', Locked = true;
        _DonationItemLbl: Label 'T-DON-ITEM', Locked = true;
        _DonationMembershipLbl: Label 'T-DONATION', Locked = true;
        _NationalIdLbl: Label '1234567890', Locked = true;
        _FlatFirstNameLbl: Label 'FlatFirst', Locked = true;
        _FlatEmailLbl: Label 'flat-donor@test.example.com', Locked = true;
        _ArrayFirstNameLbl: Label 'ArrayFirst', Locked = true;
        _ArrayEmailLbl: Label 'array-donor@test.example.com', Locked = true;

    [Test]
    procedure DonationImport_CreatesMembershipLineWithMemberData()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpl: Codeunit "NPR Entria Order Impl.";
        OrderJson: JsonToken;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] A Entria order with a DONATION product line is imported. The flat
        //            metadata.member_* properties and metadata.members[0] carry different
        //            first name and email values.
        // [THEN] The line becomes an Item/Membership line with the variable price from the
        //        payload. The flat properties win where both sources have a value, and the
        //        members array supplies everything else, including the national identifier.
        Initialize();
        GetEntriaStore(EntriaStore);
        DocumentNo := NextDocumentNo();
        OrderJson := BuildDonationOrderJson(DocumentNo, _DonationItemLbl);

        EntriaOrderImpl.ImportOrder(OrderJson, EntriaStore, DocumentNo, EcomSalesHeader);

        _Assert.AreEqual(DocumentNo, EcomSalesHeader."External No.", 'Ecom sales header must be created for the order');

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.FindFirst();
        _Assert.AreEqual(Format(EcomSalesLine.Type::Item), Format(EcomSalesLine.Type), 'Line type must be Item');
        _Assert.AreEqual(Format(EcomSalesLine.Subtype::Membership), Format(EcomSalesLine.Subtype), 'Donation line must resolve to the Membership subtype');
        _Assert.AreEqual(_DonationItemLbl, EcomSalesLine."No.", 'Item no. must come from metadata.external_id');
        _Assert.AreEqual(500, EcomSalesLine."Unit Price", 'Unit price must be taken from the payload (variable donation amount)');
        _Assert.AreEqual(1, EcomSalesLine.Quantity, 'Quantity must be 1');
        _Assert.AreEqual(Format(EcomSalesLine."Membership Operation"::CreateMembership), Format(EcomSalesLine."Membership Operation"), 'Operation must be CreateMembership');
        _Assert.IsFalse(EcomSalesLine.Subscription, 'Donation must not be a subscription');

        _Assert.AreEqual(_FlatFirstNameLbl, EcomSalesLine."Member First Name", 'metadata.member_first_name must win over members[0].first_name');
        _Assert.AreEqual(_FlatEmailLbl, EcomSalesLine."Member Email", 'metadata.member_email must win over members[0].email');
        _Assert.AreEqual('Lastname', EcomSalesLine."Member Last Name", 'Member last name from members[0]');
        _Assert.AreEqual('12345678', EcomSalesLine."Member Phone No.", 'Member phone from members[0]');
        _Assert.AreEqual('Address 1', EcomSalesLine."Member Address", 'Member address from members[0]');
        _Assert.AreEqual('City', EcomSalesLine."Member City", 'Member city from members[0]');
        _Assert.AreEqual('1234', EcomSalesLine."Member Post Code", 'Member post code from members[0]');
        _Assert.AreEqual('Denmark', EcomSalesLine."Member Country", 'Member country from members[0]');
        _Assert.AreEqual(DMY2Date(4, 6, 1990), EcomSalesLine."Member Birthday", 'Member birthday from members[0]');
        _Assert.AreEqual(_NationalIdLbl, EcomSalesLine."Member National Identifier", 'National identifier from members[0]');
        _Assert.AreEqual(Format(EcomSalesLine."Member Nat. Identifier Type"::NONE), Format(EcomSalesLine."Member Nat. Identifier Type"), 'Identifier type stays NONE until a PTE sets it');
    end;

    [Test]
    procedure DonationProcess_CreatesMemberWithNationalIdentifier()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EntriaStore: Record "NPR Entria Store";
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipRole: Record "NPR MM Membership Role";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        EntriaOrderImpl: Codeunit "NPR Entria Order Impl.";
        OrderJson: JsonToken;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] An imported donation line is captured and processed by the
        //            membership virtual item flow.
        // [THEN] A membership + member are created; the member carries the national
        //        identifier in "Social Security No." and the membership entry is
        //        confirmed against the web order no.
        Initialize();
        GetEntriaStore(EntriaStore);
        DocumentNo := NextDocumentNo();
        OrderJson := BuildDonationOrderJson(DocumentNo, _DonationItemLbl);
        EntriaOrderImpl.ImportOrder(OrderJson, EntriaStore, DocumentNo, EcomSalesHeader);

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.FindFirst();
        EcomSalesLine.Captured := true;
        EcomSalesLine.Modify();
        Commit();

        EcomCreateMMShipImpl.Process(EcomSalesLine);

        EcomSalesLine.Get(EcomSalesLine.RecordId);
        _Assert.IsFalse(IsNullGuid(EcomSalesLine."Membership Id"), 'Membership must be created and linked to the line');

        Membership.GetBySystemId(EcomSalesLine."Membership Id");
        _Assert.AreEqual(_DonationMembershipLbl, Membership."Membership Code", 'Membership code must come from the item''s membership sales setup');

        MembershipRole.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipRole.FindFirst();
        Member.Get(MembershipRole."Member Entry No.");
        _Assert.AreEqual(_NationalIdLbl, Member."Social Security No.", 'Member must carry the national identifier from the order line');
        _Assert.AreEqual(Format(Member.NationalIdentifierType::NONE), Format(Member.NationalIdentifierType), 'Member identifier type must come from the order line, NONE when no PTE set one');
        _Assert.AreEqual(_FlatFirstNameLbl, Member."First Name", 'Member first name');
        _Assert.AreEqual('Lastname', Member."Last Name", 'Member last name');

        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.FindFirst();
        _Assert.AreEqual(DocumentNo, MembershipEntry."Document No.", 'Membership entry must be confirmed with the web order no.');
    end;

    [Test]
    procedure DonationImport_NoFlatMemberProperties_ArrayFillsThem()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpl: Codeunit "NPR Entria Order Impl.";
        OrderJson: JsonToken;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] A donation line carries metadata.members[0] but no flat
        //            metadata.member_first_name / metadata.member_email.
        // [THEN] The members array supplies both, so the fields are never left blank
        //        just because the flat properties are missing.
        Initialize();
        GetEntriaStore(EntriaStore);
        DocumentNo := NextDocumentNo();
        OrderJson := BuildDonationOrderJson(DocumentNo, _DonationItemLbl, false);

        EntriaOrderImpl.ImportOrder(OrderJson, EntriaStore, DocumentNo, EcomSalesHeader);

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.FindFirst();
        _Assert.AreEqual(_ArrayFirstNameLbl, EcomSalesLine."Member First Name", 'members[0].first_name must fill the blank first name');
        _Assert.AreEqual(_ArrayEmailLbl, EcomSalesLine."Member Email", 'members[0].email must fill the blank email');
        _Assert.AreEqual(_NationalIdLbl, EcomSalesLine."Member National Identifier", 'National identifier from members[0]');
    end;

    [Test]
    procedure DonationProcess_SsnCommunityWithIdentifier_MemberCreated()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EntriaStore: Record "NPR Entria Store";
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        EntriaOrderImpl: Codeunit "NPR Entria Order Impl.";
        OrderJson: JsonToken;
        DocumentNo: Code[20];
        NationalIdentifier: Text;
    begin
        // [SCENARIO] The community identifies members by Social Security No. and the donation
        //            line carries a national identifier that no other member holds.
        // [THEN] The document validation accepts the line and the member is created with that
        //        identifier as its unique identity.
        Initialize();
        SetCommunityUniqueIdentitySsn(true);
        GetEntriaStore(EntriaStore);
        DocumentNo := NextDocumentNo();
        NationalIdentifier := NextNationalIdentifier();
        OrderJson := BuildDonationOrderJson(DocumentNo, _DonationItemLbl, true, NationalIdentifier);
        EntriaOrderImpl.ImportOrder(OrderJson, EntriaStore, DocumentNo, EcomSalesHeader);

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.FindFirst();
        EcomSalesLine.Captured := true;
        EcomSalesLine.Modify();
        Commit();

        EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        EcomSalesLine.Get(EcomSalesLine.RecordId);
        Membership.GetBySystemId(EcomSalesLine."Membership Id");
        MembershipRole.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipRole.FindFirst();
        Member.Get(MembershipRole."Member Entry No.");
        _Assert.AreEqual(CopyStr(NationalIdentifier, 1, MaxStrLen(Member."Social Security No.")), Member."Social Security No.", 'Member must carry the national identifier in an SSN community');

        SetCommunityUniqueIdentitySsn(false);
    end;

    [Test]
    procedure DonationProcess_SsnCommunityWithoutIdentifier_Fails()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EntriaStore: Record "NPR Entria Store";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        EntriaOrderImpl: Codeunit "NPR Entria Order Impl.";
        OrderJson: JsonToken;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] The community identifies members by Social Security No. but the donor
        //            left the national identifier out.
        // [THEN] The document validation that runs during capture and sales order creation
        //        rejects the line, because the community's unique identity cannot be filled.
        Initialize();
        SetCommunityUniqueIdentitySsn(true);
        GetEntriaStore(EntriaStore);
        DocumentNo := NextDocumentNo();
        OrderJson := BuildDonationOrderJson(DocumentNo, _DonationItemLbl, true, '');
        EntriaOrderImpl.ImportOrder(OrderJson, EntriaStore, DocumentNo, EcomSalesHeader);

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.FindFirst();
        Commit();

        asserterror EcomCreateMMShipImpl.ValidateMembershipOperation(EcomSalesLine, EcomSalesHeader);
        _Assert.ExpectedError('Member National Identifier must be provided');

        SetCommunityUniqueIdentitySsn(false);
    end;

    local procedure SetCommunityUniqueIdentitySsn(UseSsn: Boolean)
    var
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        MembershipSetup.Get(_DonationMembershipLbl);
        MemberCommunity.Get(MembershipSetup."Community Code");
        if UseSsn then
            MemberCommunity."Member Unique Identity" := MemberCommunity."Member Unique Identity"::SSN
        else
            MemberCommunity."Member Unique Identity" := MemberCommunity."Member Unique Identity"::NONE;
        MemberCommunity.Modify();
        Commit();
    end;

    local procedure Initialize()
    var
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        if _Initialized then
            exit;

        _MemberModuleLib.Initialize();
        _MemberModuleLib.CreateScenario_SmokeTest();

        // Individual membership for the donation item (SmokeTest only creates GROUP memberships)
        MembershipSetup.Get('T-GOLD');
        MemberCommunity.Get(MembershipSetup."Community Code");
        MemberCommunity."Member Unique Identity" := MemberCommunity."Member Unique Identity"::NONE;
        MemberCommunity."Member Logon Credentials" := MemberCommunity."Member Logon Credentials"::NA;
        // No customer means no contact, so BC's duplicate contact search never prompts mid-test.
        MemberCommunity."Membership to Cust. Rel." := false;
        MemberCommunity.Modify();

        _MemberModuleLib.SetupMembership_Simple(MembershipSetup."Community Code", _DonationMembershipLbl, '', 'Donation Membership');
        MembershipSetup.Get(_DonationMembershipLbl);
        MembershipSetup."Membership Type" := MembershipSetup."Membership Type"::INDIVIDUAL;
        MembershipSetup."Membership Member Cardinality" := 1;
        MembershipSetup.Modify();

        _MemberModuleLib.CreateItem(_DonationItemLbl, '', 'Donation Item', 0);
        _MemberModuleLib.SetupSimpleMembershipSalesItem(_DonationItemLbl, _DonationMembershipLbl);

        MembershipSalesSetup.SetRange("Membership Code", _DonationMembershipLbl);
        if MembershipSalesSetup.FindFirst() then begin
            MembershipSalesSetup.Blocked := false;
            MembershipSalesSetup.Modify();
        end;

        _Initialized := true;
    end;

    local procedure GetEntriaStore(var EntriaStore: Record "NPR Entria Store")
    var
        EntriaSetup: Record "NPR Entria Integration Setup";
    begin
        if not EntriaSetup.Get() then begin
            EntriaSetup.Init();
            EntriaSetup.Insert();
        end;

        if EntriaStore.Get(_StoreCodeLbl) then
            exit;

        EntriaStore.Init();
        EntriaStore.Code := _StoreCodeLbl;
        EntriaStore."Entria Url" := 'https://entria.test';
        EntriaStore.Enabled := true;
        EntriaStore."Sales Order Integration" := true;
        EntriaStore.Insert();
    end;

    local procedure NextDocumentNo() DocumentNo: Code[20]
    begin
        DocumentNo := CopyStr('ENT-' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(DocumentNo));
    end;

    // Ten digits nobody else holds, so an SSN community does not reject the member as a duplicate.
    local procedure NextNationalIdentifier() Identifier: Text
    var
        GuidText: Text;
        DigitsLbl: Label '0123456789', Locked = true;
        i: Integer;
    begin
        GuidText := DelChr(Format(CreateGuid()), '=', '{}-');
        for i := 1 to StrLen(GuidText) do begin
            if StrPos(DigitsLbl, Format(GuidText[i])) > 0 then
                Identifier += Format(GuidText[i]);
            if StrLen(Identifier) = 10 then
                exit(Identifier);
        end;
        exit(CopyStr(Identifier + DigitsLbl, 1, 10));
    end;

    local procedure BuildDonationOrderJson(DocumentNo: Code[20]; ItemNo: Code[20]): JsonToken
    begin
        exit(BuildDonationOrderJson(DocumentNo, ItemNo, true, _NationalIdLbl));
    end;

    local procedure BuildDonationOrderJson(DocumentNo: Code[20]; ItemNo: Code[20]; IncludeFlatMemberProperties: Boolean): JsonToken
    begin
        exit(BuildDonationOrderJson(DocumentNo, ItemNo, IncludeFlatMemberProperties, _NationalIdLbl));
    end;

    // IncludeFlatMemberProperties controls metadata.member_first_name / metadata.member_email, which
    // carry values different from members[0] so the precedence between the two sources is observable.
    local procedure BuildDonationOrderJson(DocumentNo: Code[20]; ItemNo: Code[20]; IncludeFlatMemberProperties: Boolean; NationalIdentifierValue: Text): JsonToken
    var
        BillingAddress: JsonObject;
        ItemJson: JsonObject;
        Items: JsonArray;
        Members: JsonArray;
        Metadata: JsonObject;
        Order: JsonObject;
        Payment: JsonObject;
        PaymentCollection: JsonObject;
        PaymentCollections: JsonArray;
        PaymentData: JsonObject;
        Payments: JsonArray;
        TaxLines: JsonArray;
    begin
        Order.Add('id', 'order_TEST' + DocumentNo);
        Order.Add('display_id', 16);
        Order.Add('custom_display_id', DocumentNo);
        Order.Add('email', 'donation-buyer@test.example.com');

        BillingAddress.Add('first_name', 'Billing First');
        BillingAddress.Add('last_name', 'Billing Last');
        BillingAddress.Add('address_1', 'Billing st 123');
        BillingAddress.Add('city', 'Billing City');
        BillingAddress.Add('postal_code', '7777');
        BillingAddress.Add('country_code', 'dk');
        Order.Add('billing_address', BillingAddress);

        Metadata.Add('external_id', ItemNo);
        Metadata.Add('price', 500);
        Metadata.Add('is_custom_price', true);
        Metadata.Add('membership_code', 'DONATIONSMEDLEM');
        if IncludeFlatMemberProperties then begin
            Metadata.Add('member_email', _FlatEmailLbl);
            Metadata.Add('member_first_name', _FlatFirstNameLbl);
        end;
        Members.Add(BuildMemberJson(NationalIdentifierValue));
        Metadata.Add('members', Members);

        ItemJson.Add('id', 'ordli_TEST' + DocumentNo);
        ItemJson.Add('title', 'Donation');
        ItemJson.Add('product_type', 'DONATION');
        ItemJson.Add('is_giftcard', false);
        ItemJson.Add('quantity', 1);
        ItemJson.Add('unit_price', 500);
        ItemJson.Add('subtotal', 500);
        ItemJson.Add('total', 500);
        ItemJson.Add('tax_total', 0);
        ItemJson.Add('tax_lines', TaxLines);
        ItemJson.Add('metadata', Metadata);
        Items.Add(ItemJson);
        Order.Add('items', Items);

        PaymentData.Add('pspReference', 'TEST-' + DelChr(Format(CreateGuid()), '=', '{}-'));
        PaymentData.Add('paymentMethod', 'visa');
        Payment.Add('amount', 500);
        Payment.Add('provider_id', 'pp_entria-adyen_adyen');
        Payment.Add('data', PaymentData);
        Payments.Add(Payment);
        PaymentCollection.Add('payments', Payments);
        PaymentCollections.Add(PaymentCollection);
        Order.Add('payment_collections', PaymentCollections);

        exit(Order.AsToken());
    end;

    local procedure BuildMemberJson(NationalIdentifierValue: Text): JsonObject
    var
        MemberJson: JsonObject;
    begin
        MemberJson.Add('first_name', _ArrayFirstNameLbl);
        MemberJson.Add('last_name', 'Lastname');
        MemberJson.Add('email', _ArrayEmailLbl);
        MemberJson.Add('phone_no', '12345678');
        MemberJson.Add('address', 'Address 1');
        MemberJson.Add('city', 'City');
        MemberJson.Add('post_code', '1234');
        MemberJson.Add('country', 'Denmark');
        MemberJson.Add('birthday', '1990-06-04');
        if NationalIdentifierValue <> '' then
            MemberJson.Add('national_identifier', NationalIdentifierValue);
        exit(MemberJson);
    end;
}
