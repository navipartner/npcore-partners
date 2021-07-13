page 6060099 "NPR POS Input Box Parameters"
{

    Caption = 'POS Input Box Parameters';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Ean Box Parameter";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Event Code"; Rec."Event Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Event Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Action Code"; Rec."Action Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Action Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    Style = Subordinate;
                    StyleExpr = Rec."Non Editable";
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Ean Box Value"; Rec."Ean Box Value")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Ean Box Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Non Editable"; Rec."Non Editable")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Non Editable field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Type"; Rec."Data Type")
                {

                    ToolTip = 'Specifies the value of the Data Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Value; Rec.Value)
                {

                    Enabled = (NOT Rec."Ean Box Value") AND (NOT Rec."Non Editable");
                    HideValue = Rec."Ean Box Value";
                    Style = Subordinate;
                    StyleExpr = Rec."Non Editable";
                    ToolTip = 'Specifies the value of the Value field';
                    ApplicationArea = NPRRetail;
                }
                field(OptionValueInteger; Rec.OptionValueInteger)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the OptionValueInteger field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

