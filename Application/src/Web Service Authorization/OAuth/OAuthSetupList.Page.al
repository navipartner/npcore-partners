page 6059772 "NPR OAuth Setup List"
{

    ApplicationArea = NPRRetail;
    Caption = 'OAuth Setup List';
    CardPageId = "NPR OAuth Setup Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR OAuth Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Enabled)
                {
                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}
