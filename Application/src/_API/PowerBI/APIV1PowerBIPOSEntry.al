page 6059935 NPRPBIPOSEntry
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'posEntry';
    EntitySetName = 'posEntries';
    Caption = 'PowerBI POS Entry';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR POS entry";
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
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(entryType; Rec."Entry Type")
                {
                    Caption = 'Entry Type', Locked = true;
                }
                field(eventNo; Rec."Event No.")
                {
                    Caption = 'Event No.', Locked = true;
                }
            }
        }
    }

}