page 6059990 "NPR APIV1 PBIDefaultDim"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'defaultDimension';
    EntitySetName = 'defaultDimensions';
    Caption = 'PowerBI Default Dimensions';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Default Dimension";
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
                    Caption = 'Table ID', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }
                field(dimensionCode; Rec."Dimension Code")
                {
                    Caption = 'Dimension Code', Locked = true;
                }
                field(dimensionValueCode; Rec."Dimension Value Code")
                {
                    Caption = 'Dimension Value Code', Locked = true;
                }
                field(parentId; Rec.ParentId)
                {
                    Caption = 'Parent Id', Locked = true;
                }
                field(dimensionId; Rec.DimensionId)
                {
                    Caption = 'Dimension Id', Locked = true;
                }
                field(dimensionValueId; Rec.DimensionValueId)
                {
                    Caption = 'Dimension Value Id', Locked = true;
                }
            }
        }
    }
}