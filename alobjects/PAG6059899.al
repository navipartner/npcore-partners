page 6059899 "Data Log Records Subform"
{
    // DL1.00/MH/20140801  NP-AddOn: Data Log
    //   - This Page contains Field Values of logged Record Changes.

    Caption = 'Data Log Records Subform';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Data Log Field";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field No.";"Field No.")
                {
                }
                field("Field Name";"Field Name")
                {
                }
                field("Previous Field Value";"Previous Field Value")
                {
                }
                field("Field Value Changed";"Field Value Changed")
                {
                }
                field("Field Value";"Field Value")
                {
                }
            }
        }
    }

    actions
    {
    }
}

