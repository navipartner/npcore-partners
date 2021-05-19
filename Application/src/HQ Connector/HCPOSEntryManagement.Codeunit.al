codeunit 6150915 "NPR HC POS Entry Management"
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        Document: XmlDocument;
    begin
        if LoadXmlDoc(Document) then
            ProcessPOSTransaction(Document);
    end;

    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Text001: Label '%1 with %2: %3 and %4: %5 was already inserted.';

    local procedure ProcessPOSTransaction(Document: XmlDocument)
    var
        Element: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin
        Document.GetRoot(Element);

        if Element.IsEmpty then
            exit;

        if not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'InsertPOSEntry', NodeList) then
            exit;

        if not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'posentryimport', NodeList) then
            exit;

        if not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'postransaction', NodeList) then
            exit;

        if not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'posentry', NodeList) then
            exit;

        foreach Node in NodeList do
            ProcessPOSEntry(Node.AsXmlElement());
    end;

    local procedure ProcessPOSEntry(POSEntryXmlElement: XmlElement): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin
        if POSEntryXmlElement.IsEmpty then
            exit(false);

        InsertPOSEntry(POSEntryXmlElement, POSEntry);

        if NpXmlDomMgt.FindNodes(POSEntryXmlElement.AsXmlNode(), 'posledgerregister', NodeList) then
            foreach Node in NodeList do
                UpdatePOSLedgerRegister(Node.AsXmlElement(), POSEntry);

        if NpXmlDomMgt.FindNodes(POSEntryXmlElement.AsXmlNode(), 'possalesline', NodeList) then
            foreach Node in NodeList do
                InsertPOSSalesLine(Node.AsXmlElement(), POSEntry);

        if NpXmlDomMgt.FindNodes(POSEntryXmlElement.AsXmlNode(), 'pospaymentline', NodeList) then
            foreach Node in NodeList do
                InsertPOSPaymentLine(Node.AsXmlElement(), POSEntry);

        if NpXmlDomMgt.FindNodes(POSEntryXmlElement.AsXmlNode(), 'postaxamountline', NodeList) then
            foreach Node in NodeList do
                InsertPOSTaxAmountLine(Node.AsXmlElement(), POSEntry);

        if NpXmlDomMgt.FindNodes(POSEntryXmlElement.AsXmlNode(), 'posbalancingline', NodeList) then
            foreach Node in NodeList do
                InsertPOSBalancingLine(Node.AsXmlElement(), POSEntry);

        ResetPostingstatus(POSEntry);
        POSEntry.Modify();

        Commit();
        exit(true);
    end;

    local procedure InsertPOSEntry(Element: XmlElement; var POSEntry: Record "NPR POS Entry")
    var
        TempDimensionBuffer: Record "Dimension Buffer" temporary;
        TempPOSEntry: Record "NPR POS Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin
        Clear(TempPOSEntry);
        Evaluate(TempPOSEntry."External Source Name", NpXmlDomMgt.GetXmlText(Element, 'sourcename', 0, false), 9);
        Evaluate(TempPOSEntry."External Source Entry No.", NpXmlDomMgt.GetXmlText(Element, 'entryno', 0, false), 9);
        Evaluate(TempPOSEntry."POS Store Code", NpXmlDomMgt.GetXmlText(Element, 'posstorecode', 0, false), 9);
        Evaluate(TempPOSEntry."POS Unit No.", NpXmlDomMgt.GetXmlText(Element, 'posunitno', 0, false), 9);
        Evaluate(TempPOSEntry."Document No.", NpXmlDomMgt.GetXmlText(Element, 'posdocumentno', 0, false), 9);
        Evaluate(TempPOSEntry."Entry Type", NpXmlDomMgt.GetXmlText(Element, 'entrytype', 0, false), 9);
        Evaluate(TempPOSEntry."Entry Date", NpXmlDomMgt.GetXmlText(Element, 'entrydate', 0, false), 9);
        Evaluate(TempPOSEntry."Starting Time", NpXmlDomMgt.GetXmlText(Element, 'startingtime', 0, false), 9);
        Evaluate(TempPOSEntry."Ending Time", NpXmlDomMgt.GetXmlText(Element, 'endingtime', 0, false), 9);
        Evaluate(TempPOSEntry.Description, NpXmlDomMgt.GetXmlText(Element, 'description', 0, false), 9);
        Evaluate(TempPOSEntry."Customer No.", NpXmlDomMgt.GetXmlText(Element, 'customerno', 0, false), 9);
        Evaluate(TempPOSEntry."System Entry", NpXmlDomMgt.GetXmlText(Element, 'systementry', 0, false), 9);
        if NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension1code', 0, false) <> '' then
            Evaluate(TempPOSEntry."Shortcut Dimension 1 Code", NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension1code', 0, false), 9);
        Evaluate(TempPOSEntry."System Entry", NpXmlDomMgt.GetXmlText(Element, 'systementry', 0, false), 9);
        if NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension2code', 0, false) <> '' then
            Evaluate(TempPOSEntry."Shortcut Dimension 2 Code", NpXmlDomMgt.GetXmlText(Element, 'shortcutdomension2code', 0, false), 9);
        Evaluate(TempPOSEntry."Salesperson Code", NpXmlDomMgt.GetXmlText(Element, 'salespersoncode', 0, false), 9);
        Evaluate(TempPOSEntry."No. Printed", NpXmlDomMgt.GetXmlText(Element, 'noprinted', 0, false), 9);
        Evaluate(TempPOSEntry."Post Item Entry Status", NpXmlDomMgt.GetXmlText(Element, 'postitementrystatus', 0, false), 9);
        Evaluate(TempPOSEntry."Post Entry Status", NpXmlDomMgt.GetXmlText(Element, 'postentrystatus', 0, false), 9);
        Evaluate(TempPOSEntry."Posting Date", NpXmlDomMgt.GetXmlText(Element, 'postingdate', 0, false), 9);
        Evaluate(TempPOSEntry."Document Date", NpXmlDomMgt.GetXmlText(Element, 'documentdate', 0, false), 9);
        Evaluate(TempPOSEntry."Currency Code", NpXmlDomMgt.GetXmlText(Element, 'currencycode', 0, false), 9);
        Evaluate(TempPOSEntry."Currency Factor", NpXmlDomMgt.GetXmlText(Element, 'currencyfactor', 0, false), 9);
        Evaluate(TempPOSEntry."Item Sales (LCY)", NpXmlDomMgt.GetXmlText(Element, 'salesamount', 0, false), 9);
        Evaluate(TempPOSEntry."Discount Amount", NpXmlDomMgt.GetXmlText(Element, 'discountamount', 0, false), 9);
        Evaluate(TempPOSEntry."Sales Quantity", NpXmlDomMgt.GetXmlText(Element, 'salesquantity', 0, false), 9);
        Evaluate(TempPOSEntry."Return Sales Quantity", NpXmlDomMgt.GetXmlText(Element, 'returnsalesquantity', 0, false), 9);
        Evaluate(TempPOSEntry."Amount Excl. Tax", NpXmlDomMgt.GetXmlText(Element, 'totalamount', 0, false), 9);
        Evaluate(TempPOSEntry."Tax Amount", NpXmlDomMgt.GetXmlText(Element, 'totaltaxamount', 0, false), 9);
        Evaluate(TempPOSEntry."Amount Incl. Tax", NpXmlDomMgt.GetXmlText(Element, 'totalamountincltax', 0, false), 9);
        Evaluate(TempPOSEntry."Rounding Amount (LCY)", NpXmlDomMgt.GetXmlText(Element, 'roundingamountLCY', 0, false), 9);
        Evaluate(TempPOSEntry."Tax Area Code", NpXmlDomMgt.GetXmlText(Element, 'taxareacode', 0, false), 9);
        Evaluate(TempPOSEntry.SystemId, NpXmlDomMgt.GetXmlText(Element, 'possaleid', 0, false), 9);
        Evaluate(TempPOSEntry."Customer Posting Group", NpXmlDomMgt.GetXmlText(Element, 'customerpostinggroup', 0, false), 9);
        Evaluate(TempPOSEntry."Country/Region Code", NpXmlDomMgt.GetXmlText(Element, 'countryregioncode', 0, false), 9);
        Evaluate(TempPOSEntry."Transaction Type", NpXmlDomMgt.GetXmlText(Element, 'transactiontype', 0, false), 9);
        Evaluate(TempPOSEntry."Transport Method", NpXmlDomMgt.GetXmlText(Element, 'transportmethod', 0, false), 9);
        Evaluate(TempPOSEntry."Exit Point", NpXmlDomMgt.GetXmlText(Element, 'exitpoint', 0, false), 9);
        Evaluate(TempPOSEntry.Area, NpXmlDomMgt.GetXmlText(Element, 'area', 0, false), 9);
        Evaluate(TempPOSEntry."Transaction Specification", NpXmlDomMgt.GetXmlText(Element, 'transactionscpecification', 0, false), 9);
        Evaluate(TempPOSEntry."Prices Including VAT", NpXmlDomMgt.GetXmlText(Element, 'pricesincludevat', 0, false), 9);
        Evaluate(TempPOSEntry."Reason Code", NpXmlDomMgt.GetXmlText(Element, 'reasoncode', 0, false), 9);
        if NpXmlDomMgt.GetXmlText(Element, 'dimensionsetid', 0, false) <> '' then
            Evaluate(TempPOSEntry."Dimension Set ID", NpXmlDomMgt.GetXmlText(Element, 'dimensionsetid', 0, false), 9);
        Evaluate(TempPOSEntry."Sales Document Type", NpXmlDomMgt.GetXmlText(Element, 'salesdocumenttype', 0, false), 9);
        Evaluate(TempPOSEntry."Sales Document No.", NpXmlDomMgt.GetXmlText(Element, 'salesdocumentno', 0, false), 9);
        Evaluate(TempPOSEntry."Contact No.", NpXmlDomMgt.GetXmlText(Element, 'contactno', 0, false), 9);

        if NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'posentrydimension', NodeList) then
            foreach Node in NodeList do
                BuildDimensionBuffer(Node.AsXmlElement(), TempDimensionBuffer);
        if not TempDimensionBuffer.IsEmpty then begin
            //Dimensions always overrule shortcuts etc.
            TempPOSEntry."Dimension Set ID" := DimensionManagement.CreateDimSetIDFromDimBuf(TempDimensionBuffer);
            DimensionManagement.UpdateGlobalDimFromDimSetID(
              TempPOSEntry."Dimension Set ID",
              TempPOSEntry."Shortcut Dimension 1 Code",
              TempPOSEntry."Shortcut Dimension 2 Code");
        end;

        //Record insert
        TempPOSEntry.TestField("External Source Entry No.");
        POSEntry.SetRange("From External Source", true);
        POSEntry.SetRange("External Source Name", TempPOSEntry."External Source Name");
        POSEntry.SetRange("External Source Entry No.", TempPOSEntry."External Source Entry No.");
        if POSEntry.FindFirst() then
            Error(Text001, POSEntry.TableCaption, POSEntry.FieldCaption("External Source Name"), POSEntry."External Source Name", POSEntry.FieldCaption("External Source Entry No."), POSEntry."External Source Entry No.");

        POSEntry.TransferFields(TempPOSEntry);
        POSEntry."Entry No." := 0;
        POSEntry."From External Source" := true;
        POSEntry.Insert(false, true);
    end;

    local procedure UpdatePOSLedgerRegister(Element: XmlElement; var POSEntry: Record "NPR POS Entry")
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        TempPOSPeriodRegister: Record "NPR POS Period Register" temporary;
    begin
        Evaluate(TempPOSPeriodRegister."External Source Entry No.", NpXmlDomMgt.GetXmlText(Element, 'posledgerregisterno', 0, false), 9);
        Evaluate(TempPOSPeriodRegister."Document No.", NpXmlDomMgt.GetXmlText(Element, 'posledgerregisterdocno', 0, false), 9);
        Evaluate(TempPOSPeriodRegister."No. Series", NpXmlDomMgt.GetXmlText(Element, 'noseries', 0, false), 9);
        Evaluate(TempPOSPeriodRegister."Opening Entry No.", NpXmlDomMgt.GetXmlText(Element, 'openingentryno', 0, false), 9);
        Evaluate(TempPOSPeriodRegister."Closing Entry No.", NpXmlDomMgt.GetXmlText(Element, 'closingentryno', 0, false), 9);
        Evaluate(TempPOSPeriodRegister.Status, NpXmlDomMgt.GetXmlText(Element, 'posledgerregisterstatus', 0, false), 9);
        Evaluate(TempPOSPeriodRegister."Posting Compression", NpXmlDomMgt.GetXmlText(Element, 'pospostingcompression', 0, false), 9);
        Evaluate(TempPOSPeriodRegister."Opened Date", NpXmlDomMgt.GetXmlText(Element, 'openeddate', 0, false), 9);
        Evaluate(TempPOSPeriodRegister."End of Day Date", NpXmlDomMgt.GetXmlText(Element, 'endofdaydate', 0, false), 9);

        //Record insert
        POSPeriodRegister.SetRange("From External Source", true);
        POSPeriodRegister.SetRange("External Source Name", POSEntry."External Source Name");
        POSPeriodRegister.SetRange("External Source Entry No.", TempPOSPeriodRegister."External Source Entry No.");
        if not POSPeriodRegister.FindFirst() then begin
            POSPeriodRegister."No." := 0;
            POSPeriodRegister."External Source Name" := POSEntry."External Source Name";
            POSPeriodRegister."From External Source" := true;
            POSPeriodRegister.Insert();
        end;
        POSPeriodRegister.TransferFields(TempPOSPeriodRegister, false);
        POSPeriodRegister.Modify();

        POSEntry."POS Period Register No." := POSPeriodRegister."No.";
    end;

    local procedure InsertPOSSalesLine(Element: XmlElement; var POSEntry: Record "NPR POS Entry")
    var
        TempPOSSalesLine: Record "NPR POS Entry Sales Line" temporary;
        POSSalesLine: Record "NPR POS Entry Sales Line";
        OrigPOSEntry: Record "NPR POS Entry";
        TempDimensionBuffer: Record "Dimension Buffer" temporary;
        DimensionManagement: Codeunit DimensionManagement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin
        POSEntry.TestField("Entry No.");
        Evaluate(TempPOSSalesLine."Line No.", NpXmlDomMgt.GetXmlText(Element, 'lineno', 0, false), 9);
        Evaluate(TempPOSSalesLine.Type, NpXmlDomMgt.GetXmlText(Element, 'type', 0, false), 9);
        Evaluate(TempPOSSalesLine."No.", NpXmlDomMgt.GetXmlText(Element, 'no', 0, false), 9);
        Evaluate(TempPOSSalesLine."Location Code", NpXmlDomMgt.GetXmlText(Element, 'locationcode', 0, false), 9);
        Evaluate(TempPOSSalesLine."Posting Group", NpXmlDomMgt.GetXmlText(Element, 'postinggroup', 0, false), 9);
        Evaluate(TempPOSSalesLine.Description, NpXmlDomMgt.GetXmlText(Element, 'description', 0, false), 9);
        Evaluate(TempPOSSalesLine.Quantity, NpXmlDomMgt.GetXmlText(Element, 'quantity', 0, false), 9);
        Evaluate(TempPOSSalesLine."Customer No.", NpXmlDomMgt.GetXmlText(Element, 'customerno', 0, false), 9);
        Evaluate(TempPOSSalesLine."Unit Price", NpXmlDomMgt.GetXmlText(Element, 'unitprice', 0, false), 9);
        Evaluate(TempPOSSalesLine."Unit Cost (LCY)", NpXmlDomMgt.GetXmlText(Element, 'unitcostlcy', 0, false), 9);
        Evaluate(TempPOSSalesLine."VAT %", NpXmlDomMgt.GetXmlText(Element, 'vatperc', 0, false), 9);
        Evaluate(TempPOSSalesLine."Line Discount %", NpXmlDomMgt.GetXmlText(Element, 'linediscountperc', 0, false), 9);
        Evaluate(TempPOSSalesLine."Line Discount Amount Excl. VAT", NpXmlDomMgt.GetXmlText(Element, 'linediscountamountexclvat', 0, false), 9);
        Evaluate(TempPOSSalesLine."Line Discount Amount Incl. VAT", NpXmlDomMgt.GetXmlText(Element, 'linediscountamountinclvat', 0, false), 9);
        Evaluate(TempPOSSalesLine."Amount Excl. VAT", NpXmlDomMgt.GetXmlText(Element, 'amountexclvat', 0, false), 9);
        Evaluate(TempPOSSalesLine."Amount Incl. VAT", NpXmlDomMgt.GetXmlText(Element, 'amountinclvat', 0, false), 9);
        Evaluate(TempPOSSalesLine."Line Dsc. Amt. Excl. VAT (LCY)", NpXmlDomMgt.GetXmlText(Element, 'linediscamountexclvatlcy', 0, false), 9);
        Evaluate(TempPOSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)", NpXmlDomMgt.GetXmlText(Element, 'linediscamountinclvatlcy', 0, false), 9);
        Evaluate(TempPOSSalesLine."Amount Excl. VAT (LCY)", NpXmlDomMgt.GetXmlText(Element, 'amountexclvatlcy', 0, false), 9);
        Evaluate(TempPOSSalesLine."Amount Incl. VAT (LCY)", NpXmlDomMgt.GetXmlText(Element, 'amountinclvatlcy', 0, false), 9);
        Evaluate(TempPOSSalesLine."Appl.-to Item Entry", NpXmlDomMgt.GetXmlText(Element, 'applytoentryno', 0, false), 9);
        Evaluate(TempPOSSalesLine."Item Entry No.", NpXmlDomMgt.GetXmlText(Element, 'itementryno', 0, false), 9);
        if NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension1', 0, false) <> '' then
            Evaluate(TempPOSSalesLine."Shortcut Dimension 1 Code", NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension1', 0, false), 9);
        if NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension2', 0, false) <> '' then
            Evaluate(TempPOSSalesLine."Shortcut Dimension 2 Code", NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension2', 0, false), 9);
        Evaluate(TempPOSSalesLine."Salesperson Code", NpXmlDomMgt.GetXmlText(Element, 'salespersoncode', 0, false), 9);
        Evaluate(TempPOSSalesLine."Withhold Item", NpXmlDomMgt.GetXmlText(Element, 'witholditem', 0, false), 9);
        Evaluate(TempPOSSalesLine."Move to Location", NpXmlDomMgt.GetXmlText(Element, 'movetolocation', 0, false), 9);
        Evaluate(TempPOSSalesLine."Currency Code", NpXmlDomMgt.GetXmlText(Element, 'currencycode', 0, false), 9);
        Evaluate(TempPOSSalesLine."Gen. Bus. Posting Group", NpXmlDomMgt.GetXmlText(Element, 'genbuspostinggroup', 0, false), 9);
        Evaluate(TempPOSSalesLine."Gen. Prod. Posting Group", NpXmlDomMgt.GetXmlText(Element, 'genprodpostinggroup', 0, false), 9);
        Evaluate(TempPOSSalesLine."VAT Calculation Type", NpXmlDomMgt.GetXmlText(Element, 'vatcalculationtype', 0, false), 9);
        Evaluate(TempPOSSalesLine."Gen. Posting Type", NpXmlDomMgt.GetXmlText(Element, 'genpostingtype', 0, false), 9);
        Evaluate(TempPOSSalesLine."Tax Area Code", NpXmlDomMgt.GetXmlText(Element, 'taxareacode', 0, false), 9);
        Evaluate(TempPOSSalesLine."Tax Liable", NpXmlDomMgt.GetXmlText(Element, 'taxliable', 0, false), 9);
        Evaluate(TempPOSSalesLine."Tax Group Code", NpXmlDomMgt.GetXmlText(Element, 'taxgroupcode', 0, false), 9);
        Evaluate(TempPOSSalesLine."Use Tax", NpXmlDomMgt.GetXmlText(Element, 'usetax', 0, false), 9);
        Evaluate(TempPOSSalesLine."VAT Bus. Posting Group", NpXmlDomMgt.GetXmlText(Element, 'vatbuspostinggroup', 0, false), 9);
        Evaluate(TempPOSSalesLine."VAT Prod. Posting Group", NpXmlDomMgt.GetXmlText(Element, 'vatprodpostinggroup', 0, false), 9);
        Evaluate(TempPOSSalesLine."VAT Base Amount", NpXmlDomMgt.GetXmlText(Element, 'vatbaseamount', 0, false), 9);
        Evaluate(TempPOSSalesLine."Unit Cost", NpXmlDomMgt.GetXmlText(Element, 'unitcost', 0, false), 9);
        Evaluate(TempPOSSalesLine."VAT Difference", NpXmlDomMgt.GetXmlText(Element, 'vatdifference', 0, false), 9);
        Evaluate(TempPOSSalesLine."VAT Identifier", NpXmlDomMgt.GetXmlText(Element, 'vatidentifier', 0, false), 9);
        Evaluate(TempPOSSalesLine."Sales Document Type", NpXmlDomMgt.GetXmlText(Element, 'salesdocumenttype', 0, false), 9);
        Evaluate(TempPOSSalesLine."Sales Document No.", NpXmlDomMgt.GetXmlText(Element, 'salesdocumentno', 0, false), 9);
        Evaluate(TempPOSSalesLine."Sales Document Line No.", NpXmlDomMgt.GetXmlText(Element, 'salesdocumentline', 0, false), 9);
        Evaluate(TempPOSSalesLine.SystemId, NpXmlDomMgt.GetXmlText(Element, 'origpossaleid', 0, false), 9);
        Evaluate(TempPOSSalesLine."Bin Code", NpXmlDomMgt.GetXmlText(Element, 'bincode', 0, false), 9);
        Evaluate(TempPOSSalesLine."Qty. per Unit of Measure", NpXmlDomMgt.GetXmlText(Element, 'qtyerunitofmeasure', 0, false), 9);
        Evaluate(TempPOSSalesLine."Cross-Reference No.", NpXmlDomMgt.GetXmlText(Element, 'crossreferenceno', 0, false), 9);
        Evaluate(TempPOSSalesLine."Originally Ordered No.", NpXmlDomMgt.GetXmlText(Element, 'origninallyorderedno', 0, false), 9);
        Evaluate(TempPOSSalesLine."Originally Ordered Var. Code", NpXmlDomMgt.GetXmlText(Element, 'origninallyorderedvariantcode', 0, false), 9);
        Evaluate(TempPOSSalesLine."Out-of-Stock Substitution", NpXmlDomMgt.GetXmlText(Element, 'outofstocksubstitute', 0, false), 9);
        Evaluate(TempPOSSalesLine."Purchasing Code", NpXmlDomMgt.GetXmlText(Element, 'purchasingcode', 0, false), 9);
        Evaluate(TempPOSSalesLine."Planned Delivery Date", NpXmlDomMgt.GetXmlText(Element, 'planneddeliverydate', 0, false), 9);
        Evaluate(TempPOSSalesLine."Reason Code", NpXmlDomMgt.GetXmlText(Element, 'reasoncode', 0, false), 9);
        Evaluate(TempPOSSalesLine."Discount Type", NpXmlDomMgt.GetXmlText(Element, 'discounttype', 0, false), 9);
        Evaluate(TempPOSSalesLine."Discount Code", NpXmlDomMgt.GetXmlText(Element, 'discountcode', 0, false), 9);
        TempPOSSalesLine."Discount Authorised by" := NpXmlDomMgt.GetXmlText(Element, 'discountauthorisedby', MaxStrLen(TempPOSSalesLine."Discount Authorised by"), false);
        if NpXmlDomMgt.GetXmlText(Element, 'dimensionsetid', 0, false) <> '' then
            Evaluate(TempPOSSalesLine."Dimension Set ID", NpXmlDomMgt.GetXmlText(Element, 'dimensionsetid', 0, false), 9);
        Evaluate(TempPOSSalesLine."Variant Code", NpXmlDomMgt.GetXmlText(Element, 'variantcode', 0, false), 9);
        Evaluate(TempPOSSalesLine."Unit of Measure Code", NpXmlDomMgt.GetXmlText(Element, 'unitofmeasurecode', 0, false), 9);
        Evaluate(TempPOSSalesLine."Quantity (Base)", NpXmlDomMgt.GetXmlText(Element, 'quantitybase', 0, false), 9);
        Evaluate(TempPOSSalesLine."Item Category Code", NpXmlDomMgt.GetXmlText(Element, 'itemcategorycode', 0, false), 9);
        Evaluate(TempPOSSalesLine.Nonstock, NpXmlDomMgt.GetXmlText(Element, 'nonstock', 0, false), 9);
        Evaluate(TempPOSSalesLine."BOM Item No.", NpXmlDomMgt.GetXmlText(Element, 'bomitemno', 0, false), 9);
        Evaluate(TempPOSSalesLine."Serial No.", NpXmlDomMgt.GetXmlText(Element, 'serailno', 0, false), 9);
        Evaluate(TempPOSSalesLine."Lot No.", NpXmlDomMgt.GetXmlText(Element, 'lotno', 0, false), 9);
        Evaluate(TempPOSSalesLine."Return Reason Code", NpXmlDomMgt.GetXmlText(Element, 'returnreasoncode', 0, false), 9);

        if NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'possaleslinedimension', NodeList) then
            foreach Node in NodeList do
                BuildDimensionBuffer(Node.AsXmlElement(), TempDimensionBuffer);
        if not TempDimensionBuffer.IsEmpty then begin
            //Dimensions always overrule shortcuts etc.
            TempPOSSalesLine."Dimension Set ID" := DimensionManagement.CreateDimSetIDFromDimBuf(TempDimensionBuffer);
            DimensionManagement.UpdateGlobalDimFromDimSetID(
              TempPOSSalesLine."Dimension Set ID",
              TempPOSSalesLine."Shortcut Dimension 1 Code",
              TempPOSSalesLine."Shortcut Dimension 2 Code");
        end;

        POSSalesLine.TransferFields(TempPOSSalesLine);
        POSSalesLine."POS Entry No." := POSEntry."Entry No.";
        POSSalesLine."Line No." := POSSalesLine."Line No.";
        POSSalesLine."POS Store Code" := POSEntry."POS Store Code";
        POSSalesLine."POS Unit No." := POSEntry."POS Unit No.";
        POSSalesLine."Document No." := POSEntry."Document No.";
        POSSalesLine."POS Period Register No." := POSEntry."POS Period Register No.";
        POSSalesLine."Appl.-to Item Entry" := 0;
        POSSalesLine."Item Entry No." := 0;
        POSSalesLine.Insert(false, true);
    end;

    local procedure InsertPOSPaymentLine(Element: XmlElement; var POSEntry: Record "NPR POS Entry")
    var
        TempPOSPaymentLine: Record "NPR POS Entry Payment Line" temporary;
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        OrigPOSEntry: Record "NPR POS Entry";
        TempDimensionBuffer: Record "Dimension Buffer" temporary;
        DimensionManagement: Codeunit DimensionManagement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin
        POSEntry.TestField("Entry No.");
        Evaluate(TempPOSPaymentLine."Line No.", NpXmlDomMgt.GetXmlText(Element, 'lineno', 0, false), 9);
        Evaluate(TempPOSPaymentLine."POS Payment Method Code", NpXmlDomMgt.GetXmlText(Element, 'pospaymentmethodcode', 0, false), 9);
        Evaluate(TempPOSPaymentLine."POS Payment Bin Code", NpXmlDomMgt.GetXmlText(Element, 'pospaymentbincode', 0, false), 9);
        Evaluate(TempPOSPaymentLine.Description, NpXmlDomMgt.GetXmlText(Element, 'description', 0, false), 9);
        Evaluate(TempPOSPaymentLine.Amount, NpXmlDomMgt.GetXmlText(Element, 'amount', 0, false), 9);
        Evaluate(TempPOSPaymentLine."Payment Fee %", NpXmlDomMgt.GetXmlText(Element, 'paymentfeeperc', 0, false), 9);
        Evaluate(TempPOSPaymentLine."Payment Fee Amount", NpXmlDomMgt.GetXmlText(Element, 'paymentfeeamount', 0, false), 9);
        Evaluate(TempPOSPaymentLine."Payment Amount", NpXmlDomMgt.GetXmlText(Element, 'paymentamount', 0, false), 9);
        Evaluate(TempPOSPaymentLine."Payment Fee % (Non-invoiced)", NpXmlDomMgt.GetXmlText(Element, 'paymentfeepercnoninvoiced', 0, false), 9);
        Evaluate(TempPOSPaymentLine."Payment Fee Amount (Non-inv.)", NpXmlDomMgt.GetXmlText(Element, 'paymentfeeamountnoninvoiced', 0, false), 9);
        Evaluate(TempPOSPaymentLine."Currency Code", NpXmlDomMgt.GetXmlText(Element, 'currencycode', 0, false), 9);
        if NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension1code', 0, false) <> '' then
            Evaluate(TempPOSPaymentLine."Shortcut Dimension 1 Code", NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension1code', 0, false), 9);
        if NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension2code', 0, false) <> '' then
            Evaluate(TempPOSPaymentLine."Shortcut Dimension 2 Code", NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension2code', 0, false), 9);
        Evaluate(TempPOSPaymentLine."Amount (LCY)", NpXmlDomMgt.GetXmlText(Element, 'amountlcy', 0, false), 9);
        Evaluate(TempPOSPaymentLine."Amount (Sales Currency)", NpXmlDomMgt.GetXmlText(Element, 'amoundsalescurrency', 0, false), 9);
        Evaluate(TempPOSPaymentLine."Rounding Amount", NpXmlDomMgt.GetXmlText(Element, 'roundingamount', 0, false), 9);
        Evaluate(TempPOSPaymentLine."Rounding Amount (Sales Curr.)", NpXmlDomMgt.GetXmlText(Element, 'roundingamountsalescurr', 0, false), 9);
        Evaluate(TempPOSPaymentLine."Rounding Amount (LCY)", NpXmlDomMgt.GetXmlText(Element, 'roundingamountlcy', 0, false), 9);
        Evaluate(TempPOSPaymentLine."Applies-to Doc. Type", NpXmlDomMgt.GetXmlText(Element, 'appliestodoctype', 0, false), 9);
        Evaluate(TempPOSPaymentLine."Applies-to Doc. No.", NpXmlDomMgt.GetXmlText(Element, 'appliestodocno', 0, false), 9);
        Evaluate(TempPOSPaymentLine."External Document No.", NpXmlDomMgt.GetXmlText(Element, 'externaldocno', 0, false), 9);
        Evaluate(TempPOSPaymentLine.SystemId, NpXmlDomMgt.GetXmlText(Element, 'origpossaleid', 0, false), 9);
        if NpXmlDomMgt.GetXmlText(Element, 'dimensionsetid', 0, false) <> '' then
            Evaluate(TempPOSPaymentLine."Dimension Set ID", NpXmlDomMgt.GetXmlText(Element, 'dimensionsetid', 0, false), 9);
        Evaluate(TempPOSPaymentLine.EFT, NpXmlDomMgt.GetXmlText(Element, 'eft', 0, false), 9);
        Evaluate(TempPOSPaymentLine."EFT Refundable", NpXmlDomMgt.GetXmlText(Element, 'eftrefundable', 0, false), 9);
        Evaluate(TempPOSPaymentLine.Token, NpXmlDomMgt.GetXmlText(Element, 'token', 0, false), 9);

        if NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'pospaymentlinedimension', NodeList) then
            foreach Node in NodeList do
                BuildDimensionBuffer(Node.AsXmlElement(), TempDimensionBuffer);
        if not TempDimensionBuffer.IsEmpty then begin
            //Dimensions always overrule shortcuts etc.
            TempPOSPaymentLine."Dimension Set ID" := DimensionManagement.CreateDimSetIDFromDimBuf(TempDimensionBuffer);
            DimensionManagement.UpdateGlobalDimFromDimSetID(
              TempPOSPaymentLine."Dimension Set ID",
              TempPOSPaymentLine."Shortcut Dimension 1 Code",
              TempPOSPaymentLine."Shortcut Dimension 2 Code");
        end;

        POSPaymentLine.TransferFields(TempPOSPaymentLine);
        POSPaymentLine."POS Entry No." := POSEntry."Entry No.";
        POSPaymentLine."Line No." := TempPOSPaymentLine."Line No.";
        POSPaymentLine."POS Store Code" := POSEntry."POS Store Code";
        POSPaymentLine."POS Unit No." := POSEntry."POS Unit No.";
        POSPaymentLine."Document No." := POSEntry."Document No.";
        POSPaymentLine."POS Period Register No." := POSEntry."POS Period Register No.";
        POSPaymentLine.Insert(false, true);
    end;

    local procedure InsertPOSTaxAmountLine(Element: XmlElement; var POSEntry: Record "NPR POS Entry")
    var
        TempPOSTaxAmountLine: Record "NPR POS Entry Tax Line" temporary;
        POSTaxAmountLine: Record "NPR POS Entry Tax Line";
        OStream: OutStream;
    begin
        POSEntry.TestField("Entry No.");
        Evaluate(TempPOSTaxAmountLine."Tax Area Code", NpXmlDomMgt.GetXmlText(Element, 'lineno', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Tax Jurisdiction Code", NpXmlDomMgt.GetXmlText(Element, 'taxjurisdictioncode', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."VAT Identifier", NpXmlDomMgt.GetXmlText(Element, 'vatidentifier', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Tax Calculation Type", NpXmlDomMgt.GetXmlText(Element, 'taxcalculationtype', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Tax Group Code", NpXmlDomMgt.GetXmlText(Element, 'taxgroupcode', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine.Quantity, NpXmlDomMgt.GetXmlText(Element, 'quantity', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine.Modified, NpXmlDomMgt.GetXmlText(Element, 'modified', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Use Tax", NpXmlDomMgt.GetXmlText(Element, 'usetax', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Calculated Tax Amount", NpXmlDomMgt.GetXmlText(Element, 'calculatedtaxamount', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Tax Difference", NpXmlDomMgt.GetXmlText(Element, 'taxdifference', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Tax Type", NpXmlDomMgt.GetXmlText(Element, 'taxtype', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Tax Liable", NpXmlDomMgt.GetXmlText(Element, 'taxliable', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Tax Area Code for Key", NpXmlDomMgt.GetXmlText(Element, 'taxareacodeforkey', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Invoice Discount Amount", NpXmlDomMgt.GetXmlText(Element, 'invoicediscountamount', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Inv. Disc. Base Amount", NpXmlDomMgt.GetXmlText(Element, 'invdiscbaseamount', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Tax %", NpXmlDomMgt.GetXmlText(Element, 'taxperc', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Tax Base Amount", NpXmlDomMgt.GetXmlText(Element, 'taxbaseamount', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Tax Amount", NpXmlDomMgt.GetXmlText(Element, 'taxamount', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Amount Including Tax", NpXmlDomMgt.GetXmlText(Element, 'amountincludingtax', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Line Amount", NpXmlDomMgt.GetXmlText(Element, 'lineamount', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Expense/Capitalize", NpXmlDomMgt.GetXmlText(Element, 'expensecapitalize', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Print Order", NpXmlDomMgt.GetXmlText(Element, 'printorder', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Print Description", NpXmlDomMgt.GetXmlText(Element, 'printdescription', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Calculation Order", NpXmlDomMgt.GetXmlText(Element, 'calcluationorder', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Round Tax", NpXmlDomMgt.GetXmlText(Element, 'roundtax', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Is Report-to Jurisdiction", NpXmlDomMgt.GetXmlText(Element, 'isreporttojurisdiction', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine.Positive, NpXmlDomMgt.GetXmlText(Element, 'positive', 0, false), 9);
        Evaluate(TempPOSTaxAmountLine."Tax Base Amount FCY", NpXmlDomMgt.GetXmlText(Element, 'taxbaseamountfcy', 0, false), 9);

        POSTaxAmountLine.TransferFields(TempPOSTaxAmountLine);
        POSTaxAmountLine."POS Entry No." := POSEntry."Entry No.";
        POSTaxAmountLine."Tax Area Code for Key" := TempPOSTaxAmountLine."Tax Area Code for Key";
        POSTaxAmountLine."Tax Jurisdiction Code" := TempPOSTaxAmountLine."Tax Jurisdiction Code";
        POSTaxAmountLine."VAT Identifier" := TempPOSTaxAmountLine."VAT Identifier";
        POSTaxAmountLine."Tax %" := TempPOSTaxAmountLine."Tax %";
        POSTaxAmountLine."Tax Group Code" := TempPOSTaxAmountLine."Tax Group Code";
        POSTaxAmountLine."Expense/Capitalize" := TempPOSTaxAmountLine."Expense/Capitalize";
        POSTaxAmountLine."Tax Type" := TempPOSTaxAmountLine."Tax Type";
        POSTaxAmountLine."Use Tax" := TempPOSTaxAmountLine."Use Tax";
        POSTaxAmountLine.Positive := TempPOSTaxAmountLine.Positive;
        POSTaxAmountLine.Insert();
    end;

    local procedure InsertPOSBalancingLine(Element: XmlElement; var POSEntry: Record "NPR POS Entry")
    var
        TempPOSBalancingLine: Record "NPR POS Balancing Line" temporary;
        POSBalancingLine: Record "NPR POS Balancing Line";
        TempDimensionBuffer: Record "Dimension Buffer" temporary;
        DimensionManagement: Codeunit DimensionManagement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin
        POSEntry.TestField("Entry No.");
        Evaluate(TempPOSBalancingLine."Line No.", NpXmlDomMgt.GetXmlText(Element, 'lineno', 0, false), 9);
        Evaluate(TempPOSBalancingLine."POS Payment Bin Code", NpXmlDomMgt.GetXmlText(Element, 'pospaymentbincode', 0, false), 9);
        Evaluate(TempPOSBalancingLine."POS Payment Method Code", NpXmlDomMgt.GetXmlText(Element, 'pospaymentmethodcode', 0, false), 9);
        Evaluate(TempPOSBalancingLine."Calculated Amount", NpXmlDomMgt.GetXmlText(Element, 'calculatedamount', 0, false), 9);
        Evaluate(TempPOSBalancingLine."Balanced Amount", NpXmlDomMgt.GetXmlText(Element, 'balancedamount', 0, false), 9);
        Evaluate(TempPOSBalancingLine."Balanced Diff. Amount", NpXmlDomMgt.GetXmlText(Element, 'balanceddiffamount', 0, false), 9);
        Evaluate(TempPOSBalancingLine."New Float Amount", NpXmlDomMgt.GetXmlText(Element, 'newfloatamount', 0, false), 9);
        if NpXmlDomMgt.GetXmlText(Element, 'shortcuddimension1code', 0, false) <> '' then
            Evaluate(TempPOSBalancingLine."Shortcut Dimension 1 Code", NpXmlDomMgt.GetXmlText(Element, 'shortcuddimension1code', 0, false), 9);
        if NpXmlDomMgt.GetXmlText(Element, 'shortcuddimension2code', 0, false) <> '' then
            Evaluate(TempPOSBalancingLine."Shortcut Dimension 2 Code", NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension2code', 0, false), 9);
        Evaluate(TempPOSBalancingLine."Calculated Quantity", NpXmlDomMgt.GetXmlText(Element, 'calculatedquantity', 0, false), 9);
        Evaluate(TempPOSBalancingLine."Balanced Quantity", NpXmlDomMgt.GetXmlText(Element, 'balancedquantity', 0, false), 9);
        Evaluate(TempPOSBalancingLine."Balanced Diff. Quantity", NpXmlDomMgt.GetXmlText(Element, 'balanceddiffquantity', 0, false), 9);
        Evaluate(TempPOSBalancingLine."Deposited Quantity", NpXmlDomMgt.GetXmlText(Element, 'depositedquantity', 0, false), 9);
        Evaluate(TempPOSBalancingLine."Closing Quantity", NpXmlDomMgt.GetXmlText(Element, 'closingquantity', 0, false), 9);
        Evaluate(TempPOSBalancingLine.Description, NpXmlDomMgt.GetXmlText(Element, 'description', 0, false), 9);
        Evaluate(TempPOSBalancingLine."Deposit-To Bin Amount", NpXmlDomMgt.GetXmlText(Element, 'deposittobinamount', 0, false), 9);
        Evaluate(TempPOSBalancingLine."Deposit-To Bin Code", NpXmlDomMgt.GetXmlText(Element, 'deposittobincode', 0, false), 9);
        Evaluate(TempPOSBalancingLine."Deposit-To Reference", NpXmlDomMgt.GetXmlText(Element, 'deposittoreference', 0, false), 9);
        Evaluate(TempPOSBalancingLine."Move-To Bin Amount", NpXmlDomMgt.GetXmlText(Element, 'movetobinamount', 0, false), 9);
        Evaluate(TempPOSBalancingLine."Move-To Bin Code", NpXmlDomMgt.GetXmlText(Element, 'movetobincode', 0, false), 9);
        Evaluate(TempPOSBalancingLine."Move-To Reference", NpXmlDomMgt.GetXmlText(Element, 'movetoreference', 0, false), 9);
        Evaluate(TempPOSBalancingLine."Balancing Details", NpXmlDomMgt.GetXmlText(Element, 'balancingdetails', 0, false), 9);
        Evaluate(TempPOSBalancingLine.SystemId, NpXmlDomMgt.GetXmlText(Element, 'origpossaleid', 0, false), 9);
        Evaluate(TempPOSBalancingLine."POS Bin Checkpoint Entry No.", NpXmlDomMgt.GetXmlText(Element, 'posbincheckpointentryno', 0, false), 9);
        Evaluate(TempPOSBalancingLine."Currency Code", NpXmlDomMgt.GetXmlText(Element, 'currencycode', 0, false), 9);
        if NpXmlDomMgt.GetXmlText(Element, 'dimensionsetid', 0, false) <> '' then
            Evaluate(TempPOSBalancingLine."Dimension Set ID", NpXmlDomMgt.GetXmlText(Element, 'dimensionsetid', 0, false), 9);

        if NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'posbalancinglinedimension', NodeList) then
            foreach Node in NodeList do
                BuildDimensionBuffer(Node.AsXmlElement(), TempDimensionBuffer);
        if not TempDimensionBuffer.IsEmpty then begin
            TempPOSBalancingLine."Dimension Set ID" := DimensionManagement.CreateDimSetIDFromDimBuf(TempDimensionBuffer);
            DimensionManagement.UpdateGlobalDimFromDimSetID(
              TempPOSBalancingLine."Dimension Set ID",
              TempPOSBalancingLine."Shortcut Dimension 1 Code",
              TempPOSBalancingLine."Shortcut Dimension 2 Code");
        end;

        POSBalancingLine.TransferFields(TempPOSBalancingLine);
        POSBalancingLine."POS Entry No." := POSEntry."Entry No.";
        POSBalancingLine."Line No." := TempPOSBalancingLine."Line No.";
        POSBalancingLine."POS Store Code" := POSEntry."POS Store Code";
        POSBalancingLine."POS Unit No." := POSEntry."POS Unit No.";
        POSBalancingLine."Document No." := POSEntry."Document No.";
        POSBalancingLine."POS Period Register No." := POSEntry."POS Period Register No.";
        POSBalancingLine.Insert();
    end;

    local procedure BuildDimensionBuffer(Element: XmlElement; var DimensionBuffer: Record "Dimension Buffer")
    begin
        Evaluate(DimensionBuffer."Dimension Code", NpXmlDomMgt.GetXmlText(Element, 'dimensioncode', 0, false), 9);
        Evaluate(DimensionBuffer."Dimension Value Code", NpXmlDomMgt.GetXmlText(Element, 'dimensionvalue', 0, false), 9);
        DimensionBuffer.Insert();
    end;

    local procedure ResetPostingstatus(var POSEntry: Record "NPR POS Entry")
    begin
        if POSEntry."Post Entry Status" in [POSEntry."Post Entry Status"::"Error while Posting", POSEntry."Post Entry Status"::Posted] then
            POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::Unposted;
        if POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::"Error while Posting", POSEntry."Post Item Entry Status"::Posted] then
            POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::Unposted;
        POSEntry."POS Posting Log Entry No." := 0;
    end;
}

