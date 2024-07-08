page 6014679 "NPR Endpoint Query List"
{
    Extensible = False;
    // NPR5.25\BR\20160801  CASE 234602 Object created
    // NPR5.48/JDH /20181109 CASE 334163 Added Action Captions and object caption

    Caption = 'Endpoint Query List';
    PageType = List;
    SourceTable = "NPR Endpoint Query";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Direction; Rec.Direction)
                {

                    ToolTip = 'Specifies the value of the Direction field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Endpoint Code"; Rec."Endpoint Code")
                {

                    ToolTip = 'Specifies the value of the Endpoint Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Comment"; Rec."Processing Comment")
                {

                    ToolTip = 'Specifies the value of the Processing Comment field';
                    ApplicationArea = NPRRetail;
                }
                field("Creation Date"; Rec."Creation Date")
                {

                    ToolTip = 'Specifies the value of the Creation Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Processed Date"; Rec."Processed Date")
                {

                    ToolTip = 'Specifies the value of the Processed Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Database Name"; Rec."Database Name")
                {

                    ToolTip = 'Specifies the value of the Database Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Company Name"; Rec."Company Name")
                {

                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Only New and Modified Records"; Rec."Only New and Modified Records")
                {

                    ToolTip = 'Specifies the value of the Only New and Modified Records field';
                    ApplicationArea = NPRRetail;
                }
                field("Table View"; Rec."Table View")
                {

                    ToolTip = 'Specifies the value of the Table View field';
                    ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Create New Outgoing Query action';
                ApplicationArea = NPRRetail;
            }
            action("Create Requests from Incoming Query")
            {
                Caption = 'Create Requests from Incoming Query';
                Image = Process;

                ToolTip = 'Executes the Create Requests from Incoming Query action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.ProcessQuery();
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

                ToolTip = 'Executes the Requests action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

