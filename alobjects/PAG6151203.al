page 6151203 "NpCs Document Mapping"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Document Mapping';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NpCs Document Mapping";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("From Store Code"; "From Store Code")
                {
                    ApplicationArea = All;
                }
                field("From No."; "From No.")
                {
                    ApplicationArea = All;
                }
                field("From Description"; "From Description")
                {
                    ApplicationArea = All;
                }
                field("From Description 2"; "From Description 2")
                {
                    ApplicationArea = All;
                }
                field("To No."; "To No.")
                {
                    ApplicationArea = All;
                }
                field("To Description"; "To Description")
                {
                    ApplicationArea = All;
                }
                field("To Description 2"; "To Description 2")
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

