codeunit 6151321 "NPR NpEc Purch.Doc.Import Mgt."
{
    Access = Internal;
    var
        InvalidLineTypeErr: Label 'Invalid Line Type: %1', Comment = '%1=xml attribute type';
        XmlElementIsMissingErr: Label 'XmlElement %1 is missing', Comment = '%1=xpath to element';
        XmlAttributeIsMissingInElementErr: Label 'Xml attribute %1 is missing in <%2>', Comment = '%1=Xml attribute name;%2=Xml element name';
        WrongValueTypeInNodeErr: Label 'Value "%1" is not set in proper format in <%2>. (e.g. %3)', Comment = '%1=xml element inner text;%2=xpath to element;%3=BC sample data with XML format';

    procedure DeletePurchLines(PurchHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
    begin
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        if not PurchLine.IsEmpty() then
            PurchLine.DeleteAll(true);
    end;

    procedure DeleteNotes(var PurchHeader: Record "Purchase Header")
    var
        RecordLink: Record "Record Link";
    begin
        RecordLink.SetRange("Record ID", PurchHeader.RecordId());
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetFilter("User ID", '=%1', '');
        if not RecordLink.IsEmpty() then
            RecordLink.DeleteAll(true);
    end;

    procedure InsertNote(Element: XmlElement; var PurchHeader: Record "Purchase Header")
    var
        RecordLink: Record "Record Link";
        RecordLinkManagement: Codeunit "Record Link Management";
        Node: XmlNode;
        Note: Text;
        LinkID: Integer;
    begin
        if not Element.SelectSingleNode('.//note', Node) then
            exit;
        if not Node.IsXmlElement() then
            exit;
        Note := Node.AsXmlElement().InnerText();
        if Note = '' then
            exit;

        LinkID := PurchHeader.AddLink('', PurchHeader."No.");
        RecordLink.Get(LinkID);
        RecordLink.Type := RecordLink.Type::Note;
        RecordLinkManagement.WriteNote(RecordLink, Note);
        RecordLink."User ID" := '';
        RecordLink.Modify(true);
    end;

    procedure InsertInvoiceHeader(Element: XmlElement; var PurchHeader: Record "Purchase Header")
    var
        NpEcDocument: Record "NPR NpEc Document";
        Vendor: Record Vendor;
        NpEcStore: Record "NPR NpEc Store";
        Node: XmlNode;
        DocDate: Date;
    begin
        FindStore(Element, NpEcStore);
        FindVendor(Element, Vendor);

        Clear(PurchHeader);
        PurchHeader.SetHideValidationDialog(true);
        PurchHeader.Init();
        PurchHeader."Document Type" := PurchHeader."Document Type"::Invoice;
        PurchHeader."No." := '';
        if Element.SelectSingleNode('.//vendor_invoice_no', Node) then
            PurchHeader."Vendor Invoice No." := Copystr(Node.AsXmlElement().InnerText(), 1, maxstrlen(PurchHeader."Vendor Invoice No."));

        PurchHeader.Insert(true);

        NpEcDocument.Init();
        NpEcDocument."Entry No." := 0;
        NpEcDocument."Store Code" := NpEcStore.Code;
        NpEcDocument."Reference No." := GetInvoiceNo(Element);
        NpEcDocument."Document Type" := NpEcDocument."Document Type"::"Purchase Invoice";
        NpEcDocument."Document No." := PurchHeader."No.";
        NpEcDocument.Insert(true);

        PurchHeader.Validate("Buy-from Vendor No.", Vendor."No.");

        if not Element.SelectSingleNode('.//posting_date', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'posting_date');

        if not evaluate(PurchHeader."Posting Date", Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'posting_date', Format(today(), 0, 9));

        PurchHeader.Validate("Posting Date");

        if Element.SelectSingleNode('.//document_date', Node) then
            if Evaluate(DocDate, Node.AsXmlElement().InnerText(), 9) then
                if DocDate <> 0D then
                    PurchHeader.Validate("Document Date", DocDate);

        PurchHeader.Validate("Purchaser Code", NpEcStore."Salesperson/Purchaser Code");

        PurchHeader.Validate(PurchHeader."Shortcut Dimension 1 Code", NpEcStore."Global Dimension 1 Code");
        if NpEcStore."Global Dimension 2 Code" <> '' then
            PurchHeader.Validate("Shortcut Dimension 2 Code", NpEcStore."Global Dimension 2 Code");

        PurchHeader.Validate("Location Code", NpEcStore."Location Code");
        if Element.SelectSingleNode('.//currency_code', Node) then
            PurchHeader."Currency Code" := CopyStr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(PurchHeader."Currency Code"));

        PurchHeader.Validate("Currency Code", GetCurrencyCode(PurchHeader."Currency Code"));
        PurchHeader.Modify(true);
    end;

    procedure InsertInvoiceLines(Element: XmlElement; PurchHeader: Record "Purchase Header")
    var
        Node: XmlNode;
        NodeList: XmlNodeList;
        LineNo: Integer;
    begin
        LineNo := 0;

        if not Element.SelectSingleNode('.//purchase_invoice_lines', Node) then
            exit;

        Element := Node.AsXmlElement();
        if not Element.SelectNodes('.//purchase_invoice_line', NodeList) then
            exit;

        foreach Node in NodeList do
            InsertPurchLine(Node.AsXmlElement(), PurchHeader, LineNo);
    end;

    local procedure InsertPurchLine(Element: XmlElement; PurchHeader: Record "Purchase Header"; var LineNo: Integer)
    var
        PurchLine: Record "Purchase Line";
        Attribute: XmlAttribute;
        LineType: Text;
    begin
        if not Element.Attributes().Get('type', Attribute) then
            Error(XmlAttributeIsMissingInElementErr, 'type', Element.Name());

        LineType := Attribute.Value();

        case LowerCase(LineType) of
            'comment', Format(PurchLine.Type::" ", 0, 2):
                begin
                    InsertPurchLineComment(Element, PurchHeader, LineNo);
                end;
            'item', Format(PurchLine.Type::Item, 0, 2):
                begin
                    InsertPurchLineItem(Element, PurchHeader, LineNo);
                end;
            'gl_account', Format(PurchLine.Type::"G/L Account", 0, 2):
                begin
                    InsertPurchLineGLAccount(Element, PurchHeader, LineNo);
                end;
            else
                Error(InvalidLineTypeErr, LineType);
        end;
    end;

    local procedure InsertPurchLineComment(Element: XmlElement; PurchHeader: Record "Purchase Header"; var LineNo: Integer)
    var
        PurchLine: Record "Purchase Line";
        Node: XmlNode;
    begin
        LineNo += 10000;
        PurchLine.Init();
        PurchLine."Document Type" := PurchHeader."Document Type";
        PurchLine."Document No." := PurchHeader."No.";
        PurchLine."Line No." := LineNo;
        PurchLine.Insert(true);
        PurchLine.Validate(Type, PurchLine.Type::" ");
        if not Element.SelectSingleNode('.//description', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'description');
        PurchLine.Description := CopyStr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(PurchLine.Description));
        PurchLine.Modify(true);
    end;

    local procedure InsertPurchLineItem(Element: XmlElement; PurchHeader: Record "Purchase Header"; var LineNo: Integer)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        PurchLine: Record "Purchase Line";
        Attribute: XmlAttribute;
        Node: XmlNode;
        LineAmount, Quantity, DirectUnitCost, VatPct : Decimal;
        ReferenceNo: Text;
        RandDecValue: Decimal;
    begin
        if not Element.Attributes().Get('reference_no', Attribute) then
            Error(XmlAttributeIsMissingInElementErr, 'reference_no', Element.Name());

        ReferenceNo := Attribute.Value();
        if not FindItemVariant(ReferenceNo, ItemVariant) then
            exit;

        Item.Get(ItemVariant."Item No.");
        if ItemVariant.Code <> '' then
            ItemVariant.Find();

        if not Element.SelectSingleNode('.//direct_unit_cost', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'direct_unit_cost');

        RandDecValue := Random(100);
        if not evaluate(DirectUnitCost, Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'direct_unit_cost', Format(RandDecValue, 0, 9));

        if not Element.SelectSingleNode('.//quantity', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'quantity');

        if not evaluate(Quantity, Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'quantity', Format(RandDecValue, 0, 9));

        if not Element.SelectSingleNode('.//vat_percent', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'vat_percent');

        if not evaluate(VatPct, Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'vat_percent', Format(RandDecValue, 0, 9));

        if not Element.SelectSingleNode('.//line_amount', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'line_amount');

        if not evaluate(LineAmount, Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'line_amount', Format(RandDecValue, 0, 9));

        LineNo += 10000;
        PurchLine.Init();
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

        if PurchLine."Direct Unit Cost" <> 0 then
            PurchLine.Validate("Line Amount", LineAmount)
        else
            PurchLine."Line Amount" := LineAmount;
        PurchLine.Modify(true);
    end;

    local procedure InsertPurchLineGLAccount(Element: XmlElement; PurchHeader: Record "Purchase Header"; var LineNo: Integer)
    var
        PurchLine: Record "Purchase Line";
        Attribute: XmlAttribute;
        Node: XmlNode;
        LineAmount, Quantity, DirectUnitCost : Decimal;
        AccountNo: Text;
        RandDecValue: Decimal;
    begin
        if not Element.Attributes().Get('reference_no', Attribute) then
            Error(XmlAttributeIsMissingInElementErr, 'reference_no', Element.Name());
        AccountNo := Attribute.Value();

        if not Element.SelectSingleNode('.//direct_unit_cost', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'direct_unit_cost');

        RandDecValue := Random(100);
        if not evaluate(DirectUnitCost, Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'direct_unit_cost', Format(RandDecValue, 0, 9));

        if not Element.SelectSingleNode('.//quantity', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'quantity');

        if not evaluate(Quantity, Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'quantity', Format(RandDecValue, 0, 9));

        if not Element.SelectSingleNode('.//line_amount', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'line_amount');

        if not evaluate(LineAmount, Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'line_amount', Format(RandDecValue, 0, 9));

        LineNo += 10000;
        PurchLine.Init();
        PurchLine."Document Type" := PurchHeader."Document Type";
        PurchLine."Document No." := PurchHeader."No.";
        PurchLine."Line No." := LineNo;
        PurchLine.Insert(true);

        PurchLine.Validate(Type, PurchLine.Type::"G/L Account");
        PurchLine.Validate("No.", AccountNo);
        if Quantity <> 0 then
            PurchLine.Validate(Quantity, Quantity);

        PurchLine.Validate("Direct Unit Cost", DirectUnitCost);

        if not Element.SelectSingleNode('.//description', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'description');
        PurchLine.Description := CopyStr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(PurchLine.Description));

        PurchLine.Modify(true);
    end;


    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeletePurchHeader(var Rec: Record "Purchase Header"; RunTrigger: Boolean)
    var
        NpEcDocument: Record "NPR NpEc Document";
    begin
        if Rec.IsTemporary() then
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
        if NpEcDocument.IsEmpty() then
            exit;

        NpEcDocument.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', true, true)]
    local procedure OnAfterPostPurchDoc(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20])
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpEcDocument2: Record "NPR NpEc Document";
    begin
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
        if not NpEcDocument.FindLast() then
            exit;

        if PurchInvHdrNo <> '' then begin
            NpEcDocument2.Init();
            NpEcDocument2."Entry No." := 0;
            NpEcDocument2."Store Code" := NpEcDocument."Store Code";
            NpEcDocument2."Reference No." := NpEcDocument."Reference No.";
            NpEcDocument2."Document Type" := NpEcDocument2."Document Type"::"Posted Purchase Invoice";
            NpEcDocument2."Document No." := PurchInvHdrNo;
            NpEcDocument2.Insert(true);
        end;

        if PurchCrMemoHdrNo <> '' then begin
            NpEcDocument2.Init();
            NpEcDocument2."Entry No." := 0;
            NpEcDocument2."Store Code" := NpEcDocument."Store Code";
            NpEcDocument2."Reference No." := NpEcDocument."Reference No.";
            NpEcDocument2."Document Type" := NpEcDocument2."Document Type"::"Posted Purchase Credit Memo";
            NpEcDocument2."Document No." := PurchCrMemoHdrNo;
            NpEcDocument2.Insert(true);
        end;

        if PurchRcpHdrNo <> '' then begin
            NpEcDocument2.Init();
            NpEcDocument2."Entry No." := 0;
            NpEcDocument2."Store Code" := NpEcDocument."Store Code";
            NpEcDocument2."Reference No." := NpEcDocument."Reference No.";
            NpEcDocument2."Document Type" := NpEcDocument2."Document Type"::"Posted Purchase Receipt";
            NpEcDocument2."Document No." := PurchRcpHdrNo;
            NpEcDocument2.Insert(true);
        end;

        if RetShptHdrNo <> '' then begin
            NpEcDocument2.Init();
            NpEcDocument2."Entry No." := 0;
            NpEcDocument2."Store Code" := NpEcDocument."Store Code";
            NpEcDocument2."Reference No." := NpEcDocument."Reference No.";
            NpEcDocument2."Document Type" := NpEcDocument2."Document Type"::"Posted Purchase Return Shipment";
            NpEcDocument2."Document No." := RetShptHdrNo;
            NpEcDocument2.Insert(true);
        end;
    end;

    procedure FindInvoice(Element: XmlElement; var PurchHeader: Record "Purchase Header"): Boolean
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpEcStore: Record "NPR NpEc Store";
        InvoiceNo: Text;
    begin
        Clear(PurchHeader);

        FindStore(Element, NpEcStore);
        InvoiceNo := GetInvoiceNo(Element);
        if InvoiceNo = '' then
            exit(false);

        NpEcDocument.SetRange("Store Code", NpEcStore.Code);
        NpEcDocument.SetRange("Reference No.", InvoiceNo);
        NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Purchase Invoice");
        if not NpEcDocument.FindLast() then
            exit(false);

        exit(PurchHeader.Get(PurchHeader."Document Type"::Invoice, NpEcDocument."Document No."));
    end;

    local procedure FindItemVariant(ReferenceNo: Text; var ItemVariant: Record "Item Variant"): Boolean
    var
        Item: Record Item;
        ItemRef: Record "Item Reference";
        Position: Integer;
        ItemNo, VariantCode : Text;
    begin
        Clear(ItemVariant);

        if ReferenceNo = '' then
            exit(false);

        if StrLen(ReferenceNo) <= MaxStrLen(ItemRef."Reference No.") then begin
            ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::"Bar Code");
            ItemRef.SetRange("Reference No.", UpperCase(ReferenceNo));
            if ItemRef.FindFirst() then begin
                ItemVariant."Item No." := ItemRef."Item No.";
                ItemVariant.Code := ItemRef."Variant Code";
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

    procedure FindPostedInvoice(Element: XmlElement; var PurchInvHeader: Record "Purch. Inv. Header"): Boolean
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpEcStore: Record "NPR NpEc Store";
        InvoiceNo: Text;
    begin
        FindStore(Element, NpEcStore);
        InvoiceNo := GetInvoiceNo(Element);
        NpEcDocument.SetRange("Store Code", NpEcStore.Code);
        NpEcDocument.SetRange("Reference No.", InvoiceNo);
        NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Posted Purchase Invoice");
        if not NpEcDocument.FindLast() then
            exit(false);

        exit(PurchInvHeader.Get(NpEcDocument."Document No."));
    end;

    procedure FindPostedInvoices(Element: XmlElement; var TempPurchInvHeader: Record "Purch. Inv. Header" temporary): Boolean
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpEcStore: Record "NPR NpEc Store";
        PurchInvHeader: Record "Purch. Inv. Header";
        InvoiceNo: Text;
    begin
        FindStore(Element, NpEcStore);
        InvoiceNo := GetInvoiceNo(Element);

        NpEcDocument.SetRange("Store Code", NpEcStore.Code);
        NpEcDocument.SetRange("Reference No.", InvoiceNo);
        NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Posted Purchase Invoice");
        if not NpEcDocument.FindSet() then
            exit(false);

        repeat
            if PurchInvHeader.Get(NpEcDocument."Document No.") and not TempPurchInvHeader.Get(PurchInvHeader."No.") then begin
                TempPurchInvHeader.Init();
                TempPurchInvHeader := PurchInvHeader;
                TempPurchInvHeader.Insert();
            end;
        until NpEcDocument.Next() = 0;

        exit(TempPurchInvHeader.FindFirst());
    end;

    local procedure FindStore(Element: XmlElement; var NpEcStore: Record "NPR NpEc Store")
    var
        Attribute: XmlAttribute;
    begin
        if not Element.Attributes().Get('store_code', Attribute) then
            exit;

        NpEcStore.Get(Attribute.Value());
    end;

    local procedure FindVendor(Element: XmlElement; var Vendor: Record Vendor)
    var
        Node: XmlNode;
        Attribute: XmlAttribute;
        VendorNo: Text;
    begin
        if not Element.SelectSingleNode('.//buy_from_vendor', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'buy_from_vendor');

        Clear(Vendor);
        Element := Node.AsXmlElement();
        if not Element.Attributes().Get('vendor_no', Attribute) then
            exit;

        VendorNo := Attribute.Value();
        Vendor.Get(VendorNo);
    end;

    local procedure GetCurrencyCode(CurrencyCode: Code[10]): Code[10]
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if not GLSetup.Get() then
            exit(CurrencyCode);

        if GLSetup."LCY Code" = CurrencyCode then
            exit('');

        exit(CurrencyCode);
    end;

    local procedure GetInvoiceNo(Element: XmlElement) InvoiceNo: Text
    var
        Attribute: XmlAttribute;
    begin
        if not Element.Attributes().Get('invoice_no', Attribute) then
            Error(XmlAttributeIsMissingInElementErr, 'invoice_no', Element.Name());
        InvoiceNo := Attribute.Value();
        if InvoiceNo = '' then
            Error(XmlAttributeIsMissingInElementErr, 'invoice_no', Element.Name());
    end;

    procedure InvoiceExists(Element: XmlElement): Boolean
    var
        PurchHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        if FindInvoice(Element, PurchHeader) then
            exit(true);

        if FindPostedInvoice(Element, PurchInvHeader) then
            exit(true);

        exit(false);
    end;

    procedure GetDocReferenceNo(PurchHeader: Record "Purchase Header"): Text
    var
        NpEcDocument: Record "NPR NpEc Document";
    begin
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
        if NpEcDocument.FindLast() then;
        exit(NpEcDocument."Reference No.");
    end;
}

