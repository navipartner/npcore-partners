page 6060161 "NPR Event Planning Line List"
{
    Extensible = False;
    Caption = 'Event Planning Line List';
    Editable = false;
    PageType = List;
    SourceTable = "Job Planning Line";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Job No."; Rec."Job No.")
                {

                    ToolTip = 'Specifies the value of the Job No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Job Task No."; Rec."Job Task No.")
                {

                    ToolTip = 'Specifies the value of the Job Task No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Planning Date"; Rec."Planning Date")
                {

                    ToolTip = 'Specifies the value of the Planning Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Time"; Rec."NPR Starting Time")
                {

                    ToolTip = 'Specifies the value of the NPR Starting Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Time"; Rec."NPR Ending Time")
                {

                    ToolTip = 'Specifies the value of the NPR Ending Time field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Meeting Req. Exists"; Rec."NPR Calendar Item ID" <> '')
                {

                    Caption = 'Meeting Req. Exists';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Meeting Req. Exists field';
                    ApplicationArea = NPRRetail;
                }
                field("Meeting Request Response"; Rec."NPR Meeting Request Response")
                {

                    ToolTip = 'Specifies the value of the NPR Meeting Request Response field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price (LCY)"; Rec."Unit Price (LCY)")
                {

                    ToolTip = 'Specifies the value of the Unit Price (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Amount (LCY)"; Rec."Line Amount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Line Amount (LCY) field';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Card action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

