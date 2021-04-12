page 6014679 "NPR Endpoint Query List"
{
    // NPR5.25\BR\20160801  CASE 234602 Object created
    // NPR5.48/JDH /20181109 CASE 334163 Added Action Captions and object caption

    Caption = 'Endpoint Query List';
    PageType = List;
    SourceTable = "NPR Endpoint Query";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Direction; Rec.Direction)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direction field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Endpoint Code"; Rec."Endpoint Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Endpoint Code field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Processing Comment"; Rec."Processing Comment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Comment field';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Creation Date field';
                }
                field("Processed Date"; Rec."Processed Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processed Date field';
                }
                field("Database Name"; Rec."Database Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Database Name field';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Only New and Modified Records"; Rec."Only New and Modified Records")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Only New and Modified Records field';
                }
                field("Table View"; Rec."Table View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table View field';
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
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Create New Outgoing Query action';
            }
            action("Create Requests from Incoming Query")
            {
                Caption = 'Create Requests from Incoming Query';
                Image = Process;
                ApplicationArea = All;
                ToolTip = 'Executes the Create Requests from Incoming Query action';

                trigger OnAction()
                begin
                    Rec.ProcessQuery;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Requests action';
            }
        }
    }
}

