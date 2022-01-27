page 6060141 "NPR MM Membership Alter."
{
    Extensible = False;

    Caption = 'Membership Alteration';
    PageType = List;
    SourceTable = "NPR MM Members. Alter. Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Alteration Type"; Rec."Alteration Type")
                {

                    ToolTip = 'Specifies the value of the Alteration Type field';
                    ApplicationArea = NPRRetail;
                }
                field("From Membership Code"; Rec."From Membership Code")
                {

                    ToolTip = 'Specifies the value of the From Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Item No."; Rec."Sales Item No.")
                {

                    ToolTip = 'Specifies the value of the Sales Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("To Membership Code"; Rec."To Membership Code")
                {

                    ToolTip = 'Specifies the value of the To Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Presentation Order"; Rec."Presentation Order")
                {

                    ToolTip = 'Specifies the value of the Presentation Order field';
                    ApplicationArea = NPRRetail;
                }
                field("Alteration Activate From"; Rec."Alteration Activate From")
                {

                    ToolTip = 'Specifies the value of the Alteration Activate From field';
                    ApplicationArea = NPRRetail;
                }
                field("Alteration Date Formula"; Rec."Alteration Date Formula")
                {

                    ToolTip = 'Specifies the value of the Alteration Date Formula field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Duration"; Rec."Membership Duration")
                {

                    ToolTip = 'Specifies the value of the Membership Duration field';
                    ApplicationArea = NPRRetail;
                }
                field("Activate Grace Period"; Rec."Activate Grace Period")
                {

                    ToolTip = 'Specifies the value of the Activate Grace Period field';
                    ApplicationArea = NPRRetail;
                }
                field("Grace Period Presets"; Rec."Grace Period Presets")
                {

                    ToolTip = 'Specifies the value of the Grace Period Presets field';
                    ApplicationArea = NPRRetail;
                }
                field("Grace Period Relates To"; Rec."Grace Period Relates To")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Grace Period Relates To field';
                    ApplicationArea = NPRRetail;
                }
                field("Grace Period Calculation"; Rec."Grace Period Calculation")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Grace Period Calculation field';
                    ApplicationArea = NPRRetail;
                }
                field("Grace Period Before"; Rec."Grace Period Before")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Grace Period Before field';
                    ApplicationArea = NPRRetail;
                }
                field("Grace Period After"; Rec."Grace Period After")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Grace Period After field';
                    ApplicationArea = NPRRetail;
                }
                field("Price Calculation"; Rec."Price Calculation")
                {

                    ToolTip = 'Specifies the value of the Price Calculation field';
                    ApplicationArea = NPRRetail;
                }
                field("Stacking Allowed"; Rec."Stacking Allowed")
                {

                    ToolTip = 'Specifies the value of the Stacking Allowed field';
                    ApplicationArea = NPRRetail;
                }
                field("Upgrade With New Duration"; Rec."Upgrade With New Duration")
                {

                    ToolTip = 'Specifies the value of the Upgrade With New Duration field';
                    ApplicationArea = NPRRetail;
                }
                field("Member Unit Price"; Rec."Member Unit Price")
                {

                    ToolTip = 'Specifies the value of the Member Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Member Count Calculation"; Rec."Member Count Calculation")
                {

                    ToolTip = 'Specifies the value of the Member Count Calculation field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto-Renew To"; Rec."Auto-Renew To")
                {

                    ToolTip = 'Specifies the value of the Auto-Renew To field';
                    ApplicationArea = NPRRetail;
                }
                field("Not Available Via Web Service"; Rec."Not Available Via Web Service")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Not Available Via Web Service field';
                    ApplicationArea = NPRRetail;
                }
                field("Assign Loyalty Points On Sale"; Rec."Assign Loyalty Points On Sale")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Assign Loyalty Points On Sale field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Expired Action"; Rec."Card Expired Action")
                {

                    ToolTip = 'Specifies the value of the Card Expired Action field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto-Admit Member On Sale"; Rec."Auto-Admit Member On Sale")
                {

                    ToolTip = 'Specifies the value of the Auto-Admit Member On Sale field';
                    ApplicationArea = NPRRetail;
                }
                field("Age Constraint Type"; Rec."Age Constraint Type")
                {

                    ToolTip = 'Specifies the value of the Age Constraint Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Age Constraint (Years)"; Rec."Age Constraint (Years)")
                {

                    ToolTip = 'Specifies the value of the Age Constraint (Years) field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

