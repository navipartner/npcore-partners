codeunit 6150630 "POS Manage POS Unit"
{
    // NPR5.36/BR  /20170920  CASE 279552 Object Created
    // NPR5.38/TSA /20171124 CASE 297087 Added function OpenPosUnitNo
    // NPR5.38/BR  /20171214  CASE 299888  Renamed from POSPeriodRegister to POSPeriodRegister
    // NPR5.38/BR/20180125 CASE 302803 Fill Posting Compression in POS Period Register when assigning store
    // NPR5.48/TSA /20181127 CASE 336921 Added CloseXXX() and SetEndOfDayXXX set of functions (), OpenPosUnitNoWithPeriodEntryNo(), ReOpenLastPeriodRegister()
    // NPR5.50/TSA /20190403 CASE 350974 Added SetOpeningEntryNo(), ClosePOSUnitOpenPeriods()
    // NPR5.50/TSA /20190404 CASE 351131 Inherit compression from store setup
    // NPR5.50/TSA /20190521 CASE 355647 Rerfactored CreatePeriodRegister to initiate fields in the correct order.

    TableNo = "POS Unit";

    trigger OnRun()
    begin
        OpenPOSUnit(Rec);
    end;

    procedure OpenPosUnitNo(POSUnitNo: Code[10]): Boolean
    var
        POSUnit: Record "POS Unit";
    begin

        //-NPR5.38 [297087]
        if (POSUnit.Get (POSUnitNo)) then
          OpenPOSUnit (POSUnit);

        exit (POSUnit.Status = POSUnit.Status::OPEN);
        //+NPR5.38 [297087]
    end;

    procedure OpenPosUnitNoWithPeriodEntryNo(POSUnitNo: Code[10];OpeningEntryNo: Integer)
    var
        POSUnit: Record "POS Unit";
    begin

        //-NPR5.48 [336921]
        if (POSUnitNo) = '' then
          exit;

        if (not POSUnit.Get (POSUnitNo)) then
          exit;

        POSUnit.Validate(Status,POSUnit.Status::OPEN);
        CreatePeriodRegister(POSUnit, OpeningEntryNo);
        POSUnit.Modify(true);

        //+NPR5.48 [336921]
    end;

    procedure OpenPOSUnit(var POSUnit: Record "POS Unit")
    var
        SalePOS: Record "Sale POS";
    begin
        if POSUnit."No." = '' then
          exit;
        POSUnit.Validate(Status,POSUnit.Status::OPEN);
        CreatePeriodRegister(POSUnit, 0);
        POSUnit.Modify(true);
    end;

    local procedure CreatePeriodRegister(var POSUnit: Record "POS Unit";EntryNo: Integer)
    var
        POSPeriodRegister: Record "POS Period Register";
        POSStore: Record "POS Store";
    begin

        //-NPR5.50 [355647] -- REFACTOR

        // POSPeriodRegister.INIT;
        // POSPeriodRegister."No." := 0;
        // //-NPR5.38 [302803]
        // //POSPeriodRegister."POS Store Code" := POSUnit."POS Store Code";
        // POSPeriodRegister.VALIDATE("POS Store Code",POSUnit."POS Store Code");
        // //+NPR5.38 [302803]
        // POSPeriodRegister."POS Unit No." := POSUnit."No.";
        // POSPeriodRegister.VALIDATE(Status,POSPeriodRegister.Status::OPEN);
        //
        // //-NPR5.48 [336921]
        // POSPeriodRegister."Opening Entry No." := EntryNo;
        // POSPeriodRegister."Opened Date" := CURRENTDATETIME;
        // //+NPR5.48 [336921]
        //
        // //-NPR5.50 [351131]
        // POSPeriodRegister."Posting Compression" := POSPeriodRegister."Posting Compression"::Uncompressed;
        // IF (POSStore.GET (POSUnit."POS Store Code")) THEN
        //  POSPeriodRegister."Posting Compression" := POSStore."Posting Compression";
        // //+NPR5.50 [351131]


        POSPeriodRegister.Init;
        POSPeriodRegister."No." := 0;

        POSPeriodRegister."POS Unit No." := POSUnit."No.";

        POSPeriodRegister."Opening Entry No." := EntryNo;
        POSPeriodRegister."Opened Date" := CurrentDateTime;

        POSPeriodRegister."Posting Compression" := POSPeriodRegister."Posting Compression"::Uncompressed;
        if (POSStore.Get (POSUnit."POS Store Code")) then begin
          POSPeriodRegister."POS Store Code" := POSUnit."POS Store Code";
          POSPeriodRegister."Posting Compression" := POSStore."Posting Compression";
        end;

        POSPeriodRegister.Validate (Status,POSPeriodRegister.Status::OPEN);
        //+NPR5.50 [355647]

        POSPeriodRegister.Insert(true);
    end;

    procedure ReOpenLastPeriodRegister(POSUnitNo: Code[10])
    var
        POSPeriodRegister: Record "POS Period Register";
        POSUnit: Record "POS Unit";
    begin

        //-NPR5.48 [336921]
        if (POSUnitNo = '') then
          exit;

        if (not POSUnit.Get (POSUnitNo)) then
          exit;

        POSPeriodRegister.SetFilter ("POS Unit No.", '=%1', POSUnit."No.");
        POSPeriodRegister.FindLast ();

        POSUnit.Validate(Status, POSUnit.Status::OPEN);

        POSUnit.Modify(true);

        POSPeriodRegister.Status := POSPeriodRegister.Status::OPEN;
        POSPeriodRegister.Modify ();

        //+NPR5.48 [336921]
    end;

    procedure ClosePOSUnitNo(POSUnitNo: Code[10];ClosingEntryNo: Integer): Boolean
    var
        POSUnit: Record "POS Unit";
    begin

        //-NPR5.48 [336921]
        if (POSUnit.Get (POSUnitNo)) then
          ClosePOSUnit (POSUnit, ClosingEntryNo);

        exit (POSUnit.Status = POSUnit.Status::CLOSED);
        //+NPR5.48 [336921]
    end;

    procedure ClosePOSUnit(var POSUnit: Record "POS Unit";ClosingEntryNo: Integer)
    begin

        //-NPR5.48 [336921]
        if (POSUnit."No." = '') then
          exit;

        POSUnit.Validate (Status, POSUnit.Status::CLOSED);
        ClosePeriodRegister (POSUnit, ClosingEntryNo);

        POSUnit.Modify ();
        //+NPR5.48 [336921]
    end;

    local procedure ClosePeriodRegister(POSUnit: Record "POS Unit";ClosingEntryNo: Integer)
    var
        POSPeriodRegister: Record "POS Period Register";
    begin

        //-NPR5.48 [336921]
        POSPeriodRegister.SetFilter ("POS Unit No.", '=%1', POSUnit."No.");
        POSPeriodRegister.SetFilter (Status, '<>%1', POSPeriodRegister.Status::CLOSED);

        POSPeriodRegister.ModifyAll ("Closing Entry No.", ClosingEntryNo);
        POSPeriodRegister.ModifyAll (Status, POSPeriodRegister.Status::CLOSED);
        //+NPR5.48 [336921]
    end;

    procedure ClosePOSUnitOpenPeriods(POSUnitNo: Code[10])
    var
        POSPeriodRegister: Record "POS Period Register";
        POSEntry: Record "POS Entry";
        ClosingEntryNo: Integer;
    begin

        //-NPR5.50 [350974]
        POSEntry.SetFilter ("POS Unit No.", '=%1', POSUnitNo);
        if (POSEntry.FindLast ()) then
          ClosingEntryNo := POSEntry."Entry No.";

        POSPeriodRegister.SetFilter ("POS Unit No.", '=%1', POSUnitNo);
        POSPeriodRegister.SetFilter (Status, '<>%1', POSPeriodRegister.Status::CLOSED);

        if (ClosingEntryNo <> 0) then
          POSPeriodRegister.ModifyAll ("Closing Entry No.", ClosingEntryNo);
        POSPeriodRegister.ModifyAll (Status, POSPeriodRegister.Status::CLOSED);
        //+NPR5.50 [350974]
    end;

    procedure SetOpeningEntryNo(POSUnitNo: Code[10];OpeningEntryNo: Integer)
    var
        POSPeriodRegister: Record "POS Period Register";
    begin

        //-NPR5.50 [350974]
        POSPeriodRegister.SetFilter ("POS Unit No.", '=%1', POSUnitNo);
        POSPeriodRegister.SetFilter (Status, '=%1', POSPeriodRegister.Status::OPEN);
        if (POSPeriodRegister.FindLast ()) then begin
          POSPeriodRegister."Opening Entry No." := OpeningEntryNo;
          POSPeriodRegister."Opened Date" := CurrentDateTime ();
          POSPeriodRegister.Modify ();
        end;
        //+NPR5.50 [350974]
    end;

    procedure SetEndOfDayPOSUnitNo(POSUnitNo: Code[10]): Boolean
    var
        POSUnit: Record "POS Unit";
    begin

        //-NPR5.48 [336921]
        if (POSUnit.Get (POSUnitNo)) then
          SetEndOfDayPOSUnit (POSUnit);

        exit (POSUnit.Status = POSUnit.Status::EOD);
        //+NPR5.48 [336921]
    end;

    procedure SetEndOfDayPOSUnit(var POSUnit: Record "POS Unit")
    begin

        //-NPR5.48 [336921]
        if (POSUnit."No." = '') then
          exit;

        POSUnit.Validate (Status, POSUnit.Status::EOD);
        SetEndOfDayPeriodRegister (POSUnit);

        POSUnit.Modify ();
        //+NPR5.48 [336921]
    end;

    local procedure SetEndOfDayPeriodRegister(POSUnit: Record "POS Unit")
    var
        POSPeriodRegister: Record "POS Period Register";
    begin

        //-NPR5.48 [336921]
        POSPeriodRegister.SetFilter ("POS Unit No.", '=%1', POSUnit."No.");
        POSPeriodRegister.SetFilter (Status, '=%1', POSPeriodRegister.Status::OPEN);

        POSPeriodRegister.ModifyAll ("End of Day Date", CurrentDateTime);
        POSPeriodRegister.ModifyAll (Status, POSPeriodRegister.Status::EOD);
        //+NPR5.48 [336921]
    end;
}

