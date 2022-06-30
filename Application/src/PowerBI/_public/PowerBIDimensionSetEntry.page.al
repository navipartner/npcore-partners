page 6184604 NPRPowerBIDimensionSet
{
    PageType = list;
    Caption = 'PowerBI Dimension Set Entry';
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Dimension Set Entry";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ToolTip = 'Specifies the value of the Dimension Set ID field.';
                    ApplicationArea = All;
                }
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ToolTip = 'Specifies the dimension.';
                    ApplicationArea = All;
                }
                field("Dimension Value Code"; Rec."Dimension Value Code")
                {
                    ToolTip = 'Specifies the dimension value.';
                    ApplicationArea = All;
                }
                field("Dimension Value ID"; Rec."Dimension Value ID")
                {
                    ToolTip = 'Specifies the value of the Dimension Value ID field.';
                    ApplicationArea = All;
                }
            }
        }
    }

}