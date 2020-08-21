page 6150744 "Archive POS Sale"
{
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale
    // NPR5.55/ALPO/20200423 CASE 401611 5.54 upgrade performace optimization: removed field "POS Sales Data" and related functions

    Caption = 'Archive POS Sale';
    Editable = false;
    PageType = Document;
    SourceTable = "Archive Sale POS";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field(Date; Date)
                {
                    ApplicationArea = All;
                }
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                }
                field("Payment Amount"; "Payment Amount")
                {
                    ApplicationArea = All;
                }
                field("POS Sale ID"; "POS Sale ID")
                {
                    ApplicationArea = All;
                }
                field("Retail ID"; "Retail ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
            part(SaleLines; "Archive POS Sale Lines Subpage")
            {
                Caption = 'POS Sale Lines';
                SubPageLink = "Register No." = FIELD("Register No."),
                              "Sales Ticket No." = FIELD("Sales Ticket No.");
            }
        }
        area(factboxes)
        {
            systempart(Control6014414; Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

