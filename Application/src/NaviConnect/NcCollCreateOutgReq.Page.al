page 6151535 "NPR Nc Coll. Create Outg. Req."
{
    Caption = 'Create Outgoing Collector Req.';
    DataCaptionExpression = TextCreateNewLbl;
    PageType = Document;
    ShowFilter = false;
    SourceTable = "NPR Nc Collector Request";
    SourceTableTemporary = true;
    UsageCategory = Tasks;
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table No."; Rec."Table No.")
                {
                    Lookup = true;
                    TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
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

    trigger OnClosePage()
    var
        TextConfirmCreateQst: Label 'Would you like to create this Outgoing Collector Request?';
    begin
        if (Rec.Name <> '') and (Rec."Table No." <> 0) then
            if Confirm(TextConfirmCreateQst) then
                CreateCollectorRequest();
    end;

    trigger OnOpenPage()
    begin
        Rec."No." := 1;
        Rec.Insert();
    end;

    var
        TextCreateNewLbl: Label 'Create New Outgoing Collector Request?';
        TextCreatedLbl: Label 'Collector Request %1 created.', Comment = '%1="NPR Nc Collector Request".Code';

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
        Message(TextCreatedLbl, NcCollectorRequest."No.");
    end;
}