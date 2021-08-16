page 6060130 "NPR MM Member Card List"
{

    Caption = 'Member Cards';
    AdditionalSearchTerms = ' Member Card List';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR MM Member Card";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;
    CardPageId = "NPR MM Member Card Card";
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
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
            }
        }
        area(FactBoxes)
        {
            part(MemberCard; "NPR MM Member Card FactBox")
            {
                Caption = 'Member Card Details';
                ApplicationArea = NPRRetail;
                SubPageLink = "Entry No." = FIELD("Entry No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Membership)
            {
                Caption = 'Membership';
                Ellipsis = true;
                Image = CustomerList;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Membership Card";
                RunPageLink = "Entry No." = FIELD("Membership Entry No.");
                Scope = Repeater;
                ToolTip = 'Opens Membership Card';
                ApplicationArea = NPRRetail;
            }
            action(Members)
            {
                Caption = 'Members';
                Ellipsis = true;
                Image = Customer;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Card";
                RunPageLink = "Entry No." = FIELD("Member Entry No.");
                Scope = Repeater;
                ToolTip = 'Opens Members Card';
                ApplicationArea = NPRRetail;
            }
            separator(Separator6014401)
            {
            }
            action("Arrival Log")
            {
                Caption = 'Arrival Log';
                Ellipsis = true;
                Image = Log;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Arrival Log";
                RunPageLink = "External Card No." = FIELD("External Card No.");
                Scope = Repeater;
                ToolTip = 'Opens Arrival Log List';
                ApplicationArea = NPRRetail;
            }
        }
        area(Processing)
        {
            action("Print Card")
            {
                Caption = 'Print Card';
                Image = PrintVoucher;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;
                ToolTip = 'Executes the Print Card action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
                begin
                    MemberRetailIntegration.PrintMemberCard(Rec."Member Entry No.", Rec."Entry No.");
                end;
            }
        }
    }
}

