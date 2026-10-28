codeunit 6184582 "NPR EcomSalesDocGetV3"
{
    Access = Internal;

    internal procedure GetIncomingEcomDocumentById(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        DocumentIdText: Text;
        DocumentId: Guid;
    begin
        Request.SkipCacheIfNonStickyRequest(GetReadTableIds());
        if (not Request.Paths().Get(3, DocumentIdText)) then
            exit(Response.RespondBadRequest('Missing required parameter: documentId'));

        if (not Evaluate(DocumentId, DocumentIdText)) then
            exit(Response.RespondBadRequest('Malformed parameter: documentId'));

        EcomSalesHeader.ReadIsolation := EcomSalesHeader.ReadIsolation::ReadCommitted;
        if (not EcomSalesHeader.GetBySystemId(DocumentId)) then
            exit(Response.RespondResourceNotFound());

        exit(Response.RespondOK(GetSalesDocumentJsonObject(EcomSalesHeader)));
    end;

    // Return the stored ecommerce dimensions; the created sales document may have different effective dimensions.
    local procedure EmitDimensions(DimSetID: Integer; var IncSalesDocumentJsonObject: Codeunit "NPR Json Builder")
    var
        DimSetEntry: Record "Dimension Set Entry";
    begin
        if DimSetID = 0 then
            exit;

        DimSetEntry.SetRange("Dimension Set ID", DimSetID);
        DimSetEntry.SetLoadFields("Dimension Code", "Dimension Value Code");
        if not DimSetEntry.FindSet() then
            exit;

        IncSalesDocumentJsonObject.StartArray('dimensions');
        repeat
            IncSalesDocumentJsonObject.StartObject().AddProperty('code', DimSetEntry."Dimension Code")
                                                    .AddProperty('valueCode', DimSetEntry."Dimension Value Code")
                                                    .EndObject();
        until DimSetEntry.Next() = 0;
        IncSalesDocumentJsonObject.EndArray();
    end;

    procedure GetSalesLineApiType(EcomSalesLine: Record "NPR Ecom Sales Line") IncSalesLineTypeText: Text
    var
        UnsupportedLineTypeTextErr: Label 'Sales line type %1 is not supported.', Comment = '%1 - sales line type', Locked = true;
    begin
        case EcomSalesLine.Type of
            EcomSalesLine.Type::Item:
                IncSalesLineTypeText := 'item';
            EcomSalesLine.Type::Comment:
                IncSalesLineTypeText := 'comment';
            EcomSalesLine.Type::"Shipment Fee":
                IncSalesLineTypeText := 'shipmentFee';
            EcomSalesLine.Type::Voucher:
                IncSalesLineTypeText := 'voucher';
            else
                Error(UnsupportedLineTypeTextErr, EcomSalesLine.Type);
        end;
    end;

    local procedure GetMembershipOperationText(MembershipOperation: Enum "NPR Ecom Membership Operation") MembershipOperationText: Text
    begin
        case MembershipOperation of
            MembershipOperation::CreateMembership:
                MembershipOperationText := 'createMembership';
            MembershipOperation::ConfirmMembership:
                MembershipOperationText := 'confirmMembership';
            MembershipOperation::RenewMembership:
                MembershipOperationText := 'renewMembership';
            MembershipOperation::ExtendMembership:
                MembershipOperationText := 'extendMembership';
            MembershipOperation::UpgradeMembership:
                MembershipOperationText := 'upgradeMembership';
            else
                MembershipOperationText := '';
        end;
    end;

    internal procedure GetSalesDocumentJsonObject(EcomSalesHeader: Record "NPR Ecom Sales Header") IncSalesDocumentJsonObject: Codeunit "NPR Json Builder";
    begin
        IncSalesDocumentJsonObject.StartObject('salesDocument');
        AddSalesDocumentProperties(EcomSalesHeader, IncSalesDocumentJsonObject, true);
        IncSalesDocumentJsonObject.EndObject();
    end;

    internal procedure AddSalesDocumentProperties(EcomSalesHeader: Record "NPR Ecom Sales Header"; var IncSalesDocumentJsonObject: Codeunit "NPR Json Builder"; IncludePayments: Boolean)
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        RecordLink: Record "Record Link";
        TempEcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link" temporary;
        TempEcomSalesCouponLink: Record "NPR Ecom Sales Coupon Link" temporary;
        TempEcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link" temporary;
        EcomSalesDocApiEvents: Codeunit "NPR EcomSalesDocApiEvents";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        CouponImpl: Codeunit "NPR EcomCreateCouponImpl";
        MMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        PaymentLineJsonObject: Codeunit "NPR Json Builder";
        SalesLineJsonObject: Codeunit "NPR Json Builder";
        CommentJsonObject: Codeunit "NPR Json Builder";
        EcomSalesHeaderCustomFieldsObject: Codeunit "NPR Json Builder";
    begin
        IncSalesDocumentJsonObject.AddProperty('externalNo', EcomSalesHeader."External No.")
                                 .AddProperty('id', Format(EcomSalesHeader.SystemId, 0, 4).ToLower())
                                 .AddProperty('documentType', GetSalesDocumentApiType(EcomSalesHeader))
                                 .AddProperty('creationStatus', GetSalesDocumentCreationStatusApiType(EcomSalesHeader))
                                 .AddProperty('postingStatus', GetSalesDocumentPostingStatusApiType(EcomSalesHeader))
                                 .AddProperty('currencyCode', EcomSalesHeader."Currency Code")
                                 .AddProperty('currencyExchangeRate', EcomSalesHeader."Currency Exchange Rate")
                                 .AddProperty('externalDocumentNo', EcomSalesHeader."External Document No.")
                                 .AddProperty('yourReference', EcomSalesHeader."Your Reference")
                                 .AddProperty('languageTag', EcomSalesHeader."Language Tag")
                                 .AddProperty('locationCode', EcomSalesHeader."Location Code")
                                 .AddProperty('pricesExcludingVat', EcomSalesHeader."Price Excl. VAT")
                                 .AddProperty('ticketReservationToken', EcomSalesHeader."Ticket Reservation Token")
                                 .AddProperty('captureProcessingStatus', GetSalesDocumentCaptureProcessingStatusApiType(EcomSalesHeader))
                                 .AddProperty('lastCaptureErrorMessage', EcomSalesHeader."Last Capture Error Message")
                                 .AddProperty('createdAt', EcomSalesHeader.SystemCreatedAt)
                                 .AddProperty('createdDocumentNo', EcomSalesHeader."Created Doc No.");

        AddPostedDocumentNos(EcomSalesHeader, IncSalesDocumentJsonObject);

        IncSalesDocumentJsonObject.StartObject('sellToCustomer')
                                    .AddProperty('no', EcomSalesHeader."Sell-to Customer No.")
                                    .AddProperty('name', EcomSalesHeader."Sell-to Name")
                                    .AddProperty('address', EcomSalesHeader."Sell-to Address")
                                    .AddProperty('address2', EcomSalesHeader."Sell-to Address 2")
                                    .AddProperty('postCode', EcomSalesHeader."Sell-to Post Code")
                                    .AddProperty('county', EcomSalesHeader."Sell-to County")
                                    .AddProperty('city', EcomSalesHeader."Sell-to City")
                                    .AddProperty('countryCode', EcomSalesHeader."Sell-to Country Code")
                                    .AddProperty('contact', EcomSalesHeader."Sell-to Contact")
                                    .AddProperty('email', EcomSalesHeader."Sell-to Email")
                                    .AddProperty('phone', EcomSalesHeader."Sell-to Phone No.")
                                    .AddProperty('ean', EcomSalesHeader."Sell-to EAN")
                                    .AddProperty('vatRegistrationNo', EcomSalesHeader."Sell-to VAT Registration No.")
                                    .AddProperty('invoiceEmail', EcomSalesHeader."Sell-to Invoice Email")
                                    .AddProperty('customerTemplate', EcomSalesHeader."Customer Template")
                                    .AddProperty('configurationTemplate', EcomSalesHeader."Configuration Template")
                                .EndObject()
                                .StartObject('shipToCustomer')
                                    .AddProperty('name', EcomSalesHeader."Ship-to Name")
                                    .AddProperty('address', EcomSalesHeader."Ship-to Address")
                                    .AddProperty('address2', EcomSalesHeader."Ship-to Address 2")
                                    .AddProperty('postCode', EcomSalesHeader."Ship-to Post Code")
                                    .AddProperty('county', EcomSalesHeader."Ship-to County")
                                    .AddProperty('city', EcomSalesHeader."Ship-to City")
                                    .AddProperty('countryCode', EcomSalesHeader."Ship-to Country Code")
                                    .AddProperty('contact', EcomSalesHeader."Ship-to Contact")
                                .EndObject()
                                .StartObject('shipment')
                                    .AddProperty('shipmentMethod', EcomSalesHeader."Shipment Method Code")
                                    .AddProperty('shipmentService', EcomSalesHeader."Shipment Service")
                                .EndObject();

        EmitDimensions(EcomSalesHeader."Dimension Set ID", IncSalesDocumentJsonObject);

        EcomSalesDocApiEvents.OnGetSalesDocumentCustomFieldsJsonObject(EcomSalesHeader, EcomSalesHeaderCustomFieldsObject);
        if EcomSalesHeaderCustomFieldsObject.IsInitialized() then
            IncSalesDocumentJsonObject.AddNestedObject('customFields', EcomSalesHeaderCustomFieldsObject);

        RecordLink.Reset();
        RecordLink.SetRange("Record ID", EcomSalesHeader.RecordId);
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetAutoCalcFields(Note);
        RecordLink.SetLoadFields(Note);
        // Record Link is shared across companies, so filter notes to this company.
        RecordLink.SetRange(Company, CompanyName());
        IncSalesDocumentJsonObject.StartArray('comments');
        if RecordLink.FindSet() then
            repeat
                CommentJsonObject := CreateAddCommentDocumentDetailsJsonObject(RecordLink, IncSalesDocumentJsonObject);
                IncSalesDocumentJsonObject.AddObject(CommentJsonObject);
            until RecordLink.Next() = 0;
        IncSalesDocumentJsonObject.EndArray();

        if IncludePayments then begin
            EcomSalesPmtLine.Reset();
            EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
            if EcomSalesPmtLine.FindSet() then begin
                IncSalesDocumentJsonObject.StartArray('payments');
                repeat
                    PaymentLineJsonObject := CreateAddPaymentDocumentDetailsJsonObject(EcomSalesPmtLine, IncSalesDocumentJsonObject);
                    IncSalesDocumentJsonObject.AddObject(PaymentLineJsonObject);
                until EcomSalesPmtLine.Next() = 0;
                IncSalesDocumentJsonObject.EndArray();
            end;
        end;

        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        IncSalesDocumentJsonObject.StartArray('salesDocumentLines');
        if EcomSalesLine.FindSet() then begin
            VchrImpl.LoadDocVoucherLinks(EcomSalesHeader, TempEcomSalesVoucherLink);
            CouponImpl.LoadDocCouponLinks(EcomSalesHeader, TempEcomSalesCouponLink);
            MMShipImpl.LoadDocMembershipLinks(EcomSalesHeader, TempEcomSalesMembershipLink);

            repeat
                SalesLineJsonObject := CreateAddSalesLineDetailsJsonObject(EcomSalesHeader, EcomSalesLine, TempEcomSalesVoucherLink, TempEcomSalesCouponLink, TempEcomSalesMembershipLink, IncSalesDocumentJsonObject);
                IncSalesDocumentJsonObject.AddObject(SalesLineJsonObject);
            until EcomSalesLine.Next() = 0;
        end;
        IncSalesDocumentJsonObject.EndArray();
    end;

    // Always emitted, empty when nothing is posted yet: the contract types postedDocumentNos as an array.
    internal procedure AddPostedDocumentNos(EcomSalesHeader: Record "NPR Ecom Sales Header"; var IncSalesDocumentJsonObject: Codeunit "NPR Json Builder")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        IncSalesDocumentJsonObject.StartArray('postedDocumentNos');
        case EcomSalesHeader."Document Type" of
            EcomSalesHeader."Document Type"::Order:
                begin
                    SalesInvoiceHeader.ReadIsolation := SalesInvoiceHeader.ReadIsolation::ReadCommitted;
                    SalesInvoiceHeader.SetLoadFields("No.");
                    SalesInvoiceHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
                    if SalesInvoiceHeader.FindSet() then
                        repeat
                            IncSalesDocumentJsonObject.AddValue(SalesInvoiceHeader."No.");
                        until SalesInvoiceHeader.Next() = 0;
                end;
            EcomSalesHeader."Document Type"::"Return Order":
                begin
                    SalesCrMemoHeader.ReadIsolation := SalesCrMemoHeader.ReadIsolation::ReadCommitted;
                    SalesCrMemoHeader.SetLoadFields("No.");
                    SalesCrMemoHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
                    if SalesCrMemoHeader.FindSet() then
                        repeat
                            IncSalesDocumentJsonObject.AddValue(SalesCrMemoHeader."No.");
                        until SalesCrMemoHeader.Next() = 0;
                end;
        end;
        IncSalesDocumentJsonObject.EndArray();
    end;

    internal procedure CreateAddPaymentDocumentDetailsJsonObject(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var PaymentDocumentDetailsJsonObject: Codeunit "NPR Json Builder"): Codeunit "NPR Json Builder"
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesDocApiEvents: Codeunit "NPR EcomSalesDocApiEvents";
        PaymentDocumentDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder";
    begin
        PaymentDocumentDetailsJsonObject.StartObject()
                                        .AddProperty('id', Format(EcomSalesPmtLine.SystemId, 0, 4).ToLower())
                                        .AddProperty('paymentMethodType', GetPaymentMethodTypeJsonValue(EcomSalesPmtLine))
                                        .AddProperty('externalPaymentMethodCode', EcomSalesPmtLine."External Payment Method Code")
                                        .AddProperty('externalPaymentType', EcomSalesPmtLine."External Payment Type")
                                        .AddProperty('paymentReference', EcomSalesPmtLine."Payment Reference")
                                        .AddProperty('paymentAmount', EcomSalesPmtLine.Amount)
                                        .AddProperty('pspToken', EcomSalesPmtLine."PSP Token")
                                        .AddProperty('cardExpiryDate', EcomSalesPmtLine."Card Expiry Date")
                                        .AddProperty('cardBrand', EcomSalesPmtLine."Card Brand")
                                        .AddProperty('maskedCardNumber', EcomSalesPmtLine."Masked Card Number")
                                        .AddProperty('parToken', (EcomSalesPmtLine."PAR Token"))
                                        .AddProperty('cardAliasToken', (EcomSalesPmtLine."Card Alias Token"))
                                        .AddProperty('capturedPaymentAmount', EcomSalesPmtLine."Captured Amount");

        EcomSalesLine.SetRange("Created From Pmt. Line Id", EcomSalesPmtLine.SystemId);
        EcomSalesLine.SetLoadFields(SystemId);
        if EcomSalesLine.FindSet() then begin
            PaymentDocumentDetailsJsonObject.StartArray('paymentFees');
            repeat
                PaymentDocumentDetailsJsonObject.StartObject();
                PaymentDocumentDetailsJsonObject.AddProperty('paymentFeeId', Format(EcomSalesLine.SystemId, 0, 4).ToLower());
                PaymentDocumentDetailsJsonObject.EndObject();
            until EcomSalesLine.Next() = 0;
            PaymentDocumentDetailsJsonObject.EndArray();
        end;

        EcomSalesDocApiEvents.OnGetPaymentDocumentDetailsCustomFieldsJsonObject(EcomSalesPmtLine, PaymentDocumentDetailsCustomFieldsJsonObject);
        if PaymentDocumentDetailsCustomFieldsJsonObject.IsInitialized() then
            PaymentDocumentDetailsJsonObject.AddNestedObject('customFields', PaymentDocumentDetailsCustomFieldsJsonObject);
        PaymentDocumentDetailsJsonObject.EndObject();
    end;

    internal procedure CreateAddCommentDocumentDetailsJsonObject(RecordLink: Record "Record Link"; var CommentDocumentDetailsJsonObject: Codeunit "NPR Json Builder"): Codeunit "NPR Json Builder"
    var
        RecordLinkManagement: Codeunit "Record Link Management";
    begin
        CommentDocumentDetailsJsonObject.StartObject()
                                        .AddProperty('id', Format(RecordLink.SystemId, 0, 4).ToLower())
                                        .AddProperty('comment', RecordLinkManagement.ReadNote(RecordLink));
        CommentDocumentDetailsJsonObject.EndObject();
    end;

    internal procedure CreateAddSalesLineDetailsJsonObject(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var TempEcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link" temporary; var TempEcomSalesCouponLink: Record "NPR Ecom Sales Coupon Link" temporary; var TempEcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link" temporary; var SalesLineDetailsJsonObject: Codeunit "NPR Json Builder"): Codeunit "NPR Json Builder"
    var
        EcomSalesDocApiEvents: Codeunit "NPR EcomSalesDocApiEvents";
        SalesLineDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder";
    begin
        SalesLineDetailsJsonObject.StartObject()
                                  .AddProperty('id', Format(EcomSalesLine.SystemId, 0, 4).ToLower())
                                  .AddProperty('type', GetSalesLineApiType(EcomSalesLine))
                                  .AddProperty('no', EcomSalesLine."No.")
                                  .AddProperty('variantCode', EcomSalesLine."Variant Code")
                                  .AddProperty('barcodeNo', EcomSalesLine."Barcode No.")
                                  .AddProperty('description', EcomSalesLine.Description)
                                  .AddProperty('unitPrice', EcomSalesLine."Unit Price")
                                  .AddProperty('quantity', EcomSalesLine.Quantity)
                                  .AddProperty('unitOfMeasure', Format(EcomSalesLine."Unit of Measure Code", 0, 9))
                                  .AddProperty('vatPercent', EcomSalesLine."VAT %")
                                  .AddProperty('lineAmount', EcomSalesLine."Line Amount");
        AddDateIfSet(SalesLineDetailsJsonObject, 'requestedDeliveryDate', EcomSalesLine."Requested Delivery Date");
        SalesLineDetailsJsonObject.AddProperty('invoicedQuantity', EcomSalesLine."Invoiced Qty.")
                                  .AddProperty('invoicedAmount', EcomSalesLine."Invoiced Amount")
                                  .AddProperty('captured', EcomSalesLine.Captured);
        AddProcessStatus(SalesLineDetailsJsonObject, 'virtualItemProcessStatus', EcomSalesLine."Virtual Item Process Status");
        SalesLineDetailsJsonObject.AddProperty('virtualItemProcessErrorMessage', EcomSalesLine."Virtual Item Process ErrMsg");
        AddProcessStatus(SalesLineDetailsJsonObject, 'attractionWalletProcessStatus', EcomSalesLine."Attr. Wallet Processing Status");
        SalesLineDetailsJsonObject.AddProperty('attractionWalletProcessErrorMessage', EcomSalesLine."Attr. Wallet Process ErrMsg")
                                  .AddProperty('ticketReservationLineId', Format(EcomSalesLine."Ticket Reservation Line Id", 0, 4).ToLower())
                                  .AddProperty('membershipId', Format(EcomSalesLine."Membership Id", 0, 4).ToLower())
                                  .AddProperty('membershipOperation', GetMembershipOperationText(EcomSalesLine."Membership Operation"))
                                  .AddProperty('memberFirstName', EcomSalesLine."Member First Name")
                                  .AddProperty('memberLastName', EcomSalesLine."Member Last Name")
                                  .AddProperty('memberMiddleName', EcomSalesLine."Member Middle Name")
                                  .AddProperty('memberEmail', EcomSalesLine."Member Email")
                                  .AddProperty('memberPhoneNo', EcomSalesLine."Member Phone No.");
        AddDateIfSet(SalesLineDetailsJsonObject, 'memberBirthday', EcomSalesLine."Member Birthday");
        SalesLineDetailsJsonObject.AddProperty('memberGender', EcomSalesLine."Member Gender")
                                  .AddProperty('memberAddress', EcomSalesLine."Member Address")
                                  .AddProperty('memberCity', EcomSalesLine."Member City")
                                  .AddProperty('memberCountry', EcomSalesLine."Member Country")
                                  .AddProperty('memberPostCode', EcomSalesLine."Member Post Code")
                                  .AddProperty('memberNewsletter', EcomSalesLine."Member Newsletter")
                                  .AddProperty('memberGdprApproval', EcomSalesLine."Member GDPR Approval");
        AddDateIfSet(SalesLineDetailsJsonObject, 'membershipActivationDate', EcomSalesLine."Membership Activation Date");
        SalesLineDetailsJsonObject.AddProperty('subscription', EcomSalesLine.Subscription);

        AppendIssuedAssetsArray(EcomSalesHeader, EcomSalesLine, TempEcomSalesVoucherLink, TempEcomSalesCouponLink, TempEcomSalesMembershipLink, SalesLineDetailsJsonObject);

        if (EcomSalesLine."External Line ID" <> '') or (EcomSalesLine."Parent Ext. Line ID" <> '') then begin
            SalesLineDetailsJsonObject.AddProperty('externalLineId', EcomSalesLine."External Line ID");
            if EcomSalesLine."Parent Ext. Line ID" <> '' then
                SalesLineDetailsJsonObject.AddProperty('parentExternalLineId', EcomSalesLine."Parent Ext. Line ID");
        end;

        EmitDimensions(EcomSalesLine."Dimension Set ID", SalesLineDetailsJsonObject);

        EcomSalesDocApiEvents.OnCreateAddSalesLineDetailsCustomFieldsJsonObject(EcomSalesLine, SalesLineDetailsCustomFieldsJsonObject);
        if SalesLineDetailsCustomFieldsJsonObject.IsInitialized() then
            SalesLineDetailsJsonObject.AddNestedObject('customFields', SalesLineDetailsCustomFieldsJsonObject);
        SalesLineDetailsJsonObject.EndObject();
    end;

    local procedure AppendIssuedAssetsArray(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var TempEcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link" temporary; var TempEcomSalesCouponLink: Record "NPR Ecom Sales Coupon Link" temporary; var TempEcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link" temporary; var SalesLineDetailsJsonObject: Codeunit "NPR Json Builder")
    var
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
        TicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        CouponImpl: Codeunit "NPR EcomCreateCouponImpl";
        MMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        TempWallet: Record "NPR AttractionWallet" temporary;
        TempTicket: Record "NPR TM Ticket" temporary;
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        TempMembership: Record "NPR MM Membership" temporary;
    begin
        SalesLineDetailsJsonObject.StartArray('issuedAssets');

        if EcomSalesLine."Is Attraction Wallet" then begin
            WalletMgt.BuildWalletTempBufferForLine(EcomSalesLine, TempWallet);
            if TempWallet.FindSet() then
                repeat
                    SalesLineDetailsJsonObject.StartObject()
                                              .AddProperty('id', Format(TempWallet.SystemId, 0, 4).ToLower())
                                              .AddProperty('type', 'wallet')
                                              .AddProperty('referenceNo', TempWallet.ReferenceNumber)
                                              .EndObject();
                until TempWallet.Next() = 0;
        end;

        case EcomSalesLine.Subtype of
            EcomSalesLine.Subtype::Ticket:
                begin
                    TicketImpl.BuildTicketTempBufferForLine(EcomSalesLine, TempTicket);
                    if TempTicket.FindSet() then
                        repeat
                            SalesLineDetailsJsonObject.StartObject()
                                                      .AddProperty('id', Format(TempTicket.SystemId, 0, 4).ToLower())
                                                      .AddProperty('type', 'ticket')
                                                      .AddProperty('referenceNo', TempTicket."External Ticket No.")
                                                      .EndObject();
                        until TempTicket.Next() = 0;
                end;
            EcomSalesLine.Subtype::Voucher:
                begin
                    VchrImpl.BuildVoucherTempBufferForLine(EcomSalesHeader, EcomSalesLine, TempEcomSalesVoucherLink, TempVoucher);
                    if TempVoucher.FindSet() then
                        repeat
                            SalesLineDetailsJsonObject.StartObject()
                                                      .AddProperty('id', Format(TempVoucher.SystemId, 0, 4).ToLower())
                                                      .AddProperty('type', 'voucher')
                                                      .AddProperty('referenceNo', TempVoucher."Reference No.")
                                                      .EndObject();
                        until TempVoucher.Next() = 0;
                end;
            EcomSalesLine.Subtype::Coupon:
                begin
                    CouponImpl.BuildCouponTempBufferForLine(EcomSalesLine, TempEcomSalesCouponLink, TempCoupon);
                    if TempCoupon.FindSet() then
                        repeat
                            SalesLineDetailsJsonObject.StartObject()
                                                      .AddProperty('id', Format(TempCoupon.SystemId, 0, 4).ToLower())
                                                      .AddProperty('type', 'coupon')
                                                      .AddProperty('referenceNo', TempCoupon."Reference No.")
                                                      .EndObject();
                        until TempCoupon.Next() = 0;
                end;
            EcomSalesLine.Subtype::Membership:
                begin
                    MMShipImpl.BuildMembershipTempBufferForLine(EcomSalesHeader, EcomSalesLine, TempEcomSalesMembershipLink, TempMembership);
                    if TempMembership.FindSet() then
                        repeat
                            SalesLineDetailsJsonObject.StartObject()
                                                      .AddProperty('id', Format(TempMembership.SystemId, 0, 4).ToLower())
                                                      .AddProperty('type', 'membership')
                                                      .AddProperty('referenceNo', TempMembership."External Membership No.")
                                                      .EndObject();
                        until TempMembership.Next() = 0;
                end;
        end;

        SalesLineDetailsJsonObject.EndArray();
    end;

    local procedure GetPaymentMethodTypeJsonValue(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line") PaymentMethodTypeJsonValue: Text
    var
        NotSupportedStatusErrorLbl: Label 'Payment Method Type: %1 is not supported.', Comment = '%1 - Payment Method Type', Locked = true;
    begin
        case EcomSalesPmtLine."Payment Method Type" of
            EcomSalesPmtLine."Payment Method Type"::"Payment Method":
                PaymentMethodTypeJsonValue := 'paymentGateway';
            EcomSalesPmtLine."Payment Method Type"::Voucher:
                PaymentMethodTypeJsonValue := 'voucher';
            else
                Error(NotSupportedStatusErrorLbl, EcomSalesPmtLine."Payment Method Type");
        end;
    end;

    internal procedure GetSalesDocumentCreationStatusApiType(EcomSalesHeader: Record "NPR Ecom Sales Header") SalesDocumenttatusApiType: Text
    var
        NotSupportedStatusErrorLbl: Label 'Sales document creation status: %1 is not supported.', Comment = '%1 - status', Locked = true;
    begin
        case EcomSalesHeader."Creation Status" of
            EcomSalesHeader."Creation Status"::Created:
                SalesDocumenttatusApiType := 'created';
            EcomSalesHeader."Creation Status"::Error:
                SalesDocumenttatusApiType := 'error';
            EcomSalesHeader."Creation Status"::Pending:
                SalesDocumenttatusApiType := 'pending';
            EcomSalesHeader."Creation Status"::Canceled:
                SalesDocumenttatusApiType := 'canceled';
            else
                Error(NotSupportedStatusErrorLbl, EcomSalesHeader."Creation Status");
        end;
    end;

    internal procedure GetSalesDocumentApiType(EcomSalesHeader: Record "NPR Ecom Sales Header") SalesDocumentApiType: Text
    begin
        case EcomSalesHeader."Document Type" of
            EcomSalesHeader."Document Type"::Order:
                SalesDocumentApiType := 'order';
            EcomSalesHeader."Document Type"::"Return Order":
                SalesDocumentApiType := 'returnOrder';
        end;
    end;

    internal procedure GetSalesDocumentPostingStatusApiType(EcomSalesHeader: Record "NPR Ecom Sales Header") SalesDocumentStatusApiType: Text
    var
        NotSupportedStatusErrorLbl: Label 'Sales document posting status: %1 is not supported.', Comment = '%1 - status', Locked = true;
    begin
        case EcomSalesHeader."Posting Status" of
            EcomSalesHeader."Posting Status"::"Partially Invoiced":
                SalesDocumentStatusApiType := 'partiallyInvoiced';
            EcomSalesHeader."Posting Status"::Invoiced:
                SalesDocumentStatusApiType := 'invoiced';
            EcomSalesHeader."Posting Status"::Pending:
                SalesDocumentStatusApiType := 'pending';
            else
                Error(NotSupportedStatusErrorLbl, EcomSalesHeader."Posting Status");
        end;
    end;

    internal procedure GetReadTableIds() TableIds: List of [Integer]
    begin
        TableIds.Add(Database::"NPR Ecom Sales Pmt. Line");
        TableIds.Add(Database::"NPR Ecom Sales Line");
        TableIds.Add(Database::"NPR Ecom Sales Header");
        TableIds.Add(Database::"Sales Invoice Header");
        TableIds.Add(Database::"Sales Cr.Memo Header");
    end;

    internal procedure GetSalesDocumentCaptureProcessingStatusApiType(EcomSalesHeader: Record "NPR Ecom Sales Header") CaptureProcessingStatus: Text
    begin
        case EcomSalesHeader."Capture Processing Status" of
            EcomSalesHeader."Capture Processing Status"::Error:
                CaptureProcessingStatus := 'error';
            EcomSalesHeader."Capture Processing Status"::"Partially Processed":
                CaptureProcessingStatus := 'partiallyProcessed';
            EcomSalesHeader."Capture Processing Status"::Processed:
                CaptureProcessingStatus := 'processed';
            EcomSalesHeader."Capture Processing Status"::Pending:
                CaptureProcessingStatus := 'pending';
        end;
    end;

    local procedure AddDateIfSet(var JsonBuilder: Codeunit "NPR Json Builder"; PropertyName: Text; Value: Date)
    begin
        if Value <> 0D then
            JsonBuilder.AddProperty(PropertyName, Format(Value, 0, 9));
    end;

    // The API enum requires an empty string for the blank AL status.
    local procedure AddProcessStatus(var JsonBuilder: Codeunit "NPR Json Builder"; PropertyName: Text; ProcessingStatus: Enum "NPR EcomVirtualItemProcestatus")
    begin
        if ProcessingStatus = ProcessingStatus::" " then
            JsonBuilder.AddProperty(PropertyName, '')
        else
            JsonBuilder.AddProperty(PropertyName, GetVirtualItemProcessStatusApiType(ProcessingStatus));
    end;

    local procedure GetVirtualItemProcessStatusApiType(ProcessingStatus: Enum "NPR EcomVirtualItemProcestatus"): Text
    var
        Result: Text;
    begin
        ProcessingStatus.Names().Get(ProcessingStatus.Ordinals().IndexOf(ProcessingStatus.AsInteger()), Result);
        exit(Result.ToLower());
    end;
}
