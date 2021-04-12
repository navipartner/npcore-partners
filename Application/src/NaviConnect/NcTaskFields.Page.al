page 6151503 "NPR Nc Task Fields"
{
    // NC1.00/MHA /20150113  CASE 199932 Refactored object from Web Integration
    // NC2.00/MHA /20160525  CASE 240005 NaviConnect
    // NC2.13/MHA /20180605  CASE 312583 PageType changed from ListPart to List

    Caption = 'Nc Task List Subform';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Nc Task Field";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Previous Value"; Rec."Previous Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Previous Value field';
                }
                field("New Value"; Rec."New Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Value field';
                }
            }
        }
    }

    actions
    {
    }
}

