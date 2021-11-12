table 6014629 "NPR EFT Recon. Subscriber"
{
    Caption = 'EFT Recon. Subscriber';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Provider Code"; Code[20])
        {
            Caption = 'Provider Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT Recon. Provider";
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Import,Matching';
            OptionMembers = Import,Matching;
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
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."publisher object type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", GetPublisherCodeunitId());
                EventSubscription.SetRange("Published Function", GetPublisherFunction());
                if Page.RunModal(Page::"Event Subscriptions", EventSubscription) <> Action::LookupOK then
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

                EventSubscription.SetRange("Publisher Object Type", EventSubscription."publisher object type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", GetPublisherCodeunitId());
                EventSubscription.SetRange("Published Function", GetPublisherFunction());
                EventSubscription.SetRange("Subscriber Codeunit ID", "Subscriber Codeunit ID");
                if "Subscriber Function" <> '' then
                    EventSubscription.SetRange("Subscriber Function", "Subscriber Function");
                EventSubscription.FindFirst();
            end;
        }
        field(7; "Subscriber Function"; Text[80])
        {
            Caption = 'Subscriber Function';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."publisher object type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", GetPublisherCodeunitId());
                EventSubscription.SetRange("Published Function", GetPublisherFunction());
                if Page.RunModal(Page::"Event Subscriptions", EventSubscription) <> Action::LookupOK then
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

                EventSubscription.SetRange("Publisher Object Type", EventSubscription."publisher object type"::Codeunit);
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
            CalcFormula = lookup(AllObj."Object Name" where("Object Type" = const(Codeunit),
                                                             "Object ID" = field("Subscriber Codeunit ID")));
            Caption = 'Subscriber Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
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
        key(Key1; "Provider Code", Type, "Subscriber Codeunit ID", "Subscriber Function")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        UpdateDescription();
    end;

    trigger OnRename()
    begin
        UpdateDescription();
    end;

    local procedure GetPublisherCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR EFT Reconciliation Mgt.");
    end;

    local procedure GetPublisherFunction(): Text[80]
    var
        EFTReconciliationMgt: Codeunit "NPR EFT Reconciliation Mgt.";
    begin
        exit(EFTReconciliationMgt.GetPublisherFunction(Type));
    end;

    [IntegrationEvent(true, false)]
    local procedure UpdateDescription()
    begin
    end;
}

