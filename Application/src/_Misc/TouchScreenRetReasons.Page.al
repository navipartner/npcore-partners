page 6014534 "NPR TouchScreen: Ret. Reasons"
{
    UsageCategory = None;
    Caption = 'Return reasons';
    SourceTable = "Return Reason";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Control6150616)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Default Location Code"; "Default Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Location Code field';
                }
                field("Inventory Value Zero"; "Inventory Value Zero")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Inventory Value Zero field';
                }
            }
        }
    }
}
