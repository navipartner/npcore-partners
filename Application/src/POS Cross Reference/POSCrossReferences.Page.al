page 6059811 "NPR POS Cross References"
{
    Caption = 'POS Cross References';
    PageType = List;
    SourceTable = "NPR POS Cross Reference";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference No. field';
                }
                field("Record Value"; Rec."Record Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Record Value field';
                }
            }
        }
    }
}

