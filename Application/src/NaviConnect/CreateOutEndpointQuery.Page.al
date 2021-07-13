page 6014686 "NPR Create Out. Endpoint Query"
{
    Caption = 'Create Outgoing Endpoint Query';
    DataCaptionExpression = TextCreateNew;
    PageType = Document;
    ShowFilter = false;
    SourceTable = "NPR Endpoint Query";
    SourceTableTemporary = true;
    UsageCategory = Tasks;
    ApplicationArea = NPRNaviConnect;


    layout
    {
        area(content)
        {
            group(General)
            {
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table View"; Rec."Table View")
                {

                    ToolTip = 'Specifies the value of the Table View field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Request")
            {
                Caption = 'Create Request';
                Image = Create;

                ToolTip = 'Executes the Create Request action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnClosePage()
    var
        TextConfirmCreate: Label 'Would you like to create this Outgoing Endpoint Query?';
    begin
        if (Rec.Name <> '') and (Rec."Table No." <> 0) then
            if Confirm(TextConfirmCreate) then
                CreateEndpointQuery();
    end;

    trigger OnOpenPage()
    begin
        Rec."No." := 1;
        Rec.Insert();
    end;

    var
        TextCreateNew: Label 'Create New Outgoing Query';
        TextCreated: Label 'Endpoint Query %1 created.';

    local procedure CreateEndpointQuery()
    var
        EndpointQuery: Record "NPR Endpoint Query";
    begin
        Rec.TestField(Name);
        Rec.TestField("Table No.");
        EndpointQuery.Init();
        EndpointQuery.Insert(true);
        EndpointQuery.Validate(Direction, EndpointQuery.Direction::Outgoing);
        EndpointQuery.Validate(Name, Rec.Name);
        EndpointQuery.Validate("Endpoint Code", Rec."Endpoint Code");
        EndpointQuery.Validate("Table No.", Rec."Table No.");
        EndpointQuery.Validate("Table View", Rec."Table View");
        EndpointQuery.Modify(true);
        Message(TextCreated, EndpointQuery."No.");
    end;
}

