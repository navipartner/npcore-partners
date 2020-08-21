page 6151494 "Raptor Action List"
{
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements

    Caption = 'Raptor Action List';
    Editable = false;
    PageType = List;
    SourceTable = "Raptor Action";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                }
                field("Data Type Description"; "Data Type Description")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Raptor Module Code"; "Raptor Module Code")
                {
                    ApplicationArea = All;
                }
                field("Raptor Module API Req. String"; "Raptor Module API Req. String")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

