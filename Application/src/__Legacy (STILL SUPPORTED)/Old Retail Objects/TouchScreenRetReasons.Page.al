page 6014534 "NPR TouchScreen: Ret. Reasons"
{
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
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Default Location Code"; "Default Location Code")
                {
                    ApplicationArea = All;
                }
                field("Inventory Value Zero"; "Inventory Value Zero")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }
}