codeunit 6151302 "NpEc S.Order Lookup"
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce

    TableNo = "Nc Import Entry";

    trigger OnRun()
    var
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesCrMemoHeader: Record "Sales Cr.Memo Header" temporary;
        TempSalesInvHeader: Record "Sales Invoice Header" temporary;
    begin
        if not GetOrderDocuments(Rec,TempSalesHeader,TempSalesInvHeader) then
          exit;

        if RunPageSalesOrder(TempSalesHeader) then
          exit;
        if RunPageSalesInvoice(TempSalesInvHeader) then
          exit;

        Error('');
    end;

    procedure GetOrderDocuments(ImportEntry: Record "Nc Import Entry";var TempSalesHeader: Record "Sales Header" temporary;var TempSalesInvHeader: Record "Sales Invoice Header" temporary): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        NpEcSalesDocImportMgt: Codeunit "NpEc Sales Doc. Import Mgt.";
        RecRef: RecordRef;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        OrderNo: Code[20];
        i: Integer;
    begin
        RecRef.GetTable(TempSalesHeader);
        if not RecRef.IsTemporary then
          exit(false);

        RecRef.GetTable(TempSalesInvHeader);
        if not RecRef.IsTemporary then
          exit(false);

        TempSalesHeader.DeleteAll;
        TempSalesInvHeader.DeleteAll;

        if not ImportEntry.LoadXmlDoc(XmlDoc) then
          exit(false);

        XmlElement := XmlDoc.DocumentElement;
        if not NpXmlDomMgt.FindNodes(XmlElement,'sales_order',XmlNodeList) then
          exit(false);

        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement := XmlNodeList.ItemOf(i);
          if NpEcSalesDocImportMgt.FindOrder(XmlElement,SalesHeader) then begin
            SalesHeader.FindSet;
            repeat
              if not TempSalesHeader.Get(SalesHeader."Document Type",SalesHeader."No.") then begin
                TempSalesHeader.Init;
                TempSalesHeader := SalesHeader;
                TempSalesHeader.Insert;
              end;
            until SalesHeader.Next = 0;
          end;

          if NpEcSalesDocImportMgt.FindPostedInvoice(XmlElement,SalesInvHeader) then begin
            SalesInvHeader.FindSet;
            repeat
              if not TempSalesInvHeader.Get(SalesInvHeader."No.") then begin
                TempSalesInvHeader.Init;
                TempSalesInvHeader := SalesInvHeader;
                TempSalesInvHeader.Insert;
              end;
            until SalesInvHeader.Next = 0;
          end;
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
              SalesHeader.Get(TempSalesHeader."Document Type",TempSalesHeader."No.");
              PAGE.Run(PAGE::"Sales Order",SalesHeader);
            end;
          else
            PAGE.Run(PAGE::"Sales Order List",TempSalesHeader);
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
              PAGE.Run(PAGE::"Posted Sales Invoice",SalesInvHeader);
            end;
          else
            PAGE.Run(PAGE::"Posted Sales Invoices",TempSalesInvHeader);
        end;

        exit(true);
    end;
}

