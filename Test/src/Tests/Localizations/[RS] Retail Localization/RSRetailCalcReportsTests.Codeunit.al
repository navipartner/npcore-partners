// The CRO calculation reports run on the RS retail localization engine (same setup and price lookup), so both countries are tested here.
codeunit 85600 "NPR RS Retail Calc. Rpt Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;

    #region Transfer receipt calculation

    [Test]
    procedure CROTransferCalc_ItemOnlyInMiddleActivePriceList_PrintsItsPrice()
    begin
        TransferCalc_ItemOnlyInMiddleActivePriceList_PrintsItsPrice(Report::"NPR CRO Ret. Trans. Rec. Calc");
    end;

    [Test]
    procedure RSTransferCalc_ItemOnlyInMiddleActivePriceList_PrintsItsPrice()
    begin
        TransferCalc_ItemOnlyInMiddleActivePriceList_PrintsItsPrice(Report::"NPR RS Ret. Trans. Rec. Calc.");
    end;

    local procedure TransferCalc_ItemOnlyInMiddleActivePriceList_PrintsItsPrice(ReportId: Integer)
    var
        FirstListItem: Record Item;
        Item: Record Item;
        LastListItem: Record Item;
        Retail: Record Location;
        Transit: Record Location;
        Whse: Record Location;
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        ReportXml: XmlDocument;
        RcptNo: Code[20];
        ShptNo: Code[20];
    begin
        // [SCENARIO] The transfer receipt calculation finds the item's price in any active price list of the receiving location, as posting does
        // [GIVEN] A retail location with three active sales price lists, of which only the middle one prices our item, at 1200 incl. 20% VAT
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateWholesaleLocation(Whse);
        Lib.CreateInTransitLocation(Transit);
        Lib.CreateRetailItem(FirstListItem, 100, 200, false, Retail.Code);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.CreateRetailItem(LastListItem, 100, 200, false, Retail.Code);
        AssertFirstAndLastPriceListsOfLocationLackItem(Retail.Code, Item."No.");

        // [GIVEN] 10 pcs transferred wholesale -> retail, which posting calculates from the middle list
        Lib.PostRetailPurchaseInvoice(Item."No.", Whse.Code, 10, 600);
        Lib.PostRetailTransfer(Whse.Code, Retail.Code, Transit.Code, Item."No.", 10, ShptNo, RcptNo);

        // [WHEN] Printing the transfer receipt calculation
        RunTransferCalcReport(ReportId, RcptNo, ReportXml);

        // [THEN] The receipt line carries the item's retail price
        _Assert.AreNearlyEqual(1200, ColumnDecimal(ReportXml, 'ReceiptLine_SalesPrice'), 0.01, 'The sales price must come from the active price list that holds the item');
    end;

    #endregion

    #region Purchase invoice calculation

    [Test]
    procedure CROPurchCalc_ItemPricedAtTwoRetailLocations_PrintsInvoiceLocationPrice()
    begin
        PurchCalc_ItemPricedAtTwoRetailLocations_PrintsInvoiceLocationPrice(Report::"NPR CRO Ret. Purch. Price Calc");
    end;

    [Test]
    procedure RSPurchCalc_ItemPricedAtTwoRetailLocations_PrintsInvoiceLocationPrice()
    begin
        PurchCalc_ItemPricedAtTwoRetailLocations_PrintsInvoiceLocationPrice(Report::"NPR RS Ret. Purch. Price Calc.");
    end;

    local procedure PurchCalc_ItemPricedAtTwoRetailLocations_PrintsInvoiceLocationPrice(ReportId: Integer)
    var
        Item: Record Item;
        OtherRetail: Record Location;
        Retail: Record Location;
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        ReportXml: XmlDocument;
        PostedNo: Code[20];
    begin
        // [SCENARIO] The purchase invoice calculation prices the line from the invoice location's price lists, as posting does
        // [GIVEN] Two retail locations pricing the same item differently: 1500 at the other store, whose price list sorts first, and 1200 at ours
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailLocation(OtherRetail);
        Lib.CreateRetailItem(Item, 600, 1500, false, OtherRetail.Code);
        Lib.EnsureRetailPrice(Item."No.", Retail.Code, 1200);
        AssertFirstSalesPriceLineIsAtLocation(Item."No.", OtherRetail.Code);

        // [GIVEN] 10 pcs bought into our store, which posting calculates at our 1200
        PostedNo := Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [WHEN] Printing the purchase invoice calculation
        RunPurchCalcReport(ReportId, PostedNo, ReportXml);

        // [THEN] The line carries the price of the invoice's location, not the other store's
        _Assert.AreNearlyEqual(1200, ColumnDecimal(ReportXml, 'InvLine_SalesPrice'), 0.01, 'The sales price must come from the price lists of the invoice line''s location');
    end;

    [Test]
    procedure CROPurchCalc_ServiceItemLine_IsLeftOut()
    begin
        PurchCalc_ServiceItemLine_IsLeftOut(Report::"NPR CRO Ret. Purch. Price Calc");
    end;

    [Test]
    procedure RSPurchCalc_ServiceItemLine_IsLeftOut()
    begin
        PurchCalc_ServiceItemLine_IsLeftOut(Report::"NPR RS Ret. Purch. Price Calc.");
    end;

    local procedure PurchCalc_ServiceItemLine_IsLeftOut(ReportId: Integer)
    var
        Item: Record Item;
        ServiceItem: Record Item;
        Retail: Record Location;
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        ReportXml: XmlDocument;
        PostedNo: Code[20];
    begin
        // [SCENARIO] The purchase invoice calculation leaves service item lines out, as posting does
        // [GIVEN] A retail item at 1200 incl. 20% VAT and a service item, which has no retail price
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.CreateServiceItem(ServiceItem);

        // [GIVEN] One invoice into the retail store: 10 pcs of the item, then 10 of the service
        PostedNo := Lib.PostRetailPurchase2Lines(Item."No.", ServiceItem."No.", Retail.Code, 10, 600, 50);
        AssertPostedPurchLineAtLocation(PostedNo, ServiceItem."No.", Retail.Code);

        // [WHEN] Printing the purchase invoice calculation
        RunPurchCalcReport(ReportId, PostedNo, ReportXml);

        // [THEN] Only the item line is calculated, so the retail value incl. VAT is 10 * 1200
        _Assert.AreNearlyEqual(12000, ColumnDecimal(ReportXml, 'TotalValueWithChargeInclVAT'), 0.01, 'The retail value total must not count the service line');
        _Assert.AreEqual(1, CountPrintedRows(ReportXml, 'InvLine_SalesPrice'), 'Only the item line must be printed');
    end;

    [Test]
    procedure CROPurchCalc_ZeroQuantityLine_IsLeftOut()
    begin
        PurchCalc_ZeroQuantityLine_IsLeftOut(Report::"NPR CRO Ret. Purch. Price Calc");
    end;

    [Test]
    procedure RSPurchCalc_ZeroQuantityLine_IsLeftOut()
    begin
        PurchCalc_ZeroQuantityLine_IsLeftOut(Report::"NPR RS Ret. Purch. Price Calc.");
    end;

    local procedure PurchCalc_ZeroQuantityLine_IsLeftOut(ReportId: Integer)
    var
        Item: Record Item;
        UnreceivedItem: Record Item;
        Retail: Record Location;
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        ReportXml: XmlDocument;
        PostedNo: Code[20];
    begin
        // [SCENARIO] The purchase invoice calculation leaves out invoice lines with quantity 0, for which posting books nothing, instead of stopping with a division by zero
        // [GIVEN] Two retail items at 600, retail 1200 incl. 20% VAT, in a retail store
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.CreateRetailItem(UnreceivedItem, 600, 1200, false, Retail.Code);

        // [GIVEN] A purchase order posted with Receive and Invoice: 10 pcs of the first item received, the second line with Qty. to Receive 0
        PostedNo := Lib.PostRetailPurchaseOrderWithUnreceivedLine(Item."No.", UnreceivedItem."No.", Retail.Code, 10, 600);
        AssertPostedPurchLineHasZeroQuantity(PostedNo, UnreceivedItem."No.", Retail.Code);

        // [WHEN] Printing the purchase invoice calculation
        RunPurchCalcReport(ReportId, PostedNo, ReportXml);

        // [THEN] Only the received line is calculated, so the retail value incl. VAT is 10 * 1200
        _Assert.AreNearlyEqual(12000, ColumnDecimal(ReportXml, 'TotalValueWithChargeInclVAT'), 0.01, 'The retail value total must not count the quantity 0 line');
        _Assert.AreEqual(1, CountPrintedRows(ReportXml, 'InvLine_SalesPrice'), 'Only the received line must be printed');
    end;

    [Test]
    procedure CROPurchCalc_ItemChargeOnSameInvoice_PrintsItAndPostedMargin()
    begin
        PurchCalc_ItemChargeOnSameInvoice_PrintsItAndPostedMargin(Report::"NPR CRO Ret. Purch. Price Calc");
    end;

    [Test]
    procedure RSPurchCalc_ItemChargeOnSameInvoice_PrintsItAndPostedMargin()
    begin
        PurchCalc_ItemChargeOnSameInvoice_PrintsItAndPostedMargin(Report::"NPR RS Ret. Purch. Price Calc.");
    end;

    local procedure PurchCalc_ItemChargeOnSameInvoice_PrintsItAndPostedMargin(ReportId: Integer)
    var
        Item: Record Item;
        Retail: Record Location;
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        ReportXml: XmlDocument;
        PostedNo: Code[20];
    begin
        // [SCENARIO] The purchase invoice calculation shows the invoice's item charges as dependent costs and takes them off the margin, as posting does
        // [GIVEN] 10 pcs of a retail item at 600, retail 1200 incl. 20% VAT, bought into a retail store with a 1000 item charge on the same invoice
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        PostedNo := Lib.PostRetailPurchaseWithItemCharge(Item."No.", Retail.Code, 10, 600, 1000);

        // [WHEN] Printing the purchase invoice calculation
        RunPurchCalcReport(ReportId, PostedNo, ReportXml);

        // [THEN] Dependent costs are 1000, and the margin is retail 10000 excl. VAT - cost 6000 - charge 1000 = 3000, the RUC posting books
        _Assert.AreNearlyEqual(1000, ColumnDecimal(ReportXml, 'InvLine_ItemChargeAssigned'), 0.01, 'Dependent costs must be the item charge posted on the invoice');
        _Assert.AreNearlyEqual(3000, ColumnDecimal(ReportXml, 'InvLine_MarginAmount'), 0.01, 'The margin must deduct the item charge, as posting does');
    end;

    [Test]
    procedure CROPurchCalc_ItemChargeOnPartlyInvoicedReceipt_PrintsInvoicedShare()
    begin
        PurchCalc_ItemChargeOnPartlyInvoicedReceipt_PrintsInvoicedShare(Report::"NPR CRO Ret. Purch. Price Calc");
    end;

    [Test]
    procedure RSPurchCalc_ItemChargeOnPartlyInvoicedReceipt_PrintsInvoicedShare()
    begin
        PurchCalc_ItemChargeOnPartlyInvoicedReceipt_PrintsInvoicedShare(Report::"NPR RS Ret. Purch. Price Calc.");
    end;

    local procedure PurchCalc_ItemChargeOnPartlyInvoicedReceipt_PrintsInvoicedShare(ReportId: Integer)
    var
        Item: Record Item;
        Retail: Record Location;
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        ReportXml: XmlDocument;
        OrderNo: Code[20];
        PostedNo: Code[20];
    begin
        // [SCENARIO] When an invoice covers only part of a receipt, the calculation counts the item charge for the invoiced units only, as posting does
        // [GIVEN] 10 pcs of a retail item at 600, retail 1200 incl. 20% VAT, received into a retail store
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        OrderNo := Lib.ReceivePurchaseOrderOnly(Item."No.", Retail.Code, 10, 600);

        // [GIVEN] An invoice for 5 of them with a 1000 item charge on the whole receipt line, i.e. 100 per received unit
        PostedNo := Lib.InvoicePartOfReceiptWithItemCharge(OrderNo, 5, 1000);
        // Posting books markup (1200 - 600 - 100) * 5 = 2500, VAT 6000 / 1.2 * 0.2 = 1000 and RUC 2500 - 1000 = 1500
        Lib.AssertCalcGL(PostedNo, Lib.RetailInvAcc(Retail.Code), Lib.GlobalVATAcc(), Lib.GlobalMarginAcc(), 2500, 1000, 1500);

        // [WHEN] Printing the purchase invoice calculation
        RunPurchCalcReport(ReportId, PostedNo, ReportXml);

        // [THEN] Dependent costs are 5 * 100 = 500, and the margin is retail 5000 excl. VAT - cost 3000 - 500 = 1500, the RUC posting booked
        _Assert.AreNearlyEqual(500, ColumnDecimal(ReportXml, 'InvLine_ItemChargeAssigned'), 0.01, 'Dependent costs must be the item charge of the invoiced units only');
        _Assert.AreNearlyEqual(1500, ColumnDecimal(ReportXml, 'InvLine_MarginAmount'), 0.01, 'The margin must be the RUC posting booked');
    end;

    [Test]
    procedure CROPurchCalc_ItemChargeOnOneOfTwoLines_StaysOnItsLine()
    begin
        PurchCalc_ItemChargeOnOneOfTwoLines_StaysOnItsLine(Report::"NPR CRO Ret. Purch. Price Calc");
    end;

    [Test]
    procedure RSPurchCalc_ItemChargeOnOneOfTwoLines_StaysOnItsLine()
    begin
        PurchCalc_ItemChargeOnOneOfTwoLines_StaysOnItsLine(Report::"NPR RS Ret. Purch. Price Calc.");
    end;

    local procedure PurchCalc_ItemChargeOnOneOfTwoLines_StaysOnItsLine(ReportId: Integer)
    var
        ChargedItem: Record Item;
        UnchargedItem: Record Item;
        Retail: Record Location;
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        ReportXml: XmlDocument;
        PostedNo: Code[20];
    begin
        // [SCENARIO] On an invoice with several lines, an item charge counts only on the line it is assigned to. The line after it doesn't inherit it, and no line gets the charges of the whole invoice
        // [GIVEN] Two retail items at 600, retail 1200 incl. 20% VAT, in a retail store
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(ChargedItem, 600, 1200, false, Retail.Code);
        Lib.CreateRetailItem(UnchargedItem, 600, 1200, false, Retail.Code);
        _Assert.AreNotEqual(ChargedItem.Description, UnchargedItem.Description, 'Fixture precondition: the printed lines are told apart by their descriptions');

        // [GIVEN] One invoice with 10 pcs of each, the charged item first, and a 1000 item charge assigned only to the charged item
        PostedNo := Lib.PostRetailPurchase2ItemsWithItemChargeOnFirst(ChargedItem."No.", UnchargedItem."No.", Retail.Code, 10, 600, 1000);

        // [WHEN] Printing the purchase invoice calculation
        RunPurchCalcReport(ReportId, PostedNo, ReportXml);

        // [THEN] The charged line has dependent costs of 1000, the uncharged line none, and the total is 1000
        _Assert.AreNearlyEqual(1000, LineColumnDecimal(ReportXml, ChargedItem.Description, 'InvLine_ItemChargeAssigned'), 0.01, 'The charged line must carry the item charge assigned to it');
        _Assert.AreNearlyEqual(0, LineColumnDecimal(ReportXml, UnchargedItem.Description, 'InvLine_ItemChargeAssigned'), 0.01, 'A line without an item charge must not carry another line''s charge');
        _Assert.AreNearlyEqual(1000, ColumnDecimal(ReportXml, 'TotalItemChargeAssigned'), 0.01, 'The dependent costs total must count the item charge once');
    end;

    [Test]
    procedure CROPurchCalc_NoPriceAtInvoiceLocation_RaisesError()
    begin
        PurchCalc_NoPriceAtInvoiceLocation_RaisesError(Report::"NPR CRO Ret. Purch. Price Calc");
    end;

    [Test]
    procedure RSPurchCalc_NoPriceAtInvoiceLocation_RaisesError()
    begin
        PurchCalc_NoPriceAtInvoiceLocation_RaisesError(Report::"NPR RS Ret. Purch. Price Calc.");
    end;

    local procedure PurchCalc_NoPriceAtInvoiceLocation_RaisesError(ReportId: Integer)
    var
        Item: Record Item;
        Retail: Record Location;
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        ReportXml: XmlDocument;
        PostedNo: Code[20];
    begin
        // [SCENARIO] A retail goods line needs a retail price, so the purchase invoice calculation stops, as posting does, instead of printing the line with a zero or the previous line's price
        // [GIVEN] 10 pcs of a retail item bought into a retail store at 1200 incl. 20% VAT
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        PostedNo := Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [GIVEN] The store's price for the item is removed after posting
        Lib.RemoveRetailPrice(Item."No.", Retail.Code);

        // [WHEN] Printing the purchase invoice calculation
        asserterror RunPurchCalcReport(ReportId, PostedNo, ReportXml);

        // [THEN] It stops with an error that names the item and the location
        _Assert.ExpectedErrorCode('Dialog');
        _Assert.ExpectedError(Item."No.");
        _Assert.ExpectedError(Retail.Code);
    end;

    #endregion

    #region Helpers

    // With the item in neither the first nor the last list, a lookup that reads only one end of the lists cannot find it.
    local procedure AssertFirstAndLastPriceListsOfLocationLackItem(LocationCode: Code[10]; ItemNo: Code[20])
    var
        PriceListHeader: Record "Price List Header";
    begin
        PriceListHeader.SetRange(Status, PriceListHeader.Status::Active);
        PriceListHeader.SetRange("NPR Location Code", LocationCode);
        PriceListHeader.FindFirst();
        _Assert.IsFalse(PriceListHoldsItem(PriceListHeader.Code, ItemNo), 'Fixture precondition: the location''s first active price list must not hold the item');
        PriceListHeader.FindLast();
        _Assert.IsFalse(PriceListHoldsItem(PriceListHeader.Code, ItemNo), 'Fixture precondition: the location''s last active price list must not hold the item');
    end;

    local procedure PriceListHoldsItem(PriceListCode: Code[20]; ItemNo: Code[20]): Boolean
    var
        PriceListLine: Record "Price List Line";
    begin
        PriceListLine.SetRange("Price List Code", PriceListCode);
        PriceListLine.SetRange("Asset No.", ItemNo);
        exit(not PriceListLine.IsEmpty());
    end;

    // A line at a non-retail location is skipped before the service item check, which would leave nothing to test.
    local procedure AssertPostedPurchLineAtLocation(PurchInvNo: Code[20]; ItemNo: Code[20]; LocationCode: Code[10])
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        PurchInvLine.SetRange("Document No.", PurchInvNo);
        PurchInvLine.SetRange(Type, PurchInvLine.Type::Item);
        PurchInvLine.SetRange("No.", ItemNo);
        PurchInvLine.FindFirst();
        _Assert.AreEqual(LocationCode, PurchInvLine."Location Code", 'Fixture precondition: the line must be posted at the retail location');
    end;

    // The quantity 0 line must reach the report at a retail location, or the retail location check would skip it before the division.
    local procedure AssertPostedPurchLineHasZeroQuantity(PurchInvNo: Code[20]; ItemNo: Code[20]; LocationCode: Code[10])
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        PurchInvLine.SetRange("Document No.", PurchInvNo);
        PurchInvLine.SetRange(Type, PurchInvLine.Type::Item);
        PurchInvLine.SetRange("No.", ItemNo);
        _Assert.IsTrue(PurchInvLine.FindFirst(), 'Fixture precondition: the unreceived line must be copied into the posted invoice');
        _Assert.AreEqual(0, PurchInvLine.Quantity, 'Fixture precondition: the unreceived line must be posted with quantity 0');
        _Assert.AreEqual(LocationCode, PurchInvLine."Location Code", 'Fixture precondition: the line must be posted at the retail location');
    end;

    local procedure AssertFirstSalesPriceLineIsAtLocation(ItemNo: Code[20]; LocationCode: Code[10])
    var
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
    begin
        PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Sale);
        PriceListLine.SetRange("Asset No.", ItemNo);
        PriceListLine.FindFirst();
        PriceListHeader.Get(PriceListLine."Price List Code");
        _Assert.AreEqual(LocationCode, PriceListHeader."NPR Location Code", 'Fixture precondition: the item''s first sales price line must belong to the other location');
    end;

    local procedure RunTransferCalcReport(ReportId: Integer; RcptNo: Code[20]; var ReportXml: XmlDocument)
    var
        CROTransRecCalc: Report "NPR CRO Ret. Trans. Rec. Calc";
        RSTransRecCalc: Report "NPR RS Ret. Trans. Rec. Calc.";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        case ReportId of
            Report::"NPR CRO Ret. Trans. Rec. Calc":
                begin
                    CROTransRecCalc.SetFilters(RcptNo, 0D);
                    CROTransRecCalc.SaveAs('', ReportFormat::Xml, OutStr);
                end;
            Report::"NPR RS Ret. Trans. Rec. Calc.":
                begin
                    RSTransRecCalc.SetFilters(RcptNo, 0D);
                    RSTransRecCalc.SaveAs('', ReportFormat::Xml, OutStr);
                end;
            else
                _Assert.Fail(StrSubstNo('Report %1 is not a transfer receipt calculation report', ReportId));
        end;
        ReadReportXml(TempBlob, ReportXml);
    end;

    local procedure RunPurchCalcReport(ReportId: Integer; PurchInvNo: Code[20]; var ReportXml: XmlDocument)
    var
        CRORetPurchPriceCalc: Report "NPR CRO Ret. Purch. Price Calc";
        RSRetPurchPriceCalc: Report "NPR RS Ret. Purch. Price Calc.";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        case ReportId of
            Report::"NPR CRO Ret. Purch. Price Calc":
                begin
                    CRORetPurchPriceCalc.SetFilters(PurchInvNo, 0D);
                    CRORetPurchPriceCalc.SaveAs('', ReportFormat::Xml, OutStr);
                end;
            Report::"NPR RS Ret. Purch. Price Calc.":
                begin
                    RSRetPurchPriceCalc.SetFilters(PurchInvNo, 0D);
                    RSRetPurchPriceCalc.SaveAs('', ReportFormat::Xml, OutStr);
                end;
            else
                _Assert.Fail(StrSubstNo('Report %1 is not a purchase invoice calculation report', ReportId));
        end;
        ReadReportXml(TempBlob, ReportXml);
    end;

    local procedure ReadReportXml(var TempBlob: Codeunit "Temp Blob"; var ReportXml: XmlDocument)
    var
        InStr: InStream;
    begin
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        XmlDocument.ReadFrom(InStr, ReportXml);
    end;

    // Column names are unique per report, so they identify the data item without depending on how the XML encodes its name.
    local procedure ColumnDecimal(ReportXml: XmlDocument; ColumnName: Text) Result: Decimal
    var
        Node: XmlNode;
    begin
        _Assert.IsTrue(ReportXml.SelectSingleNode(StrSubstNo('//Column[@name=''%1'']', ColumnName), Node), StrSubstNo('The report must print column %1', ColumnName));
        Evaluate(Result, Node.AsXmlElement().InnerText(), 9);
    end;

    // Picks the printed invoice line by its description, because the data item name has dots that an XPath name test can't match.
    local procedure LineColumnDecimal(ReportXml: XmlDocument; LineDescription: Text; ColumnName: Text) Result: Decimal
    var
        Node: XmlNode;
    begin
        _Assert.IsTrue(
            ReportXml.SelectSingleNode(StrSubstNo('//DataItem[Columns/Column[@name=''InvLine_Description'']=''%1'']/Columns/Column[@name=''%2'']', LineDescription, ColumnName), Node),
            StrSubstNo('The report must print column %1 for the line %2', ColumnName, LineDescription));
        Evaluate(Result, Node.AsXmlElement().InnerText(), 9);
    end;

    local procedure CountPrintedRows(ReportXml: XmlDocument; ColumnName: Text): Integer
    var
        Nodes: XmlNodeList;
    begin
        ReportXml.SelectNodes(StrSubstNo('//Column[@name=''%1'']', ColumnName), Nodes);
        exit(Nodes.Count());
    end;

    #endregion
}
