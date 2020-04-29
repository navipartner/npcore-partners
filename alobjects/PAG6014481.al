page 6014481 "Retail Report Selection List"
{
    // NPR5.29/MMV /20161215 CASE 241549 Updated page with same columns as the regular retail report selection page.
    //                                   Made editable.

    Caption = 'Report Type List - Retail';
    PageType = List;
    SourceTable = "Report Selection Retail";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Report Type";"Report Type")
                {
                }
                field(Sequence;Sequence)
                {
                }
                field("Register No.";"Register No.")
                {
                }
                field("Report ID";"Report ID")
                {
                }
                field("Report Name";"Report Name")
                {
                }
                field("XML Port ID";"XML Port ID")
                {
                    Visible = false;
                }
                field("XML Port Name";"XML Port Name")
                {
                    Visible = false;
                }
                field("Codeunit ID";"Codeunit ID")
                {
                }
                field("Codeunit Name";"Codeunit Name")
                {
                }
                field("Print Template";"Print Template")
                {
                    Width = 20;
                }
                field("Filter Object ID";"Filter Object ID")
                {
                }
                field("Record Filter";"Record Filter")
                {
                    AssistEdit = true;
                }
                field(Optional;Optional)
                {
                }
            }
        }
    }

    actions
    {
    }
}

