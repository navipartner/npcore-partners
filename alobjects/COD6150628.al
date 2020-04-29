codeunit 6150628 "POS Payment Bin Checkpoint"
{
    // NPR5.36/TSA /20170705 CASE 282251 Code to fill new entities with legacy data
    // NPR5.40/TSA /20180302 CASE 282251 Adapted for POS Entry as source CreatePosEntryBinCheckpoint()
    // NPR5.45/TSA /20180726 CASE 322769 Included assignment of "include in counting" on record to make display selection on view
    // NPR5.45/TSA /20180727 CASE 311964 Handling of transfered amount
    // NPR5.48/TSA /20181219 CASE 339139 Checking if a zero calculated amount is due to zero transactions or a zero total
    // NPR5.48/TSA /20190114 CASE 339571 Virtal counting is incorrectly detected as a transfer-out in next counting.
    // NPR5.49/TSA /20190313 CASE 347324 Missing Store on checkpoint
    // NPR5.49/TSA /20190315 CASE 348458 Same payment method over multiple bins on same unit was skipped.
    // NPR5.49/TSA /20190315 CASE 348458 Added POS Unit no to filters to handle shared bins
    // NPR5.53/TSA /20191219 CASE 383012 Added support for keeping entries with zero bin movement


    trigger OnRun()
    begin
        // Test
        // CreateAuditRollBinCheckpoint ('1', '4', 0);
    end;

    var
        t001: Label 'Opening receipt is missing!';
        UNCONFIRMED_CP: Label 'Not Counted.';
        ACCOUNT_DIFFERENCE: Label 'WARNING!\\As a result of the close workshift, there needs to be a transfer of %1 to the amount of %5 from bin %2 to bin %3. These bins are configured with different G/L Accounts, and the posting needs to be handled.\\You can either:\\A) configure the bins to use the same account\\B) perform a BIN TRANSFER prior to close workshift on unit %4\\C) manually post the difference in a journal.\\If you continue, you will have to manually post the difference in a journal. Do you want to continue?';

    procedure CreateAuditRollBinCheckpoint(RegisterNo: Code[10];BinNo: Code[10];WorkshiftCheckpointEntryNo: Integer)
    var
        PaymentTypePOS: Record "Payment Type POS";
        CountAsPaymentTypeCode: Code[10];
    begin

        PaymentTypePOS.SetFilter (Status, '=%1', PaymentTypePOS.Status::Active);
        if (PaymentTypePOS.FindSet ()) then begin
          repeat
            CountAsPaymentTypeCode := FillBinFromAuditRoll (BinNo, RegisterNo, PaymentTypePOS."No.");
          until (PaymentTypePOS.Next () = 0);
        end;

        if (PaymentTypePOS.FindSet ()) then begin
          repeat
            AddBinCountingCheckpoint_AR (BinNo, RegisterNo, PaymentTypePOS."No.", WorkshiftCheckpointEntryNo);
          until (PaymentTypePOS.Next () = 0);
        end;
    end;

    procedure CreatePosEntryBinCheckpoint(UnitNo: Code[10];BinNo: Code[10];WorkshiftCheckpointEntryNo: Integer)
    var
        POSPaymentMethod: Record "POS Payment Method";
    begin

        //-NPR5.45 [322769]
        //POSPaymentMethod.SETFILTER ("Include In Counting", '<>%1', POSPaymentMethod."Include In Counting"::NO);
        //+NPR5.45 [322769]

        POSPaymentMethod.FindSet ();
        repeat
          AddBinCountingCheckpoint_PE (BinNo, UnitNo, POSPaymentMethod.Code, WorkshiftCheckpointEntryNo);
        until (POSPaymentMethod.Next () = 0);
    end;

    local procedure FillBinFromAuditRoll(BinNo: Code[10];RegisterNo: Code[10];PaymentTypeNo: Code[10]) CountAsPaymentTypeCode: Code[10]
    var
        CashRegister: Record Register;
        AuditRoll: Record "Audit Roll";
        PaymentTypePOS: Record "Payment Type POS";
        RetailSetup: Record "Retail Setup";
        G_ReceiptFilter: Text;
        BinEntry: Record "POS Bin Entry";
        CurrencyCode: Code[10];
        POSPaymentMethod: Record "POS Payment Method";
    begin
        
        RetailSetup.Get();
        CashRegister.Get (RegisterNo);
        
        AuditRoll.SetCurrentKey ("Register No.", "Sales Ticket No.", "Sale Type", Type);
        AuditRoll.SetRange ("Register No.", CashRegister."Register No.");
        AuditRoll.SetFilter("Sales Ticket No.", '<>%1', '');
        
        G_ReceiptFilter := StrSubstNo('>=%1',CashRegister."Opened on Sales Ticket");
        AuditRoll.SetFilter("Sales Ticket No.", G_ReceiptFilter);
        
        //find the date that the register open was done, and make that date the minimum date
        if AuditRoll.FindFirst then
          AuditRoll.SetFilter("Sale Date", '%1..', AuditRoll."Sale Date");
        
        if AuditRoll.FindLast then
          G_ReceiptFilter := StrSubstNo('..%1',AuditRoll."Sales Ticket No.");
        
        if not AuditRoll.FindSet then
            Error(t001)
        else
          G_ReceiptFilter := StrSubstNo('%1' + G_ReceiptFilter,AuditRoll."Sales Ticket No.");
        
        if (not (AuditRoll.Next() > 0)) then
          exit;
        
        /* CALCULATIONS */
        
        /* SET INITIAL FILTERS */
        AuditRoll.SetFilter("Sales Ticket No." , G_ReceiptFilter);
        
        
        AuditRoll.SetRange(Type, AuditRoll.Type::Payment);
        AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Payment);
        PaymentTypePOS.SetRange(Status, PaymentTypePOS.Status::Active);
        PaymentTypePOS.SetRange ("No.", PaymentTypeNo);
        
        if (PaymentTypePOS.FindFirst ()) then begin
          AuditRoll.SetRange("No.", PaymentTypePOS."No.");
        
          CountAsPaymentTypeCode := GetCountAsPaymentTypeCode (PaymentTypeNo);
          if (not POSPaymentMethod.Get (PaymentTypeNo)) then
            Clear (POSPaymentMethod);
        
          case PaymentTypePOS."Processing Type" of
            PaymentTypePOS."Processing Type"::Cash : CurrencyCode := '';
            PaymentTypePOS."Processing Type"::"Foreign Currency" :
              begin
                CurrencyCode := PaymentTypeNo;
                if (POSPaymentMethod.Code <> '') then
                  CurrencyCode := POSPaymentMethod."Currency Code";
              end;
            PaymentTypePOS."Processing Type"::EFT,
            PaymentTypePOS."Processing Type"::"Other Credit Cards" : CurrencyCode := '';
          end;
        
          if (AuditRoll.FindSet ()) then begin
            repeat
              BinEntry.Init ();
              BinEntry."Entry No." := 0;
              BinEntry."Created At" := CurrentDateTime ();
        
              BinEntry.Type := BinEntry.Type::INPAYMENT;
              if (AuditRoll."Amount Including VAT" < 0) then
                BinEntry.Type := BinEntry.Type::OUTPAYMENT;
        
              BinEntry."Payment Bin No." := BinNo;
        
              BinEntry."Transaction Date" := AuditRoll."Sale Date";
              BinEntry."Transaction Time" := AuditRoll."Starting Time";
        
              BinEntry."Transaction Currency Code" := CurrencyCode;
              BinEntry."Transaction Amount (LCY)" := AuditRoll."Amount Including VAT";
        
              BinEntry."Transaction Amount" := AuditRoll."Currency Amount";
              if (CurrencyCode = '') then
                BinEntry."Transaction Amount" := AuditRoll."Amount Including VAT";
        
              BinEntry."Register No." := AuditRoll."Register No.";
              BinEntry."Payment Type Code" := CountAsPaymentTypeCode;
              BinEntry."Payment Method Code" := POSPaymentMethod.Code;
              BinEntry.Insert ();
        
            until (AuditRoll.Next () = 0);
          end;
        end;

    end;

    local procedure AddBinCountingCheckpoint_AR(BinNo: Code[10];RegisterNo: Code[10];PaymentTypeNo: Code[10];WorkshiftCheckpointEntryNo: Integer)
    var
        BinEntry: Record "POS Bin Entry";
        PaymentBinCheckpoint: Record "POS Payment Bin Checkpoint";
        PaymentTypePOS: Record "Payment Type POS";
        PreviosFloat: Record "POS Payment Bin Checkpoint";
        POSPaymentMethod: Record "POS Payment Method";
    begin

        PaymentTypeNo := GetCountAsPaymentTypeCode (PaymentTypeNo);
        PaymentTypePOS.SetFilter ("No.", '=%1', PaymentTypeNo);
        if (PaymentTypePOS.FindFirst ()) then ;

        if (not POSPaymentMethod.Get (PaymentTypeNo)) then
          Clear (POSPaymentMethod);

        BinEntry.SetFilter ("Payment Bin No.", '=%1', BinNo);
        BinEntry.SetFilter ("Register No.", '=%1', RegisterNo);
        BinEntry.SetFilter ("Payment Type Code", '=%1', PaymentTypeNo);
        if (BinEntry.FindLast ()) then
          if (BinEntry.Type = BinEntry.Type::CHECKPOINT) then
            exit;

        BinEntry.Init ();
        BinEntry."Entry No." := 0;
        BinEntry."Created At" := CurrentDateTime ();

        BinEntry.Type := BinEntry.Type::CHECKPOINT;
        BinEntry."Payment Bin No." := BinNo;

        BinEntry."Transaction Date" := Today;
        BinEntry."Transaction Time" := Time;
        BinEntry.Comment := UNCONFIRMED_CP;

        BinEntry."Register No." := RegisterNo;
        BinEntry."Payment Type Code" := PaymentTypeNo;
        BinEntry."Payment Method Code" := POSPaymentMethod.Code;
        BinEntry.Insert ();

        PaymentBinCheckpoint.Init;
        PaymentBinCheckpoint."Payment Type No." := PaymentTypeNo;
        PaymentBinCheckpoint."Payment Method No." := BinEntry."Payment Method Code" ;
        PaymentBinCheckpoint."Currency Code" := POSPaymentMethod."Currency Code";
        PaymentBinCheckpoint."Payment Bin No." := BinNo;

        PaymentBinCheckpoint."Created On" := CurrentDateTime ();
        PaymentBinCheckpoint."Checkpoint Date" := Today;
        PaymentBinCheckpoint."Checkpoint Time" := Time;
        PaymentBinCheckpoint."Checkpoint Bin Entry No." := BinEntry."Entry No.";
        PaymentBinCheckpoint.Comment := BinEntry.Comment;

        PaymentBinCheckpoint.Description := PaymentTypePOS.Description;
        PaymentBinCheckpoint."Workshift Checkpoint Entry No." := WorkshiftCheckpointEntryNo;
        PaymentBinCheckpoint.Insert();

        PaymentBinCheckpoint."Payment Bin Entry No. Filter" := BinEntry."Entry No.";
        PaymentBinCheckpoint.CalcFields ("Payment Bin Entry Amount", "Payment Bin Entry Amount (LCY)");
        PaymentBinCheckpoint."Calculated Amount Incl. Float" := PaymentBinCheckpoint."Payment Bin Entry Amount";
        PaymentBinCheckpoint."New Float Amount" := PaymentBinCheckpoint."Payment Bin Entry Amount";

        // Find previous checkpoint outbound float
        PreviosFloat.SetFilter ("Entry No.", '<%1', PaymentBinCheckpoint."Entry No.");
        PreviosFloat.SetFilter ("Payment Bin No.", '=%1', BinNo);
        PreviosFloat.SetFilter ("Payment Method No.", '=%1', PaymentBinCheckpoint."Payment Method No.");
        PreviosFloat.SetFilter ("Payment Type No.", '=%1', PaymentTypeNo); // will be obsolete
        if (PreviosFloat.FindLast ()) then
          PaymentBinCheckpoint."Float Amount" := PreviosFloat."New Float Amount";

        PaymentBinCheckpoint.Modify ();
    end;

    local procedure AddBinCountingCheckpoint_PE(BinNo: Code[10];UnitNo: Code[10];PaymentMethodCode: Code[10];WorkshiftCheckpointEntryNo: Integer)
    var
        BinEntry: Record "POS Bin Entry";
        PaymentBinCheckpoint: Record "POS Payment Bin Checkpoint";
        PaymentTypePOS: Record "Payment Type POS";
        PreviousFloat: Record "POS Payment Bin Checkpoint";
        PreviousZReport: Record "POS Workshift Checkpoint";
        PreviousBinCheckpoint: Record "POS Payment Bin Checkpoint";
        POSPaymentMethod: Record "POS Payment Method";
        POSBinEntry: Record "POS Bin Entry";
        POSUnit: Record "POS Unit";
        POSEndofDayProfile: Record "POS End of Day Profile";
        POSBinMovement: Boolean;
        LastCheckpointEntryNo: Integer;
    begin

        //-NPR5.49 [347324]
        POSUnit.Get (UnitNo);
        //+NPR5.49 [347324]

        PaymentBinCheckpoint.SetFilter ("Workshift Checkpoint Entry No.", '=%1', WorkshiftCheckpointEntryNo);
        PaymentBinCheckpoint.SetFilter ("Payment Method No.", '=%1', PaymentMethodCode);
        //-NPR5.49 [348458]
        PaymentBinCheckpoint.SetFilter ("Payment Bin No.", '=%1', BinNo);
        //+NPR5.49 [348458]

        if (not PaymentBinCheckpoint.IsEmpty ()) then
          exit; // no need to create it again

        // PaymentTypeNo := GetCountAsPaymentTypeCode (PaymentTypeNo);
        PaymentTypePOS.SetFilter ("No.", '=%1', PaymentMethodCode);
        if (PaymentTypePOS.FindFirst ()) then ;

        if (not POSPaymentMethod.Get (PaymentMethodCode)) then
          Clear (POSPaymentMethod);

        BinEntry.Init ();
        BinEntry."Entry No." := 0;
        BinEntry."Created At" := CurrentDateTime ();

        BinEntry.Type := BinEntry.Type::CHECKPOINT;
        BinEntry."Payment Bin No." := BinNo;

        BinEntry."Transaction Date" := Today;
        BinEntry."Transaction Time" := Time;
        BinEntry.Comment := UNCONFIRMED_CP;

        BinEntry."Register No." := UnitNo;
        BinEntry."POS Unit No." := UnitNo;

        //-NPR5.49 [347324]
        // BinEntry."POS Store Code" := ''; // TODO
        BinEntry."POS Store Code" := POSUnit."POS Store Code";
        //+NPR5.49 [347324]

        BinEntry."Payment Type Code" := PaymentTypePOS."No.";
        BinEntry."Payment Method Code" := PaymentMethodCode;
        BinEntry.Insert ();

        PaymentBinCheckpoint.Init;
        PaymentBinCheckpoint."Payment Type No." := BinEntry."Payment Type Code";
        PaymentBinCheckpoint."Payment Method No." := BinEntry."Payment Method Code" ;
        PaymentBinCheckpoint."Currency Code" := POSPaymentMethod."Currency Code";
        PaymentBinCheckpoint."Payment Bin No." := BinNo;
        //-NPR5.45 [322769]
        PaymentBinCheckpoint."Include In Counting" := POSPaymentMethod."Include In Counting";
        //+NPR5.45 [322769]

        PaymentBinCheckpoint."Created On" := CurrentDateTime ();
        PaymentBinCheckpoint."Checkpoint Date" := Today;
        PaymentBinCheckpoint."Checkpoint Time" := Time;
        PaymentBinCheckpoint."Checkpoint Bin Entry No." := BinEntry."Entry No.";
        PaymentBinCheckpoint.Comment := BinEntry.Comment;

        //-NPR5.49 [348458]
        //PaymentBinCheckpoint.Description := PaymentTypePOS.Description;
        PaymentBinCheckpoint.Description := CopyStr (StrSubstNo ('[%1] %2', BinNo, PaymentTypePOS.Description), 1, MaxStrLen(PaymentBinCheckpoint.Description));
        //+NPR5.49 [348458]

        PaymentBinCheckpoint."Workshift Checkpoint Entry No." := WorkshiftCheckpointEntryNo;
        PaymentBinCheckpoint.Insert();

        PaymentBinCheckpoint."Payment Bin Entry No. Filter" := BinEntry."Entry No.";

        //-NPR5.49 [348458]
        PaymentBinCheckpoint."POS Unit No. Filter" := UnitNo;
        PaymentBinCheckpoint.SetFilter ("POS Unit No. Filter", '=%1', UnitNo);
        //+NPR5.49 [348458]

        PaymentBinCheckpoint.CalcFields ("Payment Bin Entry Amount", "Payment Bin Entry Amount (LCY)");
        PaymentBinCheckpoint."Calculated Amount Incl. Float" := PaymentBinCheckpoint."Payment Bin Entry Amount";
        PaymentBinCheckpoint."New Float Amount" := PaymentBinCheckpoint."Payment Bin Entry Amount";

        //-NPR5.45 [311964]
        // // Find previous checkpoint outbound float
        // PreviousFloat.SETFILTER ("Entry No.", '<%1', PaymentBinCheckpoint."Entry No.");
        // PreviousFloat.SETFILTER ("Payment Bin No.", '=%1', BinNo);
        // PreviousFloat.SETFILTER ("Payment Method No.", '=%1', PaymentBinCheckpoint."Payment Method No.");
        //
        // IF (PreviousFloat.FINDLAST ()) THEN
        //  PaymentBinCheckpoint."Float Amount" := PreviousFloat."New Float Amount";

        if (PaymentMethodCode = 'K') then begin
          LastCheckpointEntryNo := LastCheckpointEntryNo; // debug stop
        end;

        //-NPR5.49 [348458]
        //PreviousZReport.SETFILTER (Type, '=%1', PreviousZReport.Type::ZREPORT);
        // PreviousZReport.SETFILTER ("POS Entry No.", '>%1', 0);

        PreviousZReport.SetFilter (Type, '=%1|=%2', PreviousZReport.Type::ZREPORT, PreviousZReport.Type::WORKSHIFT_CLOSE);
        PreviousZReport.SetFilter (Open, '=%1', false);
        //+NPR5.49 [348458]

        PreviousZReport.SetFilter ("POS Unit No.", '=%1', UnitNo);
        if (PreviousZReport.FindLast ()) then begin



          //-NPR5.49 [348458]
          //  PreviousBinCheckpoint.RESET ();
          // PreviousBinCheckpoint.SETFILTER ("Workshift Checkpoint Entry No.", '=%1', PreviousZReport."Entry No.");
          //  PreviousBinCheckpoint.SETFILTER ("Workshift Checkpoint Entry No.", '=%1', PreviousZReport."Entry No.");
          //  PreviousBinCheckpoint.SETFILTER ("Payment Method No.", '=%1', PaymentBinCheckpoint."Payment Method No.");
          //  PreviousBinCheckpoint.SETFILTER ("Payment Bin No.", '=%1', PaymentBinCheckpoint."Payment Bin No.");
          //  IF (PreviousBinCheckpoint.FINDFIRST ()) THEN BEGIN
          //
          //    PaymentBinCheckpoint."Float Amount" := PreviousBinCheckpoint."New Float Amount";
          //
          //    //-NPR5.48 [339571]
          //    POSBinEntry.SETFILTER ("Bin Checkpoint Entry No.", '=%1', PreviousBinCheckpoint."Entry No.");
          //    IF (POSBinEntry.FINDLAST ()) THEN
          //      LastCheckpointEntryNo := POSBinEntry."Entry No."; // Get last bin entry for checkpoint

          LastCheckpointEntryNo := -1;

          PreviousBinCheckpoint.Reset ();
          case PreviousZReport.Type of
            PreviousZReport.Type::ZREPORT         : PreviousBinCheckpoint.SetFilter ("Workshift Checkpoint Entry No.", '=%1', PreviousZReport."Entry No.");
            PreviousZReport.Type::WORKSHIFT_CLOSE : PreviousBinCheckpoint.SetFilter ("Workshift Checkpoint Entry No.", '=%1', PreviousZReport."Consolidated With Entry No.");
          end;

          PreviousBinCheckpoint.SetFilter ("Payment Method No.", '=%1', PaymentBinCheckpoint."Payment Method No.");
          PreviousBinCheckpoint.SetFilter ("Payment Bin No.", '=%1', PaymentBinCheckpoint."Payment Bin No.");
          if (PreviousBinCheckpoint.FindFirst ()) then begin

            PaymentBinCheckpoint."Float Amount" := PreviousBinCheckpoint."New Float Amount";

            //-NPR5.48 [339571]
            POSBinEntry.SetFilter ("Bin Checkpoint Entry No.", '=%1', PreviousBinCheckpoint."Entry No.");
            if (POSBinEntry.FindLast ()) then
              LastCheckpointEntryNo := POSBinEntry."Entry No."; // Get last bin entry for previous checkpoint
          end;

          // Aggregate the transfers from between this checkpoint and previous
          if (LastCheckpointEntryNo >= 0) then begin
          //-NPR5.49 [348458]

            POSBinEntry.Reset ();
            POSBinEntry.SetFilter ("Entry No.", '>%1', LastCheckpointEntryNo);
            // POSBinEntry.SETFILTER ("Bin Checkpoint Entry No.", '>=%1', PreviousBinCheckpoint."Entry No.");
            //+NPR5.48 [339571]

            POSBinEntry.SetFilter ("Payment Bin No.", '=%1', PaymentBinCheckpoint."Payment Bin No.");
            POSBinEntry.SetFilter ("Payment Method Code", '=%1', PaymentBinCheckpoint."Payment Method No.");
            //-NPR5.49 [348458]
            POSBinEntry.SetFilter ("POS Unit No.", '=%1', UnitNo);
            //+NPR5.49 [348458]

            POSBinEntry.SetFilter (Type, '=%1|=%2', POSBinEntry.Type::BIN_TRANSFER_IN, POSBinEntry.Type::BIN_TRANSFER_OUT);
            if (POSBinEntry.FindSet ()) then begin
              //-NPR5.48 [339139]
              POSBinMovement := true;
              //+NPR5.48 [339139]
              repeat
                case POSBinEntry.Type of
                  POSBinEntry.Type::BIN_TRANSFER_IN : PaymentBinCheckpoint."Transfer In Amount" += POSBinEntry."Transaction Amount";
                  POSBinEntry.Type::BIN_TRANSFER_OUT : PaymentBinCheckpoint."Transfer Out Amount" += POSBinEntry."Transaction Amount";
                end;
              until (POSBinEntry.Next () = 0);
            end;

            //-NPR5.48 [339139]
            // Check if the 0 float amount is a sum of transactions or result of zero transactions
            if ((not POSBinMovement) and (PaymentBinCheckpoint."Calculated Amount Incl. Float" = 0)) then begin
              POSBinEntry.SetFilter (Type, '=%1', POSBinEntry.Type::CHECKPOINT);
              if (POSBinEntry.FindFirst ()) then begin
                POSBinEntry.Reset ();
                POSBinEntry.SetFilter ("Entry No.", '%1..', POSBinEntry."Entry No.");
                POSBinEntry.SetFilter ("Payment Bin No.", '=%1', PaymentBinCheckpoint."Payment Bin No.");
                POSBinEntry.SetFilter ("Payment Method Code", '=%1', PaymentBinCheckpoint."Payment Method No.");
                POSBinEntry.SetFilter (Type, '=%1|=%2', POSBinEntry.Type::INPAYMENT, POSBinEntry.Type::OUTPAYMENT);
                POSBinMovement := (not POSBinEntry.IsEmpty ());
              end;
            end;
            //+NPR5.48 [339139]

          end;
        end;
        //+NPR5.45 [311964]

        PaymentBinCheckpoint.Modify ();

        BinEntry."Bin Checkpoint Entry No." := PaymentBinCheckpoint."Entry No.";
        BinEntry.Modify ();

        //-NPR5.48 [339139]
        // IF (PaymentBinCheckpoint."Calculated Amount Incl. Float" = 0) THEN BEGIN
        //  BinEntry.DELETE();
        //  PaymentBinCheckpoint.DELETE();
        // END;

        if ((not POSBinMovement) and (PaymentBinCheckpoint."Calculated Amount Incl. Float" = 0)) then begin

          //-NPR5.53 [383012]
          // BinEntry.DELETE();
          // PaymentBinCheckpoint.DELETE();
          POSEndofDayProfile.Init ();
          if (POSUnit."POS End of Day Profile" <> '') then begin
            if (not POSEndofDayProfile.Get (POSUnit."POS End of Day Profile")) then
              POSEndofDayProfile.Init ();
          end;

          if (not POSEndofDayProfile."Show Zero Amount Lines") then begin
            BinEntry.Delete();
            PaymentBinCheckpoint.Delete();
          end;
          //-NPR5.53 [383012]

        end;
        //+NPR5.48 [339139]
    end;

    procedure GetCountAsPaymentTypeCode(PaymentTypeNo: Code[10]) CountAsPaymentTypeCode: Code[10]
    var
        PaymentTypePOS: Record "Payment Type POS";
    begin

        PaymentTypePOS.SetRange ("No.", PaymentTypeNo);
        if (not PaymentTypePOS.FindFirst ()) then
          exit ('');

        CountAsPaymentTypeCode := PaymentTypeNo;

        case PaymentTypePOS."Processing Type" of
          PaymentTypePOS."Processing Type"::Cash : CountAsPaymentTypeCode := 'K';

          PaymentTypePOS."Processing Type"::EFT,
          PaymentTypePOS."Processing Type"::"Manual Card",
          PaymentTypePOS."Processing Type"::"Other Credit Cards" : CountAsPaymentTypeCode := 'T';

          PaymentTypePOS."Processing Type"::"Credit Voucher",
          PaymentTypePOS."Processing Type"::"Gift Voucher",
          PaymentTypePOS."Processing Type"::"Foreign Credit Voucher",
          PaymentTypePOS."Processing Type"::"Foreign Gift Voucher" : CountAsPaymentTypeCode := 'V'
        end;
    end;

    procedure FinishBinCount(POSSession: Codeunit "POS Session";WorkshiftCheckpointEntryNo: Integer)
    begin
    end;

    procedure TransferToPaymentBin(FromWorkshiftCheckpointEntryNo: Integer;FromUnitNo: Code[10];ToUnitNo: Code[10])
    var
        POSPaymentBinCheckpoint: Record "POS Payment Bin Checkpoint";
        POSBinEntry: Record "POS Bin Entry";
        ToPOSUnit: Record "POS Unit";
        FromPOSUnit: Record "POS Unit";
        ToPOSPostingSetup: Record "POS Posting Setup";
        FromPOSPostingSetup: Record "POS Posting Setup";
        POSPostEntries: Codeunit "POS Post Entries";
        TargetPaymentbin: Code[10];
    begin

        //-NPR5.49 [348458]
        ToPOSUnit.Get (ToUnitNo);
        FromPOSUnit.Get (FromUnitNo);

        POSPaymentBinCheckpoint.SetFilter ("Workshift Checkpoint Entry No.", '=%1', FromWorkshiftCheckpointEntryNo);
        if (POSPaymentBinCheckpoint.FindSet ()) then begin
          repeat
            POSPaymentBinCheckpoint.SetFilter ("POS Unit No. Filter", '=%1', FromUnitNo);
            POSPaymentBinCheckpoint.CalcFields ("Payment Bin Entry Amount", "Payment Bin Entry Amount (LCY)");
            // Get Source bin entry from (the checkpoint)
            POSBinEntry.SetFilter ("Bin Checkpoint Entry No.", '=%1', POSPaymentBinCheckpoint."Entry No.");
            if (POSBinEntry.FindFirst ()) then begin

              // Currently we do not support having differnent G/L accounts on the bins in this setup.
              if (POSPaymentBinCheckpoint."Payment Bin Entry Amount" <> 0) then begin

                // Check posting setup to have same accounts
                POSPostEntries.GetPostingSetup (FromPOSUnit."POS Store Code", POSBinEntry."Payment Method Code", POSBinEntry."Payment Bin No.", FromPOSPostingSetup);

                TargetPaymentbin := FromPOSPostingSetup."Close to POS Bin No.";
                if (TargetPaymentbin = '') then
                  TargetPaymentbin := ToPOSUnit."Default POS Payment Bin";

                POSPostEntries.GetPostingSetup (ToPOSUnit."POS Store Code", POSBinEntry."Payment Method Code", TargetPaymentbin, ToPOSPostingSetup);

                if ((FromPOSPostingSetup."Account Type" <> ToPOSPostingSetup."Account Type") or (FromPOSPostingSetup."Account No." <> ToPOSPostingSetup."Account No.")) then
                  if (not Confirm (ACCOUNT_DIFFERENCE, false, POSPaymentBinCheckpoint.Description, POSBinEntry."Payment Bin No.", TargetPaymentbin, FromUnitNo, POSPaymentBinCheckpoint."Payment Bin Entry Amount")) then
                    Error ('');

                // transfer source
                POSBinEntry."Entry No." := 0;
                POSBinEntry.Type := POSBinEntry.Type::BIN_TRANSFER_OUT;
                POSBinEntry."Created At" := CurrentDateTime();
                POSBinEntry."Transaction Date" := Today;
                POSBinEntry."Transaction Time" := Time;

                POSBinEntry."Transaction Amount" := POSPaymentBinCheckpoint."Payment Bin Entry Amount" * -1;
                POSBinEntry."Transaction Amount (LCY)" := POSPaymentBinCheckpoint."Payment Bin Entry Amount (LCY)" * -1;
                POSBinEntry.Comment := 'End-of-Day Transfer';
                POSBinEntry.Insert ();

                // transfer destination
                POSBinEntry."Entry No." := 0;
                POSBinEntry.Type := POSBinEntry.Type::BIN_TRANSFER_IN;
                POSBinEntry."POS Store Code" := ToPOSUnit."POS Store Code";
                POSBinEntry."POS Unit No." := ToPOSUnit."No.";
                POSBinEntry."Payment Bin No." := TargetPaymentbin;

                POSBinEntry."Transaction Amount" := POSPaymentBinCheckpoint."Payment Bin Entry Amount";
                POSBinEntry."Transaction Amount (LCY)" := POSPaymentBinCheckpoint."Payment Bin Entry Amount (LCY)";
                POSBinEntry.Comment := 'End-of-Day Transfer';
                POSBinEntry.Insert ();
              end;

            end;
          until (POSPaymentBinCheckpoint.Next () = 0);
        end;
    end;
}

