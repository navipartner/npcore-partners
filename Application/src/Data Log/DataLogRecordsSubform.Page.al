page 6059899 "NPR Data Log Records Subform"
{
    // DL1.00/MH/20140801  NP-AddOn: Data Log
    //   - This Page contains Field Values of logged Record Changes.

    Caption = 'Data Log Records Subform';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR Data Log Field";
    ApplicationArea = NPRRetail;

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

