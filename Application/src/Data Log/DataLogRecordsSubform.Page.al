page 6059899 "NPR Data Log Records Subform"
{
    // DL1.00/MH/20140801  NP-AddOn: Data Log
    //   - This Page contains Field Values of logged Record Changes.

    Caption = 'Data Log Records Subform';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
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
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                }
                field("Previous Field Value"; "Previous Field Value")
                {
                    ApplicationArea = All;
                }
                field("Field Value Changed"; "Field Value Changed")
                {
                    ApplicationArea = All;
                }
                field("Field Value"; "Field Value")
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

