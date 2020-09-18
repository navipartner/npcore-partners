page 6060099 "NPR Ean Box Parameters"
{
    // NPR5.32/NPKNAV/20170526  CASE 272577 Transport NPR5.32 - 26 May 2017
    // NPR5.45/MHA /20180814  CASE 319706 Reworked Identifier Dissociation to Ean Box Event Handler

    Caption = 'Ean Box Parameters';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Ean Box Parameter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Event Code"; "Event Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Action Code"; "Action Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                    StyleExpr = "Non Editable";
                }
                field("Ean Box Value"; "Ean Box Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Non Editable"; "Non Editable")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Data Type"; "Data Type")
                {
                    ApplicationArea = All;
                }
                field(Value; Value)
                {
                    ApplicationArea = All;
                    Enabled = (NOT "Ean Box Value") AND (NOT "Non Editable");
                    HideValue = "Ean Box Value";
                    Style = Subordinate;
                    StyleExpr = "Non Editable";
                }
                field(OptionValueInteger; OptionValueInteger)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

