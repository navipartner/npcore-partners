codeunit 6151365 "NPR TM TicketToDataLog"
{
    Access = Internal;

    var
        _DataLogMgt: Codeunit "NPR Data Log Management";

    procedure DeepRefreshItem(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Admission: Record "NPR TM Admission";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Schedule: Record "NPR TM Admis. Schedule";
        AdmissionScheduleLine: Record "NPR TM Admis. Schedule Lines";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        if (not Item.Get(ItemNo)) then
            exit(false);
        Refresh(Item);

        ItemVariant.SetFilter("Item No.", '=%1', Item."No.");
        if (ItemVariant.FindSet()) then begin
            repeat
                Refresh(ItemVariant);
            until (ItemVariant.Next() = 0);
        end;

        TicketBom.SetFilter("Item No.", '=%1', Item."No.");
        if (TicketBom.FindSet()) then begin
            repeat
                Refresh(TicketBom);
                if (Admission.Get(TicketBom."Admission Code")) then
                    Refresh(Admission);

                AdmissionScheduleLine.SetFilter("Admission Code", '=%1', TicketBom."Admission Code");
                if (AdmissionScheduleLine.FindSet()) then begin
                    repeat
                        if (Schedule.Get(AdmissionScheduleLine."Schedule Code")) then
                            Refresh(Schedule);
                        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionScheduleLine."Admission Code");
                        AdmissionScheduleEntry.SetFilter("Schedule Code", '=%1', AdmissionScheduleLine."Schedule Code");
                        AdmissionScheduleEntry.SetFilter("Admission Start Date", '>=%1', Today());
                        if (AdmissionScheduleEntry.FindSet()) then begin
                            repeat
                                Refresh(AdmissionScheduleEntry);
                            until (AdmissionScheduleEntry.Next() = 0);
                        end;
                    until (AdmissionScheduleLine.Next() = 0);
                end;
            until (TicketBom.Next() = 0);
        end;

        exit(true);
    end;


    internal procedure Refresh(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(AdmissionScheduleEntry);
        _DataLogMgt.LogDatabaseInsert(RecRef);
    end;

    internal procedure Refresh(Schedule: Record "NPR TM Admis. Schedule")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Schedule);
        _DataLogMgt.LogDatabaseInsert(RecRef);
    end;

    internal procedure Refresh(Admission: Record "NPR TM Admission")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Admission);
        _DataLogMgt.LogDatabaseInsert(RecRef);
    end;

    internal procedure Refresh(TicketBom: Record "NPR TM Ticket Admission BOM")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TicketBom);
        _DataLogMgt.LogDatabaseInsert(RecRef);
    end;

    internal procedure Refresh(Item: Record Item)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Item);
        _DataLogMgt.LogDatabaseInsert(RecRef);
    end;

    internal procedure Refresh(ItemVariant: Record "Item Variant")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ItemVariant);
        _DataLogMgt.LogDatabaseInsert(RecRef);
    end;

}