page 6060102 "Date Periodes"
{
    Caption = 'Date Periodes';
    PageType = List;
    SourceTable = Periodes;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Period Code"; "Period Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = All;
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = All;
                }
                field("Start Date Last Year"; "Start Date Last Year")
                {
                    ApplicationArea = All;
                }
                field("End Date Last Year"; "End Date Last Year")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

