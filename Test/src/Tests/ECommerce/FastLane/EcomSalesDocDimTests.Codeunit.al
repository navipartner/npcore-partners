#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85345 "NPR Ecom Sales Doc Dim Tests"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";
        _LibEcom: Codeunit "NPR Library Ecommerce";
        _LibraryDimension: Codeunit "Library - Dimension";
        _LibraryInventory: Codeunit "Library - Inventory";
        _LibrarySales: Codeunit "Library - Sales";
        _LibraryRandom: Codeunit "Library - Random";
        _SubscriberDimSetID: Integer;

    [Test]
    procedure LineDimensionsParsedOnCreate()
    var
        DimensionValue: Record "Dimension Value";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        // [Scenario] Dimensions sent on a sales line of the create-document request are validated and stored on the ecom sales line.
        // [Given] a dimension value, supplied as a dimension on the sales line
        CreateDimensionWithValue(DimensionValue);
        LineDims.Add(DimJson(DimensionValue."Dimension Code", DimensionValue.Code));

        // [When] the document is created through the API
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', CreateItem(), '', HeaderDims, LineDims, EcomSalesHeader);

        // [Then] the ecom sales line carries a dimension set holding that value
        GetEcomLine(EcomSalesHeader, EcomSalesLine);
        _Assert.AreNotEqual(0, EcomSalesLine."Dimension Set ID", 'Line dimension set should be assigned');
        _Assert.AreEqual(DimensionValue.Code, GetDimSetValue(EcomSalesLine."Dimension Set ID", DimensionValue."Dimension Code"), 'Line dimension value mismatch');
    end;

    [Test]
    procedure LineDimensionsNotAnArrayError()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Body: JsonObject;
        Lines: JsonArray;
        Line: JsonObject;
        ExternalNo: Code[20];
    begin
        // [Scenario] A dimensions property that is not an array is refused, and the error identifies which line carried it.
        // [Given] a sales line whose dimensions property is a string instead of an array
        ExternalNo := NextExternalNo();
        Body := _LibEcom.BuildEcomDocumentBody(ExternalNo, 'order', '');
        Line.Add('type', 'item');
        Line.Add('no', CreateItem());
        Line.Add('quantity', 1);
        Line.Add('unitPrice', 100);
        Line.Add('vatPercent', 0);
        Line.Add('lineAmount', 100);
        Line.Add('dimensions', 'not-an-array');
        Lines.Add(Line);
        Body.Add('salesDocumentLines', Lines);

        // [When] the document is created through the API
        asserterror _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);

        // [Then] the request is rejected, and the error names the offending line
        _Assert.ExpectedError('is not an array');
        _Assert.IsTrue(GetLastErrorText().Contains('salesDocumentLines'), StrSubstNo('Error should carry the JSON path of the failing line, got: %1', GetLastErrorText()));
    end;

    [Test]
    procedure PaddedDimensionCodesAreTrimmed()
    var
        DimensionValue: Record "Dimension Value";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        // [Scenario] Surrounding whitespace on a dimension code or value is normalized away instead of failing the request.
        // [Given] a line dimension whose code and value are padded with spaces
        //         (built through the Text-typed helper - a Code[20] parameter would trim them for us)
        CreateDimensionWithValue(DimensionValue);
        LineDims.Add(DimJsonText(' ' + DimensionValue."Dimension Code" + ' ', ' ' + DimensionValue.Code + ' '));

        // [When] the document is created through the API
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', CreateItem(), '', HeaderDims, LineDims, EcomSalesHeader);

        // [Then] the padding is ignored and the dimension resolves
        GetEcomLine(EcomSalesHeader, EcomSalesLine);
        _Assert.AreEqual(DimensionValue.Code, GetDimSetValue(EcomSalesLine."Dimension Set ID", DimensionValue."Dimension Code"), 'Padded dimension code/value should resolve to the trimmed dimension');
    end;

    [Test]
    procedure NullDimensionsPropertyIsIgnored()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Body: JsonObject;
        Lines: JsonArray;
        Line: JsonObject;
        NullValue: JsonValue;
        ExternalNo: Code[20];
    begin
        // [Scenario] An explicit JSON null for dimensions means "none supplied" and must not fail the request.
        // [Given] a document whose header and line both send dimensions as null, the way a
        //         client sharing one DTO between them serializes an unset collection
        ExternalNo := NextExternalNo();
        NullValue.SetValueToNull();
        Body := _LibEcom.BuildEcomDocumentBody(ExternalNo, 'order', '');
        Body.Add('dimensions', NullValue);
        Line.Add('type', 'item');
        Line.Add('no', CreateItem());
        Line.Add('quantity', 1);
        Line.Add('unitPrice', 100);
        Line.Add('vatPercent', 0);
        Line.Add('lineAmount', 100);
        Line.Add('dimensions', NullValue);
        Lines.Add(Line);
        Body.Add('salesDocumentLines', Lines);

        // [When] the document is created through the API
        _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);

        // [Then] the document is accepted and no dimensions are stored
        _Assert.AreEqual(0, EcomSalesHeader."Dimension Set ID", 'Null header dimensions must be treated as no dimensions');
        GetEcomLine(EcomSalesHeader, EcomSalesLine);
        _Assert.AreEqual(0, EcomSalesLine."Dimension Set ID", 'Null line dimensions must be treated as no dimensions');
    end;

    [Test]
    procedure LineDuplicateDimensionCodeError()
    var
        DimensionValue: Record "Dimension Value";
        DimensionValue2: Record "Dimension Value";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        // [Scenario] One line cannot carry the same dimension code twice, since only one value per dimension can be stored.
        // [Given] one line carrying the same dimension code twice, with different values
        CreateDimensionWithValue(DimensionValue);
        _LibraryDimension.CreateDimensionValue(DimensionValue2, DimensionValue."Dimension Code");
        LineDims.Add(DimJson(DimensionValue."Dimension Code", DimensionValue.Code));
        LineDims.Add(DimJson(DimensionValue."Dimension Code", DimensionValue2.Code));

        // [When] the document is created through the API
        asserterror _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', CreateItem(), '', HeaderDims, LineDims, EcomSalesHeader);

        // [Then] the duplicate is rejected
        _Assert.ExpectedError('duplicate dimension code');
    end;

    [Test]
    procedure LineUnknownDimensionValueError()
    var
        DimensionValue: Record "Dimension Value";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        // [Scenario] Dimension values are checked against the dimension setup at capture, not silently accepted.
        // [Given] a line dimension pointing at a dimension value that does not exist
        CreateDimensionWithValue(DimensionValue);
        LineDims.Add(DimJson(DimensionValue."Dimension Code", 'NONEXISTINGVAL'));

        // [When] the document is created through the API
        asserterror _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', CreateItem(), '', HeaderDims, LineDims, EcomSalesHeader);

        // [Then] the value is rejected
        _Assert.ExpectedError('NONEXISTINGVAL');
    end;

    [Test]
    procedure NoDimensionsRegression()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        // [Scenario] A request that sends no dimensions is untouched by this feature - the guard against regressing existing integrations.
        // [Given] a document that supplies no dimensions at all
        // [When] it is created through the API
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', CreateItem(), '', HeaderDims, LineDims, EcomSalesHeader);

        // [Then] the line is stored without a dimension set, exactly as before the feature
        GetEcomLine(EcomSalesHeader, EcomSalesLine);
        _Assert.AreEqual(0, EcomSalesLine."Dimension Set ID", 'Line dimension set must stay 0 when no dimensions supplied');
    end;

    [Test]
    procedure SubscriberSetsLineDimensions()
    var
        DimensionValue: Record "Dimension Value";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesDocDimTests: Codeunit "NPR Ecom Sales Doc Dim Tests";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        // [Scenario] Partners can attach dimensions to a line through the existing line-creation event, without sending them in the request.
        // [Given] a subscriber to OnBeforeInsertIncomingSalesLineBeforeInsert that assigns a dimension set,
        //         and a document that supplies no dimensions of its own
        CreateDimensionWithValue(DimensionValue);
        EcomSalesDocDimTests.SetSubscriberDimSetID(CreateDimSetID(DimensionValue));

        // [When] the document is created through the API
        BindSubscription(EcomSalesDocDimTests);
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', CreateItem(), '', HeaderDims, LineDims, EcomSalesHeader);
        UnbindSubscription(EcomSalesDocDimTests);

        // [Then] the dimension set the subscriber assigned survives the insert
        GetEcomLine(EcomSalesHeader, EcomSalesLine);
        _Assert.AreEqual(EcomSalesDocDimTests.GetSubscriberDimSetID(), EcomSalesLine."Dimension Set ID", 'Subscriber-assigned dimension set must survive insert');
    end;

    [Test]
    procedure ResponseEmitsLineDimensions()
    var
        DimensionValue: Record "Dimension Value";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ApiAgent: Codeunit "NPR EcomSalesDocApiAgentV2";
        JsonBuilder: Codeunit "NPR Json Builder";
        DocJson: JsonObject;
        LinesToken: JsonToken;
        LineToken: JsonToken;
        DimsToken: JsonToken;
        DimToken: JsonToken;
        ValueToken: JsonToken;
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        // [Scenario] The dimensions stored on a line are returned in the document JSON, so a client can read back what it sent.
        // [Given] a document created with a dimension on its sales line
        CreateDimensionWithValue(DimensionValue);
        LineDims.Add(DimJson(DimensionValue."Dimension Code", DimensionValue.Code));
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', CreateItem(), '', HeaderDims, LineDims, EcomSalesHeader);

        // [When] the document is serialized for the API response
        JsonBuilder := ApiAgent.GetSalesDocumentJsonObject(EcomSalesHeader);
        DocJson := JsonBuilder.Build();

        // [Then] the line object carries the dimension back out
        _Assert.IsTrue(DocJson.Get('salesDocumentLines', LinesToken), 'Document JSON must contain salesDocumentLines');
        LinesToken.AsArray().Get(0, LineToken);
        _Assert.IsTrue(LineToken.AsObject().Get('dimensions', DimsToken), 'Line JSON must contain dimensions array');
        DimsToken.AsArray().Get(0, DimToken);
        DimToken.AsObject().Get('valueCode', ValueToken);
        _Assert.AreEqual(DimensionValue.Code, ValueToken.AsValue().AsText(), 'Emitted line dimension valueCode mismatch');
    end;

    [Test]
    procedure LineDimensionsMergedOntoSalesLineWithPrecedence()
    var
        ConflictDimValueItem: Record "Dimension Value";
        ConflictDimValueLine: Record "Dimension Value";
        HeaderDimValue: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        SalesLine: Record "Sales Line";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
        ItemNo: Code[20];
    begin
        // [Scenario] The dimensions of a line are merged onto the created sales line: the line wins where it conflicts with a default dimension, and header dimensions are still inherited for the codes it does not mention.
        // [Given] an item with a default dimension, and a line supplying a different value for
        //         that same dimension, plus a header dimension the line does not mention
        ItemNo := CreateItem();

        CreateDimensionWithValue(ConflictDimValueItem);
        _LibraryDimension.CreateDimensionValue(ConflictDimValueLine, ConflictDimValueItem."Dimension Code");
        _LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::Item, ItemNo, ConflictDimValueItem."Dimension Code", ConflictDimValueItem.Code);

        CreateDimensionWithValue(HeaderDimValue);
        HeaderDims.Add(DimJson(HeaderDimValue."Dimension Code", HeaderDimValue.Code));
        LineDims.Add(DimJson(ConflictDimValueLine."Dimension Code", ConflictDimValueLine.Code));

        // [When] the document is created and processed into a sales document
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', ItemNo, CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);
        GetEcomLine(EcomSalesHeader, EcomSalesLine);
        ProcessToSalesDocument(EcomSalesHeader);
        GetCreatedSalesLine(EcomSalesHeader, EcomSalesLine, SalesLine);

        // [Then] the line value wins the conflict, and the header dimension is still inherited
        _Assert.AreEqual(ConflictDimValueLine.Code, GetDimSetValue(SalesLine."Dimension Set ID", ConflictDimValueLine."Dimension Code"), 'Line overlay must win the per-code conflict against the item default');
        _Assert.AreEqual(HeaderDimValue.Code, GetDimSetValue(SalesLine."Dimension Set ID", HeaderDimValue."Dimension Code"), 'Header dimension must still be inherited');
    end;

    [Test]
    procedure CommentLineDimensionsMergedOntoBlankTypeSalesLine()
    var
        DimensionValue: Record "Dimension Value";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        SalesLine: Record "Sales Line";
        Body: JsonObject;
        Lines: JsonArray;
        ItemLine: JsonObject;
        CommentLine: JsonObject;
        LineDims: JsonArray;
        ExternalNo: Code[20];
    begin
        // [Scenario] Comment lines reach the sales document as blank-type sales lines, which carry a dimension set like any other.
        // [Given] a document with a comment line carrying a dimension
        ExternalNo := NextExternalNo();
        CreateDimensionWithValue(DimensionValue);
        LineDims.Add(DimJson(DimensionValue."Dimension Code", DimensionValue.Code));

        Body := _LibEcom.BuildEcomDocumentBody(ExternalNo, 'order', CreateCustomer());
        ItemLine.Add('type', 'item');
        ItemLine.Add('no', CreateItem());
        ItemLine.Add('quantity', 1);
        ItemLine.Add('unitPrice', 100);
        ItemLine.Add('vatPercent', 0);
        ItemLine.Add('lineAmount', 100);
        Lines.Add(ItemLine);
        CommentLine.Add('type', 'comment');
        CommentLine.Add('description', 'Dimension comment line');
        CommentLine.Add('dimensions', LineDims);
        Lines.Add(CommentLine);
        Body.Add('salesDocumentLines', Lines);
        _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Type, EcomSalesLine.Type::Comment);
        EcomSalesLine.FindFirst();

        // [When] the document is processed into a sales document
        ProcessToSalesDocument(EcomSalesHeader);
        GetCreatedSalesLine(EcomSalesHeader, EcomSalesLine, SalesLine);

        // [Then] the blank-type sales line created from the comment carries the dimension
        _Assert.AreEqual(DimensionValue.Code, GetDimSetValue(SalesLine."Dimension Set ID", DimensionValue."Dimension Code"), 'Comment sales line must carry the line overlay');
    end;

    [Test]
    procedure ShipmentFeeLineDimensionsMergedOntoSalesLine()
    var
        DimensionValue: Record "Dimension Value";
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        SalesLine: Record "Sales Line";
        LibraryERM: Codeunit "Library - ERM";
        Body: JsonObject;
        Lines: JsonArray;
        ItemLine: JsonObject;
        FeeLine: JsonObject;
        LineDims: JsonArray;
        ExternalNo: Code[20];
        ExternalShipCode: Code[20];
    begin
        // [Scenario] A shipment fee line reaches the sales document through its own insert path, which must apply dimensions too.
        // [Given] a shipment mapping to a G/L account, and a shipment fee line carrying a dimension
        ExternalNo := NextExternalNo();
        ExternalShipCode := CopyStr('SHIP' + _LibraryRandom.RandText(8), 1, 20);
        ShipmentMapping.Init();
        ShipmentMapping."External Shipment Method Code" := ExternalShipCode;
        ShipmentMapping."Shipment Fee Type" := ShipmentMapping."Shipment Fee Type"::"G/L Account";
        ShipmentMapping."Shipment Fee No." := LibraryERM.CreateGLAccountWithSalesSetup();
        ShipmentMapping.Insert();

        CreateDimensionWithValue(DimensionValue);
        LineDims.Add(DimJson(DimensionValue."Dimension Code", DimensionValue.Code));

        Body := _LibEcom.BuildEcomDocumentBody(ExternalNo, 'order', CreateCustomer());
        ItemLine.Add('type', 'item');
        ItemLine.Add('no', CreateItem());
        ItemLine.Add('quantity', 1);
        ItemLine.Add('unitPrice', 100);
        ItemLine.Add('vatPercent', 0);
        ItemLine.Add('lineAmount', 100);
        Lines.Add(ItemLine);
        FeeLine.Add('type', 'shipmentFee');
        FeeLine.Add('no', ExternalShipCode);
        FeeLine.Add('description', 'Shipping');
        FeeLine.Add('quantity', 1);
        FeeLine.Add('unitPrice', 10);
        FeeLine.Add('vatPercent', 0);
        FeeLine.Add('lineAmount', 10);
        FeeLine.Add('dimensions', LineDims);
        Lines.Add(FeeLine);
        Body.Add('salesDocumentLines', Lines);
        _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Type, EcomSalesLine.Type::"Shipment Fee");
        EcomSalesLine.FindFirst();

        // [When] the document is processed into a sales document
        ProcessToSalesDocument(EcomSalesHeader);
        GetCreatedSalesLine(EcomSalesHeader, EcomSalesLine, SalesLine);

        // [Then] the shipment fee sales line carries the dimension
        _Assert.AreEqual(DimensionValue.Code, GetDimSetValue(SalesLine."Dimension Set ID", DimensionValue."Dimension Code"), 'Shipment fee sales line must carry the line overlay');
    end;

    [Test]
    procedure ReturnOrderLineDimensionsMergedOntoSalesLine()
    var
        DimensionValue: Record "Dimension Value";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        SalesLine: Record "Sales Line";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        // [Scenario] Return orders use the same line insert paths as orders, so dimensions must land on return order lines as well.
        // [Given] a return order document with a dimension on its line
        CreateDimensionWithValue(DimensionValue);
        LineDims.Add(DimJson(DimensionValue."Dimension Code", DimensionValue.Code));

        // [When] the document is created and processed into a sales document
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'returnOrder', CreateItem(), CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);
        GetEcomLine(EcomSalesHeader, EcomSalesLine);
        ProcessToSalesDocument(EcomSalesHeader);
        GetCreatedSalesLine(EcomSalesHeader, EcomSalesLine, SalesLine);

        // [Then] a return order line is created and carries the dimension
        _Assert.AreEqual(SalesLine."Document Type"::"Return Order", SalesLine."Document Type", 'Expected a return order line');
        _Assert.AreEqual(DimensionValue.Code, GetDimSetValue(SalesLine."Dimension Set ID", DimensionValue."Dimension Code"), 'Return order sales line must carry the line overlay');
    end;

    [Test]
    procedure VoucherLineDimensionsMergedOntoSalesLine()
    var
        DimensionValue: Record "Dimension Value";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NpRvVoucher: Record "NPR NpRv Voucher";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        SalesLine: Record "Sales Line";
        LibraryERM: Codeunit "Library - ERM";
        EcomSalesDocImplV2: Codeunit "NPR Ecom Sales Doc Impl V2";
    begin
        // [Scenario] A voucher line reaches the sales document through its own insert path, which
        //             must apply dimensions too. The document is built from direct records rather
        //             than through the API, because the voucher API path requires the full voucher
        //             issuing pipeline and API-create preprocessing would process the document
        //             before the voucher line exists; the merge path under test is the same one.

        // [Given] a voucher type posting to a G/L account, and an issued voucher
        NpRvVoucherType.Init();
        NpRvVoucherType.Code := CopyStr('DIMVT' + _LibraryRandom.RandText(8), 1, MaxStrLen(NpRvVoucherType.Code));
        NpRvVoucherType."Account No." := LibraryERM.CreateGLAccountWithSalesSetup();
        NpRvVoucherType.Insert();
        NpRvVoucher.Init();
        NpRvVoucher."No." := CopyStr('DIMV' + _LibraryRandom.RandText(10), 1, MaxStrLen(NpRvVoucher."No."));
        NpRvVoucher."Voucher Type" := NpRvVoucherType.Code;
        NpRvVoucher.Insert();

        // [Given] an ecom document routed to the V2 implementation
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Sell-to Customer No." := CreateCustomer();
        EcomSalesHeader."API Version Date" := EcomSalesDocImplV2.GetApiVersion();
        EcomSalesHeader.Modify(true);

        // [Given] a voucher line on it, carrying a dimension
        CreateDimensionWithValue(DimensionValue);
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := EcomSalesHeader."External No.";
        EcomSalesLine."Line No." := 10000;
        EcomSalesLine.Type := EcomSalesLine.Type::Voucher;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Voucher;
        EcomSalesLine."Virtual Item Process Status" := EcomSalesLine."Virtual Item Process Status"::Processed;
        EcomSalesLine."No." := NpRvVoucher."No.";
        EcomSalesLine."Voucher Type" := NpRvVoucherType.Code;
        EcomSalesLine.Quantity := 1;
        EcomSalesLine."Unit Price" := 50;
        EcomSalesLine."Line Amount" := 50;
        EcomSalesLine."Dimension Set ID" := CreateDimSetID(DimensionValue);
        EcomSalesLine.Insert(true);

        // [When] the document is processed into a sales document
        ProcessToSalesDocument(EcomSalesHeader);
        GetCreatedSalesLine(EcomSalesHeader, EcomSalesLine, SalesLine);

        // [Then] the voucher sales line carries the dimension
        _Assert.AreEqual(DimensionValue.Code, GetDimSetValue(SalesLine."Dimension Set ID", DimensionValue."Dimension Code"), 'Voucher sales line must carry the line overlay');
    end;

    [Test]
    procedure PostedInvoiceLineCarriesLineDimensions()
    var
        DimensionValue: Record "Dimension Value";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        // [Scenario] Dimensions survive posting: what lands on the sales line reaches the posted invoice line, which is what dimension reporting reads.
        // [Given] an order created with a dimension on its line, processed into a sales order
        CreateDimensionWithValue(DimensionValue);
        LineDims.Add(DimJson(DimensionValue."Dimension Code", DimensionValue.Code));
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', CreateItem(), CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);
        GetEcomLine(EcomSalesHeader, EcomSalesLine);
        ProcessToSalesDocument(EcomSalesHeader);

        // [When] the sales order is posted
        PostSalesDocument(EcomSalesHeader, SalesHeader);

        // [Then] the posted invoice line carries the dimension
        SalesInvoiceHeader.SetRange("Order No.", SalesHeader."No.");
        SalesInvoiceHeader.FindFirst();
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        SalesInvoiceLine.FindFirst();
        _Assert.AreEqual(DimensionValue.Code, GetDimSetValue(SalesInvoiceLine."Dimension Set ID", DimensionValue."Dimension Code"), 'Posted invoice line must carry the line dimension');
    end;

    [Test]
    procedure PostedCreditMemoLineCarriesLineDimensions()
    var
        DimensionValue: Record "Dimension Value";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        // [Scenario] The same for a return order: dimensions reach the posted credit memo line.
        // [Given] a return order created with a dimension on its line, processed into a sales return order
        CreateDimensionWithValue(DimensionValue);
        LineDims.Add(DimJson(DimensionValue."Dimension Code", DimensionValue.Code));
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'returnOrder', CreateItem(), CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);
        GetEcomLine(EcomSalesHeader, EcomSalesLine);
        ProcessToSalesDocument(EcomSalesHeader);

        // [When] the sales return order is posted
        PostSalesDocument(EcomSalesHeader, SalesHeader);

        // [Then] the posted credit memo line carries the dimension
        SalesCrMemoHeader.SetRange("Return Order No.", SalesHeader."No.");
        SalesCrMemoHeader.FindFirst();
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        SalesCrMemoLine.FindFirst();
        _Assert.AreEqual(DimensionValue.Code, GetDimSetValue(SalesCrMemoLine."Dimension Set ID", DimensionValue."Dimension Code"), 'Posted credit memo line must carry the line dimension');
    end;

    [Test]
    procedure BlockedDimensionCombinationSurfacesAtPosting()
    var
        DimensionValue1: Record "Dimension Value";
        DimensionValue2: Record "Dimension Value";
        DimensionCombination: Record "Dimension Combination";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        // [Scenario] Dimension combination rules are deliberately not enforced when the document
        //             is captured - a blocked combination is accepted into the ecom document and
        //             surfaces only when the created sales document is posted.

        // [Given] two dimensions whose combination is blocked, both supplied on one line
        CreateDimensionWithValue(DimensionValue1);
        CreateDimensionWithValue(DimensionValue2);
        LineDims.Add(DimJson(DimensionValue1."Dimension Code", DimensionValue1.Code));
        LineDims.Add(DimJson(DimensionValue2."Dimension Code", DimensionValue2.Code));

        DimensionCombination.Init();
        DimensionCombination."Dimension 1 Code" := DimensionValue1."Dimension Code";
        DimensionCombination."Dimension 2 Code" := DimensionValue2."Dimension Code";
        DimensionCombination."Combination Restriction" := DimensionCombination."Combination Restriction"::Blocked;
        DimensionCombination.Insert();

        // [When] the document is created and processed - both succeed
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', CreateItem(), CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);
        ProcessToSalesDocument(EcomSalesHeader);

        // [Then] posting fails, naming one of the two blocked dimensions, so an unrelated
        //        mandatory-dimension failure cannot satisfy this test
        asserterror PostSalesDocument(EcomSalesHeader, SalesHeader);
        _Assert.IsTrue(
            GetLastErrorText().ToLower().Contains('dimension') and
            (GetLastErrorText().Contains(DimensionValue1."Dimension Code") or GetLastErrorText().Contains(DimensionValue2."Dimension Code")),
            StrSubstNo('Posting should fail on the blocked combination of %1 and %2, got: %3',
                DimensionValue1."Dimension Code", DimensionValue2."Dimension Code", GetLastErrorText()));
    end;

    [Test]
    procedure HeaderDimensionsParsedOnCreate()
    var
        DimensionValue: Record "Dimension Value";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        // [Scenario] The header dimension behaviour that already shipped, covered here because the parsing is now shared with the line path and must not regress.
        // [Given] a dimension value, supplied as a dimension on the document header
        CreateDimensionWithValue(DimensionValue);
        HeaderDims.Add(DimJson(DimensionValue."Dimension Code", DimensionValue.Code));

        // [When] the document is created through the API
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', CreateItem(), '', HeaderDims, LineDims, EcomSalesHeader);

        // [Then] the ecom sales header carries a dimension set holding that value
        _Assert.AreNotEqual(0, EcomSalesHeader."Dimension Set ID", 'Header dimension set should be assigned');
        _Assert.AreEqual(DimensionValue.Code, GetDimSetValue(EcomSalesHeader."Dimension Set ID", DimensionValue."Dimension Code"), 'Header dimension value mismatch');
    end;

    [Test]
    procedure HeaderDimensionsMergedOntoSalesHeader()
    var
        DimensionValue: Record "Dimension Value";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        // [Scenario] Header dimensions still reach the created sales header after the parsing was shared with the line path.
        // [Given] a document with a dimension on its header
        CreateDimensionWithValue(DimensionValue);
        HeaderDims.Add(DimJson(DimensionValue."Dimension Code", DimensionValue.Code));

        // [When] the document is created and processed into a sales document
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', CreateItem(), CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);
        ProcessToSalesDocument(EcomSalesHeader);

        // [Then] the sales header carries the dimension
        SalesHeader.Get(SalesHeader."Document Type"::Order, EcomSalesHeader."Created Doc No.");
        _Assert.AreEqual(DimensionValue.Code, GetDimSetValue(SalesHeader."Dimension Set ID", DimensionValue."Dimension Code"), 'Sales header must carry the header dimension');
    end;

    [Test]
    procedure GlobalDimensionOnLineUpdatesShortcutFieldsOnSalesLine()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionValue: Record "Dimension Value";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        SalesLine: Record "Sales Line";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        // [Scenario] A line dimension for a global dimension must also reach the sales line's
        //             shortcut dimension field, not only its dimension set: posting copies the
        //             shortcut codes into the ledger entries' global dimension columns, which is
        //             what dimension-filtered reporting reads.

        // [Given] a value of global dimension 1, supplied as a dimension on the sales line
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("Global Dimension 1 Code");
        _LibraryDimension.CreateDimensionValue(DimensionValue, GeneralLedgerSetup."Global Dimension 1 Code");
        LineDims.Add(DimJson(DimensionValue."Dimension Code", DimensionValue.Code));

        // [When] the document is created and processed into a sales document
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', CreateItem(), CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);
        GetEcomLine(EcomSalesHeader, EcomSalesLine);
        ProcessToSalesDocument(EcomSalesHeader);
        GetCreatedSalesLine(EcomSalesHeader, EcomSalesLine, SalesLine);

        // [Then] the shortcut dimension field is synced from the merged dimension set
        _Assert.AreEqual(DimensionValue.Code, SalesLine."Shortcut Dimension 1 Code", 'Shortcut Dimension 1 Code must be synced from the merged dimension set');
        _Assert.AreEqual(DimensionValue.Code, GetDimSetValue(SalesLine."Dimension Set ID", DimensionValue."Dimension Code"), 'Merged set must contain the global dimension value');
    end;

    procedure SetSubscriberDimSetID(DimSetID: Integer)
    begin
        _SubscriberDimSetID := DimSetID;
    end;

    procedure GetSubscriberDimSetID(): Integer
    begin
        exit(_SubscriberDimSetID);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", 'OnBeforeInsertIncomingSalesLineBeforeInsert', '', false, false)]
    local procedure OnBeforeInsertIncomingSalesLineBeforeInsert(SalesLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
        EcomSalesLine."Dimension Set ID" := _SubscriberDimSetID;
    end;

    local procedure CreateDimensionWithValue(var DimensionValue: Record "Dimension Value")
    var
        Dimension: Record Dimension;
    begin
        _LibraryDimension.CreateDimension(Dimension);
        _LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
    end;

    local procedure CreateDimSetID(DimensionValue: Record "Dimension Value"): Integer
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
    begin
        TempDimSetEntry.Init();
        TempDimSetEntry."Dimension Code" := DimensionValue."Dimension Code";
        TempDimSetEntry."Dimension Value Code" := DimensionValue.Code;
        TempDimSetEntry."Dimension Value ID" := DimensionValue."Dimension Value ID";
        TempDimSetEntry.Insert();
        exit(DimMgt.GetDimensionSetID(TempDimSetEntry));
    end;

    local procedure DimJson(DimensionCode: Code[20]; DimensionValueCode: Code[20]): JsonObject
    begin
        exit(DimJsonText(DimensionCode, DimensionValueCode));
    end;

    local procedure DimJsonText(DimensionCode: Text; DimensionValueCode: Text): JsonObject
    var
        Dim: JsonObject;
    begin
        Dim.Add('code', DimensionCode);
        Dim.Add('valueCode', DimensionValueCode);
        exit(Dim);
    end;

    local procedure NextExternalNo(): Code[20]
    begin
        exit(CopyStr('DIM' + _LibraryRandom.RandText(10), 1, 20));
    end;

    local procedure CreateItem(): Code[20]
    var
        Item: Record Item;
    begin
        _LibraryInventory.CreateItem(Item);
        exit(Item."No.");
    end;

    local procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        // Processing must reuse this customer, which has complete posting groups, instead of
        // creating a bare one from the (missing) customer templates.
        SetCustomerMappingByCustomerNo();
        _LibrarySales.CreateCustomer(Customer);
        exit(Customer."No.");
    end;

    local procedure SetCustomerMappingByCustomerNo()
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        if not IncEcomSalesDocSetup.Get() then begin
            IncEcomSalesDocSetup.Init();
            IncEcomSalesDocSetup.Insert();
        end;
        IncEcomSalesDocSetup."Customer Mapping" := IncEcomSalesDocSetup."Customer Mapping"::"Customer No.";
        IncEcomSalesDocSetup.Modify();
    end;

    local procedure GetEcomLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.FindFirst();
    end;

    local procedure GetDimSetValue(DimSetID: Integer; DimensionCode: Code[20]): Code[20]
    var
        DimSetEntry: Record "Dimension Set Entry";
    begin
        if DimSetEntry.Get(DimSetID, DimensionCode) then
            exit(DimSetEntry."Dimension Value Code");
        exit('');
    end;

    local procedure ProcessToSalesDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesDocProcess: Codeunit "NPR EcomSalesDocProcess";
    begin
        // Feature flag 'disableApiEcomDocumentPreprocessing' decides whether the API create call
        // already processed the document, so only process here when it has not happened yet.
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        if EcomSalesHeader."Created Doc No." = '' then begin
            Commit();
            EcomSalesDocProcess.SetShowError(true);
            EcomSalesDocProcess.Run(EcomSalesHeader);
            EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        end;
        _Assert.AreNotEqual('', EcomSalesHeader."Created Doc No.", 'Sales document should have been created');
    end;

    local procedure GetCreatedSalesLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLine: Record "Sales Line")
    begin
        SalesLine.SetRange("Document No.", EcomSalesHeader."Created Doc No.");
        SalesLine.SetRange("NPR Inc Ecom Sales Line Id", EcomSalesLine.SystemId);
        SalesLine.FindFirst();
    end;

    local procedure PostSalesDocument(EcomSalesHeader: Record "NPR Ecom Sales Header"; var SalesHeader: Record "Sales Header")
    var
        SalesPost: Codeunit "Sales-Post";
        DocumentType: Enum "Sales Document Type";
    begin
        if EcomSalesHeader."Document Type" = EcomSalesHeader."Document Type"::"Return Order" then
            DocumentType := DocumentType::"Return Order"
        else
            DocumentType := DocumentType::Order;
        SalesHeader.Get(DocumentType, EcomSalesHeader."Created Doc No.");
        SalesHeader.Ship := true;
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        Commit();
        if not SalesPost.Run(SalesHeader) then
            Error('Posting failed: %1', GetLastErrorText());
    end;
}
#endif
