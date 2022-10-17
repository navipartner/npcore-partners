codeunit 6059915 "NPR Denomination Mgt."
{
    Access = Internal;

    procedure AssistEditPOSPaymentBinCheckpointDenominations(POSPaymentBinCheckp: Record "NPR POS Payment Bin Checkp."; AttachedToID: Enum "NPR Denomination Target"; ViewMode: Boolean; var TotalAmount: Decimal): Boolean
    begin
        if ViewMode then begin
            ViewPOSPaymentBinCheckpointDenominations(POSPaymentBinCheckp, AttachedToID);
            exit(false);
        end;
        if not AssistEditPOSPaymentBinCheckpointDenominations(POSPaymentBinCheckp, AttachedToID) then
            exit(false);
        TotalAmount := CalculatedCountedAmtFromAssignedDenominations(POSPaymentBinCheckp, AttachedToID);
        exit(true);
    end;

    local procedure AssistEditPOSPaymentBinCheckpointDenominations(POSPaymentBinCheckp: Record "NPR POS Payment Bin Checkp."; AttachedToID: Enum "NPR Denomination Target"): Boolean
    var
        PaymentMethodDenom: Record "NPR Payment Method Denom";
        POSPmtBinCheckpDenom: Record "NPR POS Pmt. Bin Checkp. Denom";
        TempDenominationEditBuffer: Record "NPR POS Pmt. Bin Checkp. Denom" temporary;
        NoDenomDefinedErr: Label 'No denominations are defined for Payment Method "%1"', Comment = '%1 - POS Payment Method Code';
    begin
        POSPaymentBinCheckp.TestField("Payment Method No.");

        POSPmtBinCheckpDenom.SetRange("POS Pmt. Bin Checkp. Entry No.", POSPaymentBinCheckp."Entry No.");
        POSPmtBinCheckpDenom.SetRange("Attached-to ID", AttachedToID);
        if POSPmtBinCheckpDenom.FindSet() then
            repeat
                TempDenominationEditBuffer := POSPmtBinCheckpDenom;
                TempDenominationEditBuffer.Insert();
            until POSPmtBinCheckpDenom.Next() = 0;

        PaymentMethodDenom.SetRange("POS Payment Method Code", POSPaymentBinCheckp."Payment Method No.");
        PaymentMethodDenom.SetRange(Blocked, false);
        if PaymentMethodDenom.FindSet() then
            repeat
                TempDenominationEditBuffer."POS Pmt. Bin Checkp. Entry No." := POSPaymentBinCheckp."Entry No.";
                TempDenominationEditBuffer."Attached-to ID" := AttachedToID;
                TempDenominationEditBuffer."Denomination Type" := PaymentMethodDenom."Denomination Type";
                TempDenominationEditBuffer.Denomination := PaymentMethodDenom.Denomination;
                TempDenominationEditBuffer."Denomination Variant ID" := PaymentMethodDenom."Denomination Variant ID";
                if not TempDenominationEditBuffer.Find() then begin
                    TempDenominationEditBuffer.Init();
                    TempDenominationEditBuffer."Currency Code" := POSPaymentBinCheckp."Currency Code";
                    TempDenominationEditBuffer.Insert();
                end;
            until PaymentMethodDenom.Next() = 0;

        if TempDenominationEditBuffer.IsEmpty() then
            Error(NoDenomDefinedErr, POSPaymentBinCheckp."Payment Method No.");

        if Page.RunModal(Page::"NPR Edit POS Pmt. Denomination", TempDenominationEditBuffer) <> Action::LookupOK then
            exit(false);

        POSPmtBinCheckpDenom.LockTable();
        if POSPmtBinCheckpDenom.FindSet() then
            repeat
                POSPmtBinCheckpDenom.Mark(true);
            until POSPmtBinCheckpDenom.Next() = 0;

        TempDenominationEditBuffer.SetFilter(Quantity, '<>%1', 0);
        if TempDenominationEditBuffer.FindSet() then
            repeat
                POSPmtBinCheckpDenom := TempDenominationEditBuffer;
                if not POSPmtBinCheckpDenom.Find() then
                    POSPmtBinCheckpDenom.Insert();
                POSPmtBinCheckpDenom.Quantity := TempDenominationEditBuffer.Quantity;
                POSPmtBinCheckpDenom.Amount := TempDenominationEditBuffer.Amount;
                POSPmtBinCheckpDenom.Modify();
                POSPmtBinCheckpDenom.Mark(false);
            until TempDenominationEditBuffer.Next() = 0;

        POSPmtBinCheckpDenom.MarkedOnly(true);
        if not POSPmtBinCheckpDenom.IsEmpty() then
            POSPmtBinCheckpDenom.DeleteAll();

        exit(true);
    end;

    procedure ViewPOSPaymentBinCheckpointDenominations(POSPaymentBinCheckp: Record "NPR POS Payment Bin Checkp."; AttachedToID: Enum "NPR Denomination Target")
    var
        POSPmtBinCheckpDenom: Record "NPR POS Pmt. Bin Checkp. Denom";
    begin
        POSPmtBinCheckpDenom.SetRange("POS Pmt. Bin Checkp. Entry No.", POSPaymentBinCheckp."Entry No.");
        POSPmtBinCheckpDenom.SetRange("Attached-to ID", AttachedToID);
        Page.Run(0, POSPmtBinCheckpDenom);
    end;

    procedure CalculatedCountedAmtFromAssignedDenominations(POSPaymentBinCheckp: Record "NPR POS Payment Bin Checkp."; AttachedToID: Enum "NPR Denomination Target"): Decimal
    var
        POSPmtBinCheckpDenom: Record "NPR POS Pmt. Bin Checkp. Denom";
    begin
        POSPmtBinCheckpDenom.SetRange("POS Pmt. Bin Checkp. Entry No.", POSPaymentBinCheckp."Entry No.");
        POSPmtBinCheckpDenom.SetRange("Attached-to ID", AttachedToID);
        POSPmtBinCheckpDenom.CalcSums(Amount);
        exit(POSPmtBinCheckpDenom.Amount);
    end;

    procedure StoreCountedDenominations(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSPaymentBinDenomination: Record "NPR POS Paym. Bin Denomin.";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSPmtBinCheckpDenom: Record "NPR POS Pmt. Bin Checkp. Denom";
    begin
        POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
        POSPaymentBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpoint."Entry No.");
        POSPaymentBinCheckpoint.SetRange(Status, POSPaymentBinCheckpoint.Status::TRANSFERED);
        POSPaymentBinCheckpoint.SetLoadFields("Payment Type No.", "Payment Method No.");
        if POSPaymentBinCheckpoint.FindSet() then
            repeat
                POSPmtBinCheckpDenom.SetRange("POS Pmt. Bin Checkp. Entry No.", POSPaymentBinCheckpoint."Entry No.");
                if POSPmtBinCheckpDenom.FindSet() then
                    repeat
                        POSPaymentBinDenomination."Entry No." := 0;
                        POSPaymentBinDenomination."Payment Method No." := POSPaymentBinCheckpoint."Payment Method No.";
                        POSPaymentBinDenomination."Payment Type No." := POSPaymentBinCheckpoint."Payment Type No.";
                        POSPaymentBinDenomination."POS Unit No." := POSWorkshiftCheckpoint."POS Unit No.";
                        POSPaymentBinDenomination."Workshift Checkpoint Entry No." := POSWorkshiftCheckpoint."Entry No.";
                        POSPaymentBinDenomination."Bin Checkpoint Entry No." := POSPaymentBinCheckpoint."Entry No.";
                        POSPaymentBinDenomination."Attached-to ID" := POSPmtBinCheckpDenom."Attached-to ID";
                        POSPaymentBinDenomination."Denomination Type" := POSPmtBinCheckpDenom."Denomination Type";
                        POSPaymentBinDenomination.Denomination := POSPmtBinCheckpDenom.Denomination;
                        POSPaymentBinDenomination."Denomination Variant ID" := POSPmtBinCheckpDenom."Denomination Variant ID";
                        POSPaymentBinDenomination.Quantity := POSPmtBinCheckpDenom.Quantity;
                        POSPaymentBinDenomination.Amount := POSPmtBinCheckpDenom.Amount;
                        POSPaymentBinDenomination.Insert();
                    until POSPmtBinCheckpDenom.Next() = 0;
            until POSPaymentBinCheckpoint.Next() = 0;
    end;

    procedure CalculateTotals(var POSPmtBinCheckpDenom: Record "NPR POS Pmt. Bin Checkp. Denom"; var TotalNumberOfUnits: Integer; var TotalCurrencyAmount: Decimal)
    var
        POSPmtBinCheckpDenom2: Record "NPR POS Pmt. Bin Checkp. Denom";
        TempPOSPmtBinCheckpDenom: Record "NPR POS Pmt. Bin Checkp. Denom" temporary;
    begin
        if POSPmtBinCheckpDenom.IsTemporary then begin
            TempPOSPmtBinCheckpDenom.Copy(POSPmtBinCheckpDenom, true);
            TempPOSPmtBinCheckpDenom.CalcSums(Quantity, Amount);
            TotalNumberOfUnits := TempPOSPmtBinCheckpDenom.Quantity;
            TotalCurrencyAmount := TempPOSPmtBinCheckpDenom.Amount;
            exit;
        end;

        POSPmtBinCheckpDenom2.CopyFilters(POSPmtBinCheckpDenom);
        if POSPmtBinCheckpDenom2.IsEmpty() then begin
            TotalNumberOfUnits := 0;
            TotalCurrencyAmount := 0;
            exit;
        end;
        POSPmtBinCheckpDenom2.CalcSums(Quantity, Amount);
        TotalNumberOfUnits := POSPmtBinCheckpDenom2.Quantity;
        TotalCurrencyAmount := POSPmtBinCheckpDenom2.Amount;
    end;
}