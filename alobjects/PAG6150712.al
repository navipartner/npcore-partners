page 6150712 "POS Default Views"
{
    Caption = 'POS Default Views';
    PageType = List;
    SourceTable = "POS Default View";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                }
                field("Salesperson Filter";"Salesperson Filter")
                {
                }
                field("Register Filter";"Register Filter")
                {
                }
                field("Starting Date";"Starting Date")
                {
                }
                field("Ending Date";"Ending Date")
                {
                }
                field(Monday;Monday)
                {
                    Visible = false;
                }
                field(Tuesday;Tuesday)
                {
                    Visible = false;
                }
                field(Wednesday;Wednesday)
                {
                    Visible = false;
                }
                field(Thursday;Thursday)
                {
                    Visible = false;
                }
                field(Friday;Friday)
                {
                    Visible = false;
                }
                field(Saturday;Saturday)
                {
                    Visible = false;
                }
                field(Sunday;Sunday)
                {
                    Visible = false;
                }
                field("POS View Code";"POS View Code")
                {
                }
            }
        }
    }

    actions
    {
    }
}

