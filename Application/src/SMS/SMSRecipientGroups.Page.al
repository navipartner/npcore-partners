page 6014429 "NPR SMS Recipient Groups"
{

    ApplicationArea = All;
    Caption = 'SMS Recipient Groups';
    PageType = List;
    SourceTable = "NPR SMS Recipient Group";
    UsageCategory = Administration;
    Editable = False;
    CardPageId = "NPR SMS Recipient Group";
    layout
    {
        area(content)
        {
            repeater(General)
            {
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
            }
        }
    }

}
