page 6060161 "Event Planning Line List"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017

    Caption = 'Event Planning Line List';
    Editable = false;
    PageType = List;
    SourceTable = "Job Planning Line";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Job No."; "Job No.")
                {
                    ApplicationArea = All;
                }
                field("Job Task No."; "Job Task No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                }
                field("Planning Date"; "Planning Date")
                {
                    ApplicationArea = All;
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                }
                field("Ending Time"; "Ending Time")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("""Calendar Item ID"" <> ''"; "Calendar Item ID" <> '')
                {
                    ApplicationArea = All;
                    Caption = 'Meeting Req. Exists';
                    Editable = false;
                }
                field("Meeting Request Response"; "Meeting Request Response")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit Price (LCY)"; "Unit Price (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Line Amount (LCY)"; "Line Amount (LCY)")
                {
                    ApplicationArea = All;
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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Event Card";
                    RunPageLink = "No." = FIELD("Job No.");
                    ShortCutKey = 'Shift+F7';
                }
            }
        }
    }
}

