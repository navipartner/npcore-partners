page 6060131 "NPR MM Member Cards ListPart"
{

    Caption = 'Member Cards';
    CardPageID = "NPR MM Member Card Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Member Card";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                }
                field("External Card No."; "External Card No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the External Card No. field';
                }
                field("External Card No. Last 4"; "External Card No. Last 4")
                {
                    ApplicationArea = All;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the External Card No. Last 4 field';
                }
                field("Pin Code"; "Pin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pin Code field';
                }
                field("Valid Until"; "Valid Until")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid Until field';
                }
                field("Card Is Temporary"; "Card Is Temporary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Is Temporary field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked At field';
                }
                field("Block Reason"; "Block Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Block Reason field';
                }
                field("Document ID"; "Document ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document ID field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Print Card")
            {
                Caption = 'Print Card';
                Image = PrintVoucher;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Print Card action';

                trigger OnAction()
                var
                    MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
                begin
                    MemberRetailIntegration.PrintMemberCard("Member Entry No.", "Entry No.");
                end;
            }
            action("Card Card")
            {
                Caption = 'Card Card';
                Image = Voucher;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR MM Member Card Card";
                RunPageLink = "Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("Entry No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Card Card action';
            }
        }
    }

    procedure GetCurrentEntryNo() EntryNo: Integer
    begin

        exit(Rec."Entry No.");
    end;
}

