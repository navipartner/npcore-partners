codeunit 6151326 "NpEc P.Invoice Lookup"
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce

    TableNo = "Nc Import Entry";

    trigger OnRun()
    var
        TempPurchHeader: Record "Purchase Header" temporary;
        TempPurchInvHeader: Record "Purch. Inv. Header" temporary;
    begin
        if not GetInvoiceDocuments(Rec,TempPurchHeader,TempPurchInvHeader) then
          exit;

        if RunPagePurchInvoice(TempPurchHeader) then
          exit;
        if RunPagePostedPurchInvoice(TempPurchInvHeader) then
          exit;

        Error('');
    end;

    procedure GetInvoiceDocuments(ImportEntry: Record "Nc Import Entry";var TempPurchHeader: Record "Purchase Header" temporary;var TempPurchInvHeader: Record "Purch. Inv. Header" temporary): Boolean
    var
        PurchHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        NpEcPurchDocImportMgt: Codeunit "NpEc Purch. Doc. Import Mgt.";
        RecRef: RecordRef;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        OrderNo: Code[20];
        i: Integer;
    begin
        RecRef.GetTable(TempPurchHeader);
        if not RecRef.IsTemporary then
          exit(false);

        RecRef.GetTable(TempPurchInvHeader);
        if not RecRef.IsTemporary then
          exit(false);

        TempPurchHeader.DeleteAll;
        TempPurchInvHeader.DeleteAll;

        if not ImportEntry.LoadXmlDoc(XmlDoc) then
          exit(false);

        XmlElement := XmlDoc.DocumentElement;
        if not NpXmlDomMgt.FindNodes(XmlElement,'purchase_invoice',XmlNodeList) then
          exit(false);

        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement := XmlNodeList.ItemOf(i);
          if NpEcPurchDocImportMgt.FindInvoice(XmlElement,PurchHeader) then begin
            PurchHeader.FindSet;
            repeat
              if not TempPurchHeader.Get(PurchHeader."Document Type",PurchHeader."No.") then begin
                TempPurchHeader.Init;
                TempPurchHeader := PurchHeader;
                TempPurchHeader.Insert;
              end;
            until PurchHeader.Next = 0;
          end;

          if NpEcPurchDocImportMgt.FindPostedInvoice(XmlElement,PurchInvHeader) then begin
            PurchInvHeader.FindSet;
            repeat
              if not TempPurchInvHeader.Get(PurchInvHeader."No.") then begin
                TempPurchInvHeader.Init;
                TempPurchInvHeader := PurchInvHeader;
                TempPurchInvHeader.Insert;
              end;
            until PurchInvHeader.Next = 0;
          end;
        end;

        exit(TempPurchHeader.FindSet or TempPurchInvHeader.FindSet);
    end;

    procedure RunPagePurchInvoice(var TempPurchHeader: Record "Purchase Header" temporary): Boolean
    var
        PurchHeader: Record "Purchase Header";
    begin
        case TempPurchHeader.Count of
          0:
            begin
              exit(false);
            end;
          1:
            begin
              TempPurchHeader.FindFirst;
              PurchHeader.Get(TempPurchHeader."Document Type",TempPurchHeader."No.");
              PAGE.Run(PAGE::"Purchase Invoice",PurchHeader);
            end;
          else
            PAGE.Run(PAGE::"Purchase Invoices",TempPurchHeader);
        end;

        exit(true);
    end;

    procedure RunPagePostedPurchInvoice(var TempPurchInvHeader: Record "Purch. Inv. Header" temporary): Boolean
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        case TempPurchInvHeader.Count of
          0:
            begin
              exit(false);
            end;
          1:
            begin
              TempPurchInvHeader.FindFirst;
              PurchInvHeader.Get(TempPurchInvHeader."No.");
              PAGE.Run(PAGE::"Posted Purchase Invoice",PurchInvHeader);
            end;
          else
            PAGE.Run(PAGE::"Posted Purchase Invoices",TempPurchInvHeader);
        end;

        exit(true);
    end;
}

