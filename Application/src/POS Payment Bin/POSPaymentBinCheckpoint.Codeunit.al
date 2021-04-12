codeunit 6150628 "NPR POS Payment Bin Checkpoint"
{
    var
        UNCONFIRMED_CP: Label 'Not Counted.';
        ACCOUNT_DIFFERENCE: Label 'WARNING!\\As a result of the close workshift, there needs to be a transfer of %1 to the amount of %5 from bin %2 to bin %3. These bins are configured with different G/L Accounts, and the posting needs to be handled.\\You can either:\\A) configure the bins to use the same account\\B) perform a BIN TRANSFER prior to close workshift on unit %4\\C) manually post the difference in a journal.\\If you continue, you will have to manually post the difference in a journal. Do you want to continue?';


    procedure CreatePosEntryBinCheckpoint(UnitNo: Code[10]; BinNo: Code[10]; WorkshiftCheckpointEntryNo: Integer)
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin

        POSPaymentMethod.FindSet();
        repeat
            AddBinCountingCheckpoint_PE(BinNo, UnitNo, POSPaymentMethod.Code, WorkshiftCheckpointEntryNo);
        until (POSPaymentMethod.Next() = 0);
    end;

    local procedure AddBinCountingCheckpoint_PE(BinNo: Code[10]; UnitNo: Code[10]; PaymentMethodCode: Code[10]; WorkshiftCheckpointEntryNo: Integer)
    var
        BinEntry: Record "NPR POS Bin Entry";
        PaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        PreviousZReport: Record "NPR POS Workshift Checkpoint";
        PreviousBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSBinEntry: Record "NPR POS Bin Entry";
        POSUnit: Record "NPR POS Unit";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
        POSBinMovement: Boolean;
        LastCheckpointEntryNo: Integer;
    begin

        POSUnit.Get(UnitNo);

        PaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', WorkshiftCheckpointEntryNo);
        PaymentBinCheckpoint.SetFilter("Payment Method No.", '=%1', PaymentMethodCode);
        PaymentBinCheckpoint.SetFilter("Payment Bin No.", '=%1', BinNo);

        if (not PaymentBinCheckpoint.IsEmpty()) then
            exit; // no need to create it again

        if (not POSPaymentMethod.Get(PaymentMethodCode)) then
            Clear(POSPaymentMethod);

        BinEntry.Init();
        BinEntry."Entry No." := 0;
        BinEntry."Created At" := CurrentDateTime();

        BinEntry.Type := BinEntry.Type::CHECKPOINT;
        BinEntry."Payment Bin No." := BinNo;

        BinEntry."Transaction Date" := Today();
        BinEntry."Transaction Time" := Time;
        BinEntry.Comment := UNCONFIRMED_CP;

        BinEntry."Register No." := UnitNo;
        BinEntry."POS Unit No." := UnitNo;
        BinEntry."POS Store Code" := POSUnit."POS Store Code";
        BinEntry."Payment Type Code" := PaymentMethodCode;
        BinEntry."Payment Method Code" := PaymentMethodCode;
        BinEntry.Insert();

        PaymentBinCheckpoint.Init();
        PaymentBinCheckpoint."Payment Type No." := BinEntry."Payment Type Code";
        PaymentBinCheckpoint."Payment Method No." := BinEntry."Payment Method Code";
        PaymentBinCheckpoint."Currency Code" := POSPaymentMethod."Currency Code";
        PaymentBinCheckpoint."Payment Bin No." := BinNo;
        PaymentBinCheckpoint."Include In Counting" := POSPaymentMethod."Include In Counting";
        PaymentBinCheckpoint."Created On" := CurrentDateTime();
        PaymentBinCheckpoint."Checkpoint Date" := Today();
        PaymentBinCheckpoint."Checkpoint Time" := Time;
        PaymentBinCheckpoint."Checkpoint Bin Entry No." := BinEntry."Entry No.";
        PaymentBinCheckpoint.Comment := BinEntry.Comment;
        PaymentBinCheckpoint.Description := CopyStr(StrSubstNo('[%1] %2', BinNo, POSPaymentMethod.Code), 1, MaxStrLen(PaymentBinCheckpoint.Description));
        PaymentBinCheckpoint."Workshift Checkpoint Entry No." := WorkshiftCheckpointEntryNo;
        PaymentBinCheckpoint.Insert();

        PaymentBinCheckpoint."Payment Bin Entry No. Filter" := BinEntry."Entry No.";
        PaymentBinCheckpoint."POS Unit No. Filter" := UnitNo;
        PaymentBinCheckpoint.SetFilter("POS Unit No. Filter", '=%1', UnitNo);

        PaymentBinCheckpoint.CalcFields("Payment Bin Entry Amount", "Payment Bin Entry Amount (LCY)");
        PaymentBinCheckpoint."Calculated Amount Incl. Float" := PaymentBinCheckpoint."Payment Bin Entry Amount";
        PaymentBinCheckpoint."New Float Amount" := PaymentBinCheckpoint."Payment Bin Entry Amount";

        if (PaymentMethodCode = 'K') then begin
            LastCheckpointEntryNo := LastCheckpointEntryNo; // debug stop
        end;

        PreviousZReport.SetCurrentKey("POS Unit No.", Open, "Type");
        PreviousZReport.SetFilter(Type, '=%1|=%2', PreviousZReport.Type::ZREPORT, PreviousZReport.Type::WORKSHIFT_CLOSE);
        PreviousZReport.SetFilter(Open, '=%1', false);
        PreviousZReport.SetFilter("POS Unit No.", '=%1', UnitNo);
        if (PreviousZReport.FindLast()) then begin

            LastCheckpointEntryNo := -1;

            PreviousBinCheckpoint.Reset();
            PreviousBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");

            case PreviousZReport.Type of
                PreviousZReport.Type::ZREPORT:
                    PreviousBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', PreviousZReport."Entry No.");
                PreviousZReport.Type::WORKSHIFT_CLOSE:
                    PreviousBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', PreviousZReport."Consolidated With Entry No.");
            end;

            PreviousBinCheckpoint.SetFilter("Payment Method No.", '=%1', PaymentBinCheckpoint."Payment Method No.");
            PreviousBinCheckpoint.SetFilter("Payment Bin No.", '=%1', PaymentBinCheckpoint."Payment Bin No.");
            if (PreviousBinCheckpoint.FindFirst()) then begin

                PaymentBinCheckpoint."Float Amount" := PreviousBinCheckpoint."New Float Amount";

                POSBinEntry.SetCurrentKey("Bin Checkpoint Entry No.");
                POSBinEntry.SetFilter("Bin Checkpoint Entry No.", '=%1', PreviousBinCheckpoint."Entry No.");
                if (POSBinEntry.FindLast()) then
                    LastCheckpointEntryNo := POSBinEntry."Entry No."; // Get last bin entry for previous checkpoint
            end;

            // Aggregate the transfers from between this checkpoint and previous
            if (LastCheckpointEntryNo >= 0) then begin
                POSBinEntry.Reset();
                POSBinEntry.SetCurrentKey("Payment Bin No.", "POS Unit No.", "Payment Method Code", "Type");
                POSBinEntry.SetFilter("Entry No.", '>%1', LastCheckpointEntryNo);
                POSBinEntry.SetFilter("Payment Bin No.", '=%1', PaymentBinCheckpoint."Payment Bin No.");
                POSBinEntry.SetFilter("Payment Method Code", '=%1', PaymentBinCheckpoint."Payment Method No.");
                POSBinEntry.SetFilter("POS Unit No.", '=%1', UnitNo);
                POSBinEntry.SetFilter(Type, '=%1|=%2', POSBinEntry.Type::BIN_TRANSFER_IN, POSBinEntry.Type::BIN_TRANSFER_OUT);
                if (POSBinEntry.FindSet()) then begin
                    POSBinMovement := true;
                    repeat
                        case POSBinEntry.Type of
                            POSBinEntry.Type::BIN_TRANSFER_IN:
                                PaymentBinCheckpoint."Transfer In Amount" += POSBinEntry."Transaction Amount";
                            POSBinEntry.Type::BIN_TRANSFER_OUT:
                                PaymentBinCheckpoint."Transfer Out Amount" += POSBinEntry."Transaction Amount";
                        end;
                    until (POSBinEntry.Next() = 0);
                end;

                // Check if the 0 float amount is a sum of transactions or result of zero transactions
                if ((not POSBinMovement) and (PaymentBinCheckpoint."Calculated Amount Incl. Float" = 0)) then begin
                    POSBinEntry.SetFilter(Type, '=%1', POSBinEntry.Type::CHECKPOINT);
                    if (POSBinEntry.FindFirst()) then begin
                        POSBinEntry.Reset();
                        POSBinEntry.SetCurrentKey("Payment Bin No.", "POS Unit No.", "Payment Method Code", "Type");
                        POSBinEntry.SetFilter("Entry No.", '%1..', POSBinEntry."Entry No.");
                        POSBinEntry.SetFilter("Payment Bin No.", '=%1', PaymentBinCheckpoint."Payment Bin No.");
                        POSBinEntry.SetFilter("Payment Method Code", '=%1', PaymentBinCheckpoint."Payment Method No.");
                        POSBinEntry.SetFilter(Type, '=%1|=%2', POSBinEntry.Type::INPAYMENT, POSBinEntry.Type::OUTPAYMENT);
                        POSBinMovement := (not POSBinEntry.IsEmpty());
                    end;
                end;

            end;
        end;

        PaymentBinCheckpoint.Modify();

        BinEntry."Bin Checkpoint Entry No." := PaymentBinCheckpoint."Entry No.";
        BinEntry.Modify();

        if ((not POSBinMovement) and (PaymentBinCheckpoint."Calculated Amount Incl. Float" = 0)) then begin
            POSEndofDayProfile.Init();
            if (POSUnit."POS End of Day Profile" <> '') then begin
                if (not POSEndofDayProfile.Get(POSUnit."POS End of Day Profile")) then
                    POSEndofDayProfile.Init();
            end;

            if (not POSEndofDayProfile."Show Zero Amount Lines") then begin
                BinEntry.Delete();
                PaymentBinCheckpoint.Delete();
            end;
        end;

    end;

    procedure TransferToPaymentBin(FromWorkshiftCheckpointEntryNo: Integer; FromUnitNo: Code[10]; ToUnitNo: Code[10])
    var
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSBinEntry: Record "NPR POS Bin Entry";
        ToPOSUnit: Record "NPR POS Unit";
        FromPOSUnit: Record "NPR POS Unit";
        ToPOSPostingSetup: Record "NPR POS Posting Setup";
        FromPOSPostingSetup: Record "NPR POS Posting Setup";
        POSPostEntries: Codeunit "NPR POS Post Entries";
        TargetPaymentbin: Code[10];
    begin

        ToPOSUnit.Get(ToUnitNo);
        FromPOSUnit.Get(FromUnitNo);

        POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
        POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', FromWorkshiftCheckpointEntryNo);
        if (POSPaymentBinCheckpoint.FindSet()) then begin
            repeat
                POSPaymentBinCheckpoint.SetFilter("POS Unit No. Filter", '=%1', FromUnitNo);
                POSPaymentBinCheckpoint.CalcFields("Payment Bin Entry Amount", "Payment Bin Entry Amount (LCY)");

                POSBinEntry.SetCurrentKey("Bin Checkpoint Entry No.");
                POSBinEntry.SetFilter("Bin Checkpoint Entry No.", '=%1', POSPaymentBinCheckpoint."Entry No.");
                if (POSBinEntry.FindFirst()) then begin

                    // Currently we do not support having differnent G/L accounts on the bins in this setup.
                    if (POSPaymentBinCheckpoint."Payment Bin Entry Amount" <> 0) then begin

                        // Check posting setup to have same accounts
                        POSPostEntries.GetPostingSetup(FromPOSUnit."POS Store Code", POSBinEntry."Payment Method Code", POSBinEntry."Payment Bin No.", FromPOSPostingSetup);

                        TargetPaymentbin := FromPOSPostingSetup."Close to POS Bin No.";
                        if (TargetPaymentbin = '') then begin
                            TargetPaymentbin := ToPOSUnit."Default POS Payment Bin";
                        end;

                        POSPostEntries.GetPostingSetup(ToPOSUnit."POS Store Code", POSBinEntry."Payment Method Code", TargetPaymentbin, ToPOSPostingSetup);

                        if ((FromPOSPostingSetup."Account Type" <> ToPOSPostingSetup."Account Type") or (FromPOSPostingSetup."Account No." <> ToPOSPostingSetup."Account No.")) then
                            if (not Confirm(ACCOUNT_DIFFERENCE, false, POSPaymentBinCheckpoint.Description, POSBinEntry."Payment Bin No.", TargetPaymentbin, FromUnitNo, POSPaymentBinCheckpoint."Payment Bin Entry Amount")) then
                                Error('');

                        // transfer source
                        POSBinEntry."Entry No." := 0;
                        POSBinEntry.Type := POSBinEntry.Type::BIN_TRANSFER_OUT;
                        POSBinEntry."Created At" := CurrentDateTime();
                        POSBinEntry."Transaction Date" := Today();
                        POSBinEntry."Transaction Time" := Time;

                        POSBinEntry."Transaction Amount" := POSPaymentBinCheckpoint."Payment Bin Entry Amount" * -1;
                        POSBinEntry."Transaction Amount (LCY)" := POSPaymentBinCheckpoint."Payment Bin Entry Amount (LCY)" * -1;
                        POSBinEntry.Comment := 'End-of-Day Transfer';
                        POSBinEntry.Insert();

                        // transfer destination
                        POSBinEntry."Entry No." := 0;
                        POSBinEntry.Type := POSBinEntry.Type::BIN_TRANSFER_IN;
                        POSBinEntry."POS Store Code" := ToPOSUnit."POS Store Code";
                        POSBinEntry."POS Unit No." := ToPOSUnit."No.";
                        POSBinEntry."Payment Bin No." := TargetPaymentbin;

                        POSBinEntry."Transaction Amount" := POSPaymentBinCheckpoint."Payment Bin Entry Amount";
                        POSBinEntry."Transaction Amount (LCY)" := POSPaymentBinCheckpoint."Payment Bin Entry Amount (LCY)";
                        POSBinEntry.Comment := 'End-of-Day Transfer';
                        POSBinEntry.Insert();
                    end;

                end;
            until (POSPaymentBinCheckpoint.Next() = 0);
        end;
    end;
}

