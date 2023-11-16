codeunit 6184627 "NPR PowerBI Utils"
{
    Access = Internal;

    internal procedure GetSystemModifedAt(ModifiedAt: DateTime): DateTime
    begin
        if ModifiedAt < CreateDateTime(19800101D, 0T) then
            exit(CreateDateTime(19800101D, 0T));
        exit(ModifiedAt);
    end;

    internal procedure UpdateSystemModifiedAtfilter(var RecordRef: RecordRef)
    var
        DateRecord: Record Date;
        SystemModifiedAtFieldRef: FieldRef;
        StartDate: Date;
        EndDate: Date;
        DateFrontier: Date;
        EndDateTime: DateTime;
        StartDateTime: DateTime;
        SystemModifiedAtFilterText: Text;
    begin
        SystemModifiedAtFieldRef := RecordRef.Field(RecordRef.SystemModifiedAtNo());
        SystemModifiedAtFilterText := SystemModifiedAtFieldRef.GetFilter();
        if SystemModifiedAtFilterText = '' then
            exit;

        DateRecord.Reset();
        DateRecord.SetRange("Period Type", DateRecord."Period Type"::Date);
        DateRecord.SetFilter("Period Start", SystemModifiedAtFilterText);
        if not DateRecord.FindLast() then
            exit;

        EndDate := DateRecord."Period End";
        EndDateTime := CreateDateTime(EndDate, 0T);
        if not DateRecord.FindFirst() then
            exit;

        StartDate := DateRecord."Period Start";
        if StartDate = EndDate then
            exit;

        DateFrontier := CalcDate('<-20Y>', Today);
        if StartDate > DateFrontier then
            exit;

        DateRecord.SetRange("Period Start");
        if DateRecord.FindFirst() then
            StartDate := DateRecord."Period Start";

        StartDateTime := CreateDateTime(StartDate, 0T);
        SystemModifiedAtFieldRef.SetRange(StartDateTime, EndDateTime);
    end;
}
