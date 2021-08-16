page 6014634 "NPR MM Member Card FactBox"
{
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR MM Member Card";
    Editable = false;
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'Details';
                field("External Card No."; Rec."External Card No.")
                {
                    ToolTip = 'Specifies the value of the External Card No. field';
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
                field("Document ID"; Rec."Document ID")
                {
                    ToolTip = 'Specifies the value of the Document ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Pin Code"; Rec."Pin Code")
                {
                    ToolTip = 'Specifies the value of the Pin Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Type"; Rec."Card Type")
                {
                    ToolTip = 'Specifies the value of the Card Type field';
                    ApplicationArea = NPRRetail;
                }

            }

            group(GroupTwo)
            {
                Caption = 'Member Details';

                field("Display Name"; Rec."Display Name")
                {
                    ToolTip = 'Specifies the value of the Display Name field';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                    ApplicationArea = NPRRetail;
                }
                field("External Member No."; Rec."External Member No.")
                {
                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Member Blocked"; Rec."Member Blocked")
                {
                    ToolTip = 'Specifies the value of the Member Blocked field';
                    ApplicationArea = NPRRetail;
                }
            }

            group(Membership)
            {
                Caption = 'Membership Details';

                field("External Membership No."; Rec."External Membership No.")
                {
                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Blocked"; Rec."Membership Blocked")
                {
                    ToolTip = 'Specifies the value of the Membership Blocked field';
                    ApplicationArea = NPRRetail;
                }

            }

            group(SystemFields)
            {
                Caption = 'System';

                field("Block Reason"; Rec."Block Reason")
                {
                    ToolTip = 'Specifies the value of the Block Reason field';
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
                field("Blocked By"; Rec."Blocked By")
                {
                    ToolTip = 'Specifies the value of the Blocked By field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }

                field("Membership Entry No."; Rec."Membership Entry No.")
                {
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Member Entry No."; Rec."Member Entry No.")
                {
                    ToolTip = 'Specifies the value of the Member Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field';
                    ApplicationArea = NPRRetail;
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}