page 6014481 "NPR Retail Report Select. List"
{
    // NPR5.29/MMV /20161215 CASE 241549 Updated page with same columns as the regular retail report selection page.
    //                                   Made editable.

    Caption = 'Report Type List - Retail';
    PageType = List;
    SourceTable = "NPR Report Selection Retail";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Report Type"; "Report Type")
                {
                    ApplicationArea = All;
                }
                field(Sequence; Sequence)
                {
                    ApplicationArea = All;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Report ID"; "Report ID")
                {
                    ApplicationArea = All;
                }
                field("Report Name"; "Report Name")
                {
                    ApplicationArea = All;
                }
                field("XML Port ID"; "XML Port ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("XML Port Name"; "XML Port Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Codeunit ID"; "Codeunit ID")
                {
                    ApplicationArea = All;
                }
                field("Codeunit Name"; "Codeunit Name")
                {
                    ApplicationArea = All;
                }
                field("Print Template"; "Print Template")
                {
                    ApplicationArea = All;
                    Width = 20;
                }
                field("Filter Object ID"; "Filter Object ID")
                {
                    ApplicationArea = All;
                }
                field("Record Filter"; "Record Filter")
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                }
                field(Optional; Optional)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

