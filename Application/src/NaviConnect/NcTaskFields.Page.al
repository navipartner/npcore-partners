page 6151503 "NPR Nc Task Fields"
{
    Extensible = False;
    Caption = 'Nc Task List Subform';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Nc Task Field";
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Field Name"; Rec."Field Name")
                {

                    ToolTip = 'Specifies the value of the Field Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Previous Value"; Rec."Previous Value")
                {

                    ToolTip = 'Specifies the value of the Previous Value field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("New Value"; Rec."New Value")
                {

                    ToolTip = 'Specifies the value of the New Value field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }
}

