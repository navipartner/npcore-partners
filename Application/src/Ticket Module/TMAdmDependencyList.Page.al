page 6014512 "NPR TM Adm. Dependency List"
{
    Extensible = False;
    Caption = 'Admission Dependency Lines';
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "NPR TM Adm. Dependency Line";
    ShowFilter = false;
    DelayedInsert = true;
    UsageCategory = None;
    ContextSensitiveHelpPage = 'display/ENT/Ticket+Admission+Dependencies';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Dependency Code"; Rec."Dependency Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the dependency code for this rule.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the line number for this dependency rule.';
                }
                field("Rule Sequence"; Rec."Rule Sequence")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the order in which rules are evaluated.';
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the admission code this rule applies to.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies a description.';
                }
                field(Disabled; Rec.Disabled)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies if this rule is active or not.';
                }
                field("Rule Type"; Rec."Rule Type")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies which type of rule this is.';
                }
                field(Timeframe; Rec.Timeframe)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the date formula that will be used to evaluate the dependency rule.';
                }
                field(Limit; Rec.Limit)
                {
                    ApplicationArea = NPRTickedAdvanced;
                    ToolTip = 'Specifies the limit that will be used to evaluate the dependency rule.';
                }
                field("Response Message"; Rec."Response Message")
                {
                    ApplicationArea = NPRTickedAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies a custom response message that will be shown when the rule is violated.';
                }
            }

        }
    }

}
