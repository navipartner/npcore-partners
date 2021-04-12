codeunit 6014447 "NPR Label Library Sub. Mgt."
{
    [EventSubscriber(ObjectType::Page, 7302, 'OnAfterActionEvent', 'NPR PrintLabel', false, false)]
    local procedure BinsOnAfterActionEventPrintLabel(var Rec: Record Bin)
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        PrintLabel(Rec, ReportSelectionRetail."Report Type"::"Bin Label");
    end;

    [EventSubscriber(ObjectType::Page, 5740, 'OnAfterActionEvent', 'NPR RetailPrint', false, false)]
    local procedure TransferOrderOnAfterActionEventRetailPrint(var Rec: Record "Transfer Header")
    begin
        ChooseLabel(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 5740, 'OnAfterActionEvent', 'NPR PriceLabel', false, false)]
    local procedure TransferOrderOnAfterActionEventPriceLabel(var Rec: Record "Transfer Header")
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        PrintLabel(Rec, ReportSelectionRetail."Report Type"::"Price Label");
    end;

    [EventSubscriber(ObjectType::Page, 50, 'OnAfterActionEvent', 'NPR RetailPrint', false, false)]
    local procedure PurchaseOrderOnAfterActionEventRetailPrint(var Rec: Record "Purchase Header")
    begin
        ChooseLabel(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 50, 'OnAfterActionEvent', 'NPR PriceLabel', false, false)]
    local procedure PurchaseOrderOnAfterActionEventPriceLabel(var Rec: Record "Purchase Header")
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin

        PrintLabel(Rec, ReportSelectionRetail."Report Type"::"Price Label");
    end;

    [EventSubscriber(ObjectType::Page, 51, 'OnAfterActionEvent', 'NPR RetailPrint', false, false)]
    local procedure PurchaseInvoiceOnAfterActionEventRetailPrint(var Rec: Record "Purchase Header")
    begin
        ChooseLabel(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 51, 'OnAfterActionEvent', 'NPR PriceLabel', false, false)]
    local procedure PurchaseInvoiceOnAfterActionEventPriceLabel(var Rec: Record "Purchase Header")
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        PrintLabel(Rec, ReportSelectionRetail."Report Type"::"Price Label");
    end;

    [EventSubscriber(ObjectType::Page, 40, 'OnAfterActionEvent', 'NPR PriceLabel', false, false)]
    local procedure ItemJournalOnAfterActionEventPriceLabel(var Rec: Record "Item Journal Line")
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        PrintLabel(Rec, ReportSelectionRetail."Report Type"::"Price Label");
    end;

    [EventSubscriber(ObjectType::Page, 6014402, 'OnAfterActionEvent', 'PriceLabel', false, false)]
    local procedure RetailItemJournalOnAfterActionEventPriceLabel(var Rec: Record "Item Journal Line")
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        PrintLabel(Rec, ReportSelectionRetail."Report Type"::"Price Label");
    end;

    [EventSubscriber(ObjectType::Page, 6014453, 'OnAfterActionEvent', 'RetailPrint', true, true)]
    local procedure CampaignDiscountOnAfterActionEventRetailPrint(var Rec: Record "NPR Period Discount")
    begin
        ChooseLabel(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 6014453, 'OnAfterActionEvent', 'PriceLabel', true, true)]
    local procedure CampaignDiscountOnAfterActionEventPriceLabel(var Rec: Record "NPR Period Discount")
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        PrintLabel(Rec, ReportSelectionRetail."Report Type"::"Price Label");
    end;

    [EventSubscriber(ObjectType::Page, 5743, 'OnAfterActionEvent', 'NPR RetailPrint', true, true)]
    local procedure TransferShipmentOrderOnAfterActionEventRetailPrint(var Rec: Record "Transfer Shipment Header")
    begin
        ChooseLabel(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 5743, 'OnAfterActionEvent', 'NPR PriceLabel', true, true)]
    local procedure TransferShipmentOrderOnAfterActionEventPriceLabel(var Rec: Record "Transfer Shipment Header")
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        PrintLabel(Rec, ReportSelectionRetail."Report Type"::"Price Label");
    end;

    [EventSubscriber(ObjectType::Page, 5745, 'OnAfterActionEvent', 'NPR RetailPrint', true, true)]
    local procedure TransferReceiptOrderOnAfterActionEventRetailPrint(var Rec: Record "Transfer Receipt Header")
    begin
        ChooseLabel(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 5745, 'OnAfterActionEvent', 'NPR PriceLabel', true, true)]
    local procedure TransferReceiptOrderOnAfterActionEventPriceLabel(var Rec: Record "Transfer Receipt Header")
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        PrintLabel(Rec, ReportSelectionRetail."Report Type"::"Price Label");
    end;

    procedure ChooseLabel(VarRec: Variant)
    begin
        ApplyFilterAndRun(VarRec, 0, false);
    end;

    procedure PrintLabel(VarRec: Variant; ReportType: Option)
    begin
        ApplyFilterAndRun(VarRec, ReportType, true);
    end;

    local procedure ApplyFilterAndRun(VarRec: Variant; ReportType: Option; FromPrintLabelFunction: Boolean)
    var
        RecRef: RecordRef;
        RecRef2: RecordRef;
        LabelLibrary: Codeunit "NPR Label Library";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferShipmentLine: Record "Transfer Shipment Line";
        PeriodDiscount: Record "NPR Period Discount";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferReceiptLine: Record "Transfer Receipt Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        WarehouseActivityLine: Record "Warehouse Activity Line";
    begin
        RecRef2.GetTable(VarRec);
        case RecRef2.Number of
            DATABASE::"Purchase Header":
                begin
                    RecRef2.SetTable(PurchaseHeader);
                    PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                    PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                    if FromPrintLabelFunction then
                        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
                    RecRef.GetTable(PurchaseLine);

                end;
            DATABASE::"Transfer Header":
                begin
                    RecRef2.SetTable(TransferHeader);
                    TransferLine.SetRange("Document No.", TransferHeader."No.");
                    TransferLine.SetRange("Derived From Line No.", 0);
                    RecRef.GetTable(TransferLine);
                end;
            DATABASE::"Transfer Shipment Header":
                begin
                    RecRef2.SetTable(TransferShipmentHeader);
                    TransferShipmentLine.SetRange("Document No.", TransferShipmentHeader."No.");
                    RecRef.GetTable(TransferShipmentLine);
                end;
            DATABASE::"Transfer Receipt Header":
                begin
                    RecRef2.SetTable(TransferReceiptHeader);
                    TransferReceiptLine.SetRange("Document No.", TransferReceiptHeader."No.");
                    RecRef.GetTable(TransferReceiptLine);
                end;
            DATABASE::"NPR Period Discount":
                begin
                    RecRef2.SetTable(PeriodDiscount);
                    PeriodDiscountLine.SetRange(Code, PeriodDiscount.Code);
                    RecRef.GetTable(PeriodDiscountLine);
                end;

            DATABASE::"Purch. Inv. Header":
                begin
                    RecRef2.SetTable(PurchInvHeader);
                    PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
                    if FromPrintLabelFunction then
                        PurchInvLine.SetRange(Type, PurchInvLine.Type::Item);
                    RecRef.GetTable(PurchInvLine);
                end;
            DATABASE::"Warehouse Activity Header":
                begin
                    RecRef2.SetTable(WarehouseActivityHeader);
                    WarehouseActivityLine.SetRange("Activity Type", WarehouseActivityHeader.Type);
                    WarehouseActivityLine.SetRange("No.", WarehouseActivityHeader."No.");
                    RecRef.GetTable(WarehouseActivityLine);
                end;
            else begin
                    RecRef := RecRef2;
                    RecRef.SetRecFilter();
                end;
        end;
        if FromPrintLabelFunction then begin
            LabelLibrary.InvertAllLines(RecRef);
            LabelLibrary.PrintSelection(ReportType);
        end else
            LabelLibrary.RunPrintPage(RecRef);
    end;
}