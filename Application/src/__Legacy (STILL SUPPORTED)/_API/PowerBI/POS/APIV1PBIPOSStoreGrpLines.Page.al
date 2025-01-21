page 6184933 "NPR APIV1 PBI POSStoreGrpLines"
{
    Extensible = false;
    Editable = false;
    PageType = API;
    APIPublisher = 'navipartner';
    APIGroup = 'powerBI';
    APIVersion = 'v1.0';
    EntityName = 'posStoreGroupLine';
    EntitySetName = 'posStoreGroupLines';
    DataAccessIntent = ReadOnly;
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "NPR POS Store Group Line";

    layout
    {
        area(Content)
        {
            repeater(LinesRepeater)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                }
                field(groupCode; Rec."No.")
                {
                    Caption = 'Group Code', Locked = true;
                }
                field(posStore; Rec."POS Store")
                {
                    Caption = 'POS Store', Locked = true;
                }
            }
        }
    }
}