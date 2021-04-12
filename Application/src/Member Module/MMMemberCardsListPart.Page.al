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
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("External Membership No."; Rec."External Membership No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                }
                field("External Card No."; Rec."External Card No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the External Card No. field';
                }
                field("External Card No. Last 4"; Rec."External Card No. Last 4")
                {
                    ApplicationArea = All;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the External Card No. Last 4 field';
                }
                field("Pin Code"; Rec."Pin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pin Code field';
                }
                field("Valid Until"; Rec."Valid Until")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid Until field';
                }
                field("Card Is Temporary"; Rec."Card Is Temporary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Is Temporary field';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked At field';
                }
                field("Block Reason"; Rec."Block Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Block Reason field';
                }
                field("Document ID"; Rec."Document ID")
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
                    MemberRetailIntegration.PrintMemberCard(Rec."Member Entry No.", Rec."Entry No.");
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

