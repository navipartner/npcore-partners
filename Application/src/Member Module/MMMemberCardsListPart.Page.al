page 6060131 "NPR MM Member Cards ListPart"
{
    Extensible = False;

    Caption = 'Member Cards';
    CardPageID = "NPR MM Member Card Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR MM Member Card";

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
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Membership No."; Rec."External Membership No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Card No."; Rec."External Card No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the External Card No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Card No. Last 4"; Rec."External Card No. Last 4")
                {
                    Enabled = false;
                    ToolTip = 'Specifies the value of the External Card No. Last 4 field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Pin Code"; Rec."Pin Code")
                {
                    ToolTip = 'Specifies the value of the Pin Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Valid Until"; Rec."Valid Until")
                {
                    ToolTip = 'Specifies the value of the Valid Until field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Is Temporary"; Rec."Card Is Temporary")
                {
                    ToolTip = 'Specifies the value of the Card Is Temporary field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Block Reason"; Rec."Block Reason")
                {
                    ToolTip = 'Specifies the value of the Block Reason field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Document ID"; Rec."Document ID")
                {
                    ToolTip = 'Specifies the value of the Document ID field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
                ToolTip = 'Executes the Print Card action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
                RunObject = Page "NPR MM Member Card Card";
                RunPageLink = "Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("Entry No.");

                ToolTip = 'Executes the Card Card action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
    }

    internal procedure GetCurrentEntryNo() EntryNo: Integer
    begin

        exit(Rec."Entry No.");
    end;
}

