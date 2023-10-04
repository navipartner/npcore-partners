page 6150644 "NPR APIV1 PBIItemAttrValue"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'itemAttributeValue';
    EntitySetName = 'itemAttributeValues';
    Caption = 'PowerBI Item Attribute Value';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Item Attribute Value";
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
                field(itemAttributeValueId; Rec.Id)
                {
                    Caption = 'Id', Locked = true;
                }
                field(attributeId; Rec."Attribute ID")
                {
                    Caption = 'Attribute Id', Locked = true;
                }
                field(value; Rec.Value)
                {
                    Caption = 'Value', Locked = true;
                }
                field(numericValue; Rec."Numeric Value")
                {
                    Caption = 'Numeric Value', Locked = true;
                }
                field(dateValue; Rec."Date Value")
                {
                    Caption = 'Date Value', Locked = true;
                }
                Field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
            }
        }
    }
}