page 6060131 "NPR MM Member Cards ListPart"
{

    Caption = 'Member Cards';
    CardPageID = "NPR MM Member Card Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR MM Member Card";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Membership No."; Rec."External Membership No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Card No."; Rec."External Card No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the External Card No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Card No. Last 4"; Rec."External Card No. Last 4")
                {

                    Enabled = false;
                    ToolTip = 'Specifies the value of the External Card No. Last 4 field';
                    ApplicationArea = NPRRetail;
                }
                field("Pin Code"; Rec."Pin Code")
                {

                    ToolTip = 'Specifies the value of the Pin Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid Until"; Rec."Valid Until")
                {

                    ToolTip = 'Specifies the value of the Valid Until field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Is Temporary"; Rec."Card Is Temporary")
                {

                    ToolTip = 'Specifies the value of the Card Is Temporary field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("Blocked At"; Rec."Blocked At")
                {

                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRRetail;
                }
                field("Block Reason"; Rec."Block Reason")
                {

                    ToolTip = 'Specifies the value of the Block Reason field';
                    ApplicationArea = NPRRetail;
                }
                field("Document ID"; Rec."Document ID")
                {

                    ToolTip = 'Specifies the value of the Document ID field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Print Card action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Card Card action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    procedure GetCurrentEntryNo() EntryNo: Integer
    begin

        exit(Rec."Entry No.");
    end;
}

