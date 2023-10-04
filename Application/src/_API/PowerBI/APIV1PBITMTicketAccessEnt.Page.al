page 6059968 "NPR APIV1 PBITMTicketAccessEnt"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'tmTicketAccess';
    EntitySetName = 'tmTicketAccesses';
    Caption = 'PowerBI TM Ticket Access Entry';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR TM Ticket Access Entry";
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
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity', Locked = true;
                }
                field(ticketNo; Rec."Ticket No.")
                {
                    Caption = 'Ticket No.', Locked = true;
                }
                field(ticketTypeCode; Rec."Ticket Type Code")
                {
                    Caption = 'Ticket Type Code', Locked = true;
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.', Locked = true;
                }
                field(accessDate; Rec."Access Date")
                {
                    Caption = 'Access Date', Locked = True;
                }
                field(accessTime; Rec."Access Time")
                {
                    Caption = 'Access Time', Locked = True;
                }
                field(memberCardCode; Rec."Member Card Code")
                {
                    Caption = 'Member Card Code', Locked = True;
                }
                field(status; Rec."Status")
                {
                    Caption = 'Status', Locked = True;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
            }
        }
    }
}