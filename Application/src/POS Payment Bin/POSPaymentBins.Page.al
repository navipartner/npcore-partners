page 6150620 "NPR POS Payment Bins"
{
    // NPR5.29/AP/20170126 CASE 261728 Recreated ENU-captions
    // NPR5.36/BR/20170810 CASE 277096 Added Action to navigate to POS Posting Setup
    // NPR5.40/MMV /20180302 CASE 300660 Added field opening method and action for setting parameters
    // NPR5.40/TSA /20180306 CASE 307267 Added transfer content button
    // NPR5.40/TSA /20180306 CASE 307267 Added Bin Type field
    // NPR5.41/MMV /20180425 CASE 312990 Renamed action
    // NPR5.51/TJ  /20190619 CASE 353761 Action "Transfer Out From Bin" hidden
    //                                   New action "Insert Initial Float"

    Caption = 'POS Payment Bins';
    PageType = List;
    SourceTable = "NPR POS Payment Bin";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("POS Store Code"; "POS Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                }
                field("Attached to POS Unit No."; "Attached to POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attached to POS Unit No. field';
                }
                field("Eject Method"; "Eject Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Eject Method field';
                }
                field("Bin Type"; "Bin Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bin Type field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the POS Posting Setup action';
            }
            action(EjectMethodParameters)
            {
                Caption = 'Eject Method Parameters';
                Image = Answers;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Eject Method Parameters action';

                trigger OnAction()
                var
                    POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
                begin
                    //-NPR5.40 [300660]
                    POSPaymentBinInvokeMgt.OnShowInvokeParameters(Rec);
                    //+NPR5.40 [300660]
                end;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Transfer Out From Bin action';

                trigger OnAction()
                begin
                    TransferContentsToBin("No.");
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
                ApplicationArea = All;
                ToolTip = 'Executes the Insert Initial Float action';

                trigger OnAction()
                begin
                    //-NPR5.51 [353761]
                    InsertInitialFloat();
                    //+NPR5.51 [353761]
                end;
            }
        }
    }

    var
        InitialFloatDesc: Label 'Initial Float';

    local procedure TransferContentsToBin(FromBinNo: Code[10])
    var
        CheckpointEntryNo: Integer;
        PaymentBinCheckpoint: Codeunit "NPR POS Payment Bin Checkpoint";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        PaymentBinCheckpointPage: Page "NPR POS Payment Bin Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        PageAction: Action;
        SalePOS: Record "NPR POS Sale";
    begin

        //-NPR5.40 [307267]
        CheckpointEntryNo := POSWorkshiftCheckpoint.CreateEndWorkshiftCheckpoint_POSEntry('');
        PaymentBinCheckpoint.CreatePosEntryBinCheckpoint('', "No.", CheckpointEntryNo);
        Commit;

        // Confirm amounts counted and float/bank/safe transfer
        POSPaymentBinCheckpoint.Reset();
        POSPaymentBinCheckpoint.FilterGroup(2);
        POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', CheckpointEntryNo);
        POSPaymentBinCheckpoint.FilterGroup(0);
        PaymentBinCheckpointPage.SetTableView(POSPaymentBinCheckpoint);
        PaymentBinCheckpointPage.LookupMode(true);
        PaymentBinCheckpointPage.SetTransferMode();
        PageAction := PaymentBinCheckpointPage.RunModal();
        Commit;

        if (PageAction = ACTION::LookupOK) then begin
            POSPaymentBinCheckpoint.Reset();
            POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', CheckpointEntryNo);
            POSPaymentBinCheckpoint.SetFilter(Status, '=%1', POSPaymentBinCheckpoint.Status::READY);
            if (POSPaymentBinCheckpoint.FindFirst()) then begin
                SalePOS."Register No." := 'TMP';
                SalePOS."POS Store Code" := 'TMP';
                SalePOS.Date := Today;
                SalePOS."Sales Ticket No." := DelChr(Format(CurrentDateTime(), 0, 9), '<=>', DelChr(Format(CurrentDateTime(), 0, 9), '<=>', '01234567890'));

                POSCreateEntry.CreateBalancingEntryAndLines(SalePOS, true, CheckpointEntryNo);
            end;
        end;
        //+NPR5.40 [307267]
    end;

    local procedure InsertInitialFloat()
    var
        POSPayBinSetFloat: Page "NPR POS Paym.Bin Set Float";
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentMethodTemp: Record "NPR POS Payment Method" temporary;
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        BinEntry: Record "NPR POS Bin Entry";
    begin
        //-NPR5.51 [353761]
        POSUnit.Get("Attached to POS Unit No.");

        POSPayBinSetFloat.LookupMode := true;
        POSPayBinSetFloat.SetPaymentBin(Rec);
        if POSPayBinSetFloat.RunModal = ACTION::LookupOK then begin
            POSPayBinSetFloat.GetAmounts(POSPaymentMethodTemp);

            POSPaymentMethodTemp.Reset();
            if POSPaymentMethodTemp.FindSet then begin

                POSWorkshiftCheckpoint.Init;
                POSWorkshiftCheckpoint."Entry No." := 0;

                POSWorkshiftCheckpoint."POS Unit No." := "Attached to POS Unit No.";
                POSWorkshiftCheckpoint."Created At" := CurrentDateTime;
                POSWorkshiftCheckpoint.Open := false;
                POSWorkshiftCheckpoint."POS Entry No." := 0;
                POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::ZREPORT;
                POSWorkshiftCheckpoint.Insert;

                repeat
                    POSPaymentMethod.Get(POSPaymentMethodTemp.Code);

                    // Creating the bin checkpoint
                    BinEntry.Init();
                    BinEntry."Entry No." := 0;
                    BinEntry."Created At" := CurrentDateTime();
                    BinEntry.Type := BinEntry.Type::CHECKPOINT;
                    BinEntry."Payment Bin No." := "No.";
                    BinEntry."Transaction Date" := Today;
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

                    POSPaymentBinCheckpoint.Init;
                    POSPaymentBinCheckpoint."Entry No." := 0;
                    POSPaymentBinCheckpoint.Type := POSPaymentBinCheckpoint.Type::ZREPORT;
                    POSPaymentBinCheckpoint."Float Amount" := POSPaymentMethodTemp."Rounding Precision";
                    POSPaymentBinCheckpoint."Calculated Amount Incl. Float" := POSPaymentMethodTemp."Rounding Precision";
                    POSPaymentBinCheckpoint."New Float Amount" := POSPaymentMethodTemp."Rounding Precision";
                    POSPaymentBinCheckpoint."Created On" := CurrentDateTime;
                    POSPaymentBinCheckpoint."Checkpoint Date" := Today;
                    POSPaymentBinCheckpoint."Checkpoint Time" := Time;
                    POSPaymentBinCheckpoint.Description := InitialFloatDesc;
                    POSPaymentBinCheckpoint."Payment Method No." := POSPaymentMethod.Code;
                    POSPaymentBinCheckpoint."Currency Code" := POSPaymentMethod."Currency Code";
                    POSPaymentBinCheckpoint."Payment Bin No." := "No.";
                    POSPaymentBinCheckpoint.Status := POSPaymentBinCheckpoint.Status::TRANSFERED;
                    POSPaymentBinCheckpoint."Workshift Checkpoint Entry No." := POSWorkshiftCheckpoint."Entry No.";
                    POSPaymentBinCheckpoint."Checkpoint Bin Entry No." := BinEntry."Entry No.";
                    POSPaymentBinCheckpoint."Include In Counting" := POSPaymentBinCheckpoint."Include In Counting"::YES;
                    POSPaymentBinCheckpoint.Insert;

                    BinEntry."Bin Checkpoint Entry No." := POSPaymentBinCheckpoint."Entry No.";
                    BinEntry.Modify();

                    // Creating the intial float entry
                    BinEntry."Entry No." := 0;
                    BinEntry."Bin Checkpoint Entry No." := POSPaymentBinCheckpoint."Entry No.";
                    BinEntry.Type := BinEntry.Type::FLOAT;
                    BinEntry."Transaction Amount" := POSPaymentMethodTemp."Rounding Precision";
                    CalculateTransactionAmountLCY(BinEntry);
                    BinEntry.Insert();

                until POSPaymentMethodTemp.Next = 0;
            end;
        end;
        //+NPR5.51 [353761]
    end;

    local procedure CalculateTransactionAmountLCY(var POSBinEntry: Record "NPR POS Bin Entry")
    var
        Currency: Record Currency;
        CurrencyFactor: Decimal;
        CurrExchRate: Record "Currency Exchange Rate";
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
        // IF (NOT Currency.GET (CurrencyCode)) THEN
        //  EXIT;
        //
        // EXIT (ROUND (CurrExchRate.ExchangeAmtFCYToLCY (TransactionDate, CurrencyCode, Amount,
        //                                               1 / CurrExchRate.ExchangeRate (TransactionDate, CurrencyCode))));
    end;
}

