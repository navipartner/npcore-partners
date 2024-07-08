﻿page 6150620 "NPR POS Payment Bins"
{
    Extensible = False;
    Caption = 'POS Payment Bins';
    ContextSensitiveHelpPage = 'docs/retail/pos_processes/how-to/payment_bins/';
    PageType = List;
    SourceTable = "NPR POS Payment Bin";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    PromotedActionCategories = 'New,Process,Report,Navigate';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number of the POS Payment Bin.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the POS Payment Bin, which will be diplayed when balancing the POS Unit.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ToolTip = 'Specifies which POS Store Code that the POS Payment Bin belongs to.';
                    ApplicationArea = NPRRetail;
                }
                field("Attached to POS Unit No."; Rec."Attached to POS Unit No.")
                {
                    ToolTip = 'Specifies which POS Unit is attached to the POS Payment Bin.';
                    ApplicationArea = NPRRetail;
                }
                field("Eject Method"; Rec."Eject Method")
                {
                    ToolTip = 'Specifies which method is used to physically eject the POS Payment Bin, if it is a cash drawer.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = StyleByPrintTemplateAvailability;
                }
                field("Bin Type"; Rec."Bin Type")
                {
                    ToolTip = 'Specifies which retail operations the POS Payment Bin will be involved in.';
                    ApplicationArea = NPRRetail;
                }
                field("Suppress EOD Posting"; Rec."Suppress EOD Posting")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Suppress EOD Posting field. This setting only applies to virtual bins and prevents the aggregated result from being posted. Useful when EFT bank reconciliation is done per entry.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(POSPostingSetup)
            {
                Caption = 'POS Posting Setup';
                Image = GeneralPostingSetup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Posting Setup";
                RunPageLink = "POS Payment Bin Code" = FIELD("No.");

                ToolTip = 'Open the POS Posting Setup page filtered on the selected POS Payment Bin Code.';
                ApplicationArea = NPRRetail;
            }
            action(EjectMethodParameters)
            {
                Caption = 'Eject Method Parameters';
                Image = Answers;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Opens the page for setting the Eject Method Parameters.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
                begin
                    POSPaymentBinInvokeMgt.OnShowInvokeParameters(Rec);
                end;
            }
            action(BinTransferJournal)
            {
                Caption = 'POS Payment Bin Transfer Journal';
                RunObject = Page "NPR BinTransferJournal";
                Image = TransferFunds;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Opens the page for setting up and transferring amounts from different bins.';
                ApplicationArea = NPRRetail;
            }
            action(BinEntries)
            {
                Caption = 'Payment Bin Entries';
                ApplicationArea = NPRRetail;
                ToolTip = 'Navigate to associated bin payment entries.';
                Image = BinLedger;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Category4;
                RunObject = page "NPR POS Bin Entries";
                RunPageLink = "Payment Bin No." = field("No.");
                RunPageView = sorting("Entry No.") order(descending);
            }
            action(BinTransferProfile)
            {
                Caption = 'Payment Bin Transfer Profile';
                ApplicationArea = NPRRetail;
                ToolTip = 'Navigate to the bin transfer profile setup.';
                Image = BinLedger;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Category4;
                RunObject = page "NPR BinTransferProfile";
            }
        }
        area(processing)
        {
            action("Transfer Out From Bin")
            {
                Caption = 'Transfer Out From Bin';
                Ellipsis = true;
                Image = TransferFunds;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Visible = false;

                ToolTip = 'Moves the items out from the bin to another location.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    TransferContentsToBin();
                end;
            }
            action("Insert Initial Float")
            {
                Caption = 'Insert Initial Float';
                Image = TransferFunds;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Adds an initial cash float to the system.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    InsertInitialFloat();
                end;
            }
        }
    }

    var
        InitialFloatDesc: Label 'Initial Float';
        StyleByPrintTemplateAvailability: Text;

    trigger OnAfterGetRecord()
    begin
        if IsPrintTemplateMissing(Rec) then
            StyleByPrintTemplateAvailability := 'Unfavorable'
        else
            StyleByPrintTemplateAvailability := 'Standard';
    end;

    local procedure TransferContentsToBin()
    var
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        SalePOS: Record "NPR POS Sale";
        PaymentBinCheckpoint: Codeunit "NPR POS Payment Bin Checkpoint";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        PaymentBinCheckpointPage: Page "NPR POS Payment Bin Checkpoint";
        CheckpointEntryNo: Integer;
        PageAction: Action;
    begin
        CheckpointEntryNo := POSWorkshiftCheckpoint.CreateEndWorkshiftCheckpoint_POSEntry('', '', 0);
        PaymentBinCheckpoint.CreatePosEntryBinCheckpoint('', Rec."No.", CheckpointEntryNo, POSPaymentBinCheckpoint.type::TRANSFER);
        Commit();

        // Confirm amounts counted and float/bank/safe transfer
        POSPaymentBinCheckpoint.Reset();
        POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
        POSPaymentBinCheckpoint.FilterGroup(2);
        POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', CheckpointEntryNo);
        POSPaymentBinCheckpoint.FilterGroup(0);
        PaymentBinCheckpointPage.SetTableView(POSPaymentBinCheckpoint);
        PaymentBinCheckpointPage.LookupMode(true);
        PaymentBinCheckpointPage.SetTransferMode();
        PageAction := PaymentBinCheckpointPage.RunModal();
        Commit();

        if (PageAction = ACTION::LookupOK) then begin
            POSPaymentBinCheckpoint.Reset();
            POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', CheckpointEntryNo);
            POSPaymentBinCheckpoint.SetFilter(Status, '=%1', POSPaymentBinCheckpoint.Status::READY);
            if (not POSPaymentBinCheckpoint.IsEmpty()) then begin
                SalePOS."Register No." := 'TMP';
                SalePOS."POS Store Code" := 'TMP';
                SalePOS.Date := Today();
                SalePOS."Sales Ticket No." := CopyStr(DelChr(Format(CurrentDateTime(), 0, 9), '<=>', DelChr(Format(CurrentDateTime(), 0, 9), '<=>', '01234567890')), 1, 20);

                POSCreateEntry.CreateBalancingEntryAndLines(SalePOS, true, CheckpointEntryNo);
            end;
        end;
    end;

    local procedure InsertInitialFloat()
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSUnit: Record "NPR POS Unit";
        TempPOSPaymentMethod: Record "NPR POS Payment Method" temporary;
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        BinEntry: Record "NPR POS Bin Entry";
        POSPayBinSetFloat: Page "NPR POS Paym.Bin Set Float";
    begin
        POSUnit.Get(Rec."Attached to POS Unit No.");

        POSPayBinSetFloat.LookupMode := true;
        POSPayBinSetFloat.SetPaymentBin(Rec);
        if POSPayBinSetFloat.RunModal() = ACTION::LookupOK then begin
            POSPayBinSetFloat.GetAmounts(TempPOSPaymentMethod);

            TempPOSPaymentMethod.Reset();
            if TempPOSPaymentMethod.FindSet() then begin

                POSWorkshiftCheckpoint.Init();
                POSWorkshiftCheckpoint."Entry No." := 0;

                POSWorkshiftCheckpoint."POS Unit No." := Rec."Attached to POS Unit No.";
                POSWorkshiftCheckpoint."Created At" := CurrentDateTime;
                POSWorkshiftCheckpoint.Open := false;
                POSWorkshiftCheckpoint."POS Entry No." := 0;
                POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::ZREPORT;
                POSWorkshiftCheckpoint.Insert();

                repeat
                    POSPaymentMethod.Get(TempPOSPaymentMethod.Code);

                    // Creating the bin checkpoint
                    BinEntry.Init();
                    BinEntry."Entry No." := 0;
                    BinEntry."Created At" := CurrentDateTime();
                    BinEntry.Type := BinEntry.Type::CHECKPOINT;
                    BinEntry."Payment Bin No." := Rec."No.";
                    BinEntry."Transaction Date" := Today();
                    BinEntry."Transaction Time" := Time;
                    BinEntry."POS Unit No." := POSUnit."No.";
                    BinEntry."POS Store Code" := POSUnit."POS Store Code";
                    BinEntry.Comment := CopyStr(InitialFloatDesc, 1, MaxStrLen(BinEntry.Comment));
                    BinEntry."Payment Type Code" := POSPaymentMethod.Code;
                    BinEntry."Payment Method Code" := POSPaymentMethod.Code;
                    BinEntry."Transaction Amount" := 0;
                    BinEntry."Transaction Amount (LCY)" := 0;
                    BinEntry."Transaction Currency Code" := POSPaymentMethod."Currency Code";
                    BinEntry.Insert();

                    POSPaymentBinCheckpoint.Init();
                    POSPaymentBinCheckpoint."Entry No." := 0;
                    POSPaymentBinCheckpoint.Type := POSPaymentBinCheckpoint.Type::ZREPORT;
                    POSPaymentBinCheckpoint."Float Amount" := TempPOSPaymentMethod."Rounding Precision";
                    POSPaymentBinCheckpoint."Calculated Amount Incl. Float" := TempPOSPaymentMethod."Rounding Precision";
                    POSPaymentBinCheckpoint."New Float Amount" := TempPOSPaymentMethod."Rounding Precision";
                    POSPaymentBinCheckpoint."Created On" := CurrentDateTime;
                    POSPaymentBinCheckpoint."Checkpoint Date" := Today();
                    POSPaymentBinCheckpoint."Checkpoint Time" := Time;
                    POSPaymentBinCheckpoint.Description := InitialFloatDesc;
                    POSPaymentBinCheckpoint."Payment Method No." := POSPaymentMethod.Code;
                    POSPaymentBinCheckpoint."Currency Code" := POSPaymentMethod."Currency Code";
                    POSPaymentBinCheckpoint."Payment Bin No." := Rec."No.";
                    POSPaymentBinCheckpoint.Status := POSPaymentBinCheckpoint.Status::TRANSFERED;
                    POSPaymentBinCheckpoint."Workshift Checkpoint Entry No." := POSWorkshiftCheckpoint."Entry No.";
                    POSPaymentBinCheckpoint."Checkpoint Bin Entry No." := BinEntry."Entry No.";
                    POSPaymentBinCheckpoint."Include In Counting" := POSPaymentBinCheckpoint."Include In Counting"::YES;
                    POSPaymentBinCheckpoint.Insert();

                    BinEntry."Bin Checkpoint Entry No." := POSPaymentBinCheckpoint."Entry No.";
                    BinEntry.Modify();

                    // Creating the initial float entry
                    BinEntry."Entry No." := 0;
                    BinEntry."Bin Checkpoint Entry No." := POSPaymentBinCheckpoint."Entry No.";
                    BinEntry.Type := BinEntry.Type::FLOAT;
                    BinEntry."Transaction Amount" := TempPOSPaymentMethod."Rounding Precision";
                    CalculateTransactionAmountLCY(BinEntry);
                    BinEntry.Insert();

                until TempPOSPaymentMethod.Next() = 0;
            end;
        end;
    end;

    local procedure CalculateTransactionAmountLCY(var POSBinEntry: Record "NPR POS Bin Entry")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin

        POSBinEntry."Transaction Amount (LCY)" := POSBinEntry."Transaction Amount";

        if (POSBinEntry."Transaction Amount" = 0) then
            exit;

        if (POSBinEntry."Transaction Currency Code" = '') then
            exit;

        // ** Legacy Way
        if not POSPaymentMethod.Get(POSBinEntry."Payment Type Code") then
            exit;

        if (POSPaymentMethod."Fixed Rate" <> 0) then
            POSBinEntry."Transaction Amount (LCY)" := POSBinEntry."Transaction Amount" * POSPaymentMethod."Fixed Rate" / 100;

        if (POSPaymentMethod."Rounding Precision" = 0) then
            exit;

        POSBinEntry."Transaction Amount (LCY)" := Round(POSBinEntry."Transaction Amount (LCY)", POSPaymentMethod."Rounding Precision", POSPaymentMethod.GetRoundingType());
        exit;

        // ** End Legacy

        // ** Future way
        // IF (NOT Currency.Get() (CurrencyCode)) THEN
        //  EXIT;
        //
        // EXIT (ROUND (CurrExchRate.ExchangeAmtFCYToLCY (TransactionDate, CurrencyCode, Amount,
        //                                               1 / CurrExchRate.ExchangeRate (TransactionDate, CurrencyCode))));
    end;

    local procedure IsPrintTemplateMissing(POSPaymentBin: Record "NPR POS Payment Bin"): Boolean
    var
        POSPaymBinEjectParam: Record "NPR POS Paym. Bin Eject Param.";
        RPTemplateHeader: Record "NPR RP Template Header";
        POSPaymBinEjectTempl: Codeunit "NPR POS Paym.Bin Eject: Templ.";
    begin
        if POSPaymentBin."Eject Method" <> POSPaymBinEjectTempl.InvokeMethodCode() then
            exit;
        if not POSPaymBinEjectParam.Get(POSPaymentBin."No.", POSPaymBinEjectTempl.InvokeParameterName()) or (POSPaymBinEjectParam.Value = '') then
            exit(true);
        exit(not RPTemplateHeader.Get(CopyStr(POSPaymBinEjectParam.Value, 1, MaxStrLen(RPTemplateHeader.Code))));
    end;
}