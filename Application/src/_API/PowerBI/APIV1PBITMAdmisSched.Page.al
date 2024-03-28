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
                field(eventDuration; Rec."Event Duration")
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
                field(regenerateWith; Rec."Regenerate With")
                {
                    Caption = 'Regenerate With', Locked = true;
                }
                field(visibilityonWeb; Rec."Visibility On Web")
                {
                    Caption = 'Visibility On Web', Locked = true;
                }
                field(dynamicPriceProfileCode; Rec."Dynamic Price Profile Code")
                {
                    Caption = 'Dynamic Price Profile Code', Locked = true;
                }
                field(openReservations; Rec."Open Reservations")
                {
                    Caption = 'Open Reservations', Locked = true;
                }
                field(openAdmitted; Rec."Open Admitted")
                {
                    Caption = 'Open Admitted', Locked = true;
                }
                field(departed; Rec.Departed)
                {
                    Caption = 'Departed', Locked = true;
                }
                field(initialEntry; Rec."Initial Entry")
                {
                    Caption = 'Initial Entry', Locked = true;
                }
                field(initialEntryAll; Rec."Initial Entry (All)")
                {
                    Caption = 'Initial Entry (All)', Locked = true;
                }
                field(openReservationsAll; Rec."Open Reservations (All)")
                {
                    Caption = 'Open Reservations (All)', Locked = true;
                }
                field(salesChannelFilter; Rec."Sales Channel Filter")
                {
                    Caption = 'Sales Channel Filter', Locked = true;
                }
                field(eventArrivalFromTime; Rec."Event Arrival From Time")
                {
                    Caption = 'Event Arrival From Time', Locked = true;
                }
                field(eventArrivalUntilTime; Rec."Event Arrival Until Time")
                {
                    Caption = 'Event Arrival Until Time', Locked = true;
                }
                field(salesFromDate; Rec."Sales From Date")
                {
                    Caption = 'Sales From Date', Locked = true;
                }
                field(salesFromTime; Rec."Sales From Time")
                {
                    Caption = 'Sales From Time', Locked = true;
                }
                field(salesUntilDate; Rec."Sales Until Date")
                {
                    Caption = 'Sales Until Date', Locked = true;
                }
                field(salesUntilTime; Rec."Sales Until Time")
                {
                    Caption = 'Sales Until Time', Locked = true;
                }
                field(waitingListQueue; Rec."Waiting List Queue")
                {
                    Caption = 'Waiting List Queue', Locked = true;
                }

            }
        }
    }


    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
}