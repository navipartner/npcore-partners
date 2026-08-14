#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85161 "NPR Library Ecommerce"
{
    procedure CreateEcomSalesHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        EcomSalesHeader.Init();
        EcomSalesHeader."External No." := 'TEST-' + Format(Random(9999));
        EcomSalesHeader."Document Type" := EcomSalesHeader."Document Type"::Order;
        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Pending;
        EcomSalesHeader."Bucket Id" := Random(100);
        EcomSalesHeader.Insert(true);
    end;

    procedure CreateCapturedTicketLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; ItemNo: Code[20])
    begin
        CreateTicketLine(EcomSalesLine, EcomSalesHeader, ItemNo, 1, 100);
        EcomSalesLine.Captured := true;
        EcomSalesLine.Modify();
    end;

    procedure CreateTicketLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; ItemNo: Code[20]; Qty: Decimal; UnitPrice: Decimal)
    begin
        if ItemNo = '' then
            ItemNo := CreateDefaultTicketItem();
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := CopyStr(EcomSalesHeader."External No.", 1, MaxStrLen(EcomSalesLine."External Document No."));
        EcomSalesLine."Line No." := GetNextLineNo(EcomSalesHeader);
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Ticket;
#pragma warning disable AA0139
        EcomSalesLine."No." := ItemNo;
#pragma warning restore AA0139
        EcomSalesLine.Quantity := Qty;
        EcomSalesLine."Unit Price" := UnitPrice;
        EcomSalesLine."Line Amount" := Qty * UnitPrice;
        EcomSalesLine.Insert(true);
    end;

    local procedure CreateDefaultTicketItem(): Code[20]
    var
        LibTicket: Codeunit "NPR Library - Ticket Module";
    begin
        LibTicket.CreateMinimalSetup();
        exit(LibTicket.CreateItem('', LibTicket.CreateTicketType(LibTicket.GenerateCode10(), '<+7D>', 0, 0, "NPR TM ActivationMethod_Type"::SCAN, 0, 0), 100));
    end;

    procedure CreateCapturedMembershipLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; ItemNo: Code[20]; Membership: Record "NPR MM Membership")
    begin
        CreateMembershipLine(EcomSalesLine, EcomSalesHeader, ItemNo, 1, 100);
        EcomSalesLine."Membership Id" := Membership.SystemId;
        EcomSalesLine.Captured := true;
        EcomSalesLine.Modify();
    end;

    procedure CreateCapturedMembershipLineNoToken(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; ItemNo: Code[20])
    begin
        CreateMembershipLine(EcomSalesLine, EcomSalesHeader, ItemNo, 1, 100);
        EcomSalesLine.Captured := true;
        EcomSalesLine.Modify();
    end;

    local procedure CreateMembershipLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; ItemNo: Code[20]; Qty: Decimal; UnitPrice: Decimal)
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := CopyStr(EcomSalesHeader."External No.", 1, MaxStrLen(EcomSalesLine."External Document No."));
        EcomSalesLine."Line No." := GetNextLineNo(EcomSalesHeader);
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Membership;
#pragma warning disable AA0139
        EcomSalesLine."No." := ItemNo;
#pragma warning restore AA0139
        EcomSalesLine.Quantity := Qty;
        EcomSalesLine."Unit Price" := UnitPrice;
        EcomSalesLine."Line Amount" := Qty * UnitPrice;
        EcomSalesLine.Insert(true);
    end;

    procedure CreateAdmissionWithDefaultSchedule(AdmissionCode: Code[20]; DefaultSchedule: Option): Code[20]
    var
        Admission: Record "NPR TM Admission";
    begin
        Admission.Init();
        Admission."Admission Code" := AdmissionCode;
        Admission.Description := AdmissionCode;
        Admission.Type := Admission.Type::LOCATION;
        Admission."Default Schedule" := DefaultSchedule;
        Admission."Capacity Limits By" := Admission."Capacity Limits By"::Override;
        Admission."Capacity Control" := Admission."Capacity Control"::NONE;
        Admission.Insert();
        exit(AdmissionCode);
    end;

    procedure CreateAdmissionWithCapacityControl(AdmissionCode: Code[20]; CapacityControl: Option): Code[20]
    var
        Admission: Record "NPR TM Admission";
    begin
        Admission.Init();
        Admission."Admission Code" := AdmissionCode;
        Admission.Description := AdmissionCode;
        Admission.Type := Admission.Type::LOCATION;
        Admission."Default Schedule" := Admission."Default Schedule"::TODAY;
        Admission."Capacity Limits By" := Admission."Capacity Limits By"::Override;
        Admission."Capacity Control" := CapacityControl;
        Admission.Insert();
        exit(AdmissionCode);
    end;

    procedure InsertEcomDocumentWithReservationToken(ExternalNo: Code[20]; ReservationToken: Text[100]; ItemNo: Code[20]; IncludeLineId: Boolean; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        Body: JsonObject;
        Lines: JsonArray;
        Payments: JsonArray;
        LineId: Guid;
    begin
        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', ReservationToken);
        TicketRequest.FindFirst();
        if IncludeLineId then
            LineId := TicketRequest.SystemId;
        Body := CreateHeaderJson(ExternalNo);
        Body.Add('ticketReservationToken', ReservationToken);
        AddDefaultSellTo(Body);
        AddSalesLineJson(Lines, ItemNo, 1, 100, 0, LineId);
        Body.Add('salesDocumentLines', Lines);
        Body.Add('payments', Payments);
        ProcessEcomDocument(Body, ExternalNo, EcomSalesHeader);
    end;

    procedure InsertEcomDocumentWithMemberData(ExternalNo: Code[20]; ItemNo: Code[20]; FirstName: Text; LastName: Text; Email: Text; Quantity: Decimal; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Body: JsonObject;
        Lines: JsonArray;
        Payments: JsonArray;
        EmptyGuid: Guid;
    begin
        Body := CreateHeaderJson(ExternalNo);
        AddDefaultSellTo(Body);
        AddMembershipLineJsonWithMemberData(Lines, ItemNo, EmptyGuid, FirstName, LastName, Email, Quantity);
        Body.Add('salesDocumentLines', Lines);
        Body.Add('payments', Payments);
        ProcessEcomDocument(Body, ExternalNo, EcomSalesHeader);
    end;

    procedure InsertEcomDocumentWithMembershipToken(ExternalNo: Code[20]; ItemNo: Code[20]; MembershipToken: Guid; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        InsertEcomDocumentWithMembershipTokenQty(ExternalNo, ItemNo, MembershipToken, 1, EcomSalesHeader);
    end;

    procedure InsertEcomDocumentWithMembershipTokenQty(ExternalNo: Code[20]; ItemNo: Code[20]; MembershipToken: Guid; Quantity: Decimal; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Body: JsonObject;
        Lines: JsonArray;
        Payments: JsonArray;
    begin
        Body := CreateHeaderJson(ExternalNo);
        AddDefaultSellTo(Body);
        AddMembershipLineJsonWithMemberData(Lines, ItemNo, MembershipToken, '', '', '', Quantity);
        Body.Add('salesDocumentLines', Lines);
        Body.Add('payments', Payments);
        ProcessEcomDocument(Body, ExternalNo, EcomSalesHeader);
    end;

    procedure InsertEcomDocument(ExternalNo: Code[20]; ItemNo: Code[20]; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Body: JsonObject;
        Lines: JsonArray;
        Payments: JsonArray;
        EmptyGuid: Guid;
    begin
        Body := CreateHeaderJson(ExternalNo);
        AddDefaultSellTo(Body);
        AddSalesLineJson(Lines, ItemNo, 1, 100, 0, EmptyGuid);
        Body.Add('salesDocumentLines', Lines);
        Body.Add('payments', Payments);
        ProcessEcomDocument(Body, ExternalNo, EcomSalesHeader);
    end;

    procedure InsertEcomDocumentWithVoucherPayment(ExternalNo: Code[20]; ItemNo: Code[20]; CustomerNo: Code[20]; CurrencyCode: Code[10]; NpRvVoucher: Record "NPR NpRv Voucher"; OrderAmountFCY: Decimal; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Body: JsonObject;
        Lines: JsonArray;
        Payments: JsonArray;
        EmptyGuid: Guid;
    begin
        Body := CreateHeaderJson(ExternalNo);
        if CurrencyCode <> '' then
            Body.Add('currencyCode', CurrencyCode);
        AddSellToWithCustomerNo(Body, CustomerNo);
        AddSalesLineJson(Lines, ItemNo, 1, OrderAmountFCY, 0, EmptyGuid);
        Body.Add('salesDocumentLines', Lines);
        AddVoucherPaymentJson(Payments, NpRvVoucher."Reference No.", OrderAmountFCY);
        Body.Add('payments', Payments);
        ProcessEcomDocument(Body, ExternalNo, EcomSalesHeader);
    end;

    local procedure GetNextLineNo(EcomSalesHeader: Record "NPR Ecom Sales Header"): Integer
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        if EcomSalesLine.FindLast() then
            exit(EcomSalesLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure CreateHeaderJson(ExternalNo: Code[20]): JsonObject
    var
        Body: JsonObject;
    begin
        Body.Add('externalNo', ExternalNo);
        Body.Add('documentType', 'order');
        exit(Body);
    end;

    local procedure AddDefaultSellTo(var Body: JsonObject)
    var
        SellTo: JsonObject;
    begin
        SellTo.Add('name', 'Test Customer');
        SellTo.Add('address', 'Test Street 1');
        SellTo.Add('postCode', '1234');
        SellTo.Add('city', 'Test City');
        SellTo.Add('countryCode', 'DK');
        SellTo.Add('email', 'test@ecommerce.test');
        Body.Add('sellToCustomer', SellTo);
    end;

    local procedure AddSellToWithCustomerNo(var Body: JsonObject; CustomerNo: Code[20])
    var
        SellTo: JsonObject;
    begin
        SellTo.Add('no', CustomerNo);
        SellTo.Add('name', 'Test Customer');
        SellTo.Add('address', 'Test Street 1');
        SellTo.Add('postCode', '1234');
        SellTo.Add('city', 'Test City');
        SellTo.Add('countryCode', 'DK');
        SellTo.Add('email', 'test@ecommerce.test');
        Body.Add('sellToCustomer', SellTo);
    end;

    local procedure AddSalesLineJson(var Lines: JsonArray; ItemNo: Code[20]; Quantity: Decimal; UnitPrice: Decimal; VatPercent: Decimal; ticketReservationLineId: Guid)
    var
        Line: JsonObject;
    begin
        Line.Add('type', 'item');
        Line.Add('no', ItemNo);
        Line.Add('quantity', Quantity);
        Line.Add('unitPrice', UnitPrice);
        Line.Add('vatPercent', VatPercent);
        Line.Add('lineAmount', Quantity * UnitPrice);
        if not IsNullGuid(TicketReservationLineId) then
            Line.Add('ticketReservationLineId', Format(ticketReservationLineId));
        Lines.Add(Line);
    end;


    local procedure AddMembershipLineJsonWithMemberData(var Lines: JsonArray; ItemNo: Code[20]; MembershipToken: Guid; FirstName: Text; LastName: Text; Email: Text; Quantity: Decimal)
    var
        Line: JsonObject;
    begin
        Line.Add('type', 'item');
        Line.Add('no', ItemNo);
        Line.Add('quantity', Quantity);
        Line.Add('unitPrice', 100);
        Line.Add('vatPercent', 0);
        Line.Add('lineAmount', Quantity * 100);
        if not IsNullGuid(MembershipToken) then
#pragma warning disable AA0139
            Line.Add('membershipId', Format(MembershipToken, 0, 4).ToLower());
#pragma warning restore AA0139
        if FirstName <> '' then
            Line.Add('memberFirstName', FirstName);
        if LastName <> '' then
            Line.Add('memberLastName', LastName);
        if Email <> '' then
            Line.Add('memberEmail', Email);
        Lines.Add(Line);
    end;

    local procedure AddVoucherPaymentJson(var Payments: JsonArray; VoucherReference: Code[50]; Amount: Decimal)
    var
        Payment: JsonObject;
    begin
        Payment.Add('paymentMethodType', 'voucher');
        Payment.Add('paymentReference', VoucherReference);
        Payment.Add('paymentAmount', Amount);
        Payments.Add(Payment);
    end;

    local procedure ProcessEcomDocument(Body: JsonObject; ExternalNo: Code[20]; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        ApiAgent: Codeunit "NPR EcomSalesDocApiAgentV2";
        Request: Codeunit "NPR API Request";
        BodyToken: JsonToken;
        PathSegments: List of [Text];
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        BodyToken := Body.AsToken();
        PathSegments.Add('ecommerce');
        Request.Init("Http Method"::POST, '/ecommerce/v2/sales-documents', PathSegments, QueryParams, Headers, BodyToken);
        ApiAgent.CreateIncomingEcomDocument(Request);

        EcomSalesHeader.SetRange("External No.", ExternalNo);
        EcomSalesHeader.FindFirst();
    end;

    // Header of a create-document request, without lines, so a test can compose its own line
    // objects. Pass a customer no. to have processing reuse that customer instead of creating one
    // from the customer templates.
    procedure BuildEcomDocumentBody(ExternalNo: Code[20]; DocumentTypeText: Text; CustomerNo: Code[20]): JsonObject
    var
        Body: JsonObject;
    begin
        Body.Add('externalNo', ExternalNo);
        Body.Add('documentType', DocumentTypeText);
        if CustomerNo <> '' then
            AddSellToWithCustomerNo(Body, CustomerNo)
        else
            AddDefaultSellTo(Body);
        exit(Body);
    end;

    // Posts a hand-composed request body to the V2 create endpoint. The payments array is
    // required by the endpoint, so an empty one is supplied when the test did not add it.
    procedure SubmitEcomDocumentBody(Body: JsonObject; ExternalNo: Code[20]; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Payments: JsonArray;
    begin
        if not Body.Contains('payments') then
            Body.Add('payments', Payments);
        ProcessEcomDocument(Body, ExternalNo, EcomSalesHeader);
    end;

    // Creates a single-item document, optionally carrying dimensions on the header, on the line,
    // or on both. An empty array is left out of the request entirely, so a caller can ask for a
    // document with no dimensions at all.
    procedure InsertEcomDocumentWithDimensions(ExternalNo: Code[20]; DocumentTypeText: Text; ItemNo: Code[20]; CustomerNo: Code[20]; HeaderDimensions: JsonArray; LineDimensions: JsonArray; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Body: JsonObject;
        Lines: JsonArray;
        Line: JsonObject;
    begin
        Body := BuildEcomDocumentBody(ExternalNo, DocumentTypeText, CustomerNo);
        if HeaderDimensions.Count() > 0 then
            Body.Add('dimensions', HeaderDimensions);

        Line.Add('type', 'item');
        Line.Add('no', ItemNo);
        Line.Add('quantity', 1);
        Line.Add('unitPrice', 100);
        Line.Add('vatPercent', 0);
        Line.Add('lineAmount', 100);
        if LineDimensions.Count() > 0 then
            Line.Add('dimensions', LineDimensions);
        Lines.Add(Line);
        Body.Add('salesDocumentLines', Lines);

        SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);
    end;

    // As SubmitEcomDocumentBody, but hands back the response body so a test can assert on the
    // payload the caller actually receives rather than only on the stored document.
    procedure SubmitEcomDocumentBodyForResponse(Body: JsonObject; ExternalNo: Code[20]; var EcomSalesHeader: Record "NPR Ecom Sales Header") ResponseJson: JsonObject
    var
        ApiAgent: Codeunit "NPR EcomSalesDocApiAgentV2";
        Request: Codeunit "NPR API Request";
        Response: Codeunit "NPR API Response";
        Payments: JsonArray;
        BodyToken: JsonToken;
        PathSegments: List of [Text];
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        if not Body.Contains('payments') then
            Body.Add('payments', Payments);
        BodyToken := Body.AsToken();
        PathSegments.Add('ecommerce');
        Request.Init("Http Method"::POST, '/ecommerce/v2/sales-documents', PathSegments, QueryParams, Headers, BodyToken);
        Response := ApiAgent.CreateIncomingEcomDocument(Request);
        ResponseJson := Response.GetJson();

        EcomSalesHeader.SetRange("External No.", ExternalNo);
        EcomSalesHeader.FindFirst();
    end;

    // A single-voucher-line order, submitted through the API exactly as a webshop would. The
    // voucher is unissued at this point - issuing it is the FastLane job queues' work.
    procedure InsertEcomDocumentWithVoucherLine(ExternalNo: Code[20]; VoucherTypeCode: Code[20]; CustomerNo: Code[20]; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        InsertEcomDocumentWithVoucherLine(ExternalNo, 'order', VoucherTypeCode, CustomerNo, EcomSalesHeader);
    end;

    // Same, for a caller that needs to choose the document type - specifically to build a RETURN order
    // carrying a voucher line, which is how the items-only rule for returns gets exercised: the
    // virtual-item job queues all filter Document Type = Order, so nothing may be issued for it.
    procedure InsertEcomDocumentWithVoucherLine(ExternalNo: Code[20]; DocumentTypeText: Text; VoucherTypeCode: Code[20]; CustomerNo: Code[20]; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Body: JsonObject;
        Lines: JsonArray;
        Line: JsonObject;
    begin
        Body := BuildEcomDocumentBody(ExternalNo, DocumentTypeText, CustomerNo);
        Line.Add('type', 'voucher');
        Line.Add('voucherType', VoucherTypeCode);
        Line.Add('description', 'Test gift voucher');
        Line.Add('quantity', 1);
        Line.Add('unitPrice', 100);
        Line.Add('vatPercent', 0);
        Line.Add('lineAmount', 100);
        Lines.Add(Line);
        Body.Add('salesDocumentLines', Lines);
        SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);
    end;

    // A voucher order that is actually paid for. The payment matters: a virtual-item line is only
    // marked Captured once captured payment covers its amount, and the voucher job queue refuses to
    // issue anything for an uncaptured line - so an unpaid voucher order can never leave Pending.
    procedure InsertEcomDocumentWithVoucherLineAndPayment(ExternalNo: Code[20]; VoucherTypeCode: Code[20]; CustomerNo: Code[20]; ExternalPaymentMethodCode: Code[50]; Amount: Decimal; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Body: JsonObject;
        Lines: JsonArray;
        Line: JsonObject;
        Payments: JsonArray;
        Payment: JsonObject;
    begin
        Body := BuildEcomDocumentBody(ExternalNo, 'order', CustomerNo);
        Line.Add('type', 'voucher');
        Line.Add('voucherType', VoucherTypeCode);
        Line.Add('description', 'Test gift voucher');
        Line.Add('quantity', 1);
        Line.Add('unitPrice', Amount);
        Line.Add('vatPercent', 0);
        Line.Add('lineAmount', Amount);
        Lines.Add(Line);
        Body.Add('salesDocumentLines', Lines);

        Payment.Add('paymentMethodType', 'paymentGateway');
        Payment.Add('paymentReference', ExternalNo);
        Payment.Add('paymentAmount', Amount);
        Payment.Add('externalPaymentMethodCode', ExternalPaymentMethodCode);
        Payments.Add(Payment);
        Body.Add('payments', Payments);

        SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);
    end;

    // An item that the API will classify as a coupon line, wired to an enabled ON-ECOM-SALE coupon type.
    // Every piece here is load-bearing, and the failure mode when one is missing is silence rather than an
    // error - EcomCreateCouponImpl.IsCouponItem simply returns false, the API classifies the line as a plain
    // item, "Coupons Exist" stays false, and the coupon job queue never sees the document at all:
    //   * the coupon MODULE row must exist, or the coupon type's field relation rejects the module code
    //   * "Issue Coupon Module" must be ON-ECOM-SALE; an ON-ATTRACTION-WALLET type outside a wallet bundle is
    //     rejected by the API instead
    //   * the type must be Enabled and carry a Reference No. Pattern - CreateDiscountAmountCouponType sets
    //     both ('[S]')
    //   * the NpDc Iss.OnEcomSale S.Line row is what makes the item recognisable as a coupon item
    // So a test using this should assert "Coupons Exist" straight after the API insert.
    //
    // The coupon type code is GENERATED. A fixed one would be silently adopted and rewritten by a second
    // caller of this library - which nine test codeunits consume - taking the first caller's coupon
    // semantics with it. The module row is shared by design: its code is the product's own module
    // identifier, so it is get-or-created rather than generated.
    procedure CreateEcomCouponItem(var CouponType: Record "NPR NpDc Coupon Type") ItemNo: Code[20]
    var
        CouponModule: Record "NPR NpDc Coupon Module";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryRandom: Codeunit "Library - Random";
        OnEcomSaleCouponModule: Codeunit "NPR OnEcomSaleCouponModule";
    begin
        LibraryCoupon.CreateCouponSetup();

        if not CouponModule.Get(CouponModule.Type::"Issue Coupon", OnEcomSaleCouponModule.ModuleCode()) then begin
            CouponModule.Init();
            CouponModule.Type := CouponModule.Type::"Issue Coupon";
            CouponModule.Code := OnEcomSaleCouponModule.ModuleCode();
            CouponModule.Description := 'Issue Coupon - Ecommerce Sale';
            CouponModule.Insert();
        end;

        LibraryCoupon.CreateDiscountAmountCouponType(CopyStr('ECOMCPN' + LibraryRandom.RandText(10), 1, MaxStrLen(CouponType.Code)), CouponType, 10);
        CouponType."Issue Coupon Module" := OnEcomSaleCouponModule.ModuleCode();
        CouponType.Modify();

        ItemNo := CreateEcomCouponItemForType(CouponType.Code);
    end;

    // The item half on its own, for a caller that has already built the coupon type it wants to test with -
    // specifically a type this helper would never create, such as one carrying an unsupported issue module.
    // That is the whole reason the two halves are separate: a single procedure that always creates an
    // ON-ECOM-SALE type could not serve the negative tests.
    //
    // No "does this mapping already exist" guard, deliberately. ItemNo is minted immediately above, so a row
    // for it cannot exist; a guard would only be able to hide a fixture collision that should fail loudly.
    procedure CreateEcomCouponItemForType(CouponTypeCode: Code[20]) ItemNo: Code[20]
    var
        EcomSalesCouponSetupLine: Record "NPR NpDc Iss.OnEcomSale S.Line";
        LibraryInventory: Codeunit "NPR Library - Inventory";
    begin
        ItemNo := LibraryInventory.CreateItemNo();

        // FindLast before Init: Init preserves primary-key fields, and the key is ("Coupon Type", "Line No."),
        // so the found line number survives into the increment.
        EcomSalesCouponSetupLine.SetRange("Coupon Type", CouponTypeCode);
        if not EcomSalesCouponSetupLine.FindLast() then
            EcomSalesCouponSetupLine."Line No." := 0;
        EcomSalesCouponSetupLine.Init();
        EcomSalesCouponSetupLine."Coupon Type" := CouponTypeCode;
        EcomSalesCouponSetupLine."Line No." += 10000;
        EcomSalesCouponSetupLine.Type := EcomSalesCouponSetupLine.Type::Item;
        EcomSalesCouponSetupLine."No." := ItemNo;
        EcomSalesCouponSetupLine.Insert();
    end;

    // Attraction-wallet creation is gated on a setup singleton a fresh company does not have.
    // AttractionWallet.IsWalletEnabled reads WalletAssetSetup.Enabled, and CreateWalletAssetHeader simply
    // returns false when it is off - so CreateWallet yields entry no. 0 and the caller then fails trying to look
    // that wallet up ("The Attraction Wallet does not exist ... Entry No.='0'"). Worse, the wallet job queue
    // records that failure on the LINE and leaves the header status Pending until the retry budget runs out, so
    // at header level a disabled feature is indistinguishable from a queue that never ran.
    //
    // The reference-number patterns genuinely do self-default, so Enabled is the only thing needed here.
    procedure EnableAttractionWallets(Enable: Boolean)
    var
        WalletAssetSetup: Record "NPR WalletAssetSetup";
    begin
        if not WalletAssetSetup.Get() then begin
            WalletAssetSetup.Init();
            WalletAssetSetup.Insert();
        end;
        WalletAssetSetup.Enabled := Enable;
        WalletAssetSetup.Modify();
    end;

    // A membership item the API will classify as a membership line, with the individual-membership setup that
    // ecom direct creation requires. It started as a distillation of EcomMembershipCreationTest's Initialize
    // and has since diverged deliberately: no renew / extend / upgrade variants, which are not needed to
    // issue one membership, and none of the shared demo scenario at all - see below.
    //
    // Everything here is this fixture's OWN - generated codes, its own community, its own membership - and
    // it shares nothing with the member module's demo scenario. That matters for a helper on a library nine
    // test codeunits consume: fixed codes make a second caller silently adopt and rewrite the first
    // caller's setup, and touching the demo scenario's community would change shared fixture data under
    // every other membership test in the same codeunit. MemberModuleLib.Initialize() is all that is needed
    // from the shared library - it supplies the posting setup and the MS-DEMO01 / MM-DEMO01 / MM-PK20
    // number series the calls below draw on.
    //
    // The community is relaxed to NONE identity / NA logon as a deliberate SCOPE reduction, not because an
    // ecom order could not satisfy the SetupCommunity_Simple defaults - it could, since EMAIL identity only
    // requires a non-blank Member Email (EcomCreateMMShipImpl.ValidateMembershipRequestForDirectCreation)
    // and the paid-membership helper always sends one. Relaxing keeps member matching and logon creation
    // out of a test whose subject is the job queue chain. SSN is the only identity ecom genuinely refuses.
    //
    // An INDIVIDUAL membership is built here because the shared demo scenario only offers GROUP ones, and
    // ecom direct creation needs an individual membership with cardinality 1.
    //
    // Unlike coupons, nothing here fails silently: every gate errors at API insert
    // (EcomCreateMMShipImpl.ValidateMembershipRequestForDirectCreation), so a missing piece is diagnosable
    // from the message.
    procedure CreateEcomMembershipItem() ItemNo: Code[20]
    var
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberModuleLib: Codeunit "NPR Library - Member Module";
        CommunityCode: Code[20];
        MembershipCode: Code[20];
    begin
        MemberModuleLib.Initialize();

        CommunityCode := MemberModuleLib.SetupCommunity_Simple();
        MemberCommunity.Get(CommunityCode);
        MemberCommunity."Member Unique Identity" := MemberCommunity."Member Unique Identity"::NONE;
        MemberCommunity."Member Logon Credentials" := MemberCommunity."Member Logon Credentials"::NA;
        MemberCommunity.Modify();

        MembershipCode := MemberModuleLib.GenerateCode20();
        MemberModuleLib.SetupMembership_Simple(CommunityCode, MembershipCode, '', 'Ecom Async Individual Membership');
        MembershipSetup.Get(MembershipCode);
        MembershipSetup."Membership Type" := MembershipSetup."Membership Type"::INDIVIDUAL;
        MembershipSetup."Membership Member Cardinality" := 1;
        MembershipSetup.Modify();

        ItemNo := MemberModuleLib.CreateItem(MemberModuleLib.GenerateCode20(), '', 'Ecom Async Membership Item', 100);
        MemberModuleLib.SetupSimpleMembershipSalesItem(ItemNo, MembershipCode);

        // LibraryMemberModule.CreateItem builds an item through Library - Inventory, then reassigns "No." and
        // Inserts again - so the Item Unit of Measure rows stay behind on the auto-numbered original and the
        // item under the requested No. has a base unit of measure with no matching row. Nothing notices until something builds
        // a sales line from it, which only conversion does; that is why the existing membership tests, which call
        // the implementation directly, never hit it. Supply the missing rows rather than changing that shared
        // library out from under them.
        EnsureItemUnitOfMeasureExists(ItemNo);

        MembershipSalesSetup.SetRange("Membership Code", MembershipCode);
        if MembershipSalesSetup.FindFirst() then begin
            MembershipSalesSetup.Blocked := false;
            MembershipSalesSetup.Modify();
        end;
    end;

    // Both the base and the sales unit of measure, since the sales line takes whichever the item specifies.
    local procedure EnsureItemUnitOfMeasureExists(ItemNo: Code[20])
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        EnsureItemUnitOfMeasure(ItemNo, Item."Base Unit of Measure");
        EnsureItemUnitOfMeasure(ItemNo, Item."Sales Unit of Measure");
    end;

    local procedure EnsureItemUnitOfMeasure(ItemNo: Code[20]; UnitOfMeasureCode: Code[10])
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if UnitOfMeasureCode = '' then
            exit;
        if ItemUnitOfMeasure.Get(ItemNo, UnitOfMeasureCode) then
            exit;
        ItemUnitOfMeasure.Init();
        ItemUnitOfMeasure."Item No." := ItemNo;
        ItemUnitOfMeasure.Code := UnitOfMeasureCode;
        ItemUnitOfMeasure."Qty. per Unit of Measure" := 1;
        ItemUnitOfMeasure.Insert();
    end;

    // A membership order that is actually paid for. The existing InsertEcomDocumentWithMemberData sends an EMPTY
    // payments array, so capture has nothing to settle and the membership job queue's `Captured = true` line
    // filter starves without a word - which is exactly why the existing membership tests set Captured by hand and
    // call the implementation directly. This variant carries a gateway payment so the real chain can run.
    // Line amount is fixed at 100 by AddMembershipLineJsonWithMemberData, so pass a matching Amount.
    procedure InsertEcomDocumentWithMembershipLineAndPayment(ExternalNo: Code[20]; ItemNo: Code[20]; CustomerNo: Code[20]; ExternalPaymentMethodCode: Code[50]; Amount: Decimal; MemberEmail: Text; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Body: JsonObject;
        Lines: JsonArray;
        Payments: JsonArray;
        Payment: JsonObject;
        NoExistingMembership: Guid;
    begin
        Body := BuildEcomDocumentBody(ExternalNo, 'order', CustomerNo);
        AddMembershipLineJsonWithMemberData(Lines, ItemNo, NoExistingMembership, 'Async', 'Tester', MemberEmail, 1);
        Body.Add('salesDocumentLines', Lines);

        Payment.Add('paymentMethodType', 'paymentGateway');
        Payment.Add('paymentReference', ExternalNo);
        Payment.Add('paymentAmount', Amount);
        Payment.Add('externalPaymentMethodCode', ExternalPaymentMethodCode);
        Payments.Add(Payment);
        Body.Add('payments', Payments);

        SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);
    end;

    // An ITEM order that is actually paid for. The payment is what lets the capture job queue settle the
    // document and mark its lines Captured, and every virtual-item job queue refuses to issue anything for an
    // uncaptured line - so a ticket/membership/coupon/wallet item order needs this rather than the unpaid
    // helpers above. The line is a plain 'item'; which asset it becomes is decided by the item's own setup,
    // classified by the API in TrySetItemSubtype.
    procedure InsertEcomDocumentWithItemLineAndPayment(ExternalNo: Code[20]; ItemNo: Code[20]; CustomerNo: Code[20]; ExternalPaymentMethodCode: Code[50]; Amount: Decimal; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Body: JsonObject;
        Lines: JsonArray;
        Line: JsonObject;
        Payments: JsonArray;
        Payment: JsonObject;
    begin
        Body := BuildEcomDocumentBody(ExternalNo, 'order', CustomerNo);
        Line.Add('type', 'item');
        Line.Add('no', ItemNo);
        Line.Add('quantity', 1);
        Line.Add('unitPrice', Amount);
        Line.Add('vatPercent', 0);
        Line.Add('lineAmount', Amount);
        Lines.Add(Line);
        Body.Add('salesDocumentLines', Lines);

        Payment.Add('paymentMethodType', 'paymentGateway');
        Payment.Add('paymentReference', ExternalNo);
        Payment.Add('paymentAmount', Amount);
        Payment.Add('externalPaymentMethodCode', ExternalPaymentMethodCode);
        Payments.Add(Payment);
        Body.Add('payments', Payments);

        SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);
    end;

    // Runs one of the ecommerce job queue codeunits for a single pass, the way its scheduled entry
    // would, scoped to the bucket of the document under test. Three details decide whether this
    // proves anything:
    //   * the entry must be INSERTED. Every one of these job queues calls
    //     EcomJobManagement.ShouldSoftExit(JobQueueEntry.ID) first, which returns true when it
    //     cannot Get its own entry - so an in-memory record makes the job exit having done nothing
    //     and the calling test pass for no reason at all.
    //   * "Recurring Job" must be false. The loop runs `until (not "Recurring Job") or
    //     DurationLimitReached(...)`, so a recurring entry polls for six hours.
    //   * the pass must be ISOLATED to one document. Bucket Id is the only discriminator EVERY one of
    //     these queues accepts from the parameter string: the two conversion queues also read a
    //     salesOrderNo / salesReturnOrderNo filter (EcomSalesOrderProcJQ, EcomSalesRetOrderProcJQ), but
    //     the five asset queues and the notification queue read nothing but the bucket, so it is the one
    //     lever that works for all of them. A scheduled entry passes 'bucket=1..100' - every document in
    //     the company - which in a test means the pass also processes whatever other tests left Pending,
    //     burning their retries and moving their statuses. So the document is given a bucket of its own
    //     first (see IsolateInOwnBucket) and the pass is filtered to exactly that.
    //
    // What isolation COSTS, recorded here once rather than in each caller. With a single document in
    // scope, a passing END-TO-END test shows that the document is eligible - that it survives the queue's
    // selection. It cannot show the selection is not too wide: a queue whose filters were dropped outright
    // would still find this one document, and every asset test would stay green. So do not read a green
    // end-to-end test as cover for the queue's filters.
    //
    // Exclusion is covered separately, by handing a pass a single INELIGIBLE document and asserting it was
    // left alone. Two of those tests catch a WIDENED selection as well, not merely a narrowed one, because
    // they assert Process Retry Count = 0 and EcomSalesDocProcess.HandleResponse increments that for every
    // attempted run BEFORE it looks at success - so a document the queue should have skipped but did not
    // cannot come back at zero:
    //   * ConversionJobQueueSkipsDocumentWithUnprocessedVirtualItems - the virtual-item gate
    //   * OrderJobQueueIgnoresReturnOrders - Document Type
    // A widening regression along either dimension turns those red.
    //
    // What stays uncaught in the widening direction: the five asset queues' own filters, the digital-
    // notification queue's four, and conversion's remaining dimensions - Creation Status, the retry
    // ceiling, the bucket range. For capture status it is uncatchable in principle rather than merely
    // untested: DeclinedGatewayCaptureIssuesNoVoucherAndDoesNotConvert cannot attribute the exclusion to
    // the voucher queue's filter at all, because CreateVouchers re-checks capture status itself and exits
    // without leaving a trace.
    procedure RunEcomJobQueueOnce(CodeunitId: Integer; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
    begin
        IsolateInOwnBucket(EcomSalesHeader);
        // Format(..., 0, 9) rather than Format(...): the filter is machine-consumed, so it must not
        // pick up locale formatting.
        RunJobQueueOnceWithParameters(CodeunitId, EcomJobManagement.ParamBucketFilter() + '=' + Format(EcomSalesHeader."Bucket Id", 0, 9));
    end;

    // Sweeps every eligible document in the company, using the exact parameter string production writes
    // (EcomJobManagement.CreateParameterSting, the same value ScheduleJobQueue stores). Use this ONLY in a
    // test that is deliberately about the sweep itself - the production 'bucket=1..100' range syntax, or the
    // contract that one failing document must not stop the pass. Every other test wants the scoped overload:
    // this one will also process documents other tests left Pending. Note that documents already isolated by
    // RunEcomJobQueueOnce sit above bucket 100 and are therefore invisible to this sweep.
    procedure RunEcomJobQueueOnceUnscoped(CodeunitId: Integer)
    var
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
    begin
        RunJobQueueOnceWithParameters(CodeunitId, EcomJobManagement.CreateParameterSting());
    end;

    local procedure RunJobQueueOnceWithParameters(CodeunitId: Integer; ParameterString: Text)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueRan: Boolean;
        JobQueueError: Text;
        JobQueueFailedErr: Label 'Job queue codeunit %1 failed: %2', Comment = '%1 = codeunit id, %2 = error text', Locked = true;
    begin
        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := CodeunitId;
        JobQueueEntry."Parameter String" := CopyStr(ParameterString, 1, MaxStrLen(JobQueueEntry."Parameter String"));
        JobQueueEntry."Recurring Job" := false;
        JobQueueEntry.Insert();
        Commit();

        // Capture the outcome rather than calling Run bare. The entry above is COMMITTED, so an uncaught
        // error would skip the cleanup and leave the row visible to every later test method in this
        // codeunit - BC keeps running the remaining methods after one fails, and both
        // EcomJobManagement.ScheduleJobQueue and UPGEcomSalesDocs.UpgradeEcomJQ FindFirst on exactly this
        // filter, so they would adopt the orphan as an already-scheduled job. Delete first, then re-raise,
        // so the failure still reaches the test with its original message.
        // (The row does not outlive the codeunit: TestIsolation = Codeunit reverts even committed writes.)
        JobQueueRan := Codeunit.Run(CodeunitId, JobQueueEntry);
        // Capture the call stack, not just the text. Re-raising below necessarily reports this
        // library as the throw site, so without the original stack a CI-only failure tells you
        // what broke but not where - and where is the whole reason to run the job queue in a test.
        if not JobQueueRan then
            JobQueueError := GetLastErrorText() + '\' + GetLastErrorCallStack();

        if JobQueueEntry.Get(JobQueueEntry.ID) then
            JobQueueEntry.Delete();
        Commit();

        if not JobQueueRan then
            Error(JobQueueFailedErr, CodeunitId, JobQueueError);
    end;

    // Moves the document into a bucket no other document can occupy, so a job queue pass filtered to that
    // bucket touches this document and nothing else.
    //
    // Why not just filter on the bucket the product assigned? Because AssignBucketLines picks Random(100),
    // so an unrelated document shares it roughly 1 time in 100 per document - and a cross-test failure that
    // appears 1 run in 100 is worse to diagnose than one that happens every time. Offsetting past 100 puts
    // the document beyond the range any real assignment can produce, and Entry No. is unique, so the
    // resulting bucket is unique too. Nothing in the product constrains Bucket Id to 1..100: every consumer
    // either SetFilters on it or checks it against 0.
    // The record is refreshed from the database on entry and is NOT refreshed after the pass, so a caller
    // must re-Get before asserting on header fields the job queue wrote.
    local procedure IsolateInOwnBucket(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        DigitalOrderNotifMgt: Codeunit "NPR Digital Order Notif. Mgt.";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        EntryNoTooLargeErr: Label 'Ecom document Entry No. %1 cannot be offset into an Integer Bucket Id.', Locked = true;
    begin
        if EcomSalesHeader."Entry No." > 2000000000 then
            Error(EntryNoTooLargeErr, EcomSalesHeader."Entry No.");

        // Re-read before writing. Callers run several job queues in sequence and each one modifies the
        // header, so the caller's copy is stale by the second call - modifying it as-is would roll back
        // the status and retry-count fields the previous pass just wrote.
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        EcomSalesHeader."Bucket Id" := 100 + EcomSalesHeader."Entry No.";
        EcomSalesHeader.Modify();

        // Move every copy of the bucket, or the document ends up internally inconsistent. AssignBucketId
        // establishes header = virtual-item lines = notification entries, and two of those are separate rows:
        //   * the LINES. AssignBucketLines stamps them first and the header takes their value, applying
        //     SetVirtualItemSubtypeFilter - so the same filter is applied here rather than stamping every
        //     line. No product code reads the line field today, but EcomSalesLine key Key3 includes it, so a
        //     future line-level bucket scan would otherwise find an isolated header with no lines.
        //   * the notification ENTRIES, because the digital-notification job queue filters on theirs.
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomVirtualItemMgt.SetVirtualItemSubtypeFilter(EcomSalesLine);
        EcomSalesLine.ModifyAll("Bucket Id", EcomSalesHeader."Bucket Id");

        DigitalOrderNotifMgt.SyncBucketIdToNotifEntry(EcomSalesHeader);
    end;

    // Returns every setup singleton this library can change - incoming ecom documents, digital
    // notifications and attraction wallets - to its as-installed state, so a test starts from a known
    // configuration rather than from whatever the previous test left committed.
    //
    // Call this on ENTRY, never as trailing cleanup. AL has no finally, so a failing assertion skips
    // anything after it - the same reason the payment-gateway mock is disarmed mid-test rather than at the
    // end. Restoring on exit would work only for tests that pass, which is the wrong half.
    //
    // Deleting is the cleanest baseline: every reader treats a missing row as defaults. That holds in the
    // test app, here and in the sibling FastLane codeunits, and in the product for the wallet singleton,
    // where all eight read sites spell `if not Setup.Get() then Setup.Init()` - see
    // AttractionWallet.IsWalletEnabled. So the next use sees Init() defaults whether or not the row exists.
    //
    // Keep this list in step with the enable/disable helpers below. A singleton a helper can switch on but
    // this cannot switch back leaks into every later method of the same codeunit, because isolation rolls
    // back per codeunit, not per method - which is the whole reason this procedure exists.
    //
    // This cannot be an OnRun trigger. The build gate injects its own OnRun into every changed test
    // codeunit to force feature-flag state, and refuses outright if one already exists - so declaring one
    // here would break `gate full`.
    procedure ResetEcomSetupToDefaults()
    var
        DigitalNotifSetup: Record "NPR Digital Notification Setup";
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        WalletAssetSetup: Record "NPR WalletAssetSetup";
    begin
        IncEcomSalesDocSetup.DeleteAll();
        DigitalNotifSetup.DeleteAll();
        WalletAssetSetup.DeleteAll();
    end;

    // Get-or-create the setup singleton. A fresh company has no row, so a test that needs a
    // specific setup value cannot simply Get() it.
    procedure GetIncEcomSalesDocSetup(var IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup")
    begin
        if not IncEcomSalesDocSetup.Get() then begin
            IncEcomSalesDocSetup.Init();
            IncEcomSalesDocSetup.Insert();
        end;
    end;

    procedure SetCustomerMappingByCustomerNo()
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        GetIncEcomSalesDocSetup(IncEcomSalesDocSetup);
        IncEcomSalesDocSetup."Customer Mapping" := IncEcomSalesDocSetup."Customer Mapping"::"Customer No.";
        IncEcomSalesDocSetup.Modify();
    end;

    // Pinned rather than assumed: the retry budget decides whether the first failure leaves the
    // document Pending or terminates it as Error, and the container's value is not the test's to guess.
    procedure SetMaxDocProcessRetryCount(MaxRetryCount: Integer)
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        GetIncEcomSalesDocSetup(IncEcomSalesDocSetup);
        IncEcomSalesDocSetup."Max Doc Process Retry Count" := MaxRetryCount;
        IncEcomSalesDocSetup.Modify();
    end;

    // Same reasoning as the document retry budget, for the capture leg. It decides both which documents
    // the capture job queue picks up (it filters Capture Retry Count <= this) and whether a failure leaves
    // the document retryable or terminally Error.
    procedure SetMaxCaptureRetryCount(MaxRetryCount: Integer)
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        GetIncEcomSalesDocSetup(IncEcomSalesDocSetup);
        IncEcomSalesDocSetup."Max Capture Retry Count" := MaxRetryCount;
        IncEcomSalesDocSetup.Modify();
    end;

    // Whether conversion releases the sales return order it produced. Off by default, so a test that does
    // not set this exercises the not-released branch.
    procedure SetReleaseSalesReturnOrderAfterProcessing(Release: Boolean)
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        GetIncEcomSalesDocSetup(IncEcomSalesDocSetup);
        IncEcomSalesDocSetup."Release Sale Ret Ord After Prc" := Release;
        IncEcomSalesDocSetup.Modify();
    end;

    // Order confirmations need BOTH the flag and a non-blank template id - see
    // DigitalOrderNotifMgt.ValidateOrderConfirmationSetup - so the flag alone switches the feature either
    // way. Hence: enabling only supplies a placeholder id when none is configured, so a consumer that set
    // up a real template keeps it; and disabling leaves the id alone rather than destroying that config.
    // The template record itself is never read, only its id tested for presence, so a placeholder suffices.
    procedure EnableEcomOrderConfirmation(Enable: Boolean)
    var
        DigitalNotifSetup: Record "NPR Digital Notification Setup";
    begin
        if not DigitalNotifSetup.Get() then begin
            DigitalNotifSetup.Init();
            DigitalNotifSetup.Insert();
        end;
        DigitalNotifSetup."Send Ecom Order Confirmation" := Enable;
        if Enable and (DigitalNotifSetup."Ecom Order Confirm Template Id" = '') then
            DigitalNotifSetup."Ecom Order Confirm Template Id" := 'OCTEST';
        // Pinned above zero so EcomDigitalNotifJQ's `Attempt Count < Max Attempts` filter is actually applied -
        // at zero the job queue skips that filter entirely, and a test running the queue would not exercise it.
        if DigitalNotifSetup."Max Attempts" <= 0 then
            DigitalNotifSetup."Max Attempts" := 3;
        DigitalNotifSetup.Modify();
    end;


    // Uniqueness comes from the random tail, not from Prefix - Prefix only marks which suite created
    // the document, which matters when a run leaves strays behind. Keep it short: the result is
    // truncated to the External No. length, and a long prefix would eat into the random part.
    procedure NextExternalNo(Prefix: Code[10]) ExternalNo: Code[20]
    var
        LibraryRandom: Codeunit "Library - Random";
    begin
        ExternalNo := CopyStr(Prefix + LibraryRandom.RandText(10), 1, MaxStrLen(ExternalNo));
    end;

    procedure CreateItem(): Code[20]
    var
        Item: Record Item;
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        LibraryInventory.CreateItem(Item);
        exit(Item."No.");
    end;

    // SIDE EFFECT: this also switches the company-wide ecom setup singleton to Customer Mapping
    // ::"Customer No.". It has to - processing must reuse the customer created here, which has complete
    // posting groups, instead of creating a bare one from the (missing) customer templates. A test whose
    // scenario depends on a different Customer Mapping must set it AFTER calling this, or not use it.
    procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
        LibrarySales: Codeunit "Library - Sales";
    begin
        SetCustomerMappingByCustomerNo();
        LibrarySales.CreateCustomer(Customer);
        exit(Customer."No.");
    end;

    // Counts every form the created sales document can take. CheckIfDocumentCanBeProcessed guards against
    // duplicates across these same three tables, so this is the same notion of "one document" the product uses.
    procedure CountSalesDocumentsFor(EcomSalesHeader: Record "NPR Ecom Sales Header"): Integer
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        SalesInvoiceHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        SalesCrMemoHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        exit(SalesHeader.Count() + SalesInvoiceHeader.Count() + SalesCrMemoHeader.Count());
    end;

    // A payment method captured the way a live order is: through a payment gateway. The capture job
    // queue calls the gateway, and only a successful capture marks the payment line captured - which
    // is in turn what marks a virtual-item line Captured, without which the voucher job queue skips it.
    //
    // "Captured Externally" is deliberately left false. That flag stamps Date Captured at insert time
    // and the gateway leg never runs, so a test using it would prove nothing about capture. No live
    // ecommerce customer is configured that way; the gateway in production is Adyen.
    procedure CreateGatewayCapturedPaymentMapping(): Code[50]
    var
        PaymentMapping: Record "NPR Magento Payment Mapping";
        LibraryMagento: Codeunit "NPR Library - Magento";
        LibraryPaymentGateway: Codeunit "NPR Library - Payment Gateway";
        LibraryRandom: Codeunit "Library - Random";
        PaymentCode: Code[50];
    begin
        PaymentCode := CopyStr('ECOMPAY' + LibraryRandom.RandText(10), 1, MaxStrLen(PaymentCode));
        LibraryMagento.CreatePaymentMapping(PaymentCode, '');
        PaymentMapping.SetRange("External Payment Method Code", PaymentCode);
        PaymentMapping.FindFirst();
        PaymentMapping."Payment Gateway Code" := LibraryPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration");
        PaymentMapping.Modify();
        exit(PaymentCode);
    end;

    procedure CreateFCYCurrency(var Currency: Record Currency; ExchangeRate: Decimal)
    var
        GLSetup: Record "General Ledger Setup";
        LibraryERM: Codeunit "Library - ERM";
    begin
        GLSetup.Get();
        repeat
            LibraryERM.CreateCurrency(Currency);
        until Currency.Code <> GLSetup."LCY Code"; // Ensure the created currency differs from LCY
        Currency.InitRoundingPrecision();
        Currency.Modify();

        LibraryERM.CreateExchangeRate(Currency.Code, WorkDate(), ExchangeRate, ExchangeRate);
    end;

    procedure CreateFCYCurrencyFixedBoth(var Currency: Record Currency; ExchRateAmount: Decimal; RelationalExchRateAmount: Decimal)
    var
        GLSetup: Record "General Ledger Setup";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        LibraryERM: Codeunit "Library - ERM";
    begin
        GLSetup.Get();
        repeat
            LibraryERM.CreateCurrency(Currency);
        until Currency.Code <> GLSetup."LCY Code"; // Ensure the created currency differs from LCY
        Currency.InitRoundingPrecision();
        Currency.Modify();

        // Seed a Currency Exchange Rate row with Fix Exchange Rate Amount = Both so the platform's ExchangeAmtFCYToLCY computes
        // the amount from the row's fixed amounts and ignores any factor passed in - the case the conversion guard must catch.
        LibraryERM.CreateExchangeRate(Currency.Code, WorkDate(), ExchRateAmount, RelationalExchRateAmount);
        CurrencyExchangeRate.Get(Currency.Code, WorkDate());
        CurrencyExchangeRate."Fix Exchange Rate Amount" := CurrencyExchangeRate."Fix Exchange Rate Amount"::Both;
        CurrencyExchangeRate."Exchange Rate Amount" := ExchRateAmount;
        CurrencyExchangeRate."Relational Exch. Rate Amount" := RelationalExchRateAmount;
        CurrencyExchangeRate."Adjustment Exch. Rate Amount" := ExchRateAmount;
        CurrencyExchangeRate."Relational Adjmt Exch Rate Amt" := RelationalExchRateAmount;
        CurrencyExchangeRate.Modify(true);
    end;
}
#endif
