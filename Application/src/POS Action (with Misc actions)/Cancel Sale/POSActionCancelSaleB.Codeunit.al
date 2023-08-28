codeunit 6059872 "NPR POSAction: Cancel Sale B"
{
    Access = Internal;

    var
        AltSaleCancelDescription: Text;

    procedure CancelSale(): Boolean
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Line: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        CANCEL_SALELbl: Label 'Sale was canceled %1';
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."NPRE Pre-Set Waiter Pad No." <> '' then begin
            WaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
            WaiterPadPOSMgt.CleanupWaiterPadOnSaleCancel(SalePOS, WaiterPad);  //Includes commit
        end;

        HandleLinkedDocuments(SalePOS);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.DeleteAll();

        Line."Line Type" := Line."Line Type"::Comment;
        if AltSaleCancelDescription <> '' then begin
            Line.Description := CopyStr(AltSaleCancelDescription, 1, MaxStrLen(Line.Description));
            Line."Description 2" := CopyStr(AltSaleCancelDescription, MaxStrLen(Line.Description) + 1, MaxStrLen(Line."Description 2"));
        end else
            Line.Description := StrSubstNo(CANCEL_SALELbl, CurrentDateTime);

        POSSaleLine.InsertLine(Line);
        SalePOS."Header Type" := SalePOS."Header Type"::Cancelled;
        POSSale.Refresh(SalePOS);
        POSSale.Modify(false, false);
        exit(POSSale.TryEndSale(POSSession, false));
    end;

    procedure CheckSaleBeforeCancel(Sale: Codeunit "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        PartlyPaidErr: Label 'This sales can''t be deleted. It has been partly paid. You must first void the payment.';
    begin
        Sale.GetCurrentSale(SalePOS);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::"POS Payment");
        SaleLinePOS.SetFilter("Amount Including VAT", '<> %1', 0);
        if not SaleLinePOS.IsEmpty() then
            Error(PartlyPaidErr);
    end;

    procedure SetAlternativeDescription(NewAltSaleCancelDescription: Text)
    begin
        AltSaleCancelDescription := NewAltSaleCancelDescription;
    end;

    local procedure HandleLinkedDocuments(SalePOS: Record "NPR POS Sale")
    begin
        RevertPrepaymentOnDocuments(SalePOS);
    end;

    local procedure RevertPrepaymentOnDocuments(SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sales Document Prepayment", true);
        if SaleLinePOS.IsEmpty() then
            exit;

        SaleLinePOS.FindSet();
        repeat
            if SalesHeader.Get(SaleLinePOS."Sales Document Type", SaleLinePOS."Sales Document No.") then begin
                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                if SalesLine.FindSet() then
                    repeat
                        SalesLine.Validate("Prepayment %", 0);
                        SalesLine.Modify();
                    until SalesLine.Next() = 0;
            end;
        until SaleLinePOS.Next() = 0;
    end;
}