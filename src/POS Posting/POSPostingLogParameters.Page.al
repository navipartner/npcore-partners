page 6150659 "NPR POS Posting Log Parameters"
{
    // NPR5.36/BR  /20170814  CASE  277096 Object created

    Caption = 'POS Posting Log Parameters';
    Editable = false;
    PageType = CardPart;
    UsageCategory = Administration;
    SourceTable = "NPR POS Posting Log";

    layout
    {
        area(content)
        {
            field("Parameter Posting Date"; "Parameter Posting Date")
            {
                ApplicationArea = All;
                Caption = 'Posting Date';
            }
            field("Parameter Replace Posting Date"; "Parameter Replace Posting Date")
            {
                ApplicationArea = All;
                Caption = 'Replace Posting Date';
            }
            field("Parameter Replace Doc. Date"; "Parameter Replace Doc. Date")
            {
                ApplicationArea = All;
                Caption = 'Replace Doc. Date';
            }
            field("Parameter Post Item Entries"; "Parameter Post Item Entries")
            {
                ApplicationArea = All;
                Caption = 'Post Item Entries';
            }
            field("Parameter Post POS Entries"; "Parameter Post POS Entries")
            {
                ApplicationArea = All;
                Caption = 'Post POS Entries';
            }
            field("Parameter Post Compressed"; "Parameter Post Compressed")
            {
                ApplicationArea = All;
                Caption = 'Post Compressed';
            }
            field("Parameter Stop On Error"; "Parameter Stop On Error")
            {
                ApplicationArea = All;
                Caption = 'Stop On Error';
            }
            field("Last POS Entry No. at Posting"; "Last POS Entry No. at Posting")
            {
                ApplicationArea = All;
                Caption = 'Last POS Entry No.';
            }
        }
    }

    actions
    {
    }
}

