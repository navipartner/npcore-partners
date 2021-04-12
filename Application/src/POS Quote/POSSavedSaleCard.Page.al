page 6151003 "NPR POS Saved Sale Card"
{
    UsageCategory = None;
    Caption = 'POS Saved Sale Card';
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "NPR POS Saved Sale Entry";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014411)
                {
                    ShowCaption = false;
                    field("Sales Ticket No."; Rec."Sales Ticket No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    }
                    field("Register No."; Rec."Register No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the POS Unit No. field';
                    }
                    field("Entry No."; Rec."Entry No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Entry No. field';
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Created at"; Rec."Created at")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Created at field';
                    }
                    field("Salesperson Code"; Rec."Salesperson Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Salesperson Code field';
                    }
                    field(Amount; Rec.Amount)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Amount field';
                    }
                    field("Amount Including VAT"; Rec."Amount Including VAT")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Amount Including VAT field';
                    }
                    field("Contains EFT Approval"; Rec."Contains EFT Approval")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Contains EFT Approval field';
                    }
                }
                group(Control6014409)
                {
                    ShowCaption = false;
                    field("Customer Type"; Rec."Customer Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Type field';
                    }
                    field("Customer No."; Rec."Customer No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer No. field';
                    }
                    field("Customer Price Group"; Rec."Customer Price Group")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Price Group field';
                    }
                    field("Customer Disc. Group"; Rec."Customer Disc. Group")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Disc. Group field';
                    }
                    field(Attention; Rec.Attention)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Attention field';
                    }
                    field(Reference; Rec.Reference)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Reference field';
                    }
                }
            }
            part(Lines; "NPR POS Saved Sale Subp.")
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
                    POSQuoteMgt: Codeunit "NPR POS Saved Sale Mgt.";
                begin
                    POSQuoteMgt.ViewPOSSalesData(Rec);
                end;
            }
        }
    }
}
