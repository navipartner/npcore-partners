table 6150730 "NPR POS Sales Workflow Step"
{

    Caption = 'POS Sales Workflow Step';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Scenarios Steps";
    LookupPageID = "NPR POS Scenarios Steps";

    fields
    {
        field(1; "Set Code"; Code[20])
        {
            Caption = 'Set Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.45';
            TableRelation = "NPR POS Sales Workflow Set";
        }
        field(3; "Workflow Code"; Code[20])
        {
            Caption = 'Workflow Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.45';
            NotBlank = true;
            TableRelation = "NPR POS Sales Workflow";
        }
        field(5; "Subscriber Codeunit ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Subscriber Codeunit ID';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", GetPublisherCodeunitId());
                EventSubscription.SetRange("Published Function", GetPublisherFunction());
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                "Subscriber Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Subscriber Function" := EventSubscription."Subscriber Function";
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if "Subscriber Codeunit ID" = 0 then begin
                    "Subscriber Function" := '';
                    exit;
                end;

                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", GetPublisherCodeunitId());
                EventSubscription.SetRange("Published Function", GetPublisherFunction());
                EventSubscription.SetRange("Subscriber Codeunit ID", "Subscriber Codeunit ID");
                if "Subscriber Function" <> '' then
                    EventSubscription.SetRange("Subscriber Function", "Subscriber Function");
                EventSubscription.FindFirst();
            end;
        }
        field(10; "Subscriber Codeunit Name"; Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Subscriber Codeunit ID")));
            Caption = 'Subscriber Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Subscriber Function"; Text[80])
        {
            Caption = 'Subscriber Function';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", GetPublisherCodeunitId());
                EventSubscription.SetRange("Published Function", GetPublisherFunction());
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                "Subscriber Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Subscriber Function" := EventSubscription."Subscriber Function";
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if "Subscriber Function" = '' then begin
                    "Subscriber Codeunit ID" := 0;
                    exit;
                end;

                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", GetPublisherCodeunitId());
                EventSubscription.SetRange("Published Function", GetPublisherFunction());
                EventSubscription.SetRange("Subscriber Codeunit ID", "Subscriber Codeunit ID");
                if "Subscriber Function" <> '' then
                    EventSubscription.SetRange("Subscriber Function", "Subscriber Function");
                EventSubscription.FindFirst();
            end;
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(25; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            DataClassification = CustomerContent;
        }
        field(30; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            InitValue = true;
        }
    }

    keys
    {
        key(Key1; "Set Code", "Workflow Code", "Subscriber Codeunit ID", "Subscriber Function")
        {
        }
        key(Key2; "Sequence No.")
        {
        }
    }

    fieldgroups
    {
    }

    local procedure GetPublisherCodeunitId(): Integer
    var
        POSSalesWorkflow: Record "NPR POS Sales Workflow";
    begin
        POSSalesWorkflow.Get("Workflow Code");
        exit(POSSalesWorkflow."Publisher Codeunit ID");
    end;

    local procedure GetPublisherFunction(): Text
    var
        POSSalesWorkflow: Record "NPR POS Sales Workflow";
    begin
        POSSalesWorkflow.Get("Workflow Code");
        exit(POSSalesWorkflow."Publisher Function");
    end;
}

