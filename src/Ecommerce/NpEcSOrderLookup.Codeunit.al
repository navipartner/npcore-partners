codeunit 6151302 "NPR NpEc S.Order Lookup"
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce
    // NPR5.54/MHA /20200417  CASE 390380 Updated functions for finding sales invoices

    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesCrMemoHeader: Record "Sales Cr.Memo Header" temporary;
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
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        NpEcSalesDocImportMgt: Codeunit "NPR NpEc Sales Doc. Imp. Mgt.";
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
    begin
        //-NPR5.54 [390380]
        if not TempSalesHeader.IsTemporary then
            exit(false);

        if not TempSalesInvHeader.IsTemporary then
            exit(false);
        //+NPR5.54 [390380]

        TempSalesHeader.DeleteAll;
        TempSalesInvHeader.DeleteAll;

        if not ImportEntry.LoadXmlDoc(XmlDoc) then
            exit(false);

        XmlElement := XmlDoc.DocumentElement;
        if not NpXmlDomMgt.FindNodes(XmlElement, 'sales_order', XmlNodeList) then
            exit(false);

        for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            //-NPR5.54 [390380]
            if NpEcSalesDocImportMgt.FindOrder(XmlElement, SalesHeader) and not TempSalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.") then begin
                TempSalesHeader.Init;
                TempSalesHeader := SalesHeader;
                TempSalesHeader.Insert;
            end;

            NpEcSalesDocImportMgt.FindPostedInvoices(XmlElement, TempSalesInvHeader);
            //+NPR5.54 [390380]
        end;

        exit(TempSalesHeader.FindSet or TempSalesInvHeader.FindSet);
    end;

    procedure RunPageSalesOrder(var TempSalesHeader: Record "Sales Header" temporary): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        case TempSalesHeader.Count of
            0:
                begin
                    exit(false);
                end;
            1:
                begin
                    TempSalesHeader.FindFirst;
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
        case TempSalesInvHeader.Count of
            0:
                begin
                    exit(false);
                end;
            1:
                begin
                    TempSalesInvHeader.FindFirst;
                    SalesInvHeader.Get(TempSalesInvHeader."No.");
                    PAGE.Run(PAGE::"Posted Sales Invoice", SalesInvHeader);
                end;
            else
                PAGE.Run(PAGE::"Posted Sales Invoices", TempSalesInvHeader);
        end;

        exit(true);
    end;
}

