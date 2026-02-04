page 6150920 "NPR MembershipEntryLinkList"
{
    Extensible = false;

    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR MM Membership Entry Link";
    Editable = false;
    Caption = 'Membership Ledger Entry Linked Entries';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Document Line No. field.';
                }
                field(Context; Rec.Context)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Context field.';
                }
                field("Context Period Starting Date"; Rec."Context Period Starting Date")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Context Period Starting Date field.';
                }
                field("Context Period Ending Date"; Rec."Context Period Ending Date")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Context Period Ending Date field.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {
                    Caption = 'Membership Ledger Entry No.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Membership Entry No. field.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }

            }
        }
    }
}