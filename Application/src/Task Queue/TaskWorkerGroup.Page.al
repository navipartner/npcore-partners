page 6059906 "NPR Task Worker Group"
{
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue

    Caption = 'Task Worker Group';
    PageType = List;
    SourceTable = "NPR Task Worker Group";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Language ID"; Rec."Language ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Language ID field';
                }
                field("Abbreviated Name"; Rec."Abbreviated Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Abbreviated Name field';
                }
                field("Min Interval Between Check"; Rec."Min Interval Between Check")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Min Interval Between Check field';
                }
                field("Max Interval Between Check"; Rec."Max Interval Between Check")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max Interval Between Check field';
                }
                field(Default; Rec.Default)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Standard field';
                }
            }
        }
    }

    actions
    {
    }
}

