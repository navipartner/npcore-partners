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
                    ToolTip = 'Specifies the value of the Dependency Code field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Rule Sequence"; "Rule Sequence")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Rule Sequence field';
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Disabled; Disabled)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Disabled field';
                }
                field("Rule Type"; "Rule Type")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Rule Type field';
                }
                field(Timeframe; Timeframe)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Timeframe field';
                }
                field("Response Message"; "Response Message")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Response Message field';
                }
            }

        }
    }

}