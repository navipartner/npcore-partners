page 6060084 "NPR MCS Recommendations Log"
{
    // NPR5.30/BR  /20170220  CASE 252646 Object Created

    Caption = 'MCS Recommendations Log';
    Editable = false;
    PageType = List;
    SourceTable = "NPR MCS Recommendations Log";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Start Date Time"; "Start Date Time")
                {
                    ApplicationArea = All;
                }
                field("End Date Time"; "End Date Time")
                {
                    ApplicationArea = All;
                }
                field(Response; Response)
                {
                    ApplicationArea = All;
                }
                field(Success; Success)
                {
                    ApplicationArea = All;
                }
                field("Model No."; "Model No.")
                {
                    ApplicationArea = All;
                }
                field("Seed Item No."; "Seed Item No.")
                {
                    ApplicationArea = All;
                }
                field("Selected Item"; "Selected Item")
                {
                    ApplicationArea = All;
                }
                field("Selected Rating"; "Selected Rating")
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
            action("Recommended Items")
            {
                Caption = 'Recommended Items';
                Image = SuggestLines;
                RunObject = Page "NPR MCS Recomm. Lines";
                RunPageLink = "Log Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
            }
        }
    }
}

