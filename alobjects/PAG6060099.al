page 6060099 "Ean Box Parameters"
{
    // NPR5.32/NPKNAV/20170526  CASE 272577 Transport NPR5.32 - 26 May 2017
    // NPR5.45/MHA /20180814  CASE 319706 Reworked Identifier Dissociation to Ean Box Event Handler

    Caption = 'Ean Box Parameters';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Ean Box Parameter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Event Code";"Event Code")
                {
                    Visible = false;
                }
                field("Action Code";"Action Code")
                {
                    Visible = false;
                }
                field(Name;Name)
                {
                    Style = Subordinate;
                    StyleExpr = "Non Editable";
                }
                field("Ean Box Value";"Ean Box Value")
                {
                    Editable = false;
                }
                field("Non Editable";"Non Editable")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Data Type";"Data Type")
                {
                }
                field(Value;Value)
                {
                    Enabled = (NOT "Ean Box Value") AND (NOT "Non Editable");
                    HideValue = "Ean Box Value";
                    Style = Subordinate;
                    StyleExpr = "Non Editable";
                }
                field(OptionValueInteger;OptionValueInteger)
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

