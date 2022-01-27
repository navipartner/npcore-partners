page 6059805 "NPR Item Variants Lookup"
{
    Extensible = False;
    Caption = 'Item Variants Lookup';
    PageType = List;
    SourceTable = "NPR Item Variant Buffer";
    SourceTableTemporary = true;
    Editable = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Control1)
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
                field("Description 2"; Rec."Description 2")
                {

                    Visible = true;
                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }

            }
        }
    }
}

