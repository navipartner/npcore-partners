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
                field(lastModifiedDateTime; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt))
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
                field(processOrder; Rec."Process Order")
                {
                    Caption = 'Process Order', Locked = true;
                }
                field(prebookIsRequired; Rec."Prebook Is Required")
                {
                    Caption = 'Prebook Is Required', Locked = true;
                }
                field(prebookFrom; Rec."Prebook From")
                {
                    Caption = 'Prebook From', Locked = true;
                }
                field(scheduleGeneratedUntil; Rec."Schedule Generated Until")
                {
                    Caption = 'Schedule Generated Until', Locked = true;
                }
                field(scheduleGeneratedAt; Rec."Schedule Generated At")
                {
                    Caption = 'Schedule Generated At', Locked = true;
                }
                field(visibilityOnWeb; Rec."Visibility On Web")
                {
                    Caption = 'Visibility On Web', Locked = true;
                }
                field(seatingTemplateCode; Rec."Seating Template Code")
                {
                    Caption = 'Seating Template Code', Locked = true;
                }

                field(eventArrivalFromTime; Rec."Event Arrival From Time")
                {
                    Caption = 'Event Arrival From Time', Locked = true;
                }
                field(eventArrivalUntilTime; Rec."Event Arrival Until Time")
                {
                    Caption = 'Event Arrival Until Time', Locked = true;
                }
                field(salesFromDateRel; Rec."Sales From Date (Rel.)")
                {
                    Caption = 'Sales From Date (Rel.)', Locked = true;
                }
                field(salesFromTime; Rec."Sales From Time")
                {
                    Caption = 'Sales From Time', Locked = true;
                }
                field(salesUntilDateRel; Rec."Sales Until Date (Rel.)")
                {
                    Caption = 'Sales Until Date (Rel.)', Locked = true;
                }
                field(salesUntilTime; Rec."Sales Until Time")
                {
                    Caption = 'Sales Until Time', Locked = true;
                }
                field(scheduledStartTime; Rec."Scheduled Start Time")
                {
                    Caption = 'Scheduled Start Time', Locked = true;
                }
                field(scheduledStopTime; Rec."Scheduled Stop Time")
                {
                    Caption = 'Scheduled Stop Time', Locked = true;
                }
                field(capacityLimitBy; Rec."Capacity Limit By")
                {
                    Caption = 'Capacity Limit By', Locked = true;
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'System Created At', Locked = true;
                }
                field(systemCreatedBy; Rec.SystemCreatedBy)
                {
                    Caption = 'System Created By', Locked = true;
                }
            }
        }
    }

    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
}