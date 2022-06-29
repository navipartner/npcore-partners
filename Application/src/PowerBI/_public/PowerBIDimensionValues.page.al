page 6184607 NPRPowerBIDimensionValues
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Dimension Value";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the code for the dimension value.';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies a descriptive name for the dimension value.';
                    ApplicationArea = All;
                }
                field("Global Dimension No."; Rec."Global Dimension No.")
                {
                    ToolTip = 'Specifies the value of the Global Dimension No. field.';
                    ApplicationArea = All;
                }
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ToolTip = 'Specifies the value of the Dimension Code field.';
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