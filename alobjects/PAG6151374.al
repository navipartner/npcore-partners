page 6151374 "CS Fields"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018

    Caption = 'CS Fields';
    Editable = false;
    PageType = List;
    SourceTable = "Field";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(TableNo;TableNo)
                {
                    Caption = 'TableNo';
                }
                field("No.";"No.")
                {
                    Caption = 'No.';
                }
                field(TableName;TableName)
                {
                    Caption = 'TableName';
                }
                field(FieldName;FieldName)
                {
                    Caption = 'FieldName';
                }
                field(Type;Type)
                {
                    Caption = 'Type';
                }
                field(Class;Class)
                {
                    Caption = 'Class';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

