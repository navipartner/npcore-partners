page 6151535 "NPR Nc Coll. Create Outg. Req."
{
    // NC2.01\BR\20160913  CASE 250447 Object created

    Caption = 'Create Outgoing Collector Req.';
    DataCaptionExpression = TextCreateNew;
    PageType = Document;
    ShowFilter = false;
    SourceTable = "NPR Nc Collector Request";
    SourceTableTemporary = true;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    Lookup = true;
                    TableRelation = Object.ID WHERE(Type = CONST(Table));
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table View"; "Table View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table View field';
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
                Image = "SelectEntries";
                ApplicationArea = All;
                ToolTip = 'Executes the Create Request action';

                trigger OnAction()
                begin
                    CurrPage.Close;
                end;
            }
        }
    }

    trigger OnClosePage()
    var
        TextConfirmCreate: Label 'Would you like to create this Outgoing Collector Request?';
    begin
        if (Name <> '') and ("Table No." <> 0) then
            if Confirm(TextConfirmCreate) then
                CreateCollectorRequest;
    end;

    trigger OnOpenPage()
    begin
        "No." := 1;
        Insert;
    end;

    var
        TextCreateNew: Label 'Create New Outgoing Collector Request?';
        TextCreated: Label 'Collector Request %1 created.';

    local procedure CreateCollectorRequest()
    var
        NcCollectorRequest: Record "NPR Nc Collector Request";
    begin
        TestField(Name);
        TestField("Table No.");
        NcCollectorRequest.Init;
        NcCollectorRequest.Insert(true);
        NcCollectorRequest.Validate(Direction, NcCollectorRequest.Direction::Outgoing);
        NcCollectorRequest.Validate(Name, Name);
        NcCollectorRequest.Validate("Collector Code", "Collector Code");
        NcCollectorRequest.Validate("Table No.", "Table No.");
        NcCollectorRequest.Validate("Table View", "Table View");
        NcCollectorRequest.Modify(true);
        Message(TextCreated, NcCollectorRequest."No.");
    end;
}

