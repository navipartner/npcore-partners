page 6014686 "Create Outgoing Endpoint Query"
{
    // NPR5.25\BR\20160803  CASE 234602 Object created
    // NPR5.48/JDH /20181109 CASE 334163 Added Action Captions and object caption
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Create Outgoing Endpoint Query';
    DataCaptionExpression = TextCreateNew;
    PageType = Document;
    ShowFilter = false;
    SourceTable = "Endpoint Query";
    SourceTableTemporary = true;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Name;Name)
                {
                }
                field("Table No.";"Table No.")
                {
                }
                field("Table View";"Table View")
                {
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

                trigger OnAction()
                begin
                    CurrPage.Close;
                end;
            }
        }
    }

    trigger OnClosePage()
    var
        TextConfirmCreate: Label 'Would you like to create this Outgoing Endpoint Query?';
    begin
        if (Name <> '') and ("Table No." <> 0) then
          if Confirm(TextConfirmCreate) then
            CreateEndpointQuery;
    end;

    trigger OnOpenPage()
    begin
        "No." := 1;
        Insert;
    end;

    var
        TextCreateNew: Label 'Create New Outgoing Query';
        TextCreated: Label 'Endpoint Query %1 created.';

    local procedure CreateEndpointQuery()
    var
        EndpointManagement: Codeunit "Endpoint Management";
        EndpointQuery: Record "Endpoint Query";
    begin
        TestField(Name);
        TestField("Table No.");
        EndpointQuery.Init;
        EndpointQuery.Insert(true);
        EndpointQuery.Validate(Direction,EndpointQuery.Direction::Outgoing);
        EndpointQuery.Validate(Name,Name);
        EndpointQuery.Validate("Endpoint Code","Endpoint Code");
        EndpointQuery.Validate("Table No.","Table No.");
        EndpointQuery.Validate("Table View","Table View");
        EndpointQuery.Modify(true);
        Message(TextCreated,EndpointQuery."No.");
    end;
}

