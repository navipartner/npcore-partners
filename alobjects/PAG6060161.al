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
                field("Job No.";"Job No.")
                {
                }
                field("Job Task No.";"Job Task No.")
                {
                }
                field("Line No.";"Line No.")
                {
                }
                field("Planning Date";"Planning Date")
                {
                }
                field("Starting Time";"Starting Time")
                {
                }
                field("Ending Time";"Ending Time")
                {
                }
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field("""Calendar Item ID"" <> ''";"Calendar Item ID" <> '')
                {
                    Caption = 'Meeting Req. Exists';
                    Editable = false;
                }
                field("Meeting Request Response";"Meeting Request Response")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Unit Price (LCY)";"Unit Price (LCY)")
                {
                }
                field("Line Amount (LCY)";"Line Amount (LCY)")
                {
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
                    RunPageLink = "No."=FIELD("Job No.");
                    ShortCutKey = 'Shift+F7';
                }
            }
        }
    }
}

