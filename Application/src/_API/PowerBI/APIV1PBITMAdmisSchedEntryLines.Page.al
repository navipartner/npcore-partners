page 6150784 "NPR APIV1 PBITMAdmisSchedLines"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'tmAdmiScheduleEntryLines';
    EntitySetName = 'tmAdmiScheduleEntryLines';
    Caption = 'PowerBI TM Admis Schedule Entry Lines';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR TM Admis. Schedule Lines";
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
                    Caption = 'Admission Code';
                }
                field(scheduleCode; Rec."Schedule Code")
                {
                    Caption = 'Schedule Code';
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';
                }
                field(maxCapacityPerSchEntry; Rec."Max Capacity Per Sch. Entry")
                {
                    Caption = 'Max Capacity Per Sch. Entry';
                }
                field(capacityControl; Rec."Capacity Control")
                {
                    Caption = 'Capacity Control';
                }
                field(concurrencyCode; Rec."Concurrency Code")
                {
                    Caption = 'Concurrency Code';
                }
                field(dynamicPriceProfileCode; Rec."Dynamic Price Profile Code")
                {
                    Caption = 'Dynamic Price Profile Code';
                }
                field(admissionBaseCalendarCode; Rec."Admission Base Calendar Code")
                {
                    Caption = 'Admission Base Calendar Code';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
            }
        }
    }
}