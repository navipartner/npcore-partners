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
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Previous Field Value"; "Previous Field Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Previous Field Value field';
                }
                field("Field Value Changed"; "Field Value Changed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Value Changed field';
                }
                field("Field Value"; "Field Value")
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

