page 6014582 "NPR Store Groups"
{
    Extensible = False;
    Caption = 'Store Groups';
    PageType = List;
    SourceTable = "NPR Store Group";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field("Blank Location"; Rec."Blank Location")
                {

                    ToolTip = 'Specifies the value of the Blank Location field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

