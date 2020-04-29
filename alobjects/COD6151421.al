codeunit 6151421 "Magento Lookup Return Order"
{
    // MAG2.12/MHA /20180425  CASE 309647 Object created - Sales Return Order Import
    // MAG2.23/MHA /20191018  CASE 369170 Removed unused Global Variables

    TableNo = "Nc Import Entry";

    trigger OnRun()
    var
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesCrMemoHeader: Record "Sales Cr.Memo Header" temporary;
    begin
        if not GetReturnOrderDocuments(Rec,TempSalesHeader,TempSalesCrMemoHeader) then
          exit;

        if RunPageReturnOrder(TempSalesHeader) then
          exit;
        if RunPageSalesCrMemo(TempSalesCrMemoHeader) then
          exit;
    end;

    procedure GetReturnOrderDocuments(ImportEntry: Record "Nc Import Entry";var TempSalesHeader: Record "Sales Header" temporary;var TempSalesCrMemoHeader: Record "Sales Cr.Memo Header" temporary): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        RecRef: RecordRef;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        ReturnOrderNo: Code[20];
        i: Integer;
    begin
        RecRef.GetTable(TempSalesHeader);
        if not RecRef.IsTemporary then
          exit(false);

        RecRef.GetTable(TempSalesCrMemoHeader);
        if not RecRef.IsTemporary then
          exit(false);

        TempSalesHeader.DeleteAll;
        TempSalesCrMemoHeader.DeleteAll;

        if not ImportEntry.LoadXmlDoc(XmlDoc) then
          exit(false);

        XmlElement := XmlDoc.DocumentElement;
        if not NpXmlDomMgt.FindNodes(XmlElement,'sales_return_order',XmlNodeList) then
          exit(false);

        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement := XmlNodeList.ItemOf(i);
          ReturnOrderNo := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'return_order_no',false);
          if (ReturnOrderNo <> '') and (StrLen(ReturnOrderNo) <= MaxStrLen(SalesHeader."External Order No.")) then begin
            SalesHeader.SetRange("Document Type",SalesHeader."Document Type"::"Return Order");
            SalesHeader.SetRange("External Order No.",ReturnOrderNo);
            if SalesHeader.FindSet then
              repeat
                if not TempSalesHeader.Get(SalesHeader."Document Type",SalesHeader."No.") then begin
                  TempSalesHeader.Init;
                  TempSalesHeader := SalesHeader;
                  TempSalesHeader.Insert;
                end;
              until SalesHeader.Next = 0;
            SalesCrMemoHeader.SetRange("External Order No.",ReturnOrderNo);
            if SalesCrMemoHeader.FindSet then
              repeat
                if not TempSalesCrMemoHeader.Get(SalesCrMemoHeader."No.") then begin
                  TempSalesCrMemoHeader.Init;
                  TempSalesCrMemoHeader:= SalesCrMemoHeader;
                  TempSalesCrMemoHeader.Insert;
                end;
              until SalesCrMemoHeader.Next = 0;
          end;
        end;

        exit(TempSalesHeader.FindSet or TempSalesCrMemoHeader.FindSet);
    end;

    procedure RunPageReturnOrder(var TempSalesHeader: Record "Sales Header" temporary): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        case TempSalesHeader.Count of
          0:
            exit(false);
          1:
            begin
              TempSalesHeader.FindFirst;
              SalesHeader.Get(TempSalesHeader."Document Type",TempSalesHeader."No.");
              PAGE.Run(PAGE::"Sales Return Order",SalesHeader);
            end;
          else
            PAGE.Run(PAGE::"Sales Return Order List",TempSalesHeader);
        end;

        exit(true);
    end;

    procedure RunPageSalesCrMemo(var TempSalesCrMemoHeader: Record "Sales Cr.Memo Header" temporary): Boolean
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        case TempSalesCrMemoHeader.Count of
          0:
            exit(false);
          1:
            begin
              TempSalesCrMemoHeader.FindFirst;
              SalesCrMemoHeader.Get(TempSalesCrMemoHeader."No.");
              PAGE.Run(PAGE::"Posted Sales Credit Memo",SalesCrMemoHeader);
            end;
          else
            PAGE.Run(PAGE::"Posted Sales Credit Memos",TempSalesCrMemoHeader);
        end;

        exit(true);
    end;
}

