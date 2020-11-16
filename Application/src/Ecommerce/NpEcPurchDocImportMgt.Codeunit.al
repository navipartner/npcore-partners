codeunit 6151321 "NPR NpEc Purch.Doc.Import Mgt."
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce
    // NPR5.54/MHA /20200228  CASE 319135 Removed validation of "VAT Prod. Posting Group" to avoid reset of "Unit Price"
    // NPR5.54/MHA /20200311  CASE 390380 E-commerce reference moved to NpEc Document


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
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        if PurchLine.FindFirst then
            PurchLine.DeleteAll(true);
    end;

    procedure DeleteNotes(var PurchHeader: Record "Purchase Header")
    var
        RecordLink: Record "Record Link";
    begin
        RecordLink.SetRange("Record ID", PurchHeader.RecordId);
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetFilter("User ID", '=%1', '');
        if RecordLink.FindFirst then
            RecordLink.DeleteAll(true);
    end;

    procedure InsertNote(XmlElement: DotNet NPRNetXmlElement; var PurchHeader: Record "Purchase Header")
    var
        RecordLink: Record "Record Link";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        OutStream: OutStream;
        LinkID: Integer;
        BinaryWriter: DotNet NPRNetBinaryWriter;
        Encoding: DotNet NPRNetEncoding;
        Note: Text;
    begin
        Note := NpXmlDomMgt.GetElementText(XmlElement, '/*/purchase_invoice/note', 0, false);
        if Note = '' then
            exit;

        LinkID := PurchHeader.AddLink('', PurchHeader."No.");
        RecordLink.Get(LinkID);
        RecordLink.Type := RecordLink.Type::Note;
        RecordLink.Note.CreateOutStream(OutStream);
        RecordLink."User ID" := '';
        Encoding := Encoding.UTF8;
        BinaryWriter := BinaryWriter.BinaryWriter(OutStream, Encoding);
        BinaryWriter.Write(Note);
        RecordLink.Modify(true);
    end;

    procedure InsertInvoiceHeader(XmlElement: DotNet NPRNetXmlElement; var PurchHeader: Record "Purchase Header")
    var
        NpEcDocument: Record "NPR NpEc Document";
        Vendor: Record Vendor;
        NpEcStore: Record "NPR NpEc Store";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlElement2: DotNet NPRNetXmlElement;
        DocDate: Date;
    begin
        NpXmlDomMgt.FindElement(XmlElement, '/*/purchase_invoice', true, XmlElement);
        FindStore(XmlElement, NpEcStore);

        FindVendor(XmlElement, Vendor);

        Clear(PurchHeader);
        PurchHeader.SetHideValidationDialog(true);
        PurchHeader.Init;
        PurchHeader."Document Type" := PurchHeader."Document Type"::Invoice;
        PurchHeader."No." := '';
        //-NPR5.54 [390380]
        PurchHeader."Vendor Invoice No." := NpXmlDomMgt.GetElementCode(XmlElement, 'vendor_invoice_no', MaxStrLen(PurchHeader."Vendor Invoice No."), false);
        PurchHeader.Insert(true);

        NpEcDocument.Init;
        NpEcDocument."Entry No." := 0;
        NpEcDocument."Store Code" := NpEcStore.Code;
        NpEcDocument."Reference No." := GetInvoiceNo(XmlElement);
        NpEcDocument."Document Type" := NpEcDocument."Document Type"::"Purchase Invoice";
        NpEcDocument."Document No." := PurchHeader."No.";
        NpEcDocument.Insert(true);
        //+NPR5.54 [390380]

        PurchHeader.Validate("Buy-from Vendor No.", Vendor."No.");

        PurchHeader.Validate("Posting Date", NpXmlDomMgt.GetElementDate(XmlElement, 'posting_date', true));
        DocDate := NpXmlDomMgt.GetElementDate(XmlElement, 'document_date', false);
        if DocDate <> 0D then
            PurchHeader.Validate("Document Date", DocDate);
        PurchHeader.Validate("Purchaser Code", NpEcStore."Salesperson/Purchaser Code");

        PurchHeader.Validate(PurchHeader."Shortcut Dimension 1 Code", NpEcStore."Global Dimension 1 Code");
        if NpEcStore."Global Dimension 2 Code" <> '' then
            PurchHeader.Validate("Shortcut Dimension 2 Code", NpEcStore."Global Dimension 2 Code");

        PurchHeader.Validate("Location Code", NpEcStore."Location Code");
        PurchHeader."Currency Code" := NpXmlDomMgt.GetElementCode(XmlElement, 'currency_code', MaxStrLen(PurchHeader."Currency Code"), false);
        PurchHeader.Validate("Currency Code", GetCurrencyCode(PurchHeader."Currency Code"));
        PurchHeader.Modify(true);
    end;

    procedure InsertInvoiceLines(XmlElement: DotNet NPRNetXmlElement; PurchHeader: Record "Purchase Header")
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlElementLine: DotNet NPRNetXmlElement;
        XmlElementLines: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        LineNo: Integer;
        i: Integer;
    begin
        LineNo := 0;

        XmlElementLines := XmlElement.SelectSingleNode('purchase_invoice_lines');
        if not IsNull(XmlElementLines) then begin
            NpXmlDomMgt.FindNodes(XmlElementLines, 'purchase_invoice_line', XmlNodeList);
            for i := 0 to XmlNodeList.Count - 1 do begin
                XmlElementLine := XmlNodeList.ItemOf(i);
                InsertPurchLine(XmlElementLine, PurchHeader, LineNo);
            end;
        end;
    end;

    local procedure InsertPurchLine(XmlElement: DotNet NPRNetXmlElement; PurchHeader: Record "Purchase Header"; var LineNo: Integer)
    var
        PurchLine: Record "Purchase Line";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        LineType: Text;
    begin
        LineType := NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'type', true);
        case LowerCase(LineType) of
            'comment', Format(PurchLine.Type::" ", 0, 2):
                begin
                    InsertPurchLineComment(XmlElement, PurchHeader, LineNo);
                end;
            'item', Format(PurchLine.Type::Item, 0, 2):
                begin
                    InsertPurchLineItem(XmlElement, PurchHeader, LineNo);
                end;
            'gl_account', Format(PurchLine.Type::"G/L Account", 0, 2):
                begin
                    InsertPurchLineGLAccount(XmlElement, PurchHeader, LineNo);
                end;
            else
                Error(Text001, LineType);
        end;
    end;

    local procedure InsertPurchLineComment(XmlElement: DotNet NPRNetXmlElement; PurchHeader: Record "Purchase Header"; var LineNo: Integer)
    var
        PurchLine: Record "Purchase Line";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
    begin
        LineNo += 10000;
        PurchLine.Init;
        PurchLine."Document Type" := PurchHeader."Document Type";
        PurchLine."Document No." := PurchHeader."No.";
        PurchLine."Line No." := LineNo;
        PurchLine.Insert(true);
        PurchLine.Validate(Type, PurchLine.Type::" ");
        PurchLine.Description := NpXmlDomMgt.GetElementText(XmlElement, 'description', MaxStrLen(PurchLine.Description), true);
        PurchLine.Modify(true);
    end;

    local procedure InsertPurchLineItem(XmlElement: DotNet NPRNetXmlElement; PurchHeader: Record "Purchase Header"; var LineNo: Integer)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        PurchLine: Record "Purchase Line";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        TableId: Integer;
        LineAmount: Decimal;
        Quantity: Decimal;
        DirectUnitCost: Decimal;
        VatPct: Decimal;
        ReferenceNo: Text;
    begin
        ReferenceNo := NpXmlDomMgt.GetAttributeText(XmlElement, '', 'reference_no', 0, true);
        if not FindItemVariant(ReferenceNo, ItemVariant) then
            exit;

        Item.Get(ItemVariant."Item No.");
        if ItemVariant.Code <> '' then
            ItemVariant.Find;

        DirectUnitCost := NpXmlDomMgt.GetElementDec(XmlElement, 'direct_unit_cost', true);
        Quantity := NpXmlDomMgt.GetElementDec(XmlElement, 'quantity', true);
        VatPct := NpXmlDomMgt.GetElementDec(XmlElement, 'vat_percent', true);
        LineAmount := NpXmlDomMgt.GetElementDec(XmlElement, 'line_amount', true);
        LineNo += 10000;
        PurchLine.Init;
        PurchLine."Document Type" := PurchHeader."Document Type";
        PurchLine."Document No." := PurchHeader."No.";
        PurchLine."Line No." := LineNo;
        PurchLine.Insert(true);

        PurchLine.Validate(Type, PurchLine.Type::Item);
        PurchLine.Validate("No.", Item."No.");
        PurchLine."Variant Code" := ItemVariant.Code;
        PurchLine.Validate(Quantity, Quantity);
        PurchLine.Validate("VAT %", VatPct);
        if DirectUnitCost > 0 then
            PurchLine.Validate("Direct Unit Cost", DirectUnitCost)
        else
            PurchLine."Direct Unit Cost" := DirectUnitCost;
        //-NPR5.54 [319135]
        //PurchLine.VALIDATE("VAT Prod. Posting Group");
        //+NPR5.54 [319135]

        if PurchLine."Direct Unit Cost" <> 0 then
            PurchLine.Validate("Line Amount", LineAmount)
        else
            PurchLine."Line Amount" := LineAmount;
        PurchLine.Modify(true);
    end;

    local procedure InsertPurchLineGLAccount(XmlElement: DotNet NPRNetXmlElement; PurchHeader: Record "Purchase Header"; var LineNo: Integer)
    var
        PurchLine: Record "Purchase Line";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        LineAmount: Decimal;
        Quantity: Decimal;
        DirectUnitCost: Decimal;
        AccountNo: Text;
    begin
        Quantity := NpXmlDomMgt.GetElementDec(XmlElement, 'quantity', true);
        LineAmount := NpXmlDomMgt.GetElementDec(XmlElement, 'line_amount', true);
        DirectUnitCost := NpXmlDomMgt.GetElementDec(XmlElement, 'direct_unit_cost', true);

        LineNo += 10000;
        PurchLine.Init;
        PurchLine."Document Type" := PurchHeader."Document Type";
        PurchLine."Document No." := PurchHeader."No.";
        PurchLine."Line No." := LineNo;
        PurchLine.Insert(true);

        AccountNo := NpXmlDomMgt.GetAttributeCode(XmlElement, '', 'reference_no', MaxStrLen(PurchLine."No."), true);
        PurchLine.Validate(Type, PurchLine.Type::"G/L Account");
        PurchLine.Validate("No.", AccountNo);
        if Quantity <> 0 then
            PurchLine.Validate(Quantity, Quantity);

        PurchLine.Validate("Direct Unit Cost", DirectUnitCost);
        PurchLine.Description := NpXmlDomMgt.GetElementText(XmlElement, 'description', MaxStrLen(PurchLine.Description), true);
        PurchLine.Modify(true);
    end;

    local procedure "--- NpEc Document Mgt."()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 38, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeletePurchHeader(var Rec: Record "Purchase Header"; RunTrigger: Boolean)
    var
        NpEcDocument: Record "NPR NpEc Document";
    begin
        //-NPR5.54 [390380]
        if Rec.IsTemporary then
            exit;

        case Rec."Document Type" of
            Rec."Document Type"::Quote:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Quote");
                end;
            Rec."Document Type"::Order:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Order");
                end;
            Rec."Document Type"::Invoice:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Invoice");
                end;
            Rec."Document Type"::"Credit Memo":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Credit Memo");
                end;
            Rec."Document Type"::"Blanket Order":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Blanket Order");
                end;
            Rec."Document Type"::"Return Order":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Return Order");
                end;
        end;
        NpEcDocument.SetRange("Document No.", Rec."No.");
        if NpEcDocument.IsEmpty then
            exit;

        NpEcDocument.DeleteAll;
        //+NPR5.54 [390380]
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPostPurchaseDoc', '', true, true)]
    local procedure OnAfterPostPurchDoc(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20])
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpEcDocument2: Record "NPR NpEc Document";
    begin
        //-NPR5.54 [390380]
        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::Quote:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Quote");
                end;
            PurchaseHeader."Document Type"::Order:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Order");
                end;
            PurchaseHeader."Document Type"::Invoice:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Invoice");
                end;
            PurchaseHeader."Document Type"::"Credit Memo":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Credit Memo");
                end;
            PurchaseHeader."Document Type"::"Blanket Order":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Blanket Order");
                end;
            PurchaseHeader."Document Type"::"Return Order":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Return Order");
                end;
        end;
        NpEcDocument.SetRange("Document No.", PurchaseHeader."No.");
        if not NpEcDocument.FindLast then
            exit;

        if PurchInvHdrNo <> '' then begin
            NpEcDocument2.Init;
            NpEcDocument2."Entry No." := 0;
            NpEcDocument2."Store Code" := NpEcDocument."Store Code";
            NpEcDocument2."Reference No." := NpEcDocument."Reference No.";
            NpEcDocument2."Document Type" := NpEcDocument2."Document Type"::"Posted Purchase Invoice";
            NpEcDocument2."Document No." := PurchInvHdrNo;
            NpEcDocument2.Insert(true);
        end;

        if PurchCrMemoHdrNo <> '' then begin
            NpEcDocument2.Init;
            NpEcDocument2."Entry No." := 0;
            NpEcDocument2."Store Code" := NpEcDocument."Store Code";
            NpEcDocument2."Reference No." := NpEcDocument."Reference No.";
            NpEcDocument2."Document Type" := NpEcDocument2."Document Type"::"Posted Purchase Credit Memo";
            NpEcDocument2."Document No." := PurchCrMemoHdrNo;
            NpEcDocument2.Insert(true);
        end;

        if PurchRcpHdrNo <> '' then begin
            NpEcDocument2.Init;
            NpEcDocument2."Entry No." := 0;
            NpEcDocument2."Store Code" := NpEcDocument."Store Code";
            NpEcDocument2."Reference No." := NpEcDocument."Reference No.";
            NpEcDocument2."Document Type" := NpEcDocument2."Document Type"::"Posted Purchase Receipt";
            NpEcDocument2."Document No." := PurchRcpHdrNo;
            NpEcDocument2.Insert(true);
        end;

        if RetShptHdrNo <> '' then begin
            NpEcDocument2.Init;
            NpEcDocument2."Entry No." := 0;
            NpEcDocument2."Store Code" := NpEcDocument."Store Code";
            NpEcDocument2."Reference No." := NpEcDocument."Reference No.";
            NpEcDocument2."Document Type" := NpEcDocument2."Document Type"::"Posted Purchase Return Shipment";
            NpEcDocument2."Document No." := RetShptHdrNo;
            NpEcDocument2.Insert(true);
        end;
        //+NPR5.54 [390380]
    end;

    local procedure "--- Get/Check"()
    begin
    end;

    procedure FindInvoice(XmlElement: DotNet NPRNetXmlElement; var PurchHeader: Record "Purchase Header"): Boolean
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpEcStore: Record "NPR NpEc Store";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        InvoiceNo: Text;
        StoreCode: Text;
    begin
        Clear(PurchHeader);

        FindStore(XmlElement, NpEcStore);
        InvoiceNo := GetInvoiceNo(XmlElement);
        if InvoiceNo = '' then
            exit(false);

        //-NPR5.54 [390380]
        NpEcDocument.SetRange("Store Code", NpEcStore.Code);
        NpEcDocument.SetRange("Reference No.", InvoiceNo);
        NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Invoice");
        if not NpEcDocument.FindLast then
            exit(false);

        exit(PurchHeader.Get(PurchHeader."Document Type"::Invoice, NpEcDocument."Document No."));
        //+NPR5.54 [390380]
    end;

    local procedure FindItemVariant(ReferenceNo: Text; var ItemVariant: Record "Item Variant"): Boolean
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
            ItemCrossRef.SetRange("Cross-Reference Type", ItemCrossRef."Cross-Reference Type"::"Bar Code");
            ItemCrossRef.SetRange("Cross-Reference No.", UpperCase(ReferenceNo));
            ItemCrossRef.SetRange("Discontinue Bar Code", false);
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

        Position := StrPos(ReferenceNo, '_');
        if Position > 0 then begin
            ItemNo := UpperCase(CopyStr(ReferenceNo, 1, Position));
            VariantCode := UpperCase(DelStr(ReferenceNo, 1, Position));

            if (StrLen(ItemNo) <= MaxStrLen(ItemVariant."Item No.")) and (StrLen(VariantCode) <= MaxStrLen(ItemVariant.Code)) then begin
                if ItemVariant.Get(ItemNo, VariantCode) then
                    exit(true);
            end;
        end;

        exit(false);
    end;

    procedure FindPostedInvoice(XmlElement: DotNet NPRNetXmlElement; var PurchInvHeader: Record "Purch. Inv. Header"): Boolean
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpEcStore: Record "NPR NpEc Store";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        InvoiceNo: Text;
    begin
        FindStore(XmlElement, NpEcStore);
        InvoiceNo := GetInvoiceNo(XmlElement);
        //-NPR5.54 [390380]
        NpEcDocument.SetRange("Store Code", NpEcStore.Code);
        NpEcDocument.SetRange("Reference No.", InvoiceNo);
        NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Posted Purchase Invoice");
        if not NpEcDocument.FindLast then
            exit(false);

        exit(PurchInvHeader.Get(NpEcDocument."Document No."));
        //+NPR5.54 [390380]
    end;

    procedure FindPostedInvoices(XmlElement: DotNet NPRNetXmlElement; var TempPurchInvHeader: Record "Purch. Inv. Header" temporary): Boolean
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpEcStore: Record "NPR NpEc Store";
        PurchInvHeader: Record "Purch. Inv. Header";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        InvoiceNo: Text;
    begin
        //-NPR5.54 [390380]
        FindStore(XmlElement, NpEcStore);
        InvoiceNo := GetInvoiceNo(XmlElement);

        NpEcDocument.SetRange("Store Code", NpEcStore.Code);
        NpEcDocument.SetRange("Reference No.", InvoiceNo);
        NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Posted Purchase Invoice");
        if not NpEcDocument.FindSet then
            exit(false);

        repeat
            if PurchInvHeader.Get(NpEcDocument."Document No.") and not TempPurchInvHeader.Get(PurchInvHeader."No.") then begin
                TempPurchInvHeader.Init;
                TempPurchInvHeader := PurchInvHeader;
                TempPurchInvHeader.Insert;
            end;
        until NpEcDocument.Next = 0;

        exit(TempPurchInvHeader.FindFirst);
        //+NPR5.54 [390380]
    end;

    local procedure FindStore(XmlElement: DotNet NPRNetXmlElement; var NpEcStore: Record "NPR NpEc Store")
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        StoreCode: Text;
    begin
        StoreCode := NpXmlDomMgt.GetAttributeCode(XmlElement, '/*/purchase_invoice', 'store_code', MaxStrLen(NpEcStore.Code), true);
        NpEcStore.Get(StoreCode);
    end;

    local procedure FindVendor(XmlElement: DotNet NPRNetXmlElement; var Vendor: Record Vendor)
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        VendorNo: Text;
    begin
        Clear(Vendor);

        VendorNo := NpXmlDomMgt.GetAttributeCode(XmlElement, '/*/purchase_invoice/buy_from_vendor', 'vendor_no', MaxStrLen(Vendor."No."), true);
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

    local procedure GetInvoiceNo(XmlElement: DotNet NPRNetXmlElement) InvoiceNo: Text
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
    begin
        //-NPR5.54 [390380]
        InvoiceNo := NpXmlDomMgt.GetAttributeCode(XmlElement, '/*/purchase_invoice', 'invoice_no', MaxStrLen(NpEcDocument."Reference No."), true);
        //+NPR5.54 [390380]
        if InvoiceNo = '' then
            Error(Text000, 'invoice_no', 'purchase_invoice');
    end;

    procedure InvoiceExists(XmlElement: DotNet NPRNetXmlElement): Boolean
    var
        PurchHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        if FindInvoice(XmlElement, PurchHeader) then
            exit(true);

        if FindPostedInvoice(XmlElement, PurchInvHeader) then
            exit(true);

        exit(false);
    end;

    procedure GetDocReferenceNo(PurchHeader: Record "Purchase Header"): Text
    var
        NpEcDocument: Record "NPR NpEc Document";
    begin
        //-NPR5.54 [390380]
        case PurchHeader."Document Type" of
            PurchHeader."Document Type"::Quote:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Quote");
                end;
            PurchHeader."Document Type"::Order:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Order");
                end;
            PurchHeader."Document Type"::Invoice:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Invoice");
                end;
            PurchHeader."Document Type"::"Credit Memo":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Credit Memo");
                end;
            PurchHeader."Document Type"::"Blanket Order":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Blanket Order");
                end;
            PurchHeader."Document Type"::"Return Order":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Return Order");
                end;
        end;
        NpEcDocument.SetRange("Document No.", PurchHeader."No.");
        if NpEcDocument.FindLast then;
        exit(NpEcDocument."Reference No.");
        //+NPR5.54 [390380]
    end;
}

