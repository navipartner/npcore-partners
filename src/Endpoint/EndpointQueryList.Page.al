page 6014679 "NPR Endpoint Query List"
{
    // NPR5.25\BR\20160801  CASE 234602 Object created
    // NPR5.48/JDH /20181109 CASE 334163 Added Action Captions and object caption

    Caption = 'Endpoint Query List';
    PageType = List;
    SourceTable = "NPR Endpoint Query";
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
                field("Endpoint Code"; "Endpoint Code")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Processing Comment"; "Processing Comment")
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
                field("Only New and Modified Records"; "Only New and Modified Records")
                {
                    ApplicationArea = All;
                }
                field("Table View"; "Table View")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            part(Control6150624; "NPR Endpoint QueryFilt. S.form")
            {
                SubPageLink = "Endpoint Query No." = FIELD("No.");
                SubPageView = SORTING("Endpoint Query No.", "Table No.", "Field No.")
                              ORDER(Ascending);
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create New Outgoing Query")
            {
                Caption = 'Create New Outgoing Query';
                Image = New;
                RunObject = Page "NPR Create Out. Endpoint Query";
            }
            action("Create Requests from Incoming Query")
            {
                Caption = 'Create Requests from Incoming Query';
                Image = Process;

                trigger OnAction()
                begin
                    ProcessQuery;
                end;
            }
        }
        area(navigation)
        {
            action(Requests)
            {
                Caption = 'Requests';
                Image = XMLFile;
                RunObject = Page "NPR Endpoint Request List";
                RunPageLink = "Query No." = FIELD("No.");
            }
        }
    }
}

