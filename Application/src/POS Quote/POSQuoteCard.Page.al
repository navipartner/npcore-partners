page 6151003 "NPR POS Quote Card"
{
    Caption = 'POS Quote Card';
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "NPR POS Quote Entry";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014411)
                {
                    ShowCaption = false;
                    field("Sales Ticket No."; "Sales Ticket No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Register No."; "Register No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Entry No."; "Entry No.")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Created at"; "Created at")
                    {
                        ApplicationArea = All;
                    }
                    field("Salesperson Code"; "Salesperson Code")
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
                    field("Contains EFT Approval"; "Contains EFT Approval")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6014409)
                {
                    ShowCaption = false;
                    field("Customer Type"; "Customer Type")
                    {
                        ApplicationArea = All;
                    }
                    field("Customer No."; "Customer No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Customer Price Group"; "Customer Price Group")
                    {
                        ApplicationArea = All;
                    }
                    field("Customer Disc. Group"; "Customer Disc. Group")
                    {
                        ApplicationArea = All;
                    }
                    field(Attention; Attention)
                    {
                        ApplicationArea = All;
                    }
                    field(Reference; Reference)
                    {
                        ApplicationArea = All;
                    }
                }
            }
            part(Lines; "NPR POS Quote Subpage")
            {
                Caption = 'Lines';
                SubPageLink = "Quote Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("View POS Sales Data")
            {
                Caption = 'View POS Sales Data';
                Image = XMLFile;
                ApplicationArea = All;

                trigger OnAction()
                var
                    POSQuoteMgt: Codeunit "NPR POS Quote Mgt.";
                begin
                    POSQuoteMgt.ViewPOSSalesData(Rec);
                end;
            }
        }
    }
}