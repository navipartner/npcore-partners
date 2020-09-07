page 6151167 "NPR NpGp POS Sales Entries"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'Global POS Sales Entries';
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpGp POS Sales Entry";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store Code"; "POS Store Code")
                {
                    ApplicationArea = All;
                }
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Fiscal No."; "Fiscal No.")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Currency Factor"; "Currency Factor")
                {
                    ApplicationArea = All;
                }
                field("Sales Amount"; "Sales Amount")
                {
                    ApplicationArea = All;
                }
                field("Discount Amount"; "Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("Sales Quantity"; "Sales Quantity")
                {
                    ApplicationArea = All;
                }
                field("Return Sales Quantity"; "Return Sales Quantity")
                {
                    ApplicationArea = All;
                }
                field("Total Amount"; "Total Amount")
                {
                    ApplicationArea = All;
                }
                field("Total Tax Amount"; "Total Tax Amount")
                {
                    ApplicationArea = All;
                }
                field("Total Amount Incl. Tax"; "Total Amount Incl. Tax")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Entry Time"; "Entry Time")
                {
                    ApplicationArea = All;
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                }
                field("Retail ID"; "Retail ID")
                {
                    ApplicationArea = All;
                }
            }
            part("POS Sales Lines"; "NPR NpGp POSSalesEntry Subpage")
            {
                Caption = 'POS Sales Lines';
                SubPageLink = "POS Entry No." = FIELD("Entry No.");
                ApplicationArea=All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("POS Info")
            {
                Caption = 'POS Info';
                Image = List;
                RunObject = Page "NPR NpGp POS Info POS Entry";
                ApplicationArea=All;
                //RunPageLink = "POS Entry No."=FIELD("Entry No.");
            }
        }
    }
}

