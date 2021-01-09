page 6150659 "NPR POS Posting Log Parameters"
{
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
                ToolTip = 'Specifies the value of the Posting Date field';
            }
            field("Parameter Replace Posting Date"; "Parameter Replace Posting Date")
            {
                ApplicationArea = All;
                Caption = 'Replace Posting Date';
                ToolTip = 'Specifies the value of the Replace Posting Date field';
            }
            field("Parameter Replace Doc. Date"; "Parameter Replace Doc. Date")
            {
                ApplicationArea = All;
                Caption = 'Replace Doc. Date';
                ToolTip = 'Specifies the value of the Replace Doc. Date field';
            }
            field("Parameter Post Item Entries"; "Parameter Post Item Entries")
            {
                ApplicationArea = All;
                Caption = 'Post Item Entries';
                ToolTip = 'Specifies the value of the Post Item Entries field';
            }
            field("Parameter Post POS Entries"; "Parameter Post POS Entries")
            {
                ApplicationArea = All;
                Caption = 'Post POS Entries';
                ToolTip = 'Specifies the value of the Post POS Entries field';
            }
            field("Parameter Post Compressed"; "Parameter Post Compressed")
            {
                ApplicationArea = All;
                Caption = 'Post Compressed';
                ToolTip = 'Specifies the value of the Post Compressed field';
            }
            field("Parameter Stop On Error"; "Parameter Stop On Error")
            {
                ApplicationArea = All;
                Caption = 'Stop On Error';
                ToolTip = 'Specifies the value of the Stop On Error field';
            }
            field("Last POS Entry No. at Posting"; "Last POS Entry No. at Posting")
            {
                ApplicationArea = All;
                Caption = 'Last POS Entry No.';
                ToolTip = 'Specifies the value of the Last POS Entry No. field';
            }
        }
    }

    actions
    {
    }
}

