page 6060141 "NPR MM Membership Alter."
{
    Caption = 'Membership Alteration';
    PageType = List;
    SourceTable = "NPR MM Members. Alter. Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Alteration Type"; Rec."Alteration Type")
                {

                    ToolTip = 'Specifies the value of the Alteration Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("From Membership Code"; Rec."From Membership Code")
                {

                    ToolTip = 'Specifies the value of the From Membership Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Sales Item No."; Rec."Sales Item No.")
                {

                    ToolTip = 'Specifies the value of the Sales Item No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Visible = false;
                }
                field("To Membership Code"; Rec."To Membership Code")
                {

                    ToolTip = 'Specifies the value of the To Membership Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Presentation Order"; Rec."Presentation Order")
                {

                    ToolTip = 'Specifies the value of the Presentation Order field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Alteration Activate From"; Rec."Alteration Activate From")
                {

                    ToolTip = 'Specifies the value of the Alteration Activate From field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Alteration Date Formula"; Rec."Alteration Date Formula")
                {

                    ToolTip = 'Specifies the value of the Alteration Date Formula field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Duration"; Rec."Membership Duration")
                {

                    ToolTip = 'Specifies the value of the Membership Duration field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Activate Grace Period"; Rec."Activate Grace Period")
                {

                    ToolTip = 'Specifies the value of the Activate Grace Period field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Grace Period Presets"; Rec."Grace Period Presets")
                {

                    ToolTip = 'Specifies the value of the Grace Period Presets field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Grace Period Relates To"; Rec."Grace Period Relates To")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Grace Period Relates To field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Grace Period Calculation"; Rec."Grace Period Calculation")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Grace Period Calculation field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Grace Period Before"; Rec."Grace Period Before")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Grace Period Before field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Grace Period After"; Rec."Grace Period After")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Grace Period After field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(GracePeriodRelatesToFromDate; Rec.GracePeriodRelatesToFromDate)
                {
                    Visible = false;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Grace Period Relates To From Date field.';
                }
                field(GracePeriodRelatesToUntilDate; Rec.GracePeriodRelatesToUntilDate)
                {
                    Visible = false;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Grace Period Relates To Until Date field.';
                }
                field("Price Calculation"; Rec."Price Calculation")
                {

                    ToolTip = 'Specifies the value of the Price Calculation field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Stacking Allowed"; Rec."Stacking Allowed")
                {

                    ToolTip = 'Specifies the value of the Stacking Allowed field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Upgrade With New Duration"; Rec."Upgrade With New Duration")
                {

                    ToolTip = 'Specifies the value of the Upgrade With New Duration field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Unit Price"; Rec."Member Unit Price")
                {

                    ToolTip = 'Specifies the value of the Member Unit Price field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Count Calculation"; Rec."Member Count Calculation")
                {

                    ToolTip = 'Specifies the value of the Member Count Calculation field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Auto-Renew To"; Rec."Auto-Renew To")
                {

                    ToolTip = 'Specifies the value of the Auto-Renew To field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(AutoRenewToOnAgeConstraint; Rec.AutoRenewToOnAgeConstraint)
                {
                    ToolTip = 'Specifies the value of the Auto-Renew To On Age Constraint field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Not Available Via Web Service"; Rec."Not Available Via Web Service")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Not Available Via Web Service field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Assign Loyalty Points On Sale"; Rec."Assign Loyalty Points On Sale")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Assign Loyalty Points On Sale field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Expired Action"; Rec."Card Expired Action")
                {

                    ToolTip = 'Specifies the value of the Card Expired Action field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Auto-Admit Member On Sale"; Rec."Auto-Admit Member On Sale")
                {

                    ToolTip = 'Specifies the value of the Auto-Admit Member On Sale field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Age Constraint Type"; Rec."Age Constraint Type")
                {

                    ToolTip = 'Specifies the value of the Age Constraint Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Age Constraint (Years)"; Rec."Age Constraint (Years)")
                {

                    ToolTip = 'Specifies the value of the Age Constraint (Years) field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Age Constraint Applies To"; Rec."Age Constraint Applies To")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Age Constraint Applies To field.';
                }
                field(PrintCardOnAlteration; Rec.PrintCardOnAlteration)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Print Card On Alteration field.';
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AddAlterationToGroups)
            {
                Caption = 'Add Alteration to Groups';
                ToolTip = 'Let you select one or more Groups to add the Alteration to';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                    MMMembersAlterGroup: Record "NPR MM Members. Alter. Group";
                begin
                    MMMembersAlterGroup.AddAlterationToGroups(Rec.SystemId);
                end;
            }
        }
        area(Navigation)
        {
            action(AlterationGroups)
            {
                Caption = 'Alteration Groups';
                ToolTip = 'Shows the list of Alteration Groups';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = Group;
                RunObject = Page "NPR MM Members. Alter. Groups";
            }
        }
    }
}

