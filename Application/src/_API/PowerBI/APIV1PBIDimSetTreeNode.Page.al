page 6059917 "NPR APIV1 PBIDimSetTreeNode"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'dimensionsSetTreeNode';
    EntitySetName = 'dimensionsSetTreeNodes';
    Caption = ' PowerBI Dimension Set Tree Node';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Dimension Set Tree Node";
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
                field(parentDimensionSetID; Rec."Parent Dimension Set ID")
                {
                    Caption = 'Parent Dimension Set ID', Locked = true;
                }
                field(dimensionSetID; Rec."Dimension Set ID")
                {
                    Caption = 'Dimension Set ID', Locked = true;
                }
                field(dimensionValueID; Rec."Dimension Value ID")
                {
                    Caption = 'Dimension Value ID', Locked = true;
                }
                field(inUse; Rec."In Use")
                {
                    Caption = 'In Use', Locked = true;
                }

            }
        }

    }


}