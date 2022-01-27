page 6014415 "NPR Pacsoft Package Codes"
{
    Extensible = False;

    Caption = 'Pacsoft Package Codes';
    PageType = Worksheet;
    SourceTable = "NPR Pacsoft Package Code";
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
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

