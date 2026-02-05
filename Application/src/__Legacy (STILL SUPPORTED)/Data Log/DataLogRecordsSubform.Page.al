page 6059899 "NPR Data Log Records Subform"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = False;
    Caption = 'Data Log Records Subform';
    Editable = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Data Log Field";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field No."; Rec."Field No.")
                {

                    ToolTip = 'Specifies the value of the Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Name"; Rec."Field Name")
                {

                    ToolTip = 'Specifies the value of the Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Previous Field Value"; Rec."Previous Field Value")
                {

                    ToolTip = 'Specifies the value of the Previous Field Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Value Changed"; Rec."Field Value Changed")
                {

                    ToolTip = 'Specifies the value of the Field Value Changed field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Value"; Rec."Field Value")
                {

                    ToolTip = 'Specifies the value of the Field Value field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

