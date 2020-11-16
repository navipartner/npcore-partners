codeunit 6150746 "NPR POS Warranty Mgt."
{
    trigger OnRun()
    begin
    end;

    var
        WarrantyPrintCaption: Label 'Auto printing of the warranty for this item has failed with the error: %1';
        CAPTION_WARRANTY_CERT: Label 'Warranty Certificate';

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnAfterInsertSaleLine', '', true, true)]
    local procedure PrintWarrantyAfterSaleLine(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SaleLinePOS: Record "NPR Sale Line POS")
    var
        Item: Record Item;
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CODEUNIT::"NPR POS Warranty Mgt." then
            exit;

        if (SaleLinePOS.Type <> SaleLinePOS.Type::Item) OR (SaleLinePOS."No." = '') then
            exit;

        Item.Get(SaleLinePOS."No.");

        if not Item."NPR Guarantee voucher" then
            exit;

        SaleLinePOS.SetRecFilter;

        if not TryAutoPrintWarranty(SaleLinePOS) and GuiAllowed then
            Message(WarrantyPrintCaption, GetLastErrorText);
    end;

    [TryFunction]
    local procedure TryAutoPrintWarranty(var SaleLinePOS: Record "NPR Sale Line POS")
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        RecRef: RecordRef;
        POSUnit: Record "NPR POS Unit";
    begin
        RecRef.GetTable(SaleLinePOS);
        RetailReportSelectionMgt.SetRegisterNo(SaleLinePOS."Register No.");
        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Warranty Certificate");
    end;
}