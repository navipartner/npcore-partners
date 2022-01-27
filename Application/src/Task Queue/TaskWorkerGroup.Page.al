page 6059906 "NPR Task Worker Group"
{
    Extensible = False;
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue

    Caption = 'Task Worker Group';
    PageType = List;
    SourceTable = "NPR Task Worker Group";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Language ID"; Rec."Language ID")
                {

                    ToolTip = 'Specifies the value of the Language ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Abbreviated Name"; Rec."Abbreviated Name")
                {

                    ToolTip = 'Specifies the value of the Abbreviated Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Min Interval Between Check"; Rec."Min Interval Between Check")
                {

                    ToolTip = 'Specifies the value of the Min Interval Between Check field';
                    ApplicationArea = NPRRetail;
                }
                field("Max Interval Between Check"; Rec."Max Interval Between Check")
                {

                    ToolTip = 'Specifies the value of the Max Interval Between Check field';
                    ApplicationArea = NPRRetail;
                }
                field(Default; Rec.Default)
                {

                    ToolTip = 'Specifies the value of the Standard field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

