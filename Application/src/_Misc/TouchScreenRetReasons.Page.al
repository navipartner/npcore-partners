page 6014534 "NPR TouchScreen: Ret. Reasons"
{
    Extensible = False;
    UsageCategory = Lists;

    Caption = 'Return reasons';
    SourceTable = "Return Reason";
    Editable = false;
    PageType = List;
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            repeater(Control6150616)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Location Code"; Rec."Default Location Code")
                {

                    ToolTip = 'Specifies the value of the Default Location Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Inventory Value Zero"; Rec."Inventory Value Zero")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Inventory Value Zero field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
