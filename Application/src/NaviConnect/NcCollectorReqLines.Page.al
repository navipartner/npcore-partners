page 6151533 "NPR Nc Collector Req. Lines"
{
    // NC2.01\BR\20160909  CASE 250447 Object created

    Caption = 'Nc Collector Request Lines';
    PageType = List;
    SourceTable = "NPR Nc Collector Request";
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
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Direction; Direction)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direction field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Collector Code"; "Collector Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Collector Code field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Creation Date field';
                }
                field("Processed Date"; "Processed Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processed Date field';
                }
                field("Database Name"; "Database Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Database Name field';
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Processing Comment"; "Processing Comment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Comment field';
                }
                field("External No."; "External No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External No. field';
                }
                field("Only New and Modified Records"; "Only New and Modified Records")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Only New and Modified Records field';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table View"; "Table View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table View field';
                }
                field("Table Filter"; "Table Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Filter field';
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
            }
        }
        area(factboxes)
        {
            part(Control6151420; "NPR Nc Collector Req.Filt.Subf")
            {
                SubPageLink = "Nc Collector Request No." = FIELD("No.");
                SubPageView = SORTING("Nc Collector Request No.")
                              ORDER(Ascending);
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }
}

