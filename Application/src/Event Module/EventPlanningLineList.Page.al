page 6060161 "NPR Event Planning Line List"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017

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
                field("Job No."; "Job No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Job No. field';
                }
                field("Job Task No."; "Job Task No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Job Task No. field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Planning Date"; "Planning Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Planning Date field';
                }
                field("Starting Time"; "NPR Starting Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Starting Time field';
                }
                field("Ending Time"; "NPR Ending Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Ending Time field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("""Calendar Item ID"" <> ''"; "NPR Calendar Item ID" <> '')
                {
                    ApplicationArea = All;
                    Caption = 'Meeting Req. Exists';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Meeting Req. Exists field';
                }
                field("Meeting Request Response"; "NPR Meeting Request Response")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Meeting Request Response field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit Price (LCY)"; "Unit Price (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price (LCY) field';
                }
                field("Line Amount (LCY)"; "Line Amount (LCY)")
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

