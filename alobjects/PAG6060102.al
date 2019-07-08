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
                field("Period Code";"Period Code")
                {
                }
                field(Description;Description)
                {
                }
                field("Start Date";"Start Date")
                {
                }
                field("End Date";"End Date")
                {
                }
                field("Start Date Last Year";"Start Date Last Year")
                {
                }
                field("End Date Last Year";"End Date Last Year")
                {
                }
            }
        }
    }

    actions
    {
    }
}

