page 6150744 "NPR Archive POS Sale"
{
    Extensible = False;
    Caption = 'Archive POS Sale';
    Editable = false;
    PageType = Document;
    UsageCategory = Administration;

    SourceTable = "NPR Archive Sale POS";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {

                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Date"; Rec.Date)
                {

                    ToolTip = 'Specifies the value of the Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Start Time"; Rec."Start Time")
                {

                    ToolTip = 'Specifies the value of the Start Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Name"; Rec."Customer Name")
                {

                    ToolTip = 'Specifies the value of the Customer Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {

                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Amount"; Rec."Payment Amount")
                {

                    ToolTip = 'Specifies the value of the Payment Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Sale ID"; Rec."POS Sale ID")
                {

                    ToolTip = 'Specifies the value of the POS Sale ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Retail ID"; Rec."Retail ID")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Retail ID field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(SaleLines; "NPR Arch. POS S. Lines Subpage")
            {
                Caption = 'POS Sale Lines';
                SubPageLink = "Register No." = FIELD("Register No."),
                              "Sales Ticket No." = FIELD("Sales Ticket No.");
                ApplicationArea = NPRRetail;

            }
        }
        area(factboxes)
        {
            systempart(Control6014414; Notes)
            {
                Visible = false;
                ApplicationArea = NPRRetail;

            }
        }
    }
}

