page 6014512 "NPR TM Adm. Dependency List"
{
    Caption = 'Admission Dependency Lines';
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "NPR TM Adm. Dependency Line";
    ShowFilter = false;
    DelayedInsert = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Dependency Code"; "Dependency Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                }
                field("Rule Sequence"; "Rule Sequence")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ShowMandatory = true;
                }
                field(Description; Description)
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field(Disabled; Disabled)
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Rule Type"; "Rule Type")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field(Timeframe; Timeframe)
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Response Message"; "Response Message")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }

        }
    }

}