page 6060084 "MCS Recommendations Log"
{
    // NPR5.30/BR  /20170220  CASE 252646 Object Created

    Caption = 'MCS Recommendations Log';
    Editable = false;
    PageType = List;
    SourceTable = "MCS Recommendations Log";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field(Type;Type)
                {
                }
                field("Start Date Time";"Start Date Time")
                {
                }
                field("End Date Time";"End Date Time")
                {
                }
                field(Response;Response)
                {
                }
                field(Success;Success)
                {
                }
                field("Model No.";"Model No.")
                {
                }
                field("Seed Item No.";"Seed Item No.")
                {
                }
                field("Selected Item";"Selected Item")
                {
                }
                field("Selected Rating";"Selected Rating")
                {
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
                RunObject = Page "MCS Recommendations Lines";
                RunPageLink = "Log Entry No."=FIELD("Entry No.");
            }
        }
    }
}

