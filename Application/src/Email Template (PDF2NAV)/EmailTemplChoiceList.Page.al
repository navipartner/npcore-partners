page 6059799 "NPR E-mail Templ. Choice List"
{
    Caption = 'Choose E-mail Templates';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "Field";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    Caption = 'Selected';
                    ToolTip = 'Specifies the value of the Selected field';
                }
                field("Field Caption"; "Field Caption")
                {
                    ApplicationArea = All;
                    Caption = 'E-mail Template';
                    Editable = false;
                    ToolTip = 'Specifies the value of the E-mail Template field';
                }
            }
        }
    }

    actions
    {
    }
}

