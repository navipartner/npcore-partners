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
                field("Event Code"; Rec."Event Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Event Code field';
                }
                field("Action Code"; Rec."Action Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Action Code field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                    StyleExpr = Rec."Non Editable";
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Ean Box Value"; Rec."Ean Box Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Ean Box Value field';
                }
                field("Non Editable"; Rec."Non Editable")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Non Editable field';
                }
                field("Data Type"; Rec."Data Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Type field';
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    Enabled = (NOT Rec."Ean Box Value") AND (NOT Rec."Non Editable");
                    HideValue = Rec."Ean Box Value";
                    Style = Subordinate;
                    StyleExpr = Rec."Non Editable";
                    ToolTip = 'Specifies the value of the Value field';
                }
                field(OptionValueInteger; Rec.OptionValueInteger)
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

