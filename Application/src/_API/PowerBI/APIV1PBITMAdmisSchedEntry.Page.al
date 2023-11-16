page 6150783 "NPR APIV1 PBITMAdmisSched"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'tmAdmiScheduleEntry';
    EntitySetName = 'tmAdmiScheduleEntry';
    Caption = 'PowerBI TM Admission';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR TM Admis. Schedule Entry";
    Extensible = false;
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(admissionCode; Rec."Admission Code")
                {
                    Caption = 'Admission Code', Locked = True;
                }
                field(admissionEndDate; Rec."Admission End Date")
                {
                    Caption = 'Admission End Date', Locked = True;
                }
                field(admissionEndTime; Rec."Admission End Time")
                {
                    Caption = 'Admission End Time', Locked = True;
                }
                field(admissionIs; Rec."Admission Is")
                {
                    Caption = 'Admission Is', Locked = True;
                }
                field(admissionStartDate; Rec."Admission Start Date")
                {
                    Caption = 'Admission Start Date', Locked = True;
                }
                field(admissionStartTime; Rec."Admission Start Time")
                {
                    Caption = 'Admission Start Time', Locked = True;
                }
                field(allocationBy; Rec."Allocation By")
                {
                    Caption = 'Allocation By', Locked = True;
                }
                field(cancelled; Rec."Cancelled")
                {
                    Caption = 'Cancelled', Locked = True;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = True;
                }
                field(externalScheduleEntryNo; Rec."External Schedule Entry No.")
                {
                    Caption = 'External Schedule Entry No.', Locked = True;
                }
                field(maxCapacityPerSchEntry; Rec."Max Capacity Per Sch. Entry")
                {
                    Caption = 'Max Capacity Per Sch. Entry', Locked = True;
                }
                field(reasonCode; Rec."Reason Code")
                {
                    Caption = 'Reason Code', Locked = True;
                }
                field(scheduleCode; Rec."Schedule Code")
                {
                    Caption = 'Schedule Code', Locked = True;
                }
                field(lastModifiedDateTime; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt))
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        CurrRecordRef: RecordRef;
    begin
        CurrRecordRef.GetTable(Rec);
        PowerBIUtils.UpdateSystemModifiedAtfilter(CurrRecordRef);
    end;

    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
}