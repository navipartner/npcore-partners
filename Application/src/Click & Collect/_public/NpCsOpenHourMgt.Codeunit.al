codeunit 6059902 "NPR NpCs Open. Hour Mgt."
{
    procedure DeleteOpeningHourEntriesForStore(NpCsStore: Record "NPR NpCs Store")
    var
        NpCsOpeningHourSet: Record "NPR NpCs Open. Hour Set";
        NpCsOpeningHourEntry: Record "NPR NpCs Open. Hour Entry";
    begin
        NpCsStore.TestField(Code);

        NpCsOpeningHourSet.Get(NpCsStore."Opening Hour Set");

        NpCsOpeningHourEntry.SetRange("Set Code", NpCsOpeningHourSet.Code);
        if not NpCsOpeningHourEntry.IsEmpty() then
            NpCsOpeningHourEntry.DeleteAll();
    end;

    procedure InsertOpeningHourEntry(SetCode: Code[20]; InputDate: Date; StartTime: Time; EndTime: Time)
    var
        NpCsOpeningHourEntry: Record "NPR NpCs Open. Hour Entry";
        OldNpCsOpeningHourEntry: Record "NPR NpCs Open. Hour Entry";
    begin
        OldNpCsOpeningHourEntry.SetRange("Set Code", SetCode);
        OldNpCsOpeningHourEntry.SetRange("Period Type", OldNpCsOpeningHourEntry."Period Type"::Date);
        OldNpCsOpeningHourEntry.SetRange("Entry Date", InputDate);
        if not OldNpCsOpeningHourEntry.IsEmpty() then
            OldNpCsOpeningHourEntry.DeleteAll();

        NpCsOpeningHourEntry.Init();
        NpCsOpeningHourEntry."Set Code" := SetCode;
        NpCsOpeningHourEntry."Line No." := GetNextNpCsOpeningHourEntryLineNo(SetCode);
        NpCsOpeningHourEntry.Validate("Entry Type", NpCsOpeningHourEntry."Entry Type"::"Store Open");
        NpCsOpeningHourEntry.Validate("Period Type", NpCsOpeningHourEntry."Period Type"::Date);
        NpCsOpeningHourEntry.Validate("Entry Date", InputDate);
        NpCsOpeningHourEntry.Validate("Start Time", StartTime);
        NpCsOpeningHourEntry.Validate("End Time", EndTime);
        NpCsOpeningHourEntry.Insert(true);
    end;

    local procedure GetNextNpCsOpeningHourEntryLineNo(SetCode: Code[20]): Integer
    var
        NpCsOpeningHourEntry: Record "NPR NpCs Open. Hour Entry";
    begin
        NpCsOpeningHourEntry.LockTable();
        NpCsOpeningHourEntry.SetRange("Set Code", SetCode);
        if NpCsOpeningHourEntry.FindLast() then
            exit(NpCsOpeningHourEntry."Line No." + 10000);
        exit(10000);
    end;
}