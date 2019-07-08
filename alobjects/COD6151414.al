codeunit 6151414 "Magento Lookup Sales Order"
{
    // MAG1.21/TTH/20151118 CASE 227358 Replacing Type option field with Import type. Code moved here from page 6059808 "Naviconnect Import List"
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

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
    end;

    var
        TempImportEntry: Record "Nc Import Entry" temporary;
        GambitMgt: Codeunit "Nc Gambit Management";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        SyncMgt: Codeunit "Nc Sync. Mgt.";
        ErrorText: Text;
        ShowImported: Boolean;
        WebClient: Boolean;

    procedure GetOrderDocuments(ImportEntry: Record "Nc Import Entry";var TempSalesHeader: Record "Sales Header" temporary;var TempSalesInvHeader: Record "Sales Invoice Header" temporary): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        RecRef: RecordRef;
        XmlDoc: DotNet XmlDocument;
        XmlElement: DotNet XmlElement;
        XmlNodeList: DotNet XmlNodeList;
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
          OrderNo := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'order_no',false);
          if (OrderNo <> '') and (StrLen(OrderNo) <= MaxStrLen(SalesHeader."External Order No.")) then begin
            SalesHeader.SetRange("Document Type",SalesHeader."Document Type"::Order);
            SalesHeader.SetRange("External Order No.",OrderNo);
            if SalesHeader.FindSet then
              repeat
                if not TempSalesHeader.Get(SalesHeader."Document Type",SalesHeader."No.") then begin
                  TempSalesHeader.Init;
                  TempSalesHeader := SalesHeader;
                  TempSalesHeader.Insert;
                end;
              until SalesHeader.Next = 0;
            SalesInvHeader.SetRange("External Order No.",OrderNo);
            if SalesInvHeader.FindSet then
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
          0: exit(false);
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
          0: exit(false);
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

