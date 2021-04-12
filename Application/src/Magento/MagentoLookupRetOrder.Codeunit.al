codeunit 6151421 "NPR Magento Lookup Ret.Order"
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesCrMemoHeader: Record "Sales Cr.Memo Header" temporary;
    begin
        if not GetReturnOrderDocuments(Rec, TempSalesHeader, TempSalesCrMemoHeader) then
            exit;

        if RunPageReturnOrder(TempSalesHeader) then
            exit;
        if RunPageSalesCrMemo(TempSalesCrMemoHeader) then
            exit;
    end;

    procedure GetReturnOrderDocuments(ImportEntry: Record "NPR Nc Import Entry"; var TempSalesHeader: Record "Sales Header" temporary; var TempSalesCrMemoHeader: Record "Sales Cr.Memo Header" temporary): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        RecRef: RecordRef;
        XmlDoc: XmlDocument;
        Node: XmlNode;
        ReturnOrderNoAttribute: XmlAttribute;
        XmlNodeList: XmlNodeList;
        ReturnOrderNo: Code[20];
    begin
        RecRef.GetTable(TempSalesHeader);
        if not RecRef.IsTemporary then
            exit(false);

        RecRef.GetTable(TempSalesCrMemoHeader);
        if not RecRef.IsTemporary then
            exit(false);

        TempSalesHeader.DeleteAll();
        TempSalesCrMemoHeader.DeleteAll();

        if not ImportEntry.LoadXmlDoc(XmlDoc) then
            exit(false);

        if not XmlDoc.SelectNodes('.//*[local-name()="sales_return_order"]', XmlNodeList) then
            exit(false);

        foreach Node in XmlNodeList do begin
            if Node.AsXmlElement().Attributes().Get('return_order_no', ReturnOrderNoAttribute) then
                ReturnOrderNo := ReturnOrderNoAttribute.Value;
            if (ReturnOrderNo <> '') and (StrLen(ReturnOrderNo) <= MaxStrLen(SalesHeader."NPR External Order No.")) then begin
                SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
                SalesHeader.SetRange("NPR External Order No.", ReturnOrderNo);
                if SalesHeader.FindSet() then
                    repeat
                        if not TempSalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.") then begin
                            TempSalesHeader.Init();
                            TempSalesHeader := SalesHeader;
                            TempSalesHeader.Insert();
                        end;
                    until SalesHeader.Next() = 0;
                SalesCrMemoHeader.SetRange("NPR External Order No.", ReturnOrderNo);
                if SalesCrMemoHeader.FindSet() then
                    repeat
                        if not TempSalesCrMemoHeader.Get(SalesCrMemoHeader."No.") then begin
                            TempSalesCrMemoHeader.Init();
                            TempSalesCrMemoHeader := SalesCrMemoHeader;
                            TempSalesCrMemoHeader.Insert();
                        end;
                    until SalesCrMemoHeader.Next() = 0;
            end;
        end;

        exit(TempSalesHeader.FindSet() or TempSalesCrMemoHeader.FindSet);
    end;

    procedure RunPageReturnOrder(var TempSalesHeader: Record "Sales Header" temporary): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        case TempSalesHeader.Count() of
            0:
                exit(false);
            1:
                begin
                    TempSalesHeader.FindFirst();
                    SalesHeader.Get(TempSalesHeader."Document Type", TempSalesHeader."No.");
                    PAGE.Run(PAGE::"Sales Return Order", SalesHeader);
                end;
            else
                PAGE.Run(PAGE::"Sales Return Order List", TempSalesHeader);
        end;

        exit(true);
    end;

    procedure RunPageSalesCrMemo(var TempSalesCrMemoHeader: Record "Sales Cr.Memo Header" temporary): Boolean
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        case TempSalesCrMemoHeader.Count() of
            0:
                exit(false);
            1:
                begin
                    TempSalesCrMemoHeader.FindFirst();
                    SalesCrMemoHeader.Get(TempSalesCrMemoHeader."No.");
                    PAGE.Run(PAGE::"Posted Sales Credit Memo", SalesCrMemoHeader);
                end;
            else
                PAGE.Run(PAGE::"Posted Sales Credit Memos", TempSalesCrMemoHeader);
        end;

        exit(true);
    end;
}