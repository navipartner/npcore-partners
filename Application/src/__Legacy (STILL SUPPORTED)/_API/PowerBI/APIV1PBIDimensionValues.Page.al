page 6059918 "NPR APIV1 PBIDimensionValues"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'dimensionValue';
    EntitySetName = 'dimensionValues';
    Caption = 'PowerBI Dimension Values';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Dimension Value";
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
                    Caption = 'Code', Locked = true;
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name', Locked = true;
                }
                field(globalDimensionNo; Rec."Global Dimension No.")
                {
                    Caption = 'Global Dimension No.', Locked = true;
                }
                field(dimensionCode; Rec."Dimension Code")
                {
                    Caption = 'Dimension Code', Locked = true;
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