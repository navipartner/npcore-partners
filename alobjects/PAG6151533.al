page 6151533 "Nc Collector Request Lines"
{
    // NC2.01\BR\20160909  CASE 250447 Object created

    Caption = 'Nc Collector Request Lines';
    PageType = List;
    SourceTable = "Nc Collector Request";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                }
                field(Direction;Direction)
                {
                }
                field(Name;Name)
                {
                }
                field("Collector Code";"Collector Code")
                {
                }
                field(Status;Status)
                {
                }
                field("Creation Date";"Creation Date")
                {
                }
                field("Processed Date";"Processed Date")
                {
                }
                field("Database Name";"Database Name")
                {
                }
                field("Company Name";"Company Name")
                {
                }
                field("User ID";"User ID")
                {
                }
                field("Processing Comment";"Processing Comment")
                {
                }
                field("External No.";"External No.")
                {
                }
                field("Only New and Modified Records";"Only New and Modified Records")
                {
                }
                field("Table No.";"Table No.")
                {
                }
                field("Table View";"Table View")
                {
                }
                field("Table Filter";"Table Filter")
                {
                }
                field("Table Name";"Table Name")
                {
                }
            }
        }
        area(factboxes)
        {
            part(Control6151420;"Nc Collector Req. Filter Subf.")
            {
                SubPageLink = "Nc Collector Request No."=FIELD("No.");
                SubPageView = SORTING("Nc Collector Request No.")
                              ORDER(Ascending);
            }
        }
    }

    actions
    {
    }
}

