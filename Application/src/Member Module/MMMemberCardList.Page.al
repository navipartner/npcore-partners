page 6060130 "NPR MM Member Card List"
{

    Caption = 'Member Card List';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR MM Member Card";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                }
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field("External Card No."; "External Card No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Card No. field';
                }
                field("External Member No."; "External Member No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Member No. field';
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Display Name"; "Display Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Display Name field';
                }
                field("E-Mail Address"; "E-Mail Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                }
                field("Valid Until"; "Valid Until")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid Until field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Member Blocked"; "Member Blocked")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Blocked field';
                }
                field("Membership Blocked"; "Membership Blocked")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Blocked field';
                }
                field("Card Is Temporary"; "Card Is Temporary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Is Temporary field';
                }
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Membership Card";
                RunPageLink = "Entry No." = FIELD("Membership Entry No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Membership action';
            }
            action(Members)
            {
                Caption = 'Members';
                Ellipsis = true;
                Image = Customer;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Card";
                RunPageLink = "Entry No." = FIELD("Member Entry No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Members action';
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Arrival Log";
                RunPageLink = "External Card No." = FIELD("External Card No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Arrival Log action';
            }
        }
    }
}

