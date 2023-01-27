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
            }
        }
    }
}