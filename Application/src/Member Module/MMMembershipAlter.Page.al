page 6060141 "NPR MM Membership Alter."
{

    Caption = 'Membership Alteration';
    PageType = List;
    SourceTable = "NPR MM Members. Alter. Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Alteration Type"; "Alteration Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Alteration Type field';
                }
                field("From Membership Code"; "From Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Membership Code field';
                }
                field("Sales Item No."; "Sales Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Item No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("To Membership Code"; "To Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Membership Code field';
                }
                field("Presentation Order"; "Presentation Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Presentation Order field';
                }
                field("Alteration Activate From"; "Alteration Activate From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Alteration Activate From field';
                }
                field("Alteration Date Formula"; "Alteration Date Formula")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Alteration Date Formula field';
                }
                field("Membership Duration"; "Membership Duration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Duration field';
                }
                field("Activate Grace Period"; "Activate Grace Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Activate Grace Period field';
                }
                field("Grace Period Presets"; "Grace Period Presets")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Grace Period Presets field';
                }
                field("Grace Period Relates To"; "Grace Period Relates To")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Grace Period Relates To field';
                }
                field("Grace Period Calculation"; "Grace Period Calculation")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Grace Period Calculation field';
                }
                field("Grace Period Before"; "Grace Period Before")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Grace Period Before field';
                }
                field("Grace Period After"; "Grace Period After")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Grace Period After field';
                }
                field("Price Calculation"; "Price Calculation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price Calculation field';
                }
                field("Stacking Allowed"; "Stacking Allowed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Stacking Allowed field';
                }
                field("Upgrade With New Duration"; "Upgrade With New Duration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Upgrade With New Duration field';
                }
                field("Member Unit Price"; "Member Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Unit Price field';
                }
                field("Member Count Calculation"; "Member Count Calculation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Count Calculation field';
                }
                field("Auto-Renew To"; "Auto-Renew To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto-Renew To field';
                }
                field("Not Available Via Web Service"; "Not Available Via Web Service")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Not Available Via Web Service field';
                }
                field("Assign Loyalty Points On Sale"; "Assign Loyalty Points On Sale")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Assign Loyalty Points On Sale field';
                }
                field("Card Expired Action"; "Card Expired Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Expired Action field';
                }
                field("Auto-Admit Member On Sale"; "Auto-Admit Member On Sale")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto-Admit Member On Sale field';
                }
                field("Age Constraint Type"; "Age Constraint Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Age Constraint Type field';
                }
                field("Age Constraint (Years)"; "Age Constraint (Years)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Age Constraint (Years) field';
                }
            }
        }
    }

    actions
    {
    }
}

