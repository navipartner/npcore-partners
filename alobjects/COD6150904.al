codeunit 6150904 "HC Audit Roll Management"
{
    // NPR5.37/BR  /20171027  CASE 267552 HQ Connector Created Object
    // NPR5.44/MHA /20180704  CASE 318391 Added PostAuditRoll based on attribute @direct_posting
    // NPR5.48/MHA /20181121  CASE 326055 Added "Reference" in InsertAuditRollLine()

    TableNo = "Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: DotNet npNetXmlDocument;
    begin
        if LoadXmlDoc(XmlDoc) then
          //-NPR5.44 [318391]
          //UpdateAuditRoll(XmlDoc);
          UpdateAuditRolls(XmlDoc);
          //+NPR5.44 [318391]
    end;

    var
        NcSetup: Record "Nc Setup";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Initialized: Boolean;
        Text001: Label 'Audit Roll %1 - %2 - %3 - %4 - %5 - %6 allready exists.';

    local procedure UpdateAuditRolls(XmlDoc: DotNet npNetXmlDocument)
    var
        XmlElement: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        i: Integer;
    begin
        if IsNull(XmlDoc) then
          exit;

        XmlElement := XmlDoc.DocumentElement;

        if IsNull(XmlElement) then
          exit;

        //-NPR5.44 [318391]
        // IF NOT NpXmlDomMgt.FindNodes(XmlElement,'InsertAuditRoll',XmlNodeList) THEN
        //  EXIT;
        //
        // IF NOT NpXmlDomMgt.FindNodes(XmlElement,'auditrolllineimport',XmlNodeList) THEN
        //  EXIT;
        //
        // IF NOT NpXmlDomMgt.FindNodes(XmlElement,'insertauditrollline',XmlNodeList) THEN
        //  EXIT;
        //
        // IF NOT NpXmlDomMgt.FindNodes(XmlElement,'auditrollline',XmlNodeList) THEN
        //  EXIT;
        //
        // FOR i := 0 TO XmlNodeList.Count - 1 DO BEGIN
        //  XmlElement := XmlNodeList.ItemOf(i);
        //  UpdateAuditRollLine(XmlElement)
        // END;
        if not NpXmlDomMgt.FindNodes(XmlElement,'insertauditrollline',XmlNodeList) then
          exit;

        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement := XmlNodeList.ItemOf(i);
          UpdateAuditRoll(XmlElement)
        end;
        //+NPR5.44 [318391]
    end;

    local procedure UpdateAuditRoll(XmlElement: DotNet npNetXmlElement) DocumentNoFilter: Text
    var
        XmlElement2: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        i: Integer;
        DirectPost: Boolean;
        DocumentNo: Text;
    begin
        //-NPR5.44 [318391]
        if not NpXmlDomMgt.FindNodes(XmlElement,'auditrollline',XmlNodeList) then
          exit;

        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement2 := XmlNodeList.ItemOf(i);
          DocumentNo := UpdateAuditRollLine(XmlElement2);
          AppendDocumentNoFilter(DocumentNo,DocumentNoFilter);
        end;

        Commit;
        if DocumentNoFilter = '' then
          exit;
        if not Evaluate(DirectPost,NpXmlDomMgt.GetXmlAttributeText(XmlElement,'direct_posting',false),9) then
          exit;

        if DirectPost then
          PostAuditRoll(DocumentNoFilter);
        //+NPR5.44 [318391]
    end;

    local procedure UpdateAuditRollLine(ItemXmlElement: DotNet npNetXmlElement) DocumentNo: Text
    var
        HCAuditRoll: Record "HC Audit Roll";
        ChildXmlElement: DotNet npNetXmlElement;
    begin
        //-NPR5.44 [318391]
        // IF ISNULL(ItemXmlElement) THEN
        //  EXIT(FALSE);
        //
        // InsertAuditRollLine(ItemXmlElement,HCAuditRoll);
        //
        // IF NpXmlDomMgt.FindNode(ItemXmlElement,'comment',ChildXmlElement) THEN BEGIN
        //  UpdateComments(HCAuditRoll,ChildXmlElement);
        // END;
        //
        // COMMIT;
        //
        // EXIT(TRUE);
        if IsNull(ItemXmlElement) then
          exit('');

        InsertAuditRollLine(ItemXmlElement,HCAuditRoll);

        if NpXmlDomMgt.FindNode(ItemXmlElement,'comment',ChildXmlElement) then begin
          UpdateComments(HCAuditRoll,ChildXmlElement);
        end;
        exit(HCAuditRoll."Sales Ticket No.");
        //+NPR5.44 [318391]
    end;

    local procedure PreprocessAuditRollLine(var HCAuditRoll: Record "HC Audit Roll")
    begin
        with HCAuditRoll do begin
          Posted := false;
          "Item Entry Posted" := false;
          "Dimension Set ID" := 0;
          "Shortcut Dimension 1 Code" := '';
          "Shortcut Dimension 2 Code" := '';

          //Mark lines as posted under certain conditions
          if Type = Type::Cancelled then
            Posted := true;
          if Type = Type::Comment then
            Posted := true;
          if (Type = Type::"Open/Close") and  ("Sale Type" = "Sale Type"::Comment) then
            //-NPR5.37 [286526]
            if "No." = '' then
            //-NPR5.37 [286526]
              Posted := true;
         if ("Allocated No." <> '' ) then
            Posted := true;
         if Offline  then
            Posted := true;
        end;
    end;

    local procedure AppendDocumentNoFilter(DocumentNo: Text;var DocumentNoFilter: Text)
    begin
        //-NPR5.44 [318391]
        if DocumentNo = '' then
          exit;

        if DocumentNoFilter <> '' then
          DocumentNoFilter += '|';

        DocumentNoFilter += DocumentNo;
        //+NPR5.44 [318391]
    end;

    local procedure PostAuditRoll(DocumentNoFilter: Text)
    var
        HCAuditRoll: Record "HC Audit Roll";
    begin
        //-NPR5.44 [318391]
        HCAuditRoll.SetFilter("Sales Ticket No.",DocumentNoFilter);
        CODEUNIT.Run(CODEUNIT::"HC Post audit roll",HCAuditRoll);
        //+NPR5.44 [318391]
    end;

    local procedure "--- Database"()
    begin
    end;

    local procedure InsertAuditRollLine(XmlElement: DotNet npNetXmlElement;var HCAuditRoll: Record "HC Audit Roll")
    var
        TempHCAuditRoll: Record "HC Audit Roll" temporary;
        OStream: OutStream;
    begin
        Evaluate(TempHCAuditRoll."Register No.",NpXmlDomMgt.GetXmlText(XmlElement,'registerno',0,false),9);
        Evaluate(TempHCAuditRoll."Sales Ticket No.",NpXmlDomMgt.GetXmlText(XmlElement,'salesticketno',0,false),9);
        Evaluate(TempHCAuditRoll."Sale Type",NpXmlDomMgt.GetXmlText(XmlElement,'saletype',0,false),9);
        Evaluate(TempHCAuditRoll."Line No.",NpXmlDomMgt.GetXmlText(XmlElement,'lineno',0,false),9);
        Evaluate(TempHCAuditRoll.Type,NpXmlDomMgt.GetXmlText(XmlElement,'type',0,false),9);
        Evaluate(TempHCAuditRoll."No.",NpXmlDomMgt.GetXmlText(XmlElement,'no',0,false),9);
        Evaluate(TempHCAuditRoll.Lokationskode,NpXmlDomMgt.GetXmlText(XmlElement,'lokationskode',0,false),9);
        Evaluate(TempHCAuditRoll.Description,NpXmlDomMgt.GetXmlText(XmlElement,'description',0,false),9);
        Evaluate(TempHCAuditRoll.Unit,NpXmlDomMgt.GetXmlText(XmlElement,'unit',0,false),9);
        Evaluate(TempHCAuditRoll.Quantity,NpXmlDomMgt.GetXmlText(XmlElement,'quantity',0,false),9);
        Evaluate(TempHCAuditRoll."VAT %",NpXmlDomMgt.GetXmlText(XmlElement,'vatperc',0,false),9);
        Evaluate(TempHCAuditRoll."Line Discount %",NpXmlDomMgt.GetXmlText(XmlElement,'linediscountperc',0,false),9);
        Evaluate(TempHCAuditRoll."Line Discount Amount",NpXmlDomMgt.GetXmlText(XmlElement,'linediscountamount',0,false),9);
        Evaluate(TempHCAuditRoll."Sale Date",NpXmlDomMgt.GetXmlText(XmlElement,'saledate',0,false),9);
        Evaluate(TempHCAuditRoll."Posted Doc. No.",NpXmlDomMgt.GetXmlText(XmlElement,'posteddocno',0,false),9);
        Evaluate(TempHCAuditRoll.Amount,NpXmlDomMgt.GetXmlText(XmlElement,'amount',0,false),9);
        Evaluate(TempHCAuditRoll."Amount Including VAT",NpXmlDomMgt.GetXmlText(XmlElement,'amountinclvat',0,false),9);
        Evaluate(TempHCAuditRoll."Department Code",NpXmlDomMgt.GetXmlText(XmlElement,'departmentcode',0,false),9);
        Evaluate(TempHCAuditRoll."Serial No.",NpXmlDomMgt.GetXmlText(XmlElement,'serialno',0,false),9);
        Evaluate(TempHCAuditRoll."Customer/Item Discount %",NpXmlDomMgt.GetXmlText(XmlElement,'customeritemdiscount',0,false),9);
        Evaluate(TempHCAuditRoll."Gen. Bus. Posting Group",NpXmlDomMgt.GetXmlText(XmlElement,'genbuspostinggroup',0,false),9);
        Evaluate(TempHCAuditRoll."Gen. Prod. Posting Group",NpXmlDomMgt.GetXmlText(XmlElement,'genprodpostinggroup',0,false),9);
        Evaluate(TempHCAuditRoll."VAT Bus. Posting Group",NpXmlDomMgt.GetXmlText(XmlElement,'vatbuspostinggroup',0,false),9);
        Evaluate(TempHCAuditRoll."VAT Prod. Posting Group",NpXmlDomMgt.GetXmlText(XmlElement,'vatprodpostinggroup',0,false),9);
        Evaluate(TempHCAuditRoll."Currency Code",NpXmlDomMgt.GetXmlText(XmlElement,'currencycode',0,false),9);
        Evaluate(TempHCAuditRoll.Cost,NpXmlDomMgt.GetXmlText(XmlElement,'cost',0,false),9);
        Evaluate(TempHCAuditRoll."Gift voucher ref.",NpXmlDomMgt.GetXmlText(XmlElement,'giftvoucherref',0,false),9);
        Evaluate(TempHCAuditRoll."Credit voucher ref.",NpXmlDomMgt.GetXmlText(XmlElement,'creditvoucherref',0,false),9);
        Evaluate(TempHCAuditRoll."Shortcut Dimension 1 Code",NpXmlDomMgt.GetXmlText(XmlElement,'shortcutdimension1',0,false),9);
        Evaluate(TempHCAuditRoll."Shortcut Dimension 2 Code",NpXmlDomMgt.GetXmlText(XmlElement,'shortcutdimension2',0,false),9);
        Evaluate(TempHCAuditRoll."Bin Code",NpXmlDomMgt.GetXmlText(XmlElement,'bincode',0,false),9);
        Evaluate(TempHCAuditRoll."Tax Area Code",NpXmlDomMgt.GetXmlText(XmlElement,'taxareacode',0,false),9);
        Evaluate(TempHCAuditRoll."Tax Liable",NpXmlDomMgt.GetXmlText(XmlElement,'taxliable',0,false),9);
        Evaluate(TempHCAuditRoll."Tax Group Code",NpXmlDomMgt.GetXmlText(XmlElement,'taxgroupcode',0,false),9);
        Evaluate(TempHCAuditRoll."Use Tax",NpXmlDomMgt.GetXmlText(XmlElement,'usetax',0,false),9);
        Evaluate(TempHCAuditRoll."Return Reason Code",NpXmlDomMgt.GetXmlText(XmlElement,'returnreasoncode',0,false),9);
        Evaluate(TempHCAuditRoll."Clustered Key",NpXmlDomMgt.GetXmlText(XmlElement,'clusteredkey',0,false),9);
        Evaluate(TempHCAuditRoll."Unit Cost",NpXmlDomMgt.GetXmlText(XmlElement,'unitcost',0,false),9);
        Evaluate(TempHCAuditRoll."System-Created Entry",NpXmlDomMgt.GetXmlText(XmlElement,'systemcreatedentry',0,false),9);
        Evaluate(TempHCAuditRoll."Variant Code",NpXmlDomMgt.GetXmlText(XmlElement,'variantcode',0,false),9);
        Evaluate(TempHCAuditRoll."Allocated No.",NpXmlDomMgt.GetXmlText(XmlElement,'allocatedno',0,false),9);
        Evaluate(TempHCAuditRoll."Document Type",NpXmlDomMgt.GetXmlText(XmlElement,'documenttype',0,false),9);
        Evaluate(TempHCAuditRoll."Retail Document Type",NpXmlDomMgt.GetXmlText(XmlElement,'retaildocumenttype',0,false),9);
        Evaluate(TempHCAuditRoll."Retail Document No.",NpXmlDomMgt.GetXmlText(XmlElement,'retaildocumentno',0,false),9);
        Evaluate(TempHCAuditRoll."Sales Document Type",NpXmlDomMgt.GetXmlText(XmlElement,'salesdocumenttype',0,false),9);
        Evaluate(TempHCAuditRoll."Sales Document No.",NpXmlDomMgt.GetXmlText(XmlElement,'salesdocumentno',0,false),9);
        Evaluate(TempHCAuditRoll."Sales Document Prepayment",NpXmlDomMgt.GetXmlText(XmlElement,'salesdocumentprepayment',0,false),9);
        Evaluate(TempHCAuditRoll."Sales Doc. Prepayment %",NpXmlDomMgt.GetXmlText(XmlElement,'salesdocprepaymentperc',0,false),9);
        Evaluate(TempHCAuditRoll."Sales Document Invoice",NpXmlDomMgt.GetXmlText(XmlElement,'salesdocumentinvoice',0,false),9);
        Evaluate(TempHCAuditRoll."Sales Document Ship",NpXmlDomMgt.GetXmlText(XmlElement,'salesdocumentship',0,false),9);
        Evaluate(TempHCAuditRoll."POS Sale ID",NpXmlDomMgt.GetXmlText(XmlElement,'possaleid',0,false),9);
        Evaluate(TempHCAuditRoll."Salesperson Code",NpXmlDomMgt.GetXmlText(XmlElement,'salespersoncode',0,false),9);
        Evaluate(TempHCAuditRoll."Discount Type",NpXmlDomMgt.GetXmlText(XmlElement,'discounttype',0,false),9);
        Evaluate(TempHCAuditRoll."Dimension Set ID",NpXmlDomMgt.GetXmlText(XmlElement,'dimensionsetid',0,false),9);
        Evaluate(TempHCAuditRoll."Cash Terminal Approved",NpXmlDomMgt.GetXmlText(XmlElement,'cashterminalapproved',0,false),9);
        Evaluate(TempHCAuditRoll."Drawer Opened",NpXmlDomMgt.GetXmlText(XmlElement,'draweropened',0,false),9);
        Evaluate(TempHCAuditRoll."Starting Time",NpXmlDomMgt.GetXmlText(XmlElement,'startingtime',0,false),9);
        Evaluate(TempHCAuditRoll."Closing Time",NpXmlDomMgt.GetXmlText(XmlElement,'closingtime',0,false),9);
        Evaluate(TempHCAuditRoll."Receipt Type",NpXmlDomMgt.GetXmlText(XmlElement,'receipttype',0,false),9);
        Evaluate(TempHCAuditRoll."Closing Cash",NpXmlDomMgt.GetXmlText(XmlElement,'closingcash',0,false),9);
        Evaluate(TempHCAuditRoll."Opening Cash",NpXmlDomMgt.GetXmlText(XmlElement,'openingcash',0,false),9);
        Evaluate(TempHCAuditRoll."Transferred to Balance Account",NpXmlDomMgt.GetXmlText(XmlElement,'transferredtobalanceaccount',0,false),9);
        Evaluate(TempHCAuditRoll.Difference,NpXmlDomMgt.GetXmlText(XmlElement,'difference',0,false),9);
        Evaluate(TempHCAuditRoll."Change Register",NpXmlDomMgt.GetXmlText(XmlElement,'changeregister',0,false),9);
        Evaluate(TempHCAuditRoll.Posted,NpXmlDomMgt.GetXmlText(XmlElement,'posted',0,false),9);
        Evaluate(TempHCAuditRoll."Posting Date",NpXmlDomMgt.GetXmlText(XmlElement,'postingdate',0,false),9);
        Evaluate(TempHCAuditRoll."Internal Posting No.",NpXmlDomMgt.GetXmlText(XmlElement,'internalpostingno',0,false),9);
        Evaluate(TempHCAuditRoll.Color,NpXmlDomMgt.GetXmlText(XmlElement,'color',0,false),9);
        Evaluate(TempHCAuditRoll.Size,NpXmlDomMgt.GetXmlText(XmlElement,'size',0,false),9);
        Evaluate(TempHCAuditRoll."Serial No. not Created",NpXmlDomMgt.GetXmlText(XmlElement,'serialnonotcreated',0,false),9);
        Evaluate(TempHCAuditRoll."Customer No.",NpXmlDomMgt.GetXmlText(XmlElement,'customerno',0,false),9);
        Evaluate(TempHCAuditRoll."Customer Type",NpXmlDomMgt.GetXmlText(XmlElement,'customertype',0,false),9);
        Evaluate(TempHCAuditRoll."Payment Type No.",NpXmlDomMgt.GetXmlText(XmlElement,'paymenttypeno',0,false),9);
        Evaluate(TempHCAuditRoll."N3 Debit Sale Conversion",NpXmlDomMgt.GetXmlText(XmlElement,'n3debitsaleconversion',0,false),9);
        Evaluate(TempHCAuditRoll."Buffer Document Type",NpXmlDomMgt.GetXmlText(XmlElement,'bufferdocumenttype',0,false),9);
        Evaluate(TempHCAuditRoll."Buffer ID",NpXmlDomMgt.GetXmlText(XmlElement,'bufferid',0,false),9);
        Evaluate(TempHCAuditRoll."Buffer Invoice No.",NpXmlDomMgt.GetXmlText(XmlElement,'bufferinvoiceno',0,false),9);
        Evaluate(TempHCAuditRoll."Reason Code",NpXmlDomMgt.GetXmlText(XmlElement,'reasoncode',0,false),9);
        Evaluate(TempHCAuditRoll."Description 2",NpXmlDomMgt.GetXmlText(XmlElement,'description2',0,false),9);
        Evaluate(TempHCAuditRoll."Money bag no.",NpXmlDomMgt.GetXmlText(XmlElement,'moneybagno',0,false),9);
        Evaluate(TempHCAuditRoll."External Document No.",NpXmlDomMgt.GetXmlText(XmlElement,'externaldocumentno',0,false),9);
        Evaluate(TempHCAuditRoll.LineCounter,NpXmlDomMgt.GetXmlText(XmlElement,'linecounter',0,false),9);
        Evaluate(TempHCAuditRoll.Balancing,NpXmlDomMgt.GetXmlText(XmlElement,'balancing',0,false),9);
        Evaluate(TempHCAuditRoll.Vendor,NpXmlDomMgt.GetXmlText(XmlElement,'vendor',0,false),9);
        Evaluate(TempHCAuditRoll."Invoiz Guid",NpXmlDomMgt.GetXmlText(XmlElement,'invoizguid',0,false),9);
        Evaluate(TempHCAuditRoll."No. Printed",NpXmlDomMgt.GetXmlText(XmlElement,'noprinted',0,false),9);
        Evaluate(TempHCAuditRoll.Offline,NpXmlDomMgt.GetXmlText(XmlElement,'offline',0,false),9);
        Evaluate(TempHCAuditRoll."Customer Post Code",NpXmlDomMgt.GetXmlText(XmlElement,'customerpostcode',0,false),9);
        Evaluate(TempHCAuditRoll."Currency Amount",NpXmlDomMgt.GetXmlText(XmlElement,'currencyamount',0,false),9);
        Evaluate(TempHCAuditRoll."Item Entry Posted",NpXmlDomMgt.GetXmlText(XmlElement,'itementryposted',0,false),9);
        Evaluate(TempHCAuditRoll.Send,NpXmlDomMgt.GetXmlText(XmlElement,'send',0,false),9);
        Evaluate(TempHCAuditRoll."Offline receipt no.",NpXmlDomMgt.GetXmlText(XmlElement,'offlinereceiptno',0,false),9);
        //-NPR5.48 [326055]
        TempHCAuditRoll.Reference := NpXmlDomMgt.GetXmlText(XmlElement,'reference',MaxStrLen(TempHCAuditRoll.Reference),false);
        //+NPR5.48 [326055]
        PreprocessAuditRollLine(TempHCAuditRoll);

        //Record insert
        if not HCAuditRoll.Get(TempHCAuditRoll."Register No.",TempHCAuditRoll."Sales Ticket No.",TempHCAuditRoll."Sale Type",TempHCAuditRoll."Line No.",TempHCAuditRoll."No.",TempHCAuditRoll."Sale Date") then begin
          HCAuditRoll.Init;
          HCAuditRoll := TempHCAuditRoll;
          HCAuditRoll.Insert;
        //-NPR5.44 [318391]
        //END ELSE
        //  ERROR(Text001,TempHCAuditRoll."Register No.",TempHCAuditRoll."Sales Ticket No.",TempHCAuditRoll."Sale Type",TempHCAuditRoll."Line No.",TempHCAuditRoll."No.",TempHCAuditRoll."Sale Date");
        end;
        //+NPR5.44 [318391]
    end;

    local procedure UpdateComments(var BCAuditRoll: Record "HC Audit Roll";VariantXmlElement: DotNet npNetXmlElement)
    var
        ItemVariant: Record "Item Variant";
    begin
        /*
        COMMENT.DELETEALL;
        REPEAT
          COMMENT.INIT;
          COMMENT."Item No." := NpXmlDomMgt.GetXmlText(VariantXmlElement,'itemno',TRUE);
          TempItemVariant.Code := NpXmlDomMgt.GetXmlText(VariantXmlElement,'code',TRUE);
          TempItemVariant.Description := NpXmlDomMgt.GetXmlText(VariantXmlElement,'description',0,TRUE);
          TempItemVariant."Description 2" := NpXmlDomMgt.GetXmlText(VariantXmlElement,'description2',0,TRUE);
          COMMENT.INSERT;
        
          VariantXmlElement := VariantXmlElement.NextSibling;
          IF NOT ISNULL(VariantXmlElement) THEN
            IF VariantXmlElement.Name <> 'variants' THEN
              CLEAR(VariantXmlElement);
        UNTIL ISNULL(VariantXmlElement);
        
        BuildItemVariants(Item,TempItemVariant);
        */

    end;
}

