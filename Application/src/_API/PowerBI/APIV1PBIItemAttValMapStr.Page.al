page 6150698 "NPR APIV1 PBIItemAttValMapStr"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'itemAttributeValueMappingStructure';
    EntitySetName = 'itemAttributeValueMappingStructures';
    Caption = 'PowerBI Item Attribute Value Mapping Structure';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Item Attribute Value Mapping";
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
                field(tableId; Rec."Table ID")
                {
                    Caption = 'Table Id', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }
                field(itemAttributeId; Rec."Item Attribute ID")
                {
                    caption = 'Item Attribute Id', Locked = true;
                }
                field(itemAttributeValueId; Rec."Item Attribute Value ID")
                {
                    caption = 'Item Attribute Value Id', Locked = true;
                }
                part(ItemAttribute; "NPR APIV1 PBIItemAttribute")
                {
                    Caption = 'Item Attribute', Locked = true;
                    EntityName = 'itemAttribute';
                    EntitySetName = 'itemAttributes';
                    SubPageLink = ID = field("Item Attribute ID");
                }
                part(ItemAttributeValue; "NPR APIV1 PBIItemAttrValue")
                {
                    Caption = 'Item Attribute Value', Locked = true;
                    EntityName = 'itemAttributeValue';
                    EntitySetName = 'itemAttributeValues';
                    SubPageLink = "Attribute ID" = field("Item Attribute ID"), ID = field("Item Attribute Value ID");
                }
                field(lastModifiedDateTime; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt))
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        CurrRecordRef: RecordRef;
    begin
        CurrRecordRef.GetTable(Rec);
        PowerBIUtils.UpdateSystemModifiedAtfilter(CurrRecordRef);
    end;

    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
}