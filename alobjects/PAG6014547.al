page 6014547 "Field Lookup"
{
    Caption = 'Field Lookup';
    Editable = false;
    PageType = List;
    SourceTable = "Field";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("No.";"No.")
                {
                    Caption = 'No.';
                }
                field("Field Caption";"Field Caption")
                {
                    Caption = 'Field Caption';
                }
            }
        }
    }

    actions
    {
    }
}

