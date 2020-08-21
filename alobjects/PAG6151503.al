page 6151503 "Nc Task Fields"
{
    // NC1.00/MHA /20150113  CASE 199932 Refactored object from Web Integration
    // NC2.00/MHA /20160525  CASE 240005 NaviConnect
    // NC2.13/MHA /20180605  CASE 312583 PageType changed from ListPart to List

    Caption = 'Nc Task List Subform';
    Editable = false;
    PageType = List;
    SourceTable = "Nc Task Field";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                }
                field("Previous Value"; "Previous Value")
                {
                    ApplicationArea = All;
                }
                field("New Value"; "New Value")
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

