codeunit 85577 "NPR Library Ecom Doc Api"
{
    Access = Internal;

    var
        _Assert: Codeunit "Assert";
        _LibEcom: Codeunit "NPR Library Ecommerce";
        _LibAPI: Codeunit "NPR Library - NPRetail API";
        _LibDimension: Codeunit "Library - Dimension";
        _LibPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _EcomApiPermissionSetLbl: Label 'NPR API Ecom', Locked = true;
        _ApiVersionHeaderLbl: Label 'x-api-version', Locked = true;
        _DocumentsPathLbl: Label 'ecommerce/documents', Locked = true;
        _CustomFieldsLbl: Label 'customFields', Locked = true;
        _ForeignCompanyLbl: Label 'VERSIONING OTHER CO', Locked = true;
        _FullDocumentNoteLbl: Label 'Please leave the parcel at the back door.', Locked = true;
        _RootKeysLbl: Label 'externalNo,id,documentType,creationStatus,postingStatus,currencyCode,currencyExchangeRate,externalDocumentNo,yourReference,languageTag,locationCode,pricesExcludingVat,ticketReservationToken,captureProcessingStatus,lastCaptureErrorMessage,createdAt,createdDocumentNo,postedDocumentNos,sellToCustomer,shipToCustomer,shipment,dimensions,comments,payments,salesDocumentLines', Locked = true;
        _PaymentKeysLbl: Label 'id,paymentMethodType,externalPaymentMethodCode,externalPaymentType,paymentReference,paymentAmount,pspToken,cardExpiryDate,cardBrand,maskedCardNumber,parToken,cardAliasToken,capturedPaymentAmount,paymentFees', Locked = true;
        _LineBaseKeysLbl: Label 'id,type,no,variantCode,barcodeNo,description,unitPrice,quantity,unitOfMeasure,vatPercent,lineAmount,requestedDeliveryDate,invoicedQuantity,invoicedAmount,captured,virtualItemProcessStatus,virtualItemProcessErrorMessage,attractionWalletProcessStatus,attractionWalletProcessErrorMessage,ticketReservationLineId,membershipId,membershipOperation,memberFirstName,memberLastName,memberMiddleName,memberEmail,memberPhoneNo,memberBirthday,memberGender,memberAddress,memberCity,memberCountry,memberPostCode,memberNewsletter,memberGdprApproval,membershipActivationDate,subscription,issuedAssets', Locked = true;
        _CommentKeysLbl: Label 'id,comment', Locked = true;
        _EnvelopeKeysLbl: Label 'salesDocuments,morePages,nextPageKey,nextPageURL', Locked = true;
        _SummaryKeysLbl: Label 'externalNo,id,documentType,creationStatus,postingStatus,currencyCode,externalDocumentNo,captureProcessingStatus,createdAt,createdDocumentNo,postedDocumentNos,sellToCustomer', Locked = true;
        _SummarySellToKeysLbl: Label 'no,name,email,phone', Locked = true;
        _EmptyRootKeysLbl: Label 'externalNo,id,documentType,creationStatus,postingStatus,currencyCode,currencyExchangeRate,externalDocumentNo,yourReference,languageTag,locationCode,pricesExcludingVat,ticketReservationToken,captureProcessingStatus,lastCaptureErrorMessage,createdAt,createdDocumentNo,postedDocumentNos,sellToCustomer,shipToCustomer,shipment', Locked = true;
        _ShipToKeysLbl: Label 'name,address,address2,postCode,county,city,countryCode,contact', Locked = true;
        _ShipmentKeysLbl: Label 'shipmentMethod,shipmentService', Locked = true;
        _IssuedAssetKeysLbl: Label 'id,type,referenceNo', Locked = true;
        _DimensionKeysLbl: Label 'code,valueCode', Locked = true;
        _V3SellToKeysLbl: Label 'no,name,address,address2,postCode,county,city,countryCode,contact,email,phone,ean,vatRegistrationNo,invoiceEmail,customerTemplate,configurationTemplate', Locked = true;
        _V3BlankLineBaseKeysLbl: Label 'id,type,no,variantCode,barcodeNo,description,unitPrice,quantity,unitOfMeasure,vatPercent,lineAmount,invoicedQuantity,invoicedAmount,captured,virtualItemProcessStatus,virtualItemProcessErrorMessage,attractionWalletProcessStatus,attractionWalletProcessErrorMessage,ticketReservationLineId,membershipId,membershipOperation,memberFirstName,memberLastName,memberMiddleName,memberEmail,memberPhoneNo,memberGender,memberAddress,memberCity,memberCountry,memberPostCode,memberNewsletter,memberGdprApproval,subscription,issuedAssets', Locked = true;
        _FullDocumentCustomerTemplateLbl: Label 'VERS-CUST-TMPL', Locked = true;
        _FullDocumentConfigTemplateLbl: Label 'VERSCFG01', Locked = true;
        _LineAExternalIdLbl: Label 'VERSIONING-LINE-A', Locked = true;
        _AtContextLbl: Label '%1 (%2)', Locked = true;
        _VoucherTypeCode: Code[20];
        _VoucherNoSeries: Code[20];

    procedure CreateFullDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        VoucherType: Record "NPR NpRv Voucher Type";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        Body: JsonObject;
        LineA: JsonObject;
        LineB: JsonObject;
        LineC: JsonObject;
        Lines: JsonArray;
        Payments: JsonArray;
        Comments: JsonArray;
        Comment: JsonObject;
        HeaderDimensions: JsonArray;
        LineDimensions: JsonArray;
        ExternalNo: Code[20];
        ItemNo: Code[20];
    begin
        EnsureVoucherType(VoucherType);
        ItemNo := _LibEcom.CreateItem();
        ExternalNo := _LibEcom.NextExternalNo('VERFULL');
        Body := HeaderBody(ExternalNo, NewEmail());

        HeaderDimensions.Add(NewDimensionJson());
        Body.Add('dimensions', HeaderDimensions);

        Comment.Add('comment', _FullDocumentNoteLbl);
        Comments.Add(Comment);
        Body.Add('comments', Comments);

        LineA := ItemLineJson(ItemNo, 100);
        LineA.Add('externalLineId', _LineAExternalIdLbl);
        LineDimensions.Add(NewDimensionJson());
        LineA.Add('dimensions', LineDimensions);
        Lines.Add(LineA);

        LineB := ItemLineJson(ItemNo, 50);
        LineB.Add('externalLineId', 'VERSIONING-LINE-B');
        LineB.Add('parentExternalLineId', _LineAExternalIdLbl);
        Lines.Add(LineB);

        LineC.Add('type', 'voucher');
        LineC.Add('voucherType', VoucherType.Code);
        LineC.Add('description', 'Versioning gift voucher');
        LineC.Add('quantity', 1);
        LineC.Add('unitPrice', 100);
        LineC.Add('vatPercent', 0);
        LineC.Add('lineAmount', 100);
        Lines.Add(LineC);
        Body.Add('salesDocumentLines', Lines);

        Payments.Add(CardPaymentJson(ExternalNo, 250));
        Body.Add('payments', Payments);

        _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);

        EcomSalesHeader."Customer Template" := _FullDocumentCustomerTemplateLbl;
        EcomSalesHeader."Configuration Template" := _FullDocumentConfigTemplateLbl;
        EcomSalesHeader.Modify();

        EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesPmtLine.FindFirst();

        FindLine(EcomSalesHeader, 1, EcomSalesLine);
        EcomSalesLine."Requested Delivery Date" := 20260304D;
        EcomSalesLine."Member Birthday" := 19900517D;
        EcomSalesLine."Membership Activation Date" := 20260401D;
        EcomSalesLine."Virtual Item Process Status" := EcomSalesLine."Virtual Item Process Status"::Processed;
        EcomSalesLine."Attr. Wallet Processing Status" := EcomSalesLine."Attr. Wallet Processing Status"::Error;
        EcomSalesLine."Created From Pmt. Line Id" := EcomSalesPmtLine.SystemId;
        EcomSalesLine.Modify();

        // Voucher issuance requires a captured line.
        FindLine(EcomSalesHeader, 3, EcomSalesLine);
        EcomSalesLine.Captured := true;
        EcomSalesLine.Modify();
        VchrImpl.Process(EcomSalesLine);

        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        Commit();
    end;

    procedure CreateParityDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        CreateFullDocument(EcomSalesHeader);
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.FindSet();
        repeat
            if EcomSalesLine."Requested Delivery Date" = 0D then
                EcomSalesLine."Requested Delivery Date" := 20260305D;
            if EcomSalesLine."Member Birthday" = 0D then
                EcomSalesLine."Member Birthday" := 19850212D;
            if EcomSalesLine."Membership Activation Date" = 0D then
                EcomSalesLine."Membership Activation Date" := 20260402D;
            if not (EcomSalesLine."Virtual Item Process Status" in [EcomSalesLine."Virtual Item Process Status"::Processed, EcomSalesLine."Virtual Item Process Status"::Error]) then
                EcomSalesLine."Virtual Item Process Status" := EcomSalesLine."Virtual Item Process Status"::Error;
            if not (EcomSalesLine."Attr. Wallet Processing Status" in [EcomSalesLine."Attr. Wallet Processing Status"::Processed, EcomSalesLine."Attr. Wallet Processing Status"::Error]) then
                EcomSalesLine."Attr. Wallet Processing Status" := EcomSalesLine."Attr. Wallet Processing Status"::Processed;
            EcomSalesLine.Modify();
        until EcomSalesLine.Next() = 0;
        Commit();
    end;

    procedure CreateEmptyDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Body: JsonObject;
        Lines: JsonArray;
        Payments: JsonArray;
        ExternalNo: Code[20];
    begin
        ExternalNo := _LibEcom.NextExternalNo('VEREMPTY');
        Body := HeaderBody(ExternalNo, NewEmail());
        Body.Add('salesDocumentLines', Lines);
        Body.Add('payments', Payments);
        _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);
        Commit();
    end;

    procedure CreateDocument(Email: Text; PaymentCount: Integer; LineCount: Integer; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Body: JsonObject;
        Lines: JsonArray;
        Payments: JsonArray;
        ExternalNo: Code[20];
        ItemNo: Code[20];
        i: Integer;
    begin
        ExternalNo := _LibEcom.NextExternalNo('VERDOC');
        Body := HeaderBody(ExternalNo, Email);
        if LineCount > 0 then
            ItemNo := _LibEcom.CreateItem();
        for i := 1 to LineCount do
            Lines.Add(ItemLineJson(ItemNo, 100));
        Body.Add('salesDocumentLines', Lines);
        for i := 1 to PaymentCount do
            Payments.Add(CardPaymentJson(ExternalNo + '-' + Format(i), 100));
        Body.Add('payments', Payments);
        _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);
        Commit();
    end;

    // A note that belongs to another company: Record Link is shared across companies, and the note
    // carries the header's own Record ID.
    procedure AddForeignCompanyNote(EcomSalesHeader: Record "NPR Ecom Sales Header"; NoteText: Text)
    var
        RecordLink: Record "Record Link";
        RecordLinkManagement: Codeunit "Record Link Management";
    begin
        RecordLink.Init();
        RecordLink."Record ID" := EcomSalesHeader.RecordId;
        RecordLink.Type := RecordLink.Type::Note;
        RecordLink.Company := _ForeignCompanyLbl;
        RecordLink.Created := CurrentDateTime();
        RecordLink."User ID" := CopyStr(UserId(), 1, MaxStrLen(RecordLink."User ID"));
        RecordLink.Insert(true);
        RecordLinkManagement.WriteNote(RecordLink, NoteText);
        RecordLink.Modify();
        Commit();
    end;

    procedure GetById(DocumentId: Guid; ApiVersion: Text; SendHeader: Boolean) Response: JsonObject
    var
        Body: JsonObject;
        QueryParameters: Dictionary of [Text, Text];
    begin
        Commit();
        Response := _LibAPI.CallApi('GET', _DocumentsPathLbl + '/' + LowerCase(Format(DocumentId, 0, 4)), Body, QueryParameters, VersionHeaders(ApiVersion, SendHeader));
    end;

    procedure Find(QueryParameters: Dictionary of [Text, Text]; ApiVersion: Text; SendHeader: Boolean) Response: JsonObject
    var
        Body: JsonObject;
    begin
        Commit();
        Response := _LibAPI.CallApi('GET', _DocumentsPathLbl, Body, QueryParameters, VersionHeaders(ApiVersion, SendHeader));
    end;

    procedure BodyOf(Response: JsonObject): JsonObject
    begin
        exit(_LibAPI.GetResponseBody(Response));
    end;

    procedure StatusOf(Response: JsonObject): Integer
    var
        Token: JsonToken;
    begin
        if Response.Get('statusCode', Token) then
            exit(Token.AsValue().AsInteger());
    end;

    // Ignore subscriber-defined customFields when checking the API's standard keys.
    procedure KeysOf(Object: JsonObject) KeyList: Text
    var
        KeyName: Text;
    begin
        foreach KeyName in Object.Keys() do
            if KeyName <> _CustomFieldsLbl then begin
                if KeyList <> '' then
                    KeyList += ',';
                KeyList += KeyName;
            end;
    end;

    procedure WithoutCustomFields(Body: JsonObject) BodyText: Text
    var
        Stripped: JsonToken;
    begin
        Stripped := Body.Clone();
        RemoveCustomFields(Stripped);
        Stripped.WriteTo(BodyText);
    end;

    procedure HasCustomFieldsAnywhere(Body: JsonObject): Boolean
    begin
        exit(ContainsCustomFields(Body.AsToken()));
    end;

    procedure AssertNoEmptyCustomFields(Body: JsonObject; Context: Text)
    begin
        CheckNoEmptyCustomFields(Body.AsToken(), Context);
    end;

    // Use only with get-by-id bodies; find summaries lack the version markers.
    procedure VersionOf(Body: JsonObject): Text
    var
        Token: JsonToken;
        SellToCustomer: JsonObject;
    begin
        if Body.Get('sellToCustomer', Token) then
            if Token.IsObject() then begin
                SellToCustomer := Token.AsObject();
                if SellToCustomer.Contains('type') then
                    exit('V1');
                if SellToCustomer.Contains('customerTemplate') then
                    exit('V3');
            end;
        exit('V2');
    end;

    procedure ObjectAt(Object: JsonObject; KeyName: Text): JsonObject
    begin
        exit(TokenAt(Object, KeyName).AsObject());
    end;

    procedure ArrayAt(Object: JsonObject; KeyName: Text): JsonArray
    begin
        exit(TokenAt(Object, KeyName).AsArray());
    end;

    procedure TextAt(Object: JsonObject; KeyName: Text): Text
    begin
        exit(TokenAt(Object, KeyName).AsValue().AsText());
    end;

    procedure ElementAt(Elements: JsonArray; Index: Integer): JsonObject
    var
        Token: JsonToken;
    begin
        Elements.Get(Index, Token);
        exit(Token.AsObject());
    end;

    procedure FullDocumentNote(): Text
    begin
        exit(_FullDocumentNoteLbl);
    end;

    procedure RootKeys(): Text
    begin
        exit(_RootKeysLbl);
    end;

    procedure PaymentKeys(): Text
    begin
        exit(_PaymentKeysLbl);
    end;

    procedure CommentKeys(): Text
    begin
        exit(_CommentKeysLbl);
    end;

    procedure LineBaseKeys(): Text
    begin
        exit(_LineBaseKeysLbl);
    end;

    procedure EnvelopeKeys(): Text
    begin
        exit(_EnvelopeKeysLbl);
    end;

    procedure SummaryKeys(): Text
    begin
        exit(_SummaryKeysLbl);
    end;

    procedure SummarySellToKeys(): Text
    begin
        exit(_SummarySellToKeysLbl);
    end;

    procedure GrantApiPermission()
    begin
        _LibAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), CopyStr(_EcomApiPermissionSetLbl, 1, 20));
    end;

    procedure EmptyRootKeys(): Text
    begin
        exit(_EmptyRootKeysLbl);
    end;

    procedure ShipToKeys(): Text
    begin
        exit(_ShipToKeysLbl);
    end;

    procedure ShipmentKeys(): Text
    begin
        exit(_ShipmentKeysLbl);
    end;

    procedure IssuedAssetKeys(): Text
    begin
        exit(_IssuedAssetKeysLbl);
    end;

    procedure DimensionKeys(): Text
    begin
        exit(_DimensionKeysLbl);
    end;

    procedure V3SellToKeys(): Text
    begin
        exit(_V3SellToKeysLbl);
    end;

    procedure V3BlankLineBaseKeys(): Text
    begin
        exit(_V3BlankLineBaseKeysLbl);
    end;

    procedure GetSalesDocumentTextV2(EcomSalesHeader: Record "NPR Ecom Sales Header"): Text
    var
        GetV2: Codeunit "NPR EcomSalesDocGetV2";
    begin
        exit(GetV2.GetSalesDocumentJsonObject(EcomSalesHeader).BuildAsText());
    end;

    procedure GetSalesDocumentTextV3(EcomSalesHeader: Record "NPR Ecom Sales Header"): Text
    var
        GetV3: Codeunit "NPR EcomSalesDocGetV3";
    begin
        exit(GetV3.GetSalesDocumentJsonObject(EcomSalesHeader).BuildAsText());
    end;

    procedure GetByIdBody(DocumentId: Guid; ApiVersion: Text): JsonObject
    var
        Response: JsonObject;
    begin
        Response := GetById(DocumentId, ApiVersion, true);
        _Assert.AreEqual(200, StatusOf(Response), At('A get by id of an existing document must answer HTTP 200.', 'x-api-version ' + ApiVersion));
        exit(BodyOf(Response));
    end;

    procedure FindBody(Email: Text; WithDetails: Boolean; ApiVersion: Text): JsonObject
    var
        Response: JsonObject;
        QueryParameters: Dictionary of [Text, Text];
    begin
        QueryParameters.Add('email', Email);
        if WithDetails then
            QueryParameters.Add('withDetails', 'true');
        Response := Find(QueryParameters, ApiVersion, true);
        _Assert.AreEqual(200, StatusOf(Response), At('A find must answer HTTP 200.', 'x-api-version ' + ApiVersion));
        exit(BodyOf(Response));
    end;

    procedure PostDocument(ExternalNo: Code[20]; ApiVersion: Text) Response: JsonObject
    var
        Body: JsonObject;
        Line: JsonObject;
        Lines: JsonArray;
        Payments: JsonArray;
        QueryParameters: Dictionary of [Text, Text];
    begin
        Body := _LibEcom.BuildEcomDocumentBody(ExternalNo, 'order', '');
        Line.Add('type', 'item');
        Line.Add('no', _LibEcom.CreateItem());
        Line.Add('quantity', 1);
        Line.Add('unitPrice', 100);
        Line.Add('vatPercent', 0);
        Line.Add('lineAmount', 100);
        Lines.Add(Line);
        Body.Add('salesDocumentLines', Lines);
        Body.Add('payments', Payments);
        Commit();
        Response := _LibAPI.CallApi('POST', _DocumentsPathLbl, Body, QueryParameters, VersionHeaders(ApiVersion, true));
    end;

    procedure AssertFullDocumentPinnedV3(Body: JsonObject; WithPayments: Boolean; Context: Text)
    var
        SellToCustomer: JsonObject;
        Payment: JsonObject;
        Fee: JsonObject;
        Comment: JsonObject;
        LineA: JsonObject;
        LineB: JsonObject;
        LineC: JsonObject;
        IssuedAsset: JsonObject;
        Lines: JsonArray;
        ExpectedRootKeys: Text;
    begin
        ExpectedRootKeys := _RootKeysLbl;
        if not WithPayments then
            ExpectedRootKeys := ExpectedRootKeys.Replace(',payments,', ',');
        _Assert.AreEqual(ExpectedRootKeys, KeysOf(Body), At('Root keys', Context));

        SellToCustomer := ObjectAt(Body, 'sellToCustomer');
        _Assert.AreEqual(_V3SellToKeysLbl, KeysOf(SellToCustomer), At('sellToCustomer keys', Context));
        _Assert.AreEqual(_FullDocumentCustomerTemplateLbl, TextAt(SellToCustomer, 'customerTemplate'), At('sellToCustomer customerTemplate', Context));
        _Assert.AreEqual(_FullDocumentConfigTemplateLbl, TextAt(SellToCustomer, 'configurationTemplate'), At('sellToCustomer configurationTemplate', Context));
        _Assert.AreEqual(_ShipToKeysLbl, KeysOf(ObjectAt(Body, 'shipToCustomer')), At('shipToCustomer keys', Context));
        _Assert.AreEqual(_ShipmentKeysLbl, KeysOf(ObjectAt(Body, 'shipment')), At('shipment keys', Context));
        _Assert.AreEqual(_DimensionKeysLbl, KeysOf(SingleObjectAt(Body, 'dimensions', Context)), At('Header dimension keys', Context));

        Comment := SingleObjectAt(Body, 'comments', Context);
        _Assert.AreEqual(_CommentKeysLbl, KeysOf(Comment), At('Comment keys', Context));
        _Assert.AreEqual(_FullDocumentNoteLbl, TextAt(Comment, 'comment'), At('Comment text', Context));

        Lines := ArrayAt(Body, 'salesDocumentLines');
        _Assert.AreEqual(3, Lines.Count(), At('The document must answer its three lines.', Context));
        LineA := ElementAt(Lines, 0);
        LineB := ElementAt(Lines, 1);
        LineC := ElementAt(Lines, 2);

        if WithPayments then begin
            Payment := SingleObjectAt(Body, 'payments', Context);
            _Assert.AreEqual(_PaymentKeysLbl, KeysOf(Payment), At('Payment keys', Context));
            Fee := SingleObjectAt(Payment, 'paymentFees', Context);
            _Assert.AreEqual('paymentFeeId', KeysOf(Fee), At('Payment fee keys', Context));
            _Assert.AreEqual(TextAt(LineA, 'id'), TextAt(Fee, 'paymentFeeId'), At('The payment fee must point at line A.', Context));
        end;

        _Assert.AreEqual(_LineBaseKeysLbl + ',externalLineId,dimensions', KeysOf(LineA), At('Line A keys', Context));
        _Assert.AreEqual(_LineAExternalIdLbl, TextAt(LineA, 'externalLineId'), At('Line A externalLineId', Context));
        _Assert.AreEqual(_DimensionKeysLbl, KeysOf(SingleObjectAt(LineA, 'dimensions', Context)), At('Line A dimension keys', Context));
        _Assert.AreEqual('2026-03-04', TextAt(LineA, 'requestedDeliveryDate'), At('Line A requestedDeliveryDate', Context));
        _Assert.AreEqual('1990-05-17', TextAt(LineA, 'memberBirthday'), At('Line A memberBirthday', Context));
        _Assert.AreEqual('2026-04-01', TextAt(LineA, 'membershipActivationDate'), At('Line A membershipActivationDate', Context));
        _Assert.AreEqual('processed', TextAt(LineA, 'virtualItemProcessStatus'), At('Line A virtualItemProcessStatus', Context));
        _Assert.AreEqual('error', TextAt(LineA, 'attractionWalletProcessStatus'), At('Line A attractionWalletProcessStatus', Context));

        _Assert.AreEqual(_V3BlankLineBaseKeysLbl + ',externalLineId,parentExternalLineId', KeysOf(LineB), At('Line B keys', Context));
        _Assert.AreEqual(_LineAExternalIdLbl, TextAt(LineB, 'parentExternalLineId'), At('Line B parentExternalLineId', Context));
        _Assert.AreEqual('', TextAt(LineB, 'virtualItemProcessStatus'), At('Line B virtualItemProcessStatus', Context));
        _Assert.AreEqual('', TextAt(LineB, 'attractionWalletProcessStatus'), At('Line B attractionWalletProcessStatus', Context));

        _Assert.AreEqual(_V3BlankLineBaseKeysLbl, KeysOf(LineC), At('Line C keys', Context));
        _Assert.AreEqual('', TextAt(LineC, 'virtualItemProcessStatus'), At('Line C virtualItemProcessStatus', Context));
        _Assert.AreEqual('', TextAt(LineC, 'attractionWalletProcessStatus'), At('Line C attractionWalletProcessStatus', Context));
        IssuedAsset := SingleObjectAt(LineC, 'issuedAssets', Context);
        _Assert.AreEqual(_IssuedAssetKeysLbl, KeysOf(IssuedAsset), At('Issued asset keys', Context));
        _Assert.AreEqual('voucher', TextAt(IssuedAsset, 'type'), At('Issued asset type', Context));
    end;

    procedure AssertDetailedHitEqualsGetById(EcomSalesHeader: Record "NPR Ecom Sales Header"; ApiVersion: Text)
    var
        GetBody: JsonObject;
        Hit: JsonObject;
        Hits: JsonArray;
        Context: Text;
    begin
        Context := 'x-api-version ' + ApiVersion;
        GetBody := GetByIdBody(EcomSalesHeader.SystemId, ApiVersion).Clone().AsObject();
        _Assert.IsTrue(GetBody.Contains('payments'), At('The get-by-id document must carry payments for the comparison to mean anything.', Context));
        GetBody.Remove('payments');

        Hits := ArrayAt(FindBody(EcomSalesHeader."Sell-to Email", true, ApiVersion), 'salesDocuments');
        _Assert.AreEqual(1, Hits.Count(), At('The e-mail must find exactly the seeded document.', Context));
        Hit := ElementAt(Hits, 0);
        _Assert.IsFalse(Hit.Contains('payments'), At('A detailed hit must not carry payments.', Context));
        _Assert.AreEqual(WithoutCustomFields(GetBody), WithoutCustomFields(Hit), At('A detailed hit must equal the get-by-id document without payments.', Context));
    end;

    procedure SingleObjectAt(Object: JsonObject; KeyName: Text; Context: Text): JsonObject
    var
        Elements: JsonArray;
    begin
        Elements := ArrayAt(Object, KeyName);
        _Assert.AreEqual(1, Elements.Count(), At(KeyName + ' must hold exactly one entry.', Context));
        exit(ElementAt(Elements, 0));
    end;

    procedure AssertCustomFieldsPlaced(Body: JsonObject)
    var
        Elements: JsonArray;
        RootKeyList: List of [Text];
        Position: Integer;
        i: Integer;
    begin
        RootKeyList := Body.Keys();
        Position := RootKeyList.IndexOf(_CustomFieldsLbl);
        _Assert.IsTrue(Position > 1, 'The root must carry customFields after its first key.');
        _Assert.IsTrue(Position < RootKeyList.Count(), 'The root must carry keys after customFields.');
        _Assert.AreEqual('dimensions', RootKeyList.Get(Position - 1), 'customFields must come right after dimensions in the root.');
        _Assert.AreEqual('comments', RootKeyList.Get(Position + 1), 'customFields must come right before comments in the root.');

        Elements := ArrayAt(Body, 'payments');
        for i := 0 to Elements.Count() - 1 do
            AssertCustomFieldsLast(ElementAt(Elements, i), StrSubstNo('Payment %1', i));
        Elements := ArrayAt(Body, 'salesDocumentLines');
        for i := 0 to Elements.Count() - 1 do
            AssertCustomFieldsLast(ElementAt(Elements, i), StrSubstNo('Line %1', i));
    end;

    procedure AssertBothWriters(Object: JsonObject; Context: Text)
    var
        CustomFields: JsonObject;
    begin
        CustomFields := ObjectAt(Object, _CustomFieldsLbl);
        _Assert.AreEqual(2, CustomFields.Keys().Count(), Context + ': customFields must hold exactly the two writers'' keys.');
        _Assert.IsTrue(CustomFields.Contains('writerA'), Context + ': customFields must hold writerA.');
        _Assert.IsTrue(CustomFields.Contains('writerB'), Context + ': customFields must hold writerB.');
    end;

    procedure AssertEachElementHasBothWriters(Object: JsonObject; ArrayName: Text)
    var
        Elements: JsonArray;
        i: Integer;
    begin
        Elements := ArrayAt(Object, ArrayName);
        _Assert.IsTrue(Elements.Count() > 0, ArrayName + ' must not be empty.');
        for i := 0 to Elements.Count() - 1 do
            AssertBothWriters(ElementAt(Elements, i), StrSubstNo('%1 %2', ArrayName, i));
    end;

    procedure AssertEachHitHasBothWriters(Body: JsonObject)
    var
        Hits: JsonArray;
        Hit: JsonObject;
        i: Integer;
    begin
        Hits := ArrayAt(Body, 'salesDocuments');
        _Assert.AreEqual(2, Hits.Count(), 'The e-mail must find both seeded documents.');
        for i := 0 to Hits.Count() - 1 do begin
            Hit := ElementAt(Hits, i);
            AssertBothWriters(Hit, StrSubstNo('Hit %1', i));
            AssertEachElementHasBothWriters(Hit, 'salesDocumentLines');
        end;
    end;

    procedure AssertObjectWriter(Object: JsonObject; Context: Text)
    begin
        _Assert.AreEqual('objectWriter', KeysOf(ObjectAt(Object, _CustomFieldsLbl)), Context + ': customFields must hold exactly objectWriter.');
    end;

    procedure AssertEachElementHasObjectWriter(Object: JsonObject; ArrayName: Text)
    var
        Elements: JsonArray;
        i: Integer;
    begin
        Elements := ArrayAt(Object, ArrayName);
        _Assert.IsTrue(Elements.Count() > 0, ArrayName + ' must not be empty.');
        for i := 0 to Elements.Count() - 1 do
            AssertObjectWriter(ElementAt(Elements, i), StrSubstNo('%1 %2', ArrayName, i));
    end;

    local procedure AssertCustomFieldsLast(Object: JsonObject; Context: Text)
    var
        KeyList: List of [Text];
    begin
        KeyList := Object.Keys();
        _Assert.AreEqual(_CustomFieldsLbl, KeyList.Get(KeyList.Count()), Context + ': customFields must be the last key.');
    end;

    local procedure At(Message: Text; Context: Text): Text
    begin
        exit(StrSubstNo(_AtContextLbl, Message, Context));
    end;

    // Reuse PARTIAL because recreating its number series can issue duplicate voucher numbers.
    local procedure EnsureVoucherType(var VoucherType: Record "NPR NpRv Voucher Type")
    var
        NoSeries: Record "No. Series";
    begin
        if (_VoucherTypeCode <> '') and VoucherType.Get(_VoucherTypeCode) then
            if (VoucherType."No. Series" = _VoucherNoSeries) and NoSeries.Get(_VoucherNoSeries) then
                exit;
        _LibPOSMasterData.CreatePartialVoucherType(VoucherType, false);
        VoucherType."Allow Top-up" := false;
        VoucherType.Modify();
        _VoucherTypeCode := VoucherType.Code;
        _VoucherNoSeries := VoucherType."No. Series";
    end;

    local procedure TokenAt(Object: JsonObject; KeyName: Text) Token: JsonToken
    var
        MissingKeyErr: Label 'The object must carry %1.', Locked = true;
    begin
        if not Object.Get(KeyName, Token) then
            Error(MissingKeyErr, KeyName);
    end;

    local procedure VersionHeaders(ApiVersion: Text; SendHeader: Boolean) Headers: Dictionary of [Text, Text]
    begin
        if SendHeader then
            Headers.Add(_ApiVersionHeaderLbl, ApiVersion);
    end;

    local procedure RemoveCustomFields(Token: JsonToken)
    var
        Object: JsonObject;
        Child: JsonToken;
        KeyName: Text;
    begin
        if Token.IsArray() then begin
            foreach Child in Token.AsArray() do
                RemoveCustomFields(Child);
            exit;
        end;
        if not Token.IsObject() then
            exit;
        Object := Token.AsObject();
        if Object.Contains(_CustomFieldsLbl) then
            Object.Remove(_CustomFieldsLbl);
        foreach KeyName in Object.Keys() do begin
            Object.Get(KeyName, Child);
            RemoveCustomFields(Child);
        end;
    end;

    local procedure ContainsCustomFields(Token: JsonToken): Boolean
    var
        Object: JsonObject;
        Child: JsonToken;
        KeyName: Text;
    begin
        if Token.IsArray() then begin
            foreach Child in Token.AsArray() do
                if ContainsCustomFields(Child) then
                    exit(true);
            exit(false);
        end;
        if not Token.IsObject() then
            exit(false);
        Object := Token.AsObject();
        if Object.Contains(_CustomFieldsLbl) then
            exit(true);
        foreach KeyName in Object.Keys() do begin
            Object.Get(KeyName, Child);
            if ContainsCustomFields(Child) then
                exit(true);
        end;
        exit(false);
    end;

    local procedure CheckNoEmptyCustomFields(Token: JsonToken; Context: Text)
    var
        Object: JsonObject;
        Child: JsonToken;
        KeyName: Text;
    begin
        if Token.IsArray() then begin
            foreach Child in Token.AsArray() do
                CheckNoEmptyCustomFields(Child, Context);
            exit;
        end;
        if not Token.IsObject() then
            exit;
        Object := Token.AsObject();
        foreach KeyName in Object.Keys() do begin
            Object.Get(KeyName, Child);
            if KeyName = _CustomFieldsLbl then begin
                _Assert.IsTrue(Child.IsObject(), At('customFields must be an object.', Context));
                _Assert.IsTrue(Child.AsObject().Keys().Count() > 0, At('customFields must not be empty.', Context));
            end else
                CheckNoEmptyCustomFields(Child, Context);
        end;
    end;

    local procedure HeaderBody(ExternalNo: Code[20]; Email: Text) Body: JsonObject
    var
        SellTo: JsonObject;
    begin
        SellTo.Add('name', 'Versioning Customer');
        SellTo.Add('address', 'Versioning Street 1');
        SellTo.Add('postCode', '1234');
        SellTo.Add('city', 'Versioning City');
        SellTo.Add('countryCode', 'DK');
        SellTo.Add('email', Email);
        Body.Add('externalNo', ExternalNo);
        Body.Add('documentType', 'order');
        Body.Add('sellToCustomer', SellTo);
    end;

    local procedure ItemLineJson(ItemNo: Code[20]; Amount: Decimal) Line: JsonObject
    begin
        Line.Add('type', 'item');
        Line.Add('no', ItemNo);
        Line.Add('description', 'Versioning item');
        Line.Add('quantity', 1);
        Line.Add('unitPrice', Amount);
        Line.Add('vatPercent', 0);
        Line.Add('lineAmount', Amount);
    end;

    local procedure CardPaymentJson(PaymentReference: Text; Amount: Decimal) Payment: JsonObject
    begin
        Payment.Add('paymentMethodType', 'paymentGateway');
        Payment.Add('externalPaymentMethodCode', _LibEcom.CreateGatewayCapturedPaymentMapping());
        Payment.Add('paymentReference', PaymentReference);
        Payment.Add('paymentAmount', Amount);
        Payment.Add('pspToken', 'VERSIONING-PSP-TOKEN');
        Payment.Add('cardExpiryDate', '03/2030');
        Payment.Add('cardBrand', 'visa');
        Payment.Add('maskedCardNumber', '411111******1111');
        Payment.Add('parToken', 'VERSIONING-PAR-TOKEN');
        Payment.Add('cardAliasToken', 'VERSIONING-ALIAS');
    end;

    local procedure NewDimensionJson() DimensionJson: JsonObject
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
    begin
        _LibDimension.CreateDimension(Dimension);
        _LibDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionJson.Add('code', DimensionValue."Dimension Code");
        DimensionJson.Add('valueCode', DimensionValue.Code);
    end;

    local procedure NewEmail(): Text
    begin
        exit('versioning.' + DelChr(Format(CreateGuid()), '=', '{}-').ToLower() + '@versioning.test');
    end;

    local procedure FindLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; Position: Integer; var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.FindSet();
        if Position > 1 then
            EcomSalesLine.Next(Position - 1);
    end;
}
