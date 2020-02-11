codeunit 6151321 "NpEc Purch. Doc. Import Mgt."
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Xml attribute %1 is missing in <%2>';
        Text001: Label 'Invalid Line Type: %1';
        Text002: Label 'Customer Mapping within Country Code "%1" and Post Code "%2" not found';
        Text003: Label 'Unknown Item: %1 ';

    local procedure "--- Database"()
    begin
    end;

    procedure DeletePurchLines(PurchHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
    begin
        PurchLine.SetRange("Document Type",PurchHeader."Document Type");
        PurchLine.SetRange("Document No.",PurchHeader."No.");
        if PurchLine.FindFirst then
          PurchLine.DeleteAll(true);
    end;

    procedure DeleteNotes(var PurchHeader: Record "Purchase Header")
    var
        RecordLink: Record "Record Link";
    begin
        RecordLink.SetRange("Record ID",PurchHeader.RecordId);
        RecordLink.SetRange(Type,RecordLink.Type::Note);
        RecordLink.SetFilter("User ID",'=%1','');
        if RecordLink.FindFirst then
          RecordLink.DeleteAll(true);
    end;

    procedure InsertNote(XmlElement: DotNet npNetXmlElement;var PurchHeader: Record "Purchase Header")
    var
        RecordLink: Record "Record Link";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        OutStream: OutStream;
        LinkID: Integer;
        BinaryWriter: DotNet npNetBinaryWriter;
        Encoding: DotNet npNetEncoding;
        Note: Text;
    begin
        Note := NpXmlDomMgt.GetElementText(XmlElement,'/*/purchase_invoice/note',0,false);
        if Note  = '' then
          exit;

        LinkID := PurchHeader.AddLink('',PurchHeader."No.");
        RecordLink.Get(LinkID);
        RecordLink.Type := RecordLink.Type::Note;
        RecordLink.Note.CreateOutStream(OutStream);
        RecordLink."User ID" := '';
        Encoding := Encoding.UTF8;
        BinaryWriter := BinaryWriter.BinaryWriter(OutStream,Encoding);
        BinaryWriter.Write(Note);
        RecordLink.Modify(true);
    end;

    procedure InsertInvoiceHeader(XmlElement: DotNet npNetXmlElement;var PurchHeader: Record "Purchase Header")
    var
        Vendor: Record Vendor;
        NpEcStore: Record "NpEc Store";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement2: DotNet npNetXmlElement;
        DocDate: Date;
    begin
        NpXmlDomMgt.FindElement(XmlElement,'/*/purchase_invoice',true,XmlElement);
        FindStore(XmlElement,NpEcStore);

        FindVendor(XmlElement,Vendor);

        Clear(PurchHeader);
        PurchHeader.SetHideValidationDialog(true);
        PurchHeader.Init;
        PurchHeader."Document Type" := PurchHeader."Document Type"::Invoice;
        PurchHeader."No." := '';
        PurchHeader."NpEc Store Code" := NpEcStore.Code;
        PurchHeader."NpEc Document No." := GetInvoiceNo(XmlElement);
        PurchHeader."Vendor Invoice No." := NpXmlDomMgt.GetElementCode(XmlElement,'vendor_invoice_no',MaxStrLen(PurchHeader."Vendor Invoice No."),false);
        PurchHeader.Insert(true);

        PurchHeader.Validate("Buy-from Vendor No.",Vendor."No.");

        PurchHeader.Validate("Posting Date",NpXmlDomMgt.GetElementDate(XmlElement,'posting_date',true));
        DocDate :=  NpXmlDomMgt.GetElementDate(XmlElement,'document_date',false);
        if DocDate <> 0D then
          PurchHeader.Validate("Document Date",DocDate);
        PurchHeader.Validate("Purchaser Code",NpEcStore."Salesperson/Purchaser Code");

          PurchHeader.Validate(PurchHeader."Shortcut Dimension 1 Code",NpEcStore."Global Dimension 1 Code");
        if NpEcStore."Global Dimension 2 Code" <> '' then
          PurchHeader.Validate("Shortcut Dimension 2 Code",NpEcStore."Global Dimension 2 Code");

        PurchHeader.Validate("Location Code",NpEcStore."Location Code");
        PurchHeader."Currency Code" := NpXmlDomMgt.GetElementCode(XmlElement,'currency_code',MaxStrLen(PurchHeader."Currency Code"),false);
        PurchHeader.Validate("Currency Code",GetCurrencyCode(PurchHeader."Currency Code"));
        PurchHeader.Modify(true);
    end;

    procedure InsertInvoiceLines(XmlElement: DotNet npNetXmlElement;PurchHeader: Record "Purchase Header")
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElementLine: DotNet npNetXmlElement;
        XmlElementLines: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        LineNo: Integer;
        i: Integer;
    begin
        LineNo := 0;

        XmlElementLines := XmlElement.SelectSingleNode('purchase_invoice_lines');
        if not IsNull(XmlElementLines) then begin
          NpXmlDomMgt.FindNodes(XmlElementLines,'purchase_invoice_line',XmlNodeList);
          for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElementLine := XmlNodeList.ItemOf(i);
            InsertPurchLine(XmlElementLine,PurchHeader,LineNo);
          end;
        end;
    end;

    local procedure InsertPurchLine(XmlElement: DotNet npNetXmlElement;PurchHeader: Record "Purchase Header";var LineNo: Integer)
    var
        PurchLine: Record "Purchase Line";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        LineType: Text;
    begin
        LineType := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'type',true);
        case LowerCase(LineType) of
          'comment',Format(PurchLine.Type::" ",0,2):
            begin
              InsertPurchLineComment(XmlElement,PurchHeader,LineNo);
            end;
          'item',Format(PurchLine.Type::Item,0,2):
            begin
              InsertPurchLineItem(XmlElement,PurchHeader,LineNo);
            end;
          'gl_account',Format(PurchLine.Type::"G/L Account",0,2):
            begin
              InsertPurchLineGLAccount(XmlElement,PurchHeader,LineNo);
            end;
          else
            Error(Text001,LineType);
        end;
    end;

    local procedure InsertPurchLineComment(XmlElement: DotNet npNetXmlElement;PurchHeader: Record "Purchase Header";var LineNo: Integer)
    var
        PurchLine: Record "Purchase Line";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
    begin
        LineNo += 10000;
        PurchLine.Init;
        PurchLine."Document Type" := PurchHeader."Document Type";
        PurchLine."Document No." := PurchHeader."No.";
        PurchLine."Line No." := LineNo;
        PurchLine.Insert(true);
        PurchLine.Validate(Type,PurchLine.Type::" ");
        PurchLine.Description := NpXmlDomMgt.GetElementText(XmlElement,'description',MaxStrLen(PurchLine.Description),true);
        PurchLine.Modify(true);
    end;

    local procedure InsertPurchLineItem(XmlElement: DotNet npNetXmlElement;PurchHeader: Record "Purchase Header";var LineNo: Integer)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        PurchLine: Record "Purchase Line";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        TableId: Integer;
        LineAmount: Decimal;
        Quantity: Decimal;
        DirectUnitCost: Decimal;
        VatPct: Decimal;
        ReferenceNo: Text;
    begin
        ReferenceNo := NpXmlDomMgt.GetAttributeText(XmlElement,'','reference_no',0,true);
        if not FindItemVariant(ReferenceNo,ItemVariant) then
          exit;

        Item.Get(ItemVariant."Item No.");
        if ItemVariant.Code <> '' then
          ItemVariant.Find;

        DirectUnitCost := NpXmlDomMgt.GetElementDec(XmlElement,'direct_unit_cost',true);
        Quantity := NpXmlDomMgt.GetElementDec(XmlElement,'quantity',true);
        VatPct := NpXmlDomMgt.GetElementDec(XmlElement,'vat_percent',true);
        LineAmount := NpXmlDomMgt.GetElementDec(XmlElement,'line_amount',true);
        LineNo += 10000;
        PurchLine.Init;
        PurchLine."Document Type" := PurchHeader."Document Type";
        PurchLine."Document No." := PurchHeader."No.";
        PurchLine."Line No." := LineNo;
        PurchLine.Insert(true);

        PurchLine.Validate(Type,PurchLine.Type::Item);
        PurchLine.Validate("No.",Item."No.");
        PurchLine."Variant Code" := ItemVariant.Code;
        PurchLine.Validate(Quantity,Quantity);
        PurchLine.Validate("VAT %",VatPct);
        if DirectUnitCost > 0 then
          PurchLine.Validate("Direct Unit Cost",DirectUnitCost)
        else
          PurchLine."Direct Unit Cost" := DirectUnitCost;
        PurchLine.Validate("VAT Prod. Posting Group");

        if PurchLine."Direct Unit Cost" <> 0 then
          PurchLine.Validate("Line Amount",LineAmount)
        else
          PurchLine."Line Amount" := LineAmount;
        PurchLine.Modify(true);
    end;

    local procedure InsertPurchLineGLAccount(XmlElement: DotNet npNetXmlElement;PurchHeader: Record "Purchase Header";var LineNo: Integer)
    var
        PurchLine: Record "Purchase Line";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        LineAmount: Decimal;
        Quantity: Decimal;
        DirectUnitCost: Decimal;
        AccountNo: Text;
    begin
        Quantity := NpXmlDomMgt.GetElementDec(XmlElement,'quantity',true);
        LineAmount := NpXmlDomMgt.GetElementDec(XmlElement,'line_amount',true);
        DirectUnitCost := NpXmlDomMgt.GetElementDec(XmlElement,'direct_unit_cost',true);

        LineNo += 10000;
        PurchLine.Init;
        PurchLine."Document Type" := PurchHeader."Document Type";
        PurchLine."Document No." := PurchHeader."No.";
        PurchLine."Line No." := LineNo;
        PurchLine.Insert(true);

        AccountNo := NpXmlDomMgt.GetAttributeCode(XmlElement,'','reference_no',MaxStrLen(PurchLine."No."),true);
        PurchLine.Validate(Type,PurchLine.Type::"G/L Account");
        PurchLine.Validate("No.",AccountNo);
        if Quantity <> 0 then
          PurchLine.Validate(Quantity,Quantity);

        PurchLine.Validate("Direct Unit Cost",DirectUnitCost);
        PurchLine.Description := NpXmlDomMgt.GetElementText(XmlElement,'description',MaxStrLen(PurchLine.Description),true);
        PurchLine.Modify(true);
    end;

    local procedure "--- Get/Check"()
    begin
    end;

    procedure FindInvoice(XmlElement: DotNet npNetXmlElement;var PurchHeader: Record "Purchase Header"): Boolean
    var
        NpEcStore: Record "NpEc Store";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        InvoiceNo: Text;
        StoreCode: Text;
    begin
        Clear(PurchHeader);

        FindStore(XmlElement,NpEcStore);
        InvoiceNo := GetInvoiceNo(XmlElement);
        if InvoiceNo = '' then
          exit(false);

        PurchHeader.SetRange("Document Type",PurchHeader."Document Type"::Invoice);
        PurchHeader.SetRange("NpEc Store Code",NpEcStore.Code);
        PurchHeader.SetRange("NpEc Document No.",InvoiceNo);
        exit(PurchHeader.FindFirst);
    end;

    local procedure FindItemVariant(ReferenceNo: Text;var ItemVariant: Record "Item Variant"): Boolean
    var
        Item: Record Item;
        ItemCrossRef: Record "Item Cross Reference";
        Position: Integer;
        ItemNo: Text;
        VariantCode: Text;
    begin
        Clear(ItemVariant);

        if ReferenceNo = '' then
          exit(false);

        if StrLen(ReferenceNo) <= MaxStrLen(ItemCrossRef."Cross-Reference No.") then begin
          ItemCrossRef.SetRange("Cross-Reference Type",ItemCrossRef."Cross-Reference Type"::"Bar Code");
          ItemCrossRef.SetRange("Cross-Reference No.",UpperCase(ReferenceNo));
          ItemCrossRef.SetRange("Discontinue Bar Code",false);
          if ItemCrossRef.FindFirst then begin
            ItemVariant."Item No." := ItemCrossRef."Item No.";
            ItemVariant.Code := ItemCrossRef."Variant Code";
            exit(true);
          end;
        end;

        if StrLen(ReferenceNo) <= MaxStrLen(Item."No.") then begin
          if Item.Get(UpperCase(ReferenceNo)) then begin
            ItemVariant."Item No." := Item."No.";
            exit(true);
          end;
        end;

        Position := StrPos(ReferenceNo,'_');
        if Position > 0 then begin
          ItemNo := UpperCase(CopyStr(ReferenceNo,1,Position));
          VariantCode := UpperCase(DelStr(ReferenceNo,1,Position));

          if (StrLen(ItemNo) <= MaxStrLen(ItemVariant."Item No.")) and (StrLen(VariantCode) <= MaxStrLen(ItemVariant.Code)) then begin
            if ItemVariant.Get(ItemNo,VariantCode) then
                exit(true);
          end;
        end;

        exit(false);
    end;

    procedure FindPostedInvoice(XmlElement: DotNet npNetXmlElement;var PurchInvHeader: Record "Purch. Inv. Header"): Boolean
    var
        NpEcStore: Record "NpEc Store";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        InvoiceNo: Text;
    begin
        FindStore(XmlElement,NpEcStore);
        InvoiceNo := GetInvoiceNo(XmlElement);
        PurchInvHeader.SetRange("NpEc Store Code",NpEcStore.Code);
        PurchInvHeader.SetRange("NpEc Document No.",InvoiceNo);
        exit(PurchInvHeader.FindFirst);
    end;

    local procedure FindStore(XmlElement: DotNet npNetXmlElement;var NpEcStore: Record "NpEc Store")
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        StoreCode: Text;
    begin
        StoreCode := NpXmlDomMgt.GetAttributeCode(XmlElement,'/*/purchase_invoice','store_code',MaxStrLen(NpEcStore.Code),true);
        NpEcStore.Get(StoreCode);
    end;

    local procedure FindVendor(XmlElement: DotNet npNetXmlElement;var Vendor: Record Vendor)
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        VendorNo: Text;
    begin
        Clear(Vendor);

        VendorNo := NpXmlDomMgt.GetAttributeCode(XmlElement,'/*/purchase_invoice/buy_from_vendor','vendor_no',MaxStrLen(Vendor."No."),true);
        Vendor.Get(VendorNo);
    end;

    local procedure GetCurrencyCode(CurrencyCode: Code[10]): Code[10]
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if not GLSetup.Get then
          exit(CurrencyCode);

        if GLSetup."LCY Code" = CurrencyCode then
          exit('');

        exit(CurrencyCode);
    end;

    local procedure GetInvoiceNo(XmlElement: DotNet npNetXmlElement) InvoiceNo: Text
    var
        PurchHeader: Record "Purchase Header";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
    begin
        InvoiceNo := NpXmlDomMgt.GetAttributeCode(XmlElement,'/*/purchase_invoice','invoice_no',MaxStrLen(PurchHeader."NpEc Document No."),true);
        if InvoiceNo = '' then
          Error(Text000,'invoice_no','purchase_invoice');
    end;

    procedure InvoiceExists(XmlElement: DotNet npNetXmlElement): Boolean
    var
        PurchHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        if FindInvoice(XmlElement,PurchHeader) then
          exit(true);

        if FindPostedInvoice(XmlElement,PurchInvHeader) then
          exit(true);

        exit(false);
    end;
}

