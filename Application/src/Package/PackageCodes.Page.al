page 6014570 "NPR Package Codes"
{
    Extensible = False;

    Caption = 'Package Codes';
    PageType = ListPart;
    SourceTable = "NPR Package Code";
    UsageCategory = Lists;
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
                field(Id; Rec.Id)
                {

                    ToolTip = 'Specifies the value of the Id field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}

