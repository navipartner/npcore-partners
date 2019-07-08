codeunit 6014447 "Label Library Sub. Mgt."
{
    // NPR5.30/NPKNAV/20170310  CASE 262533 Transport NPR5.30 - 26 January 2017
    // NPR5.43/TS  /20180625 CASE 317852  Added Function ItemJournalOnAfterActionEventPriceLabel
    // NPR5.46/EMGO/20180910 CASE 324737  Changed ChooseLabel function and PrintLabel function from local til global function.
    //                                    Added Transfer Shipment Header case to ApplyFilterAndRun
    // NPR5.46/JDH /20181001 CASE 294354  Restructured functionality for printing


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 7302, 'OnAfterActionEvent', 'PrintLabel', false, false)]
    local procedure BinsOnAfterActionEventPrintLabel(var Rec: Record Bin)
    var
        ReportSelectionRetail: Record "Report Selection Retail";
    begin
        PrintLabel(Rec,ReportSelectionRetail."Report Type"::"Bin Label");
    end;

    [EventSubscriber(ObjectType::Page, 5740, 'OnAfterActionEvent', 'RetailPrint', false, false)]
    local procedure TransferOrderOnAfterActionEventRetailPrint(var Rec: Record "Transfer Header")
    begin
        ChooseLabel(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 5740, 'OnAfterActionEvent', 'PriceLabel', false, false)]
    local procedure TransferOrderOnAfterActionEventPriceLabel(var Rec: Record "Transfer Header")
    var
        ReportSelectionRetail: Record "Report Selection Retail";
    begin
        PrintLabel(Rec,ReportSelectionRetail."Report Type"::"Price Label");
    end;

    [EventSubscriber(ObjectType::Page, 50, 'OnAfterActionEvent', 'RetailPrint', false, false)]
    local procedure PurchaseOrderOnAfterActionEventRetailPrint(var Rec: Record "Purchase Header")
    begin
        ChooseLabel(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 50, 'OnAfterActionEvent', 'PriceLabel', false, false)]
    local procedure PurchaseOrderOnAfterActionEventPriceLabel(var Rec: Record "Purchase Header")
    var
        ReportSelectionRetail: Record "Report Selection Retail";
    begin
        PrintLabel(Rec,ReportSelectionRetail."Report Type"::"Price Label");
    end;

    [EventSubscriber(ObjectType::Page, 51, 'OnAfterActionEvent', 'RetailPrint', false, false)]
    local procedure PurchaseInvoiceOnAfterActionEventRetailPrint(var Rec: Record "Purchase Header")
    begin
        ChooseLabel(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 51, 'OnAfterActionEvent', 'PriceLabel', false, false)]
    local procedure PurchaseInvoiceOnAfterActionEventPriceLabel(var Rec: Record "Purchase Header")
    var
        ReportSelectionRetail: Record "Report Selection Retail";
    begin
        PrintLabel(Rec,ReportSelectionRetail."Report Type"::"Price Label");
    end;

    [EventSubscriber(ObjectType::Page, 40, 'OnAfterActionEvent', 'PriceLabel', false, false)]
    local procedure ItemJournalOnAfterActionEventPriceLabel(var Rec: Record "Item Journal Line")
    var
        ReportSelectionRetail: Record "Report Selection Retail";
    begin
        //-NPR5.43 [317852]
        PrintLabel(Rec,ReportSelectionRetail."Report Type"::"Price Label");
        //+NPR5.43 [317852]
    end;

    [EventSubscriber(ObjectType::Page, 6014453, 'OnAfterActionEvent', 'RetailPrint', true, true)]
    local procedure CampaignDiscountOnAfterActionEventRetailPrint(var Rec: Record "Period Discount")
    begin
        //-NPR5.46 [294354]
        ChooseLabel(Rec);
        //+NPR5.46 [294354]
    end;

    [EventSubscriber(ObjectType::Page, 6014453, 'OnAfterActionEvent', 'PriceLabel', true, true)]
    local procedure CampaignDiscountOnAfterActionEventPriceLabel(var Rec: Record "Period Discount")
    var
        ReportSelectionRetail: Record "Report Selection Retail";
    begin
        //-NPR5.46 [294354]
        PrintLabel(Rec,ReportSelectionRetail."Report Type"::"Price Label");
        //+NPR5.46 [294354]
    end;

    [EventSubscriber(ObjectType::Page, 5743, 'OnAfterActionEvent', 'RetailPrint', true, true)]
    local procedure TransferShipmentOrderOnAfterActionEventRetailPrint(var Rec: Record "Transfer Shipment Header")
    begin
        ChooseLabel(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 5743, 'OnAfterActionEvent', 'PriceLabel', true, true)]
    local procedure TransferShipmentOrderOnAfterActionEventPriceLabel(var Rec: Record "Transfer Shipment Header")
    var
        ReportSelectionRetail: Record "Report Selection Retail";
    begin
        PrintLabel(Rec,ReportSelectionRetail."Report Type"::"Price Label");
    end;

    [EventSubscriber(ObjectType::Page, 5745, 'OnAfterActionEvent', 'RetailPrint', true, true)]
    local procedure TransferReceiptOrderOnAfterActionEventRetailPrint(var Rec: Record "Transfer Receipt Header")
    begin
        ChooseLabel(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 5745, 'OnAfterActionEvent', 'PriceLabel', true, true)]
    local procedure TransferReceiptOrderOnAfterActionEventPriceLabel(var Rec: Record "Transfer Receipt Header")
    var
        ReportSelectionRetail: Record "Report Selection Retail";
    begin
        PrintLabel(Rec,ReportSelectionRetail."Report Type"::"Price Label");
    end;

    procedure ChooseLabel(VarRec: Variant)
    begin
        ApplyFilterAndRun(VarRec,0,false);
    end;

    procedure PrintLabel(VarRec: Variant;ReportType: Option)
    begin
        ApplyFilterAndRun(VarRec,ReportType,true);
    end;

    local procedure ApplyFilterAndRun(VarRec: Variant;ReportType: Option;FromPrintLabelFunction: Boolean)
    var
        RecRef: RecordRef;
        RecRef2: RecordRef;
        LabelLibrary: Codeunit "Label Library";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJnlLine: Record "Item Journal Line";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferShipmentLine: Record "Transfer Shipment Line";
        PeriodDiscount: Record "Period Discount";
        PeriodDiscountLine: Record "Period Discount Line";
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferReceiptLine: Record "Transfer Receipt Line";
    begin
        RecRef2.GetTable(VarRec);
        case RecRef2.Number of
          DATABASE::"Purchase Header":
            begin
              RecRef2.SetTable(PurchaseHeader);
              PurchaseLine.SetRange("Document Type",PurchaseHeader."Document Type");
              PurchaseLine.SetRange("Document No.",PurchaseHeader."No.");
              if FromPrintLabelFunction then
                PurchaseLine.SetRange(Type,PurchaseLine.Type::Item);
              RecRef.GetTable(PurchaseLine);
            end;
          DATABASE::"Transfer Header":
            begin
              RecRef2.SetTable(TransferHeader);
              TransferLine.SetRange("Document No.",TransferHeader."No.");
              //-NPR5.46 [294354]
              TransferLine.SetRange("Derived From Line No.", 0);
              //+NPR5.46 [294354]
              RecRef.GetTable(TransferLine);
            end;
          //-NPR5.46
          DATABASE::"Transfer Shipment Header":
            begin
              RecRef2.SetTable(TransferShipmentHeader);
              TransferShipmentLine.SetRange("Document No.", TransferShipmentHeader."No.");
              RecRef.GetTable(TransferShipmentLine);
            end;
          //+NPR5.46
          //-NPR5.46 [294354]
          DATABASE::"Transfer Receipt Header":
            begin
              RecRef2.SetTable(TransferReceiptHeader);
              TransferReceiptLine.SetRange("Document No." , TransferReceiptHeader."No.");
              RecRef.GetTable(TransferReceiptLine);
            end;
          DATABASE::"Period Discount":
            begin
              RecRef2.SetTable(PeriodDiscount);
              PeriodDiscountLine.SetRange(Code, PeriodDiscount.Code);
              RecRef.GetTable(PeriodDiscountLine);
            end;
          //+NPR5.46 [294354]
          else begin
            RecRef := RecRef2;
            RecRef.SetRecFilter;
          end;
        end;
        if FromPrintLabelFunction then begin
          LabelLibrary.InvertAllLines(RecRef);
          LabelLibrary.PrintSelection(ReportType);
        end else
          LabelLibrary.RunPrintPage(RecRef);
    end;
}

