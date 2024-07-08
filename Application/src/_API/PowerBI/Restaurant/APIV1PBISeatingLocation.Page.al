page 6059997 "NPR APIV1 PBISeatingLocation"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'seatingLocation';
    EntitySetName = 'seatingLocations';
    Caption = 'PowerBI Seating Location';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR NPRE Seating Location";
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
                field("code"; Rec.Code)
                {
                    Caption = 'Code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'description', Locked = true;
                }
                field(restaurantCode; Rec."Restaurant Code")
                {
                    Caption = 'Restaurant Code', Locked = true;
                }
                field(posStore; Rec."POS Store")
                {
                    Caption = 'POS Store', Locked = true;
                }
            }
        }
    }
}