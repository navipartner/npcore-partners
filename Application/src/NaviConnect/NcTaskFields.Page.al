page 6151503 "NPR Nc Task Fields"
{
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
}

