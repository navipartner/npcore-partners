page 6151494 "NPR Raptor Action List"
{
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements

    Caption = 'Raptor Action List';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Raptor Action";
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
                field(Comment; Rec.Comment)
                {

                    ToolTip = 'Specifies the value of the Comment field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Type Description"; Rec."Data Type Description")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Data Type Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Raptor Module Code"; Rec."Raptor Module Code")
                {

                    ToolTip = 'Specifies the value of the Raptor Module Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Raptor Module API Req. String"; Rec."Raptor Module API Req. String")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Raptor Module API Req. String field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

