page 6150787 "NPR APIV1 PBITicketType"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'ticketType';
    EntitySetName = 'ticketsType';
    Caption = 'PowerBI Ticket Type';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR TM Ticket Type";
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
                field("code"; Rec."Code")
                {
                    Caption = 'Code';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(externalTicketPattern; Rec."External Ticket Pattern")
                {
                    Caption = 'External Ticket Pattern';
                }
                field(maxNoOfEntries; Rec."Max No. Of Entries")
                {
                    Caption = 'Max No. Of Entries';
                }
            }
        }
    }
}