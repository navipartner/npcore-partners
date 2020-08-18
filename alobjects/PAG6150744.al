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
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                }
                field(Date; Date)
                {
                }
                field("Start Time"; "Start Time")
                {
                }
                field("Customer No."; "Customer No.")
                {
                }
                field(Name; Name)
                {
                    Visible = false;
                }
                field("Customer Name"; "Customer Name")
                {
                }
                field("Location Code"; "Location Code")
                {
                }
                field(Amount; Amount)
                {
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                }
                field("Payment Amount"; "Payment Amount")
                {
                }
                field("POS Sale ID"; "POS Sale ID")
                {
                }
                field("Retail ID"; "Retail ID")
                {
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

