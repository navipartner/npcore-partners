page 6059799 "NPR E-mail Templ. Choice List"
{
    Caption = 'Choose E-mail Templates';
    PageType = List;
    UsageCategory = Administration;
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
                }
                field("Field Caption"; "Field Caption")
                {
                    ApplicationArea = All;
                    Caption = 'E-mail Template';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }
}

