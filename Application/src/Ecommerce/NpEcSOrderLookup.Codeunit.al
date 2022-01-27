codeunit 6151302 "NPR NpEc S.Order Lookup"
{
    Access = Internal;
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesInvHeader: Record "Sales Invoice Header" temporary;
    begin
        if not GetOrderDocuments(Rec, TempSalesHeader, TempSalesInvHeader) then
            exit;

        if RunPageSalesOrder(TempSalesHeader) then
            exit;
        if RunPageSalesInvoice(TempSalesInvHeader) then
            exit;

        Error('');
    end;

    procedure GetOrderDocuments(ImportEntry: Record "NPR Nc Import Entry"; var TempSalesHeader: Record "Sales Header" temporary; var TempSalesInvHeader: Record "Sales Invoice Header" temporary): Boolean
    var
        SalesHeader: Record "Sales Header";
        NpEcSalesDocImportMgt: Codeunit "NPR NpEc Sales Doc. Imp. Mgt.";
        Document: XmlDocument;
        Element: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin
        if not TempSalesHeader.IsTemporary() then
            exit(false);

        if not TempSalesInvHeader.IsTemporary() then
            exit(false);

        TempSalesHeader.DeleteAll();
        TempSalesInvHeader.DeleteAll();

        if not Load(ImportEntry, Document) then
            exit;
        if not Document.GetRoot(Element) then
            exit;

        if not Element.SelectNodes('//sales_order', NodeList) then
            exit;

        foreach Node in NodeList do begin
            Element := Node.AsXmlElement();
            if NpEcSalesDocImportMgt.FindOrder(Element, SalesHeader) and not TempSalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.") then begin
                TempSalesHeader.Init();
                TempSalesHeader := SalesHeader;
                TempSalesHeader.Insert();
            end;

            NpEcSalesDocImportMgt.FindPostedInvoices(Element, TempSalesInvHeader);
        end;

        exit(TempSalesHeader.FindSet() or TempSalesInvHeader.FindSet());
    end;

    procedure RunPageSalesOrder(var TempSalesHeader: Record "Sales Header" temporary): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        case TempSalesHeader.Count() of
            0:
                begin
                    exit(false);
                end;
            1:
                begin
                    TempSalesHeader.FindFirst();
                    SalesHeader.Get(TempSalesHeader."Document Type", TempSalesHeader."No.");
                    PAGE.Run(PAGE::"Sales Order", SalesHeader);
                end;
            else
                PAGE.Run(PAGE::"Sales Order List", TempSalesHeader);
        end;

        exit(true);
    end;

    procedure RunPageSalesInvoice(var TempSalesInvHeader: Record "Sales Invoice Header" temporary): Boolean
    var
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        case TempSalesInvHeader.Count() of
            0:
                begin
                    exit(false);
                end;
            1:
                begin
                    TempSalesInvHeader.FindFirst();
                    SalesInvHeader.Get(TempSalesInvHeader."No.");
                    PAGE.Run(PAGE::"Posted Sales Invoice", SalesInvHeader);
                end;
            else
                PAGE.Run(PAGE::"Posted Sales Invoices", TempSalesInvHeader);
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

