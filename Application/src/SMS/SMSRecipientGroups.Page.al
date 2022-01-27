page 6014429 "NPR SMS Recipient Groups"
{
    Extensible = False;


    Caption = 'SMS Recipient Groups';
    PageType = List;
    SourceTable = "NPR SMS Recipient Group";
    UsageCategory = Administration;
    Editable = False;
    CardPageId = "NPR SMS Recipient Group";
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            repeater(General)
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

}
