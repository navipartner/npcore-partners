table 6151529 "NPR Nc Collector Request"
{
    Caption = 'Nc Collector Request';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; Direction; Option)
        {
            Caption = 'Direction';
            DataClassification = CustomerContent;
            OptionCaption = 'Incoming,Outgoing';
            OptionMembers = Incoming,Outgoing;
        }
        field(5; Name; Text[30])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(10; "Collector Code"; Code[20])
        {
            Caption = 'Collector Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Collector";
        }
        field(30; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'New,Processed,Rejected';
            OptionMembers = New,Processed,Rejected;
        }
        field(40; "Creation Date"; DateTime)
        {
            Caption = 'Creation Date';
            DataClassification = CustomerContent;
        }
        field(50; "Processed Date"; DateTime)
        {
            Caption = 'Processed Date';
            DataClassification = CustomerContent;
        }
        field(100; "Database Name"; Text[250])
        {
            Caption = 'Database Name';
            DataClassification = CustomerContent;
        }
        field(120; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
        }
        field(130; "User ID"; Text[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(150; "Processing Comment"; Text[250])
        {
            Caption = 'Processing Comment';
            DataClassification = CustomerContent;
        }
        field(160; "External No."; BigInteger)
        {
            Caption = 'External No.';
            DataClassification = CustomerContent;
        }
        field(170; "Only New and Modified Records"; Boolean)
        {
            Caption = 'Only New and Modified Records';
            DataClassification = CustomerContent;
        }
        field(200; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Table No." <> xRec."Table No." then
                    Validate("Table View", '');
            end;
        }
        field(205; "Table View"; Text[250])
        {
            Caption = 'Table View';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                FilterPageBuild: FilterPageBuilder;
                RecRef: RecordRef;
            begin
                if "Table No." <> 0 then begin
                    RecRef.Open("Table No.");
                    FilterPageBuild.AddRecordRef(RecRef.Caption, RecRef);
                    if "Table View" <> '' then
                        FilterPageBuild.SetView(RecRef.Caption, "Table View");
                    FilterPageBuild.PageCaption := RecRef.Caption;
                    FilterPageBuild.RunModal();
                    Validate("Table View", FilterPageBuild.GetView(RecRef.Caption));
                end;
            end;

            trigger OnValidate()
            var
                RecRef: RecordRef;
                NcCollectorManagement: Codeunit "NPR Nc Collector Management";
            begin
                if ("Table View" <> '') and (IsTemporary = false) then begin
                    RecRef.Open("Table No.");
                    RecRef.SetView("Table View");
                    NcCollectorManagement.InsertFilterRecords(Rec, RecRef);
                end;
            end;
        }
        field(210; "Table Filter"; TableFilter)
        {
            Caption = 'Table Filter';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                TableFilter: Record "Table Filter";
                TableFilterPage: Page "Table Filter";
            begin
                TableFilter.FilterGroup(2);
                TableFilter.SetRange("Table Number", "Table No.");
                TableFilter.FilterGroup(0);
                TableFilterPage.SetTableView(TableFilter);
                TableFilterPage.SetSourceTable(Format("Table Filter"), "Table No.", '');
                if ACTION::OK = TableFilterPage.RunModal() then
                    Evaluate("Table Filter", TableFilterPage.CreateTextTableFilter(false));
            end;
        }
        field(220; "Table Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    trigger OnDelete()
    var
        NcCollectorRequestFilter: Record "NPR Nc Collector Req. Filter";
    begin
        NcCollectorRequestFilter.SetRange("Nc Collector Request No.", "No.");
        NcCollectorRequestFilter.DeleteAll(true);
    end;

    trigger OnInsert()
    var
        ActiveSession: Record "Active Session";
    begin
        "Creation Date" := CurrentDateTime;

        if "Database Name" = '' then begin
            ActiveSession.SetRange("Session ID", SessionId());
            if ActiveSession.FindFirst() then
                "Database Name" := CopyStr("Database Name", 1, MaxStrLen("Database Name"));
        end;

        if "User ID" = '' then
            "User ID" := CopyStr(UserId, 1, MaxStrLen("User ID"));
        if "Company Name" = '' then
            "Company Name" := CopyStr(CompanyName, 1, MaxStrLen("Company Name"));
    end;

    trigger OnModify()
    begin
        case Status of
            Status::Processed:
                "Processed Date" := CurrentDateTime();
            Status::Rejected:
                if "Processed Date" = 0DT then
                    "Processed Date" := CurrentDateTime();
        end;
    end;
}

