page 6059916 "NPR APIV1 PBIDimensionSet"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'dimensionsSetEntry';
    EntitySetName = 'dimensionsSetEntries';
    Caption = 'PowerBI Dimensions Set Entry';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Dimension Set Entry";
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
                field(dimensionSetID; Rec."Dimension Set ID")
                {
                    Caption = 'Dimension Set ID', Locked = true;
                }
                field(dimensionCode; Rec."Dimension Code")
                {
                    Caption = 'Dimension Code', Locked = true;
                }
                field(dimensionValueCode; Rec."Dimension Value Code")
                {
                    Caption = 'Dimension Value Code', Locked = true;
                }
                field(dimensionValueID; Rec."Dimension Value ID")
                {
                    Caption = 'Dimension Value ID', Locked = true;
                }
#if not (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'System Row Version', Locked = true;
                }
#endif
            }
        }
    }
}