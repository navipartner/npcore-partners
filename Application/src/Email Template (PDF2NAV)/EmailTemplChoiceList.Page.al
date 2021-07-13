page 6059799 "NPR E-mail Templ. Choice List"
{
    Caption = 'Choose E-mail Templates';
    PageType = List;
    UsageCategory = None;
    SourceTable = "Field";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Enabled; Rec.Enabled)
                {

                    Caption = 'Selected';
                    ToolTip = 'Specifies the value of the Selected field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Caption"; Rec."Field Caption")
                {

                    Caption = 'E-mail Template';
                    Editable = false;
                    ToolTip = 'Specifies the value of the E-mail Template field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

