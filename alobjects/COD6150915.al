codeunit 6150915 "HC POS Entry Management"
{
    // NPR5.39/BR  /20180212 CASE 295007 HQ Connector Created Object

    TableNo = "Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: DotNet XmlDocument;
    begin
        if LoadXmlDoc(XmlDoc) then
          ProcessPOSTransaction(XmlDoc);
    end;

    var
        NcSetup: Record "Nc Setup";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Initialized: Boolean;
        Text001: Label '%1 with %2: %3 and %4: %5 was already inserted.';

    local procedure ProcessPOSTransaction(XmlDoc: DotNet XmlDocument)
    var
        XmlElement: DotNet XmlElement;
        XmlNodeList: DotNet XmlNodeList;
        i: Integer;
    begin
        if IsNull(XmlDoc) then
          exit;

        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'InsertPOSEntry',XmlNodeList) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'posentryimport',XmlNodeList) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'postransaction',XmlNodeList) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'posentry',XmlNodeList) then
          exit;

        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement := XmlNodeList.ItemOf(i);
          ProcessPOSEntry(XmlElement)
        end;
    end;

    local procedure ProcessPOSEntry(POSEntryXmlElement: DotNet XmlElement) Imported: Boolean
    var
        POSEntry: Record "POS Entry";
        ChildXmlElement: DotNet XmlElement;
        XmlElement: DotNet XmlElement;
        XmlNodeList: DotNet XmlNodeList;
        i: Integer;
    begin
        if IsNull(POSEntryXmlElement) then
          exit(false);

        InsertPOSEntry(POSEntryXmlElement,POSEntry);

        if NpXmlDomMgt.FindNodes(POSEntryXmlElement,'posledgerregister',XmlNodeList) then
          for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            UpdatePOSLedgerRegister(XmlElement,POSEntry);
          end;

        if NpXmlDomMgt.FindNodes(POSEntryXmlElement,'possalesline',XmlNodeList) then
          for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            InsertPOSSalesLine(XmlElement,POSEntry);
          end;

        if NpXmlDomMgt.FindNodes(POSEntryXmlElement,'pospaymentline',XmlNodeList) then
          for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            InsertPOSPaymentLine(XmlElement,POSEntry);
          end;

        if NpXmlDomMgt.FindNodes(POSEntryXmlElement,'postaxamountline',XmlNodeList) then
          for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            InsertPOSTaxAmountLine(XmlElement,POSEntry);
          end;

        if NpXmlDomMgt.FindNodes(POSEntryXmlElement,'posbalancingline',XmlNodeList) then
          for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            InsertPOSBalancingLine(XmlElement,POSEntry);
          end;

        ResetPostingstatus(POSEntry);
        POSEntry.Modify;

        Commit;
        exit(true);
    end;

    local procedure InsertPOSEntry(XmlElement: DotNet XmlElement;var POSEntry: Record "POS Entry")
    var
        TempDimensionBuffer: Record "Dimension Buffer" temporary;
        TempPOSEntry: Record "POS Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
        OStream: OutStream;
        DimXmlElement: DotNet XmlElement;
        XmlNodeList: DotNet XmlNodeList;
        i: Integer;
    begin
        Clear(TempPOSEntry);
        Evaluate(TempPOSEntry."External Source Name",NpXmlDomMgt.GetXmlText(XmlElement,'sourcename',0,false),9);
        Evaluate(TempPOSEntry."External Source Entry No.",NpXmlDomMgt.GetXmlText(XmlElement,'entryno',0,false),9);
        Evaluate(TempPOSEntry."POS Store Code",NpXmlDomMgt.GetXmlText(XmlElement,'posstorecode',0,false),9);
        Evaluate(TempPOSEntry."POS Unit No.",NpXmlDomMgt.GetXmlText(XmlElement,'posunitno',0,false),9);
        Evaluate(TempPOSEntry."Document No.",NpXmlDomMgt.GetXmlText(XmlElement,'posdocumentno',0,false),9);
        Evaluate(TempPOSEntry."Entry Type",NpXmlDomMgt.GetXmlText(XmlElement,'entrytype',0,false),9);
        Evaluate(TempPOSEntry."Entry Date",NpXmlDomMgt.GetXmlText(XmlElement,'entrydate',0,false),9);
        Evaluate(TempPOSEntry."Starting Time",NpXmlDomMgt.GetXmlText(XmlElement,'startingtime',0,false),9);
        Evaluate(TempPOSEntry."Ending Time",NpXmlDomMgt.GetXmlText(XmlElement,'endingtime',0,false),9);
        Evaluate(TempPOSEntry.Description,NpXmlDomMgt.GetXmlText(XmlElement,'description',0,false),9);
        Evaluate(TempPOSEntry."Customer No.",NpXmlDomMgt.GetXmlText(XmlElement,'customerno',0,false),9);
        Evaluate(TempPOSEntry."System Entry",NpXmlDomMgt.GetXmlText(XmlElement,'systementry',0,false),9);
        if NpXmlDomMgt.GetXmlText(XmlElement,'shortcutdimension1code',0,false) <> '' then
          Evaluate(TempPOSEntry."Shortcut Dimension 1 Code",NpXmlDomMgt.GetXmlText(XmlElement,'shortcutdimension1code',0,false),9);
        Evaluate(TempPOSEntry."System Entry",NpXmlDomMgt.GetXmlText(XmlElement,'systementry',0,false),9);
        if NpXmlDomMgt.GetXmlText(XmlElement,'shortcutdimension2code',0,false) <> '' then
          Evaluate(TempPOSEntry."Shortcut Dimension 2 Code",NpXmlDomMgt.GetXmlText(XmlElement,'shortcutdomension2code',0,false),9);
        Evaluate(TempPOSEntry."Salesperson Code",NpXmlDomMgt.GetXmlText(XmlElement,'salespersoncode',0,false),9);
        Evaluate(TempPOSEntry."No. Printed",NpXmlDomMgt.GetXmlText(XmlElement,'noprinted',0,false),9);
        Evaluate(TempPOSEntry."Post Item Entry Status",NpXmlDomMgt.GetXmlText(XmlElement,'postitementrystatus',0,false),9);
        Evaluate(TempPOSEntry."Post Entry Status",NpXmlDomMgt.GetXmlText(XmlElement,'postentrystatus',0,false),9);
        Evaluate(TempPOSEntry."Posting Date",NpXmlDomMgt.GetXmlText(XmlElement,'postingdate',0,false),9);
        Evaluate(TempPOSEntry."Document Date",NpXmlDomMgt.GetXmlText(XmlElement,'documentdate',0,false),9);
        Evaluate(TempPOSEntry."Currency Code",NpXmlDomMgt.GetXmlText(XmlElement,'currencycode',0,false),9);
        Evaluate(TempPOSEntry."Currency Factor",NpXmlDomMgt.GetXmlText(XmlElement,'currencyfactor',0,false),9);
        Evaluate(TempPOSEntry."Sales Amount",NpXmlDomMgt.GetXmlText(XmlElement,'salesamount',0,false),9);
        Evaluate(TempPOSEntry."Discount Amount",NpXmlDomMgt.GetXmlText(XmlElement,'discountamount',0,false),9);
        Evaluate(TempPOSEntry."Sales Quantity",NpXmlDomMgt.GetXmlText(XmlElement,'salesquantity',0,false),9);
        Evaluate(TempPOSEntry."Return Sales Quantity",NpXmlDomMgt.GetXmlText(XmlElement,'returnsalesquantity',0,false),9);
        Evaluate(TempPOSEntry."Total Amount",NpXmlDomMgt.GetXmlText(XmlElement,'totalamount',0,false),9);
        Evaluate(TempPOSEntry."Total Tax Amount",NpXmlDomMgt.GetXmlText(XmlElement,'totaltaxamount',0,false),9);
        Evaluate(TempPOSEntry."Total Amount Incl. Tax",NpXmlDomMgt.GetXmlText(XmlElement,'totalamountincltax',0,false),9);
        Evaluate(TempPOSEntry."Rounding Amount (LCY)",NpXmlDomMgt.GetXmlText(XmlElement,'roundingamountLCY',0,false),9);
        Evaluate(TempPOSEntry."Tax Area Code",NpXmlDomMgt.GetXmlText(XmlElement,'taxareacode',0,false),9);
        Evaluate(TempPOSEntry."POS Sale ID",NpXmlDomMgt.GetXmlText(XmlElement,'possaleid',0,false),9);
        Evaluate(TempPOSEntry."Customer Posting Group",NpXmlDomMgt.GetXmlText(XmlElement,'customerpostinggroup',0,false),9);
        Evaluate(TempPOSEntry."Country/Region Code",NpXmlDomMgt.GetXmlText(XmlElement,'countryregioncode',0,false),9);
        Evaluate(TempPOSEntry."Transaction Type",NpXmlDomMgt.GetXmlText(XmlElement,'transactiontype',0,false),9);
        Evaluate(TempPOSEntry."Transport Method",NpXmlDomMgt.GetXmlText(XmlElement,'transportmethod',0,false),9);
        Evaluate(TempPOSEntry."Exit Point",NpXmlDomMgt.GetXmlText(XmlElement,'exitpoint',0,false),9);
        Evaluate(TempPOSEntry.Area,NpXmlDomMgt.GetXmlText(XmlElement,'area',0,false),9);
        Evaluate(TempPOSEntry."Transaction Specification",NpXmlDomMgt.GetXmlText(XmlElement,'transactionscpecification',0,false),9);
        Evaluate(TempPOSEntry."Prices Including VAT",NpXmlDomMgt.GetXmlText(XmlElement,'pricesincludevat',0,false),9);
        Evaluate(TempPOSEntry."Reason Code",NpXmlDomMgt.GetXmlText(XmlElement,'reasoncode',0,false),9);
        if NpXmlDomMgt.GetXmlText(XmlElement,'dimensionsetid',0,false) <> '' then
          Evaluate(TempPOSEntry."Dimension Set ID",NpXmlDomMgt.GetXmlText(XmlElement,'dimensionsetid',0,false),9);
        Evaluate(TempPOSEntry."Sales Document Type",NpXmlDomMgt.GetXmlText(XmlElement,'salesdocumenttype',0,false),9);
        Evaluate(TempPOSEntry."Sales Document No.",NpXmlDomMgt.GetXmlText(XmlElement,'salesdocumentno',0,false),9);
        Evaluate(TempPOSEntry."Contact No.",NpXmlDomMgt.GetXmlText(XmlElement,'contactno',0,false),9);

        if NpXmlDomMgt.FindNodes(XmlElement,'posentrydimension',XmlNodeList) then
          for i := 0 to XmlNodeList.Count - 1 do begin
            DimXmlElement := XmlNodeList.ItemOf(i);
            BuildDimensionBuffer(DimXmlElement,TempDimensionBuffer);
          end;
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
        POSEntry.SetRange("From External Source",true);
        POSEntry.SetRange("External Source Name",TempPOSEntry."External Source Name");
        POSEntry.SetRange("External Source Entry No.",TempPOSEntry."External Source Entry No.");
        if POSEntry.FindFirst then
          Error(Text001,POSEntry.TableCaption,POSEntry.FieldCaption("External Source Name"),POSEntry."External Source Name",POSEntry.FieldCaption("External Source Entry No."),POSEntry."External Source Entry No.");

        POSEntry.TransferFields(TempPOSEntry);
        POSEntry."Entry No." := 0;
        POSEntry."From External Source" := true;
        POSEntry.Insert;
    end;

    local procedure UpdatePOSLedgerRegister(XmlElement: DotNet XmlElement;var POSEntry: Record "POS Entry")
    var
        POSPeriodRegister: Record "POS Period Register";
        TempPOSPeriodRegister: Record "POS Period Register" temporary;
        OStream: OutStream;
    begin
        Evaluate(TempPOSPeriodRegister."External Source Entry No.",NpXmlDomMgt.GetXmlText(XmlElement,'posledgerregisterno',0,false),9);
        Evaluate(TempPOSPeriodRegister."Document No.",NpXmlDomMgt.GetXmlText(XmlElement,'posledgerregisterdocno',0,false),9);
        Evaluate(TempPOSPeriodRegister."No. Series",NpXmlDomMgt.GetXmlText(XmlElement,'noseries',0,false),9);
        Evaluate(TempPOSPeriodRegister."Opening Entry No.",NpXmlDomMgt.GetXmlText(XmlElement,'openingentryno',0,false),9);
        Evaluate(TempPOSPeriodRegister."Closing Entry No.",NpXmlDomMgt.GetXmlText(XmlElement,'closingentryno',0,false),9);
        Evaluate(TempPOSPeriodRegister.Status,NpXmlDomMgt.GetXmlText(XmlElement,'posledgerregisterstatus',0,false),9);
        Evaluate(TempPOSPeriodRegister."Posting Compression",NpXmlDomMgt.GetXmlText(XmlElement,'pospostingcompression',0,false),9);
        Evaluate(TempPOSPeriodRegister."Opened Date",NpXmlDomMgt.GetXmlText(XmlElement,'openeddate',0,false),9);
        Evaluate(TempPOSPeriodRegister."End of Day Date",NpXmlDomMgt.GetXmlText(XmlElement,'endofdaydate',0,false),9);

        //Record insert
        POSPeriodRegister.SetRange("From External Source",true);
        POSPeriodRegister.SetRange("External Source Name",POSEntry."External Source Name");
        POSPeriodRegister.SetRange("External Source Entry No.",TempPOSPeriodRegister."External Source Entry No.");
        if not POSPeriodRegister.FindFirst then begin
          POSPeriodRegister."No." := 0;
          POSPeriodRegister."External Source Name" := POSEntry."External Source Name";
          POSPeriodRegister."From External Source" := true;
          POSPeriodRegister.Insert;
        end;
        POSPeriodRegister.TransferFields(TempPOSPeriodRegister,false);
        POSPeriodRegister.Modify;

        POSEntry."POS Period Register No." := POSPeriodRegister."No.";
    end;

    local procedure InsertPOSSalesLine(XmlElement: DotNet XmlElement;var POSEntry: Record "POS Entry")
    var
        TempPOSSalesLine: Record "POS Sales Line" temporary;
        POSSalesLine: Record "POS Sales Line";
        OrigPOSEntry: Record "POS Entry";
        OStream: OutStream;
        TempDimensionBuffer: Record "Dimension Buffer" temporary;
        DimensionManagement: Codeunit DimensionManagement;
        DimXmlElement: DotNet XmlElement;
        XmlNodeList: DotNet XmlNodeList;
        i: Integer;
    begin
        POSEntry.TestField("Entry No.");
        Evaluate(TempPOSSalesLine."Line No.",NpXmlDomMgt.GetXmlText(XmlElement,'lineno',0,false),9);
        Evaluate(TempPOSSalesLine.Type,NpXmlDomMgt.GetXmlText(XmlElement,'type',0,false),9);
        Evaluate(TempPOSSalesLine."No.",NpXmlDomMgt.GetXmlText(XmlElement,'no',0,false),9);
        Evaluate(TempPOSSalesLine."Location Code",NpXmlDomMgt.GetXmlText(XmlElement,'locationcode',0,false),9);
        Evaluate(TempPOSSalesLine."Posting Group",NpXmlDomMgt.GetXmlText(XmlElement,'postinggroup',0,false),9);
        Evaluate(TempPOSSalesLine.Description,NpXmlDomMgt.GetXmlText(XmlElement,'description',0,false),9);
        Evaluate(TempPOSSalesLine.Quantity,NpXmlDomMgt.GetXmlText(XmlElement,'quantity',0,false),9);
        Evaluate(TempPOSSalesLine."Customer No.",NpXmlDomMgt.GetXmlText(XmlElement,'customerno',0,false),9);
        Evaluate(TempPOSSalesLine."Unit Price",NpXmlDomMgt.GetXmlText(XmlElement,'unitprice',0,false),9);
        Evaluate(TempPOSSalesLine."Unit Cost (LCY)",NpXmlDomMgt.GetXmlText(XmlElement,'unitcostlcy',0,false),9);
        Evaluate(TempPOSSalesLine."VAT %",NpXmlDomMgt.GetXmlText(XmlElement,'vatperc',0,false),9);
        Evaluate(TempPOSSalesLine."Line Discount %",NpXmlDomMgt.GetXmlText(XmlElement,'linediscountperc',0,false),9);
        Evaluate(TempPOSSalesLine."Line Discount Amount Excl. VAT",NpXmlDomMgt.GetXmlText(XmlElement,'linediscountamountexclvat',0,false),9);
        Evaluate(TempPOSSalesLine."Line Discount Amount Incl. VAT",NpXmlDomMgt.GetXmlText(XmlElement,'linediscountamountinclvat',0,false),9);
        Evaluate(TempPOSSalesLine."Amount Excl. VAT",NpXmlDomMgt.GetXmlText(XmlElement,'amountexclvat',0,false),9);
        Evaluate(TempPOSSalesLine."Amount Incl. VAT",NpXmlDomMgt.GetXmlText(XmlElement,'amountinclvat',0,false),9);
        Evaluate(TempPOSSalesLine."Line Dsc. Amt. Excl. VAT (LCY)",NpXmlDomMgt.GetXmlText(XmlElement,'linediscamountexclvatlcy',0,false),9);
        Evaluate(TempPOSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)",NpXmlDomMgt.GetXmlText(XmlElement,'linediscamountinclvatlcy',0,false),9);
        Evaluate(TempPOSSalesLine."Amount Excl. VAT (LCY)",NpXmlDomMgt.GetXmlText(XmlElement,'amountexclvatlcy',0,false),9);
        Evaluate(TempPOSSalesLine."Amount Incl. VAT (LCY)",NpXmlDomMgt.GetXmlText(XmlElement,'amountinclvatlcy',0,false),9);
        Evaluate(TempPOSSalesLine."Appl.-to Item Entry",NpXmlDomMgt.GetXmlText(XmlElement,'applytoentryno',0,false),9);
        Evaluate(TempPOSSalesLine."Item Entry No.",NpXmlDomMgt.GetXmlText(XmlElement,'itementryno',0,false),9);
        if NpXmlDomMgt.GetXmlText(XmlElement,'shortcutdimension1',0,false) <> '' then
          Evaluate(TempPOSSalesLine."Shortcut Dimension 1 Code",NpXmlDomMgt.GetXmlText(XmlElement,'shortcutdimension1',0,false),9);
        if NpXmlDomMgt.GetXmlText(XmlElement,'shortcutdimension2',0,false) <> '' then
          Evaluate(TempPOSSalesLine."Shortcut Dimension 2 Code",NpXmlDomMgt.GetXmlText(XmlElement,'shortcutdimension2',0,false),9);
        Evaluate(TempPOSSalesLine."Salesperson Code",NpXmlDomMgt.GetXmlText(XmlElement,'salespersoncode',0,false),9);
        Evaluate(TempPOSSalesLine."Withhold Item",NpXmlDomMgt.GetXmlText(XmlElement,'witholditem',0,false),9);
        Evaluate(TempPOSSalesLine."Move to Location",NpXmlDomMgt.GetXmlText(XmlElement,'movetolocation',0,false),9);
        Evaluate(TempPOSSalesLine."Currency Code",NpXmlDomMgt.GetXmlText(XmlElement,'currencycode',0,false),9);
        Evaluate(TempPOSSalesLine."Gen. Bus. Posting Group",NpXmlDomMgt.GetXmlText(XmlElement,'genbuspostinggroup',0,false),9);
        Evaluate(TempPOSSalesLine."Gen. Prod. Posting Group",NpXmlDomMgt.GetXmlText(XmlElement,'genprodpostinggroup',0,false),9);
        Evaluate(TempPOSSalesLine."VAT Calculation Type",NpXmlDomMgt.GetXmlText(XmlElement,'vatcalculationtype',0,false),9);
        Evaluate(TempPOSSalesLine."Gen. Posting Type",NpXmlDomMgt.GetXmlText(XmlElement,'genpostingtype',0,false),9);
        Evaluate(TempPOSSalesLine."Tax Area Code",NpXmlDomMgt.GetXmlText(XmlElement,'taxareacode',0,false),9);
        Evaluate(TempPOSSalesLine."Tax Liable",NpXmlDomMgt.GetXmlText(XmlElement,'taxliable',0,false),9);
        Evaluate(TempPOSSalesLine."Tax Group Code",NpXmlDomMgt.GetXmlText(XmlElement,'taxgroupcode',0,false),9);
        Evaluate(TempPOSSalesLine."Use Tax",NpXmlDomMgt.GetXmlText(XmlElement,'usetax',0,false),9);
        Evaluate(TempPOSSalesLine."VAT Bus. Posting Group",NpXmlDomMgt.GetXmlText(XmlElement,'vatbuspostinggroup',0,false),9);
        Evaluate(TempPOSSalesLine."VAT Prod. Posting Group",NpXmlDomMgt.GetXmlText(XmlElement,'vatprodpostinggroup',0,false),9);
        Evaluate(TempPOSSalesLine."VAT Base Amount",NpXmlDomMgt.GetXmlText(XmlElement,'vatbaseamount',0,false),9);
        Evaluate(TempPOSSalesLine."Unit Cost",NpXmlDomMgt.GetXmlText(XmlElement,'unitcost',0,false),9);
        Evaluate(TempPOSSalesLine."VAT Difference",NpXmlDomMgt.GetXmlText(XmlElement,'vatdifference',0,false),9);
        Evaluate(TempPOSSalesLine."VAT Identifier",NpXmlDomMgt.GetXmlText(XmlElement,'vatidentifier',0,false),9);
        Evaluate(TempPOSSalesLine."Sales Document Type",NpXmlDomMgt.GetXmlText(XmlElement,'salesdocumenttype',0,false),9);
        Evaluate(TempPOSSalesLine."Sales Document No.",NpXmlDomMgt.GetXmlText(XmlElement,'salesdocumentno',0,false),9);
        Evaluate(TempPOSSalesLine."Sales Document Line No.",NpXmlDomMgt.GetXmlText(XmlElement,'salesdocumentline',0,false),9);
        Evaluate(TempPOSSalesLine."Orig. POS Sale ID",NpXmlDomMgt.GetXmlText(XmlElement,'origpossaleid',0,false),9);
        Evaluate(TempPOSSalesLine."Orig. POS Line No.",NpXmlDomMgt.GetXmlText(XmlElement,'origposlineno',0,false),9);
        Evaluate(TempPOSSalesLine."Bin Code",NpXmlDomMgt.GetXmlText(XmlElement,'bincode',0,false),9);
        Evaluate(TempPOSSalesLine."Qty. per Unit of Measure",NpXmlDomMgt.GetXmlText(XmlElement,'qtyerunitofmeasure',0,false),9);
        Evaluate(TempPOSSalesLine."Cross-Reference No.",NpXmlDomMgt.GetXmlText(XmlElement,'crossreferenceno',0,false),9);
        Evaluate(TempPOSSalesLine."Originally Ordered No.",NpXmlDomMgt.GetXmlText(XmlElement,'origninallyorderedno',0,false),9);
        Evaluate(TempPOSSalesLine."Originally Ordered Var. Code",NpXmlDomMgt.GetXmlText(XmlElement,'origninallyorderedvariantcode',0,false),9);
        Evaluate(TempPOSSalesLine."Out-of-Stock Substitution",NpXmlDomMgt.GetXmlText(XmlElement,'outofstocksubstitute',0,false),9);
        Evaluate(TempPOSSalesLine."Purchasing Code",NpXmlDomMgt.GetXmlText(XmlElement,'purchasingcode',0,false),9);
        Evaluate(TempPOSSalesLine."Product Group Code",NpXmlDomMgt.GetXmlText(XmlElement,'productgroupcode',0,false),9);
        Evaluate(TempPOSSalesLine."Planned Delivery Date",NpXmlDomMgt.GetXmlText(XmlElement,'planneddeliverydate',0,false),9);
        Evaluate(TempPOSSalesLine."Reason Code",NpXmlDomMgt.GetXmlText(XmlElement,'reasoncode',0,false),9);
        Evaluate(TempPOSSalesLine."Discount Type",NpXmlDomMgt.GetXmlText(XmlElement,'discounttype',0,false),9);
        Evaluate(TempPOSSalesLine."Discount Code",NpXmlDomMgt.GetXmlText(XmlElement,'discountcode',0,false),9);
        TempPOSSalesLine."Discount Authorised by" := NpXmlDomMgt.GetXmlText(XmlElement,'discountauthorisedby',MaxStrLen(TempPOSSalesLine."Discount Authorised by"),false);
        if NpXmlDomMgt.GetXmlText(XmlElement,'dimensionsetid',0,false) <> '' then
          Evaluate(TempPOSSalesLine."Dimension Set ID",NpXmlDomMgt.GetXmlText(XmlElement,'dimensionsetid',0,false),9);
        Evaluate(TempPOSSalesLine."Variant Code",NpXmlDomMgt.GetXmlText(XmlElement,'variantcode',0,false),9);
        Evaluate(TempPOSSalesLine."Unit of Measure Code",NpXmlDomMgt.GetXmlText(XmlElement,'unitofmeasurecode',0,false),9);
        Evaluate(TempPOSSalesLine."Quantity (Base)",NpXmlDomMgt.GetXmlText(XmlElement,'quantitybase',0,false),9);
        Evaluate(TempPOSSalesLine."Item Category Code",NpXmlDomMgt.GetXmlText(XmlElement,'itemcategorycode',0,false),9);
        Evaluate(TempPOSSalesLine.Nonstock,NpXmlDomMgt.GetXmlText(XmlElement,'nonstock',0,false),9);
        Evaluate(TempPOSSalesLine."BOM Item No.",NpXmlDomMgt.GetXmlText(XmlElement,'bomitemno',0,false),9);
        Evaluate(TempPOSSalesLine."Serial No.",NpXmlDomMgt.GetXmlText(XmlElement,'serailno',0,false),9);
        Evaluate(TempPOSSalesLine."Lot No.",NpXmlDomMgt.GetXmlText(XmlElement,'lotno',0,false),9);
        Evaluate(TempPOSSalesLine."Return Reason Code",NpXmlDomMgt.GetXmlText(XmlElement,'returnreasoncode',0,false),9);

        if NpXmlDomMgt.FindNodes(XmlElement,'possaleslinedimension',XmlNodeList) then
          for i := 0 to XmlNodeList.Count - 1 do begin
            DimXmlElement := XmlNodeList.ItemOf(i);
            BuildDimensionBuffer(DimXmlElement,TempDimensionBuffer);
          end;
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
        POSSalesLine."POS Unit No." :=  POSEntry."POS Unit No.";
        POSSalesLine."Document No." := POSEntry."Document No.";
        POSSalesLine."POS Period Register No." := POSEntry."POS Period Register No.";
        POSSalesLine."Appl.-to Item Entry" := 0;
        POSSalesLine."Item Entry No." := 0;
        if TempPOSSalesLine."Orig. POS Sale ID" <> 0 then begin
          OrigPOSEntry.SetRange("From External Source",true);
          OrigPOSEntry.SetRange("External Source Name",POSEntry."External Source Name");
          OrigPOSEntry.SetRange("External Source Entry No.",TempPOSSalesLine."Orig. POS Sale ID" );
          if OrigPOSEntry.FindFirst then begin
            POSSalesLine."Orig. POS Sale ID" := OrigPOSEntry."Entry No.";
            POSSalesLine."Orig. POS Line No." := TempPOSSalesLine."Orig. POS Line No.";
          end else begin
            POSSalesLine."Orig. POS Sale ID" := 0;
            POSSalesLine."Orig. POS Line No." := 10000;
          end;
        end;
        POSSalesLine.Insert;
    end;

    local procedure InsertPOSPaymentLine(XmlElement: DotNet XmlElement;var POSEntry: Record "POS Entry")
    var
        TempPOSPaymentLine: Record "POS Payment Line" temporary;
        POSPaymentLine: Record "POS Payment Line";
        OrigPOSEntry: Record "POS Entry";
        OStream: OutStream;
        TempDimensionBuffer: Record "Dimension Buffer" temporary;
        DimensionManagement: Codeunit DimensionManagement;
        DimXmlElement: DotNet XmlElement;
        XmlNodeList: DotNet XmlNodeList;
        i: Integer;
    begin
        POSEntry.TestField("Entry No.");
        Evaluate(TempPOSPaymentLine."Line No.",NpXmlDomMgt.GetXmlText(XmlElement,'lineno',0,false),9);
        Evaluate(TempPOSPaymentLine."POS Payment Method Code",NpXmlDomMgt.GetXmlText(XmlElement,'pospaymentmethodcode',0,false),9);
        Evaluate(TempPOSPaymentLine."POS Payment Bin Code",NpXmlDomMgt.GetXmlText(XmlElement,'pospaymentbincode',0,false),9);
        Evaluate(TempPOSPaymentLine.Description,NpXmlDomMgt.GetXmlText(XmlElement,'description',0,false),9);
        Evaluate(TempPOSPaymentLine.Amount,NpXmlDomMgt.GetXmlText(XmlElement,'amount',0,false),9);
        Evaluate(TempPOSPaymentLine."Payment Fee %",NpXmlDomMgt.GetXmlText(XmlElement,'paymentfeeperc',0,false),9);
        Evaluate(TempPOSPaymentLine."Payment Fee Amount",NpXmlDomMgt.GetXmlText(XmlElement,'paymentfeeamount',0,false),9);
        Evaluate(TempPOSPaymentLine."Payment Amount",NpXmlDomMgt.GetXmlText(XmlElement,'paymentamount',0,false),9);
        Evaluate(TempPOSPaymentLine."Payment Fee % (Non-invoiced)",NpXmlDomMgt.GetXmlText(XmlElement,'paymentfeepercnoninvoiced',0,false),9);
        Evaluate(TempPOSPaymentLine."Payment Fee Amount (Non-inv.)",NpXmlDomMgt.GetXmlText(XmlElement,'paymentfeeamountnoninvoiced',0,false),9);
        Evaluate(TempPOSPaymentLine."Currency Code",NpXmlDomMgt.GetXmlText(XmlElement,'currencycode',0,false),9);
        if NpXmlDomMgt.GetXmlText(XmlElement,'shortcutdimension1code',0,false) <> '' then
          Evaluate(TempPOSPaymentLine."Shortcut Dimension 1 Code",NpXmlDomMgt.GetXmlText(XmlElement,'shortcutdimension1code',0,false),9);
        if NpXmlDomMgt.GetXmlText(XmlElement,'shortcutdimension2code',0,false) <> '' then
          Evaluate(TempPOSPaymentLine."Shortcut Dimension 2 Code",NpXmlDomMgt.GetXmlText(XmlElement,'shortcutdimension2code',0,false),9);
        Evaluate(TempPOSPaymentLine."Amount (LCY)",NpXmlDomMgt.GetXmlText(XmlElement,'amountlcy',0,false),9);
        Evaluate(TempPOSPaymentLine."Amount (Sales Currency)",NpXmlDomMgt.GetXmlText(XmlElement,'amoundsalescurrency',0,false),9);
        Evaluate(TempPOSPaymentLine."Rounding Amount",NpXmlDomMgt.GetXmlText(XmlElement,'roundingamount',0,false),9);
        Evaluate(TempPOSPaymentLine."Rounding Amount (Sales Curr.)",NpXmlDomMgt.GetXmlText(XmlElement,'roundingamountsalescurr',0,false),9);
        Evaluate(TempPOSPaymentLine."Rounding Amount (LCY)",NpXmlDomMgt.GetXmlText(XmlElement,'roundingamountlcy',0,false),9);
        Evaluate(TempPOSPaymentLine."Applies-to Doc. Type",NpXmlDomMgt.GetXmlText(XmlElement,'appliestodoctype',0,false),9);
        Evaluate(TempPOSPaymentLine."Applies-to Doc. No.",NpXmlDomMgt.GetXmlText(XmlElement,'appliestodocno',0,false),9);
        Evaluate(TempPOSPaymentLine."External Document No.",NpXmlDomMgt.GetXmlText(XmlElement,'externaldocno',0,false),9);
        Evaluate(TempPOSPaymentLine."Orig. POS Sale ID",NpXmlDomMgt.GetXmlText(XmlElement,'origpossaleid',0,false),9);
        Evaluate(TempPOSPaymentLine."Orig. POS Line No.",NpXmlDomMgt.GetXmlText(XmlElement,'origposlineno',0,false),9);
        if NpXmlDomMgt.GetXmlText(XmlElement,'dimensionsetid',0,false) <> '' then
          Evaluate(TempPOSPaymentLine."Dimension Set ID",NpXmlDomMgt.GetXmlText(XmlElement,'dimensionsetid',0,false),9);
        Evaluate(TempPOSPaymentLine.EFT,NpXmlDomMgt.GetXmlText(XmlElement,'eft',0,false),9);
        Evaluate(TempPOSPaymentLine."EFT Refundable",NpXmlDomMgt.GetXmlText(XmlElement,'eftrefundable',0,false),9);
        Evaluate(TempPOSPaymentLine.Token,NpXmlDomMgt.GetXmlText(XmlElement,'token',0,false),9);

        if NpXmlDomMgt.FindNodes(XmlElement,'pospaymentlinedimension',XmlNodeList) then
          for i := 0 to XmlNodeList.Count - 1 do begin
            DimXmlElement := XmlNodeList.ItemOf(i);
            BuildDimensionBuffer(DimXmlElement,TempDimensionBuffer);
          end;
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
        POSPaymentLine."POS Unit No." :=  POSEntry."POS Unit No.";
        POSPaymentLine."Document No." := POSEntry."Document No.";
        POSPaymentLine."POS Period Register No." := POSEntry."POS Period Register No.";
        if TempPOSPaymentLine."Orig. POS Sale ID" <> 0 then begin
          OrigPOSEntry.SetRange("From External Source",true);
          OrigPOSEntry.SetRange("External Source Name",POSEntry."External Source Name");
          OrigPOSEntry.SetRange("External Source Entry No.",TempPOSPaymentLine."Orig. POS Sale ID" );
          if OrigPOSEntry.FindFirst then begin
            POSPaymentLine."Orig. POS Sale ID" := OrigPOSEntry."Entry No.";
            POSPaymentLine."Orig. POS Line No." := TempPOSPaymentLine."Orig. POS Line No.";
          end else begin
            POSPaymentLine."Orig. POS Sale ID" := 0;
            POSPaymentLine."Orig. POS Line No." := 10000;
          end;
        end;
        POSPaymentLine.Insert;
    end;

    local procedure InsertPOSTaxAmountLine(XmlElement: DotNet XmlElement;var POSEntry: Record "POS Entry")
    var
        TempPOSTaxAmountLine: Record "POS Tax Amount Line" temporary;
        POSTaxAmountLine: Record "POS Tax Amount Line";
        OStream: OutStream;
    begin
        POSEntry.TestField("Entry No.");
        Evaluate(TempPOSTaxAmountLine."Tax Area Code",NpXmlDomMgt.GetXmlText(XmlElement,'lineno',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Tax Jurisdiction Code",NpXmlDomMgt.GetXmlText(XmlElement,'taxjurisdictioncode',0,false),9);
        Evaluate(TempPOSTaxAmountLine."VAT Identifier",NpXmlDomMgt.GetXmlText(XmlElement,'vatidentifier',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Tax Calculation Type",NpXmlDomMgt.GetXmlText(XmlElement,'taxcalculationtype',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Tax Group Code",NpXmlDomMgt.GetXmlText(XmlElement,'taxgroupcode',0,false),9);
        Evaluate(TempPOSTaxAmountLine.Quantity,NpXmlDomMgt.GetXmlText(XmlElement,'quantity',0,false),9);
        Evaluate(TempPOSTaxAmountLine.Modified,NpXmlDomMgt.GetXmlText(XmlElement,'modified',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Use Tax",NpXmlDomMgt.GetXmlText(XmlElement,'usetax',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Calculated Tax Amount",NpXmlDomMgt.GetXmlText(XmlElement,'calculatedtaxamount',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Tax Difference",NpXmlDomMgt.GetXmlText(XmlElement,'taxdifference',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Tax Type",NpXmlDomMgt.GetXmlText(XmlElement,'taxtype',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Tax Liable",NpXmlDomMgt.GetXmlText(XmlElement,'taxliable',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Tax Area Code for Key",NpXmlDomMgt.GetXmlText(XmlElement,'taxareacodeforkey',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Invoice Discount Amount",NpXmlDomMgt.GetXmlText(XmlElement,'invoicediscountamount',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Inv. Disc. Base Amount",NpXmlDomMgt.GetXmlText(XmlElement,'invdiscbaseamount',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Tax %",NpXmlDomMgt.GetXmlText(XmlElement,'taxperc',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Tax Base Amount",NpXmlDomMgt.GetXmlText(XmlElement,'taxbaseamount',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Tax Amount",NpXmlDomMgt.GetXmlText(XmlElement,'taxamount',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Amount Including Tax",NpXmlDomMgt.GetXmlText(XmlElement,'amountincludingtax',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Line Amount",NpXmlDomMgt.GetXmlText(XmlElement,'lineamount',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Expense/Capitalize",NpXmlDomMgt.GetXmlText(XmlElement,'expensecapitalize',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Print Order",NpXmlDomMgt.GetXmlText(XmlElement,'printorder',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Print Description",NpXmlDomMgt.GetXmlText(XmlElement,'printdescription',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Calculation Order",NpXmlDomMgt.GetXmlText(XmlElement,'calcluationorder',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Round Tax",NpXmlDomMgt.GetXmlText(XmlElement,'roundtax',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Is Report-to Jurisdiction",NpXmlDomMgt.GetXmlText(XmlElement,'isreporttojurisdiction',0,false),9);
        Evaluate(TempPOSTaxAmountLine.Positive,NpXmlDomMgt.GetXmlText(XmlElement,'positive',0,false),9);
        Evaluate(TempPOSTaxAmountLine."Tax Base Amount FCY",NpXmlDomMgt.GetXmlText(XmlElement,'taxbaseamountfcy',0,false),9);

        POSTaxAmountLine.TransferFields(TempPOSTaxAmountLine);
        POSTaxAmountLine."POS Entry No." := POSEntry."Entry No.";
        POSTaxAmountLine."Tax Area Code for Key" := TempPOSTaxAmountLine."Tax Area Code for Key";
        POSTaxAmountLine."Tax Jurisdiction Code"  := TempPOSTaxAmountLine."Tax Jurisdiction Code";
        POSTaxAmountLine."VAT Identifier" := TempPOSTaxAmountLine."VAT Identifier";
        POSTaxAmountLine."Tax %" := TempPOSTaxAmountLine."Tax %";
        POSTaxAmountLine."Tax Group Code" := TempPOSTaxAmountLine."Tax Group Code";
        POSTaxAmountLine."Expense/Capitalize" := TempPOSTaxAmountLine."Expense/Capitalize";
        POSTaxAmountLine."Tax Type" := TempPOSTaxAmountLine."Tax Type";
        POSTaxAmountLine."Use Tax" := TempPOSTaxAmountLine."Use Tax";
        POSTaxAmountLine.Positive := TempPOSTaxAmountLine.Positive;
        POSTaxAmountLine.Insert;
    end;

    local procedure InsertPOSBalancingLine(XmlElement: DotNet XmlElement;var POSEntry: Record "POS Entry")
    var
        TempPOSBalancingLine: Record "POS Balancing Line" temporary;
        POSBalancingLine: Record "POS Balancing Line";
        OStream: OutStream;
        TempDimensionBuffer: Record "Dimension Buffer" temporary;
        DimensionManagement: Codeunit DimensionManagement;
        DimXmlElement: DotNet XmlElement;
        XmlNodeList: DotNet XmlNodeList;
        i: Integer;
    begin
        POSEntry.TestField("Entry No.");
        Evaluate(TempPOSBalancingLine."Line No.",NpXmlDomMgt.GetXmlText(XmlElement,'lineno',0,false),9);
        Evaluate(TempPOSBalancingLine."POS Payment Bin Code",NpXmlDomMgt.GetXmlText(XmlElement,'pospaymentbincode',0,false),9);
        Evaluate(TempPOSBalancingLine."POS Payment Method Code",NpXmlDomMgt.GetXmlText(XmlElement,'pospaymentmethodcode',0,false),9);
        Evaluate(TempPOSBalancingLine."Calculated Amount",NpXmlDomMgt.GetXmlText(XmlElement,'calculatedamount',0,false),9);
        Evaluate(TempPOSBalancingLine."Balanced Amount",NpXmlDomMgt.GetXmlText(XmlElement,'balancedamount',0,false),9);
        Evaluate(TempPOSBalancingLine."Balanced Diff. Amount",NpXmlDomMgt.GetXmlText(XmlElement,'balanceddiffamount',0,false),9);
        Evaluate(TempPOSBalancingLine."New Float Amount",NpXmlDomMgt.GetXmlText(XmlElement,'newfloatamount',0,false),9);
        if NpXmlDomMgt.GetXmlText(XmlElement,'shortcuddimension1code',0,false) <> '' then
          Evaluate(TempPOSBalancingLine."Shortcut Dimension 1 Code",NpXmlDomMgt.GetXmlText(XmlElement,'shortcuddimension1code',0,false),9);
        if NpXmlDomMgt.GetXmlText(XmlElement,'shortcuddimension2code',0,false) <> '' then
          Evaluate(TempPOSBalancingLine."Shortcut Dimension 2 Code",NpXmlDomMgt.GetXmlText(XmlElement,'shortcutdimension2code',0,false),9);
        Evaluate(TempPOSBalancingLine."Calculated Quantity",NpXmlDomMgt.GetXmlText(XmlElement,'calculatedquantity',0,false),9);
        Evaluate(TempPOSBalancingLine."Balanced Quantity",NpXmlDomMgt.GetXmlText(XmlElement,'balancedquantity',0,false),9);
        Evaluate(TempPOSBalancingLine."Balanced Diff. Quantity",NpXmlDomMgt.GetXmlText(XmlElement,'balanceddiffquantity',0,false),9);
        Evaluate(TempPOSBalancingLine."Deposited Quantity",NpXmlDomMgt.GetXmlText(XmlElement,'depositedquantity',0,false),9);
        Evaluate(TempPOSBalancingLine."Closing Quantity",NpXmlDomMgt.GetXmlText(XmlElement,'closingquantity',0,false),9);
        Evaluate(TempPOSBalancingLine.Description,NpXmlDomMgt.GetXmlText(XmlElement,'description',0,false),9);
        Evaluate(TempPOSBalancingLine."Deposit-To Bin Amount",NpXmlDomMgt.GetXmlText(XmlElement,'deposittobinamount',0,false),9);
        Evaluate(TempPOSBalancingLine."Deposit-To Bin Code",NpXmlDomMgt.GetXmlText(XmlElement,'deposittobincode',0,false),9);
        Evaluate(TempPOSBalancingLine."Deposit-To Reference",NpXmlDomMgt.GetXmlText(XmlElement,'deposittoreference',0,false),9);
        Evaluate(TempPOSBalancingLine."Move-To Bin Amount",NpXmlDomMgt.GetXmlText(XmlElement,'movetobinamount',0,false),9);
        Evaluate(TempPOSBalancingLine."Move-To Bin Code",NpXmlDomMgt.GetXmlText(XmlElement,'movetobincode',0,false),9);
        Evaluate(TempPOSBalancingLine."Move-To Reference",NpXmlDomMgt.GetXmlText(XmlElement,'movetoreference',0,false),9);
        Evaluate(TempPOSBalancingLine."Balancing Details",NpXmlDomMgt.GetXmlText(XmlElement,'balancingdetails',0,false),9);
        Evaluate(TempPOSBalancingLine."Orig. POS Sale ID",NpXmlDomMgt.GetXmlText(XmlElement,'origpossaleid',0,false),9);
        Evaluate(TempPOSBalancingLine."Orig. POS Line No.",NpXmlDomMgt.GetXmlText(XmlElement,'origposlineno',0,false),9);
        Evaluate(TempPOSBalancingLine."POS Bin Checkpoint Entry No.",NpXmlDomMgt.GetXmlText(XmlElement,'posbincheckpointentryno',0,false),9);
        Evaluate(TempPOSBalancingLine."Currency Code",NpXmlDomMgt.GetXmlText(XmlElement,'currencycode',0,false),9);
        if NpXmlDomMgt.GetXmlText(XmlElement,'dimensionsetid',0,false) <> '' then
          Evaluate(TempPOSBalancingLine."Dimension Set ID",NpXmlDomMgt.GetXmlText(XmlElement,'dimensionsetid',0,false),9);

        if NpXmlDomMgt.FindNodes(XmlElement,'posbalancinglinedimension',XmlNodeList) then
          for i := 0 to XmlNodeList.Count - 1 do begin
            DimXmlElement := XmlNodeList.ItemOf(i);
            BuildDimensionBuffer(DimXmlElement,TempDimensionBuffer);
          end;
        if not TempDimensionBuffer.IsEmpty then begin
          //Dimensions always overrule shortcuts etc.
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
        POSBalancingLine."POS Unit No." :=  POSEntry."POS Unit No.";
        POSBalancingLine."Document No." := POSEntry."Document No.";
        POSBalancingLine."POS Period Register No." := POSEntry."POS Period Register No.";
        POSBalancingLine.Insert;
    end;

    local procedure BuildDimensionBuffer(XmlElement: DotNet XmlElement;var DimensionBuffer: Record "Dimension Buffer")
    var
        POSPeriodRegister: Record "POS Period Register";
        TempPOSPeriodRegister: Record "POS Period Register" temporary;
        OStream: OutStream;
    begin
        Evaluate(DimensionBuffer."Dimension Code",NpXmlDomMgt.GetXmlText(XmlElement,'dimensioncode',0,false),9);
        Evaluate(DimensionBuffer."Dimension Value Code",NpXmlDomMgt.GetXmlText(XmlElement,'dimensionvalue',0,false),9);
        DimensionBuffer.Insert;
    end;

    local procedure ResetPostingstatus(var POSEntry: Record "POS Entry")
    begin
        if POSEntry."Post Entry Status" in [POSEntry."Post Entry Status"::"Error while Posting",POSEntry."Post Entry Status"::Posted] then
          POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::Unposted;
        if POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::"Error while Posting",POSEntry."Post Item Entry Status"::Posted] then
          POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::Unposted;
        POSEntry."POS Posting Log Entry No." := 0;
    end;
}

