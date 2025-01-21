page 6184932 "NPR APIV1 PBI POS Store Group"
{
    Editable = false;
    Extensible = false;
    PageType = API;
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    EntityName = 'posStoreGroup';
    EntitySetName = 'posStoreGroups';
    DataAccessIntent = ReadOnly;
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "NPR POS Store Group";

    layout
    {
        area(Content)
        {
            repeater(GroupsRepeater)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                }
                field(groupCode; Rec."No.")
                {
                    Caption = 'Group Code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                part(posStoreGroupLines; "NPR APIV1 PBI POSStoreGrpLines")
                {
                    SubPageLink = "No." = field("No.");
                }
            }
        }
    }
}