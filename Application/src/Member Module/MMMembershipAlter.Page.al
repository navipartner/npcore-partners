page 6060141 "NPR MM Membership Alter."
{

    Caption = 'Membership Alteration';
    PageType = List;
    SourceTable = "NPR MM Members. Alter. Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Alteration Type"; "Alteration Type")
                {
                    ApplicationArea = All;
                }
                field("From Membership Code"; "From Membership Code")
                {
                    ApplicationArea = All;
                }
                field("Sales Item No."; "Sales Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("To Membership Code"; "To Membership Code")
                {
                    ApplicationArea = All;
                }
                field("Presentation Order"; "Presentation Order")
                {
                    ApplicationArea = All;
                }
                field("Alteration Activate From"; "Alteration Activate From")
                {
                    ApplicationArea = All;
                }
                field("Alteration Date Formula"; "Alteration Date Formula")
                {
                    ApplicationArea = All;
                }
                field("Membership Duration"; "Membership Duration")
                {
                    ApplicationArea = All;
                }
                field("Activate Grace Period"; "Activate Grace Period")
                {
                    ApplicationArea = All;
                }
                field("Grace Period Presets"; "Grace Period Presets")
                {
                    ApplicationArea = All;
                }
                field("Grace Period Relates To"; "Grace Period Relates To")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Grace Period Calculation"; "Grace Period Calculation")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Grace Period Before"; "Grace Period Before")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Grace Period After"; "Grace Period After")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Price Calculation"; "Price Calculation")
                {
                    ApplicationArea = All;
                }
                field("Stacking Allowed"; "Stacking Allowed")
                {
                    ApplicationArea = All;
                }
                field("Upgrade With New Duration"; "Upgrade With New Duration")
                {
                    ApplicationArea = All;
                }
                field("Member Unit Price"; "Member Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Member Count Calculation"; "Member Count Calculation")
                {
                    ApplicationArea = All;
                }
                field("Auto-Renew To"; "Auto-Renew To")
                {
                    ApplicationArea = All;
                }
                field("Not Available Via Web Service"; "Not Available Via Web Service")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Assign Loyalty Points On Sale"; "Assign Loyalty Points On Sale")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Card Expired Action"; "Card Expired Action")
                {
                    ApplicationArea = All;
                }
                field("Auto-Admit Member On Sale"; "Auto-Admit Member On Sale")
                {
                    ApplicationArea = All;
                }
                field("Age Constraint Type"; "Age Constraint Type")
                {
                    ApplicationArea = All;
                }
                field("Age Constraint (Years)"; "Age Constraint (Years)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

