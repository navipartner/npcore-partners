codeunit 6151326 "NPR NpEc P.Invoice Look."
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        TempPurchHeader: Record "Purchase Header" temporary;
        TempPurchInvHeader: Record "Purch. Inv. Header" temporary;
    begin
        if not GetInvoiceDocuments(Rec, TempPurchHeader, TempPurchInvHeader) then
            exit;

        if RunPagePurchInvoice(TempPurchHeader) then
            exit;
        if RunPagePostedPurchInvoice(TempPurchInvHeader) then
            exit;

        Error('');
    end;

    procedure GetInvoiceDocuments(ImportEntry: Record "NPR Nc Import Entry"; var TempPurchHeader: Record "Purchase Header" temporary; var TempPurchInvHeader: Record "Purch. Inv. Header" temporary): Boolean
    var
        PurchHeader: Record "Purchase Header";
        NpEcPurchDocImportMgt: Codeunit "NPR NpEc Purch.Doc.Import Mgt.";
        Document: XmlDocument;
        Element: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin
        if not TempPurchHeader.IsTemporary() then
            exit;

        if not TempPurchInvHeader.IsTemporary() then
            exit;

        TempPurchHeader.DeleteAll();
        TempPurchInvHeader.DeleteAll();

        if not Load(ImportEntry, Document) then
            exit;
        if not Document.GetRoot(Element) then
            exit;

        if not Element.SelectNodes('//purchase_invoice', NodeList) then
            exit;

        foreach Node in NodeList do begin
            Element := Node.AsXmlElement();
            if NpEcPurchDocImportMgt.FindInvoice(Element, PurchHeader) and not TempPurchHeader.Get(PurchHeader."Document Type", PurchHeader."No.") then begin
                TempPurchHeader.Init();
                TempPurchHeader := PurchHeader;
                TempPurchHeader.Insert();
            end;

            NpEcPurchDocImportMgt.FindPostedInvoices(Element, TempPurchInvHeader);
        end;

        exit(TempPurchHeader.FindSet() or TempPurchInvHeader.FindSet());
    end;

    procedure RunPagePurchInvoice(var TempPurchHeader: Record "Purchase Header" temporary): Boolean
    var
        PurchHeader: Record "Purchase Header";
    begin
        case TempPurchHeader.Count() of
            0:
                begin
                    exit(false);
                end;
            1:
                begin
                    TempPurchHeader.FindFirst();
                    PurchHeader.Get(TempPurchHeader."Document Type", TempPurchHeader."No.");
                    PAGE.Run(PAGE::"Purchase Invoice", PurchHeader);
                end;
            else
                PAGE.Run(PAGE::"Purchase Invoices", TempPurchHeader);
        end;

        exit(true);
    end;

    procedure RunPagePostedPurchInvoice(var TempPurchInvHeader: Record "Purch. Inv. Header" temporary): Boolean
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        case TempPurchInvHeader.Count() of
            0:
                begin
                    exit(false);
                end;
            1:
                begin
                    TempPurchInvHeader.FindFirst();
                    PurchInvHeader.Get(TempPurchInvHeader."No.");
                    PAGE.Run(PAGE::"Posted Purchase Invoice", PurchInvHeader);
                end;
            else
                PAGE.Run(PAGE::"Posted Purchase Invoices", TempPurchInvHeader);
        end;

        exit(true);
    end;

    local procedure Load(Rec: Record "NPR Nc Import Entry"; var Document: XmlDocument): Boolean
    var
        XmlDomMgt: Codeunit "XML DOM Management";
        InStr: InStream;
        DocumentSource: Text;
    begin
        Rec.CalcFields("Document Source");
        if not Rec."Document Source".HasValue() then
            exit(false);
        Rec."Document Source".CreateInStream(InStr);
        XmlDocument.ReadFrom(InStr, Document);
        Document.WriteTo(DocumentSource);
        DocumentSource := XmlDomMgt.RemoveNamespaces(DocumentSource);
        XmlDocument.ReadFrom(DocumentSource, Document);
        exit(true);
    end;
}

