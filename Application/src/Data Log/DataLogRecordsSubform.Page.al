page 6059899 "NPR Data Log Records Subform"
{
    // DL1.00/MH/20140801  NP-AddOn: Data Log
    //   - This Page contains Field Values of logged Record Changes.

    Caption = 'Data Log Records Subform';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Data Log Field";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Previous Field Value"; Rec."Previous Field Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Previous Field Value field';
                }
                field("Field Value Changed"; Rec."Field Value Changed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Value Changed field';
                }
                field("Field Value"; Rec."Field Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Value field';
                }
            }
        }
    }

    actions
    {
    }
}

