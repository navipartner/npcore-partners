page 6060099 "NPR POS Input Box Parameters"
{

    Caption = 'POS Input Box Parameters';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Event Code field';
                }
                field("Action Code"; "Action Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Action Code field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                    StyleExpr = "Non Editable";
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Ean Box Value"; "Ean Box Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Ean Box Value field';
                }
                field("Non Editable"; "Non Editable")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Non Editable field';
                }
                field("Data Type"; "Data Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Type field';
                }
                field(Value; Value)
                {
                    ApplicationArea = All;
                    Enabled = (NOT "Ean Box Value") AND (NOT "Non Editable");
                    HideValue = "Ean Box Value";
                    Style = Subordinate;
                    StyleExpr = "Non Editable";
                    ToolTip = 'Specifies the value of the Value field';
                }
                field(OptionValueInteger; OptionValueInteger)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the OptionValueInteger field';
                }
            }
        }
    }

    actions
    {
    }
}

