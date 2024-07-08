page 6059965 "NPR APIV1 PBITMAdmission"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'tmAdmission';
    EntitySetName = 'tmAdmissions';
    Caption = 'PowerBI TM Admission';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR TM Admission";
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
                    Caption = 'Admission Code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(type; Rec."Type")
                {
                    Caption = 'Type', Locked = true;
                }
                field(admissionBaseCalendarCode; Rec."Admission Base Calendar Code")
                {
                    Caption = 'Admission Base Calendar Code', Locked = True;
                }
                field(capacityControl; Rec."Capacity Control")
                {
                    Caption = 'Capacity Control', Locked = True;
                }
                field(capacityLimitsBy; Rec."Capacity Limits By")
                {
                    Caption = 'Capacity Limits By', Locked = True;
                }
                field(defaultSchedule; Rec."Default Schedule")
                {
                    Caption = 'Default Schedule', Locked = True;
                }
                field(dependencyCode; Rec."Dependency Code")
                {
                    Caption = 'Dependency Code', Locked = True;
                }

                field(eTicketTypeCode; Rec."eTicket Type Code")
                {
                    Caption = 'eTicket Type Code', Locked = True;
                }
                field(locationAdmissionCode; Rec."Location Admission Code")
                {
                    Caption = 'Location Admission Code', Locked = True;
                }
                field(maxCapacityPerSchEntry; Rec."Max Capacity Per Sch. Entry")
                {
                    Caption = 'Max Capacity Per Sch. Entry';
                }
                field(prebookIsRequired; Rec."Prebook Is Required")
                {
                    Caption = 'Prebook Is Required';
                }
                field(prebookFrom; Rec."Prebook From")
                {
                    Caption = 'Prebook From';
                }
                field(ticketholderNotificationType; Rec."Ticketholder Notification Type")
                {
                    Caption = 'Ticketholder Notification Type';
                }
                field(pOSScheduleSelectionDateF; Rec."POS Schedule Selection Date F.")
                {
                    Caption = 'POS Schedule Selection Date F.';
                }

                field(stakeholderEMailPhoneNo; Rec."Stakeholder (E-Mail/Phone No.)")
                {
                    Caption = 'Stakeholder (E-Mail/Phone No.)';
                }
                field(waitingListSetupCode; Rec."Waiting List Setup Code")
                {
                    Caption = 'Waiting List Setup Code';
                }
                field(ticketBaseCalendarCode; Rec."Ticket Base Calendar Code")
                {
                    Caption = 'Ticket Base Calendar Code';
                }
                field(eventArrivalFromTime; Rec."Event Arrival From Time")
                {
                    Caption = 'Event Arrival From Time';
                }
                field(eventArrivalUntilTime; Rec."Event Arrival Until Time")
                {
                    Caption = 'Event Arrival Until Time';
                }
                field(salesFromDateRel; Rec."Sales From Date (Rel.)")
                {
                    Caption = 'Sales From Date (Rel.)';
                }
                field(salesFromTime; Rec."Sales From Time")
                {
                    Caption = 'Sales From Time';
                }
                field(salesUntilDateRel; Rec."Sales Until Date (Rel.)")
                {
                    Caption = 'Sales Until Date (Rel.)';
                }
                field(salesUntilTime; Rec."Sales Until Time")
                {
                    Caption = 'Sales Until Time';
                }
                field(additionalExperienceItemNo; Rec."Additional Experience Item No.")
                {
                    Caption = 'Additional Experience Item No.';
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'System Created At', Locked = true;
                }
                field(systemCreatedBy; Rec.SystemCreatedBy)
                {
                    Caption = 'System Created By', Locked = true;
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'System Modified At', Locked = true;
                }
                field(systemModifiedBy; Rec.SystemModifiedBy)
                {
                    Caption = 'System Modified By', Locked = true;
                }
                field(categoryCode; Rec.Category)
                {
                    Caption = 'Category Code';
                }

            }
        }
    }
}

