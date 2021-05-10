page 6151535 "NPR Nc Coll. Create Outg. Req."
{
    Caption = 'Create Outgoing Collector Req.';
    DataCaptionExpression = TextCreateNew;
    PageType = Document;
    ShowFilter = false;
    SourceTable = "NPR Nc Collector Request";
    SourceTableTemporary = true;
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    Lookup = true;
                    TableRelation = Object.ID WHERE(Type = CONST(Table));
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table View"; Rec."Table View")
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
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnClosePage()
    var
        TextConfirmCreate: Label 'Would you like to create this Outgoing Collector Request?';
    begin
        if (Rec.Name <> '') and (Rec."Table No." <> 0) then
            if Confirm(TextConfirmCreate) then
                CreateCollectorRequest();
    end;

    trigger OnOpenPage()
    begin
        Rec."No." := 1;
        Rec.Insert();
    end;

    var
        TextCreateNew: Label 'Create New Outgoing Collector Request?';
        TextCreated: Label 'Collector Request %1 created.';

    local procedure CreateCollectorRequest()
    var
        NcCollectorRequest: Record "NPR Nc Collector Request";
    begin
        Rec.TestField(Name);
        Rec.TestField("Table No.");
        NcCollectorRequest.Init();
        NcCollectorRequest.Insert(true);
        NcCollectorRequest.Validate(Direction, NcCollectorRequest.Direction::Outgoing);
        NcCollectorRequest.Validate(Name, Rec.Name);
        NcCollectorRequest.Validate("Collector Code", Rec."Collector Code");
        NcCollectorRequest.Validate("Table No.", Rec."Table No.");
        NcCollectorRequest.Validate("Table View", Rec."Table View");
        NcCollectorRequest.Modify(true);
        Message(TextCreated, NcCollectorRequest."No.");
    end;
}

