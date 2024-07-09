codeunit 6150630 "NPR POS Manage POS Unit"
{
    TableNo = "NPR POS Unit";

    trigger OnRun()
    begin
        OpenPOSUnit(Rec);
    end;

    internal procedure OpenPosUnitNo(POSUnitNo: Code[10]): Boolean
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if (POSUnit.Get(POSUnitNo)) then
            OpenPOSUnit(POSUnit);

        exit(POSUnit.Status = POSUnit.Status::OPEN);
    end;

    internal procedure OpenPosUnitNoWithPeriodEntryNo(POSUnitNo: Code[10]; OpeningEntryNo: Integer)
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if (POSUnitNo) = '' then
            exit;

        if (not POSUnit.Get(POSUnitNo)) then
            exit;

        POSUnit.Validate(Status, POSUnit.Status::OPEN);
        CreatePeriodRegister(POSUnit, OpeningEntryNo);
        POSUnit.Modify(true);
    end;

    procedure OpenPOSUnit(var POSUnit: Record "NPR POS Unit")
    begin
        if POSUnit."No." = '' then
            exit;
        POSUnit.Validate(Status, POSUnit.Status::OPEN);
        CreatePeriodRegister(POSUnit, 0);
        POSUnit.Modify(true);
    end;

    local procedure CreatePeriodRegister(var POSUnit: Record "NPR POS Unit"; EntryNo: Integer)
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        POSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        POSPeriodRegister.Init();
        POSPeriodRegister."No." := 0;

        POSPeriodRegister."POS Unit No." := POSUnit."No.";

        POSPeriodRegister."Opening Entry No." := EntryNo;
        POSPeriodRegister."Opened Date" := CurrentDateTime;

        POSPeriodRegister."Posting Compression" := POSPeriodRegister."Posting Compression"::Uncompressed;
        if POSStore.Get(POSUnit."POS Store Code") then begin
            POSPeriodRegister."POS Store Code" := POSUnit."POS Store Code";
            POSStore.GetProfile(POSPostingProfile);
            POSPeriodRegister."Posting Compression" := POSPostingProfile."Posting Compression";
        end;

        POSPeriodRegister.Validate(Status, POSPeriodRegister.Status::OPEN);

        POSPeriodRegister.Insert(true);
    end;

    internal procedure ReOpenLastPeriodRegister(POSUnitNo: Code[10])
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        POSUnit: Record "NPR POS Unit";
    begin
        if (POSUnitNo = '') then
            exit;

        if (not POSUnit.Get(POSUnitNo)) then
            exit;

        POSPeriodRegister.SetCurrentKey("POS Unit No.");
        POSPeriodRegister.SetFilter("POS Unit No.", '=%1', POSUnit."No.");
        POSPeriodRegister.FindLast();

        POSUnit.Validate(Status, POSUnit.Status::OPEN);

        POSUnit.Modify(true);

        POSPeriodRegister.Status := POSPeriodRegister.Status::OPEN;
        POSPeriodRegister.Modify();
    end;

    procedure ClosePOSUnitNo(POSUnitNo: Code[10]; ClosingEntryNo: Integer): Boolean
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if (POSUnit.Get(POSUnitNo)) then
            ClosePOSUnit(POSUnit, ClosingEntryNo);

        exit(POSUnit.Status = POSUnit.Status::CLOSED);
    end;

    procedure ClosePOSUnit(var POSUnit: Record "NPR POS Unit"; ClosingEntryNo: Integer)
    begin
        if (POSUnit."No." = '') then
            exit;

        POSUnit.Validate(Status, POSUnit.Status::CLOSED);
        ClosePeriodRegister(POSUnit."No.", ClosingEntryNo);

        POSUnit.Modify();
    end;

    local procedure ClosePeriodRegister(POSUnitNo: Code[10]; ClosingEntryNo: Integer)
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        POSPeriodRegister2: Record "NPR POS Period Register";
    begin
        POSPeriodRegister.SetCurrentKey("POS Unit No.");
        POSPeriodRegister.SetFilter("POS Unit No.", '=%1', POSUnitNo);
        POSPeriodRegister.SetFilter(Status, '<>%1', POSPeriodRegister.Status::CLOSED);

        if (POSPeriodRegister.FindSet()) then begin
            repeat
                POSPeriodRegister2.Get(POSPeriodRegister."No.");
                POSPeriodRegister2.Status := POSPeriodRegister2.Status::CLOSED;
                POSPeriodRegister2."Closing Entry No." := ClosingEntryNo;
                POSPeriodRegister2.Modify();
            until (POSPeriodRegister.Next() = 0)
        end;
    end;


    [Obsolete('Use the ClosePOSUnitOpenPeriods(POSStoreCode, POSUnitNo) function instead.', '2023-06-28')]
    procedure ClosePOSUnitOpenPeriods(POSUnitNo: Code[10])
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if (not POSUnit.Get(POSUnitNo)) then
            POSUnit.Init();

        ClosePOSUnitOpenPeriods(POSUnit."POS Store Code", POSUnitNo);
    end;

    procedure ClosePOSUnitOpenPeriods(POSStoreCode: Code[10]; POSUnitNo: Code[10])
    var
        POSEntry: Record "NPR POS Entry";
        ClosingEntryNo: Integer;
    begin
        POSEntry.SetCurrentKey("POS Store Code", "POS Unit No.");
        POSEntry.SetFilter("POS Store Code", '=%1', POSStoreCode);
        POSEntry.SetFilter("POS Unit No.", '=%1', POSUnitNo);
        if (POSEntry.FindLast()) then
            ClosingEntryNo := POSEntry."Entry No.";

        ClosePeriodRegister(POSUnitNo, ClosingEntryNo);
    end;

    procedure SetOpeningEntryNo(POSUnitNo: Code[10]; OpeningEntryNo: Integer)
    var
        POSPeriodRegister: Record "NPR POS Period Register";
    begin
        POSPeriodRegister.SetCurrentKey("POS Unit No.");
        POSPeriodRegister.SetFilter("POS Unit No.", '=%1', POSUnitNo);
        POSPeriodRegister.SetFilter(Status, '=%1', POSPeriodRegister.Status::OPEN);
        if (POSPeriodRegister.FindLast()) then begin
            POSPeriodRegister."Opening Entry No." := OpeningEntryNo;
            POSPeriodRegister."Opened Date" := CurrentDateTime();
            POSPeriodRegister.Modify();
        end;
    end;

    internal procedure SetEndOfDayPOSUnitNo(POSUnitNo: Code[10]): Boolean
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if (POSUnit.Get(POSUnitNo)) then
            SetEndOfDayPOSUnit(POSUnit);

        exit(POSUnit.Status = POSUnit.Status::EOD);
    end;

    internal procedure SetEndOfDayPOSUnit(var POSUnit: Record "NPR POS Unit")
    begin
        if (POSUnit."No." = '') then
            exit;

        POSUnit.Validate(Status, POSUnit.Status::EOD);
        SetEndOfDayPeriodRegister(POSUnit);

        POSUnit.Modify();
    end;

    local procedure SetEndOfDayPeriodRegister(POSUnit: Record "NPR POS Unit")
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        POSPeriodRegister2: Record "NPR POS Period Register";
    begin
        POSPeriodRegister.SetCurrentKey("POS Unit No.");
        POSPeriodRegister.SetFilter("POS Unit No.", '=%1', POSUnit."No.");
        POSPeriodRegister.SetFilter(Status, '=%1', POSPeriodRegister.Status::OPEN);

        if (POSPeriodRegister.FindSet()) then begin
            repeat
                POSPeriodRegister2.Get(POSPeriodRegister."No.");
                POSPeriodRegister2.Status := POSPeriodRegister2.Status::EOD;
                POSPeriodRegister2."End of Day Date" := CurrentDateTime();
                POSPeriodRegister2.Modify();
            until (POSPeriodRegister.Next() = 0)
        end;
    end;
}
