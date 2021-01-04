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
                        ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    }
                    field("Register No."; "Register No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cash Register No. field';
                    }
                    field("Entry No."; "Entry No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Entry No. field';
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Created at"; "Created at")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Created at field';
                    }
                    field("Salesperson Code"; "Salesperson Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Salesperson Code field';
                    }
                    field(Amount; Amount)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Amount field';
                    }
                    field("Amount Including VAT"; "Amount Including VAT")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Amount Including VAT field';
                    }
                    field("Contains EFT Approval"; "Contains EFT Approval")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Contains EFT Approval field';
                    }
                }
                group(Control6014409)
                {
                    ShowCaption = false;
                    field("Customer Type"; "Customer Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Type field';
                    }
                    field("Customer No."; "Customer No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer No. field';
                    }
                    field("Customer Price Group"; "Customer Price Group")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Price Group field';
                    }
                    field("Customer Disc. Group"; "Customer Disc. Group")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Disc. Group field';
                    }
                    field(Attention; Attention)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Attention field';
                    }
                    field(Reference; Reference)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Reference field';
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
                ToolTip = 'Executes the View POS Sales Data action';

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