page 6060161 "NPR Event Planning Line List"
{
    Caption = 'Event Planning Line List';
    Editable = false;
    PageType = List;
    SourceTable = "Job Planning Line";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Job No."; Rec."Job No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Job No. field';
                }
                field("Job Task No."; Rec."Job Task No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Job Task No. field';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Planning Date"; Rec."Planning Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Planning Date field';
                }
                field("Starting Time"; Rec."NPR Starting Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Starting Time field';
                }
                field("Ending Time"; Rec."NPR Ending Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Ending Time field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("""Calendar Item ID"" <> ''"; Rec."NPR Calendar Item ID" <> '')
                {
                    ApplicationArea = All;
                    Caption = 'Meeting Req. Exists';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Meeting Req. Exists field';
                }
                field("Meeting Request Response"; Rec."NPR Meeting Request Response")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Meeting Request Response field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit Price (LCY)"; Rec."Unit Price (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price (LCY) field';
                }
                field("Line Amount (LCY)"; Rec."Line Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Amount (LCY) field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Card)
                {
                    Caption = 'Card';
                    Image = EditLines;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR Event Card";
                    RunPageLink = "No." = FIELD("Job No.");
                    ShortCutKey = 'Shift+F7';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Card action';
                }
            }
        }
    }
}

