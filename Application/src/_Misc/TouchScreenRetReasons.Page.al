page 6014534 "NPR TouchScreen: Ret. Reasons"
{
    UsageCategory = Lists;
    ApplicationArea = All;
    Caption = 'Return reasons';
    SourceTable = "Return Reason";
    Editable = false;
    PageType = List;
    layout
    {
        area(content)
        {
            repeater(Control6150616)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Default Location Code"; Rec."Default Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Location Code field';
                }
                field("Inventory Value Zero"; Rec."Inventory Value Zero")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Inventory Value Zero field';
                }
            }
        }
    }
}
