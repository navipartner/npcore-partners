page 6151494 "NPR Raptor Action List"
{
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements

    Caption = 'Raptor Action List';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Raptor Action";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Comment field';
                }
                field("Data Type Description"; "Data Type Description")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Data Type Description field';
                }
                field("Raptor Module Code"; "Raptor Module Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Raptor Module Code field';
                }
                field("Raptor Module API Req. String"; "Raptor Module API Req. String")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Raptor Module API Req. String field';
                }
            }
        }
    }

    actions
    {
    }
}

