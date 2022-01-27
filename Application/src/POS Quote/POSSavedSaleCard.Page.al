page 6151003 "NPR POS Saved Sale Card"
{
    Extensible = False;
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

                        ToolTip = 'Specifies the value of the Sales Ticket No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Register No."; Rec."Register No.")
                    {

                        ToolTip = 'Specifies the value of the POS Unit No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Entry No."; Rec."Entry No.")
                    {

                        ToolTip = 'Specifies the value of the Entry No. field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Created at"; Rec."Created at")
                    {

                        ToolTip = 'Specifies the value of the Created at field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Salesperson Code"; Rec."Salesperson Code")
                    {

                        ToolTip = 'Specifies the value of the Salesperson Code field';
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
                    field("Contains EFT Approval"; Rec."Contains EFT Approval")
                    {

                        ToolTip = 'Specifies the value of the Contains EFT Approval field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014409)
                {
                    ShowCaption = false;
                    field("Customer Type"; Rec."Customer Type")
                    {

                        ToolTip = 'Specifies the value of the Customer Type field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer No."; Rec."Customer No.")
                    {

                        ToolTip = 'Specifies the value of the Customer No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer Price Group"; Rec."Customer Price Group")
                    {

                        ToolTip = 'Specifies the value of the Customer Price Group field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer Disc. Group"; Rec."Customer Disc. Group")
                    {

                        ToolTip = 'Specifies the value of the Customer Disc. Group field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Attention; Rec.Attention)
                    {

                        ToolTip = 'Specifies the value of the Attention field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Reference; Rec.Reference)
                    {

                        ToolTip = 'Specifies the value of the Reference field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            part(Lines; "NPR POS Saved Sale Subp.")
            {
                Caption = 'Lines';
                SubPageLink = "Quote Entry No." = FIELD("Entry No.");
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the View POS Sales Data action';
                ApplicationArea = NPRRetail;

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
