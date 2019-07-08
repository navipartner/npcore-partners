page 6014679 "Endpoint Query List"
{
    // NPR5.25\BR\20160801  CASE 234602 Object created
    // NPR5.48/JDH /20181109 CASE 334163 Added Action Captions and object caption

    Caption = 'Endpoint Query List';
    PageType = List;
    SourceTable = "Endpoint Query";
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
                field("Endpoint Code";"Endpoint Code")
                {
                }
                field(Status;Status)
                {
                }
                field("Processing Comment";"Processing Comment")
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
                field("Only New and Modified Records";"Only New and Modified Records")
                {
                }
                field("Table View";"Table View")
                {
                }
            }
        }
        area(factboxes)
        {
            part(Control6150624;"Endpoint Query Filter Subform")
            {
                SubPageLink = "Endpoint Query No."=FIELD("No.");
                SubPageView = SORTING("Endpoint Query No.","Table No.","Field No.")
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
                RunObject = Page "Create Outgoing Endpoint Query";
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
                RunObject = Page "Endpoint Request List";
                RunPageLink = "Query No."=FIELD("No.");
            }
        }
    }
}

