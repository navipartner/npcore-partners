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
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Direction; Direction)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Collector Code"; "Collector Code")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = All;
                }
                field("Processed Date"; "Processed Date")
                {
                    ApplicationArea = All;
                }
                field("Database Name"; "Database Name")
                {
                    ApplicationArea = All;
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Processing Comment"; "Processing Comment")
                {
                    ApplicationArea = All;
                }
                field("External No."; "External No.")
                {
                    ApplicationArea = All;
                }
                field("Only New and Modified Records"; "Only New and Modified Records")
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field("Table View"; "Table View")
                {
                    ApplicationArea = All;
                }
                field("Table Filter"; "Table Filter")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            part(Control6151420; "Nc Collector Req. Filter Subf.")
            {
                SubPageLink = "Nc Collector Request No." = FIELD("No.");
                SubPageView = SORTING("Nc Collector Request No.")
                              ORDER(Ascending);
            }
        }
    }

    actions
    {
    }
}

