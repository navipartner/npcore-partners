table 6150729 "NPR POS Sales Workflow"
{
    Access = Internal;

    Caption = 'POS Sales Workflow';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Scenarios";
    LookupPageID = "NPR POS Scenarios";
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Scenarios have been moved to hardcoded codeunit calls for internal steps, and event subscribers for PTE steps';

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Publisher Codeunit ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Publisher Codeunit ID';
            DataClassification = CustomerContent;
        }
        field(15; "Publisher Codeunit Name"; Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Publisher Codeunit ID")));
            Caption = 'Publisher Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Publisher Function"; Text[80])
        {
            Caption = 'Publisher Function';
            DataClassification = CustomerContent;
        }
        field(100; "Workflow Steps"; Integer)
        {
            CalcFormula = Count("NPR POS Sales Workflow Step" WHERE("Set Code" = CONST(''),
                                                                 "Workflow Code" = FIELD(Code)));
            Caption = 'Workflow Steps';
            Description = 'NPR5.45';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
    begin
        POSSalesWorkflowStep.SetRange("Workflow Code", Code);
        if POSSalesWorkflowStep.FindFirst() then
            POSSalesWorkflowStep.DeleteAll();
    end;

    procedure DiscoverPOSSalesWorkflow(NewCode: Code[20]; NewDescription: Text[100]; NewPublisherCodeunitId: Integer; NewPublisherFunction: Text[80])
    var
        PrevRec: Text;
    begin
        if not Get(NewCode) then begin
            Init();
            Code := NewCode;
            Insert(true);
        end;

        PrevRec := Format(Rec);

        Description := NewDescription;
        "Publisher Codeunit ID" := NewPublisherCodeunitId;
        "Publisher Function" := NewPublisherFunction;

        if PrevRec <> Format(Rec) then
            Modify(true);
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnDiscoverPOSSalesWorkflows()
    begin
    end;

    procedure InitPOSSalesWorkflowSteps() StepsInitiated: Integer
    var
        EventSubscription: Record "Event Subscription";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
    begin
        EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
        EventSubscription.SetRange("Publisher Object ID", "Publisher Codeunit ID");
        EventSubscription.SetRange("Published Function", "Publisher Function");
        if not EventSubscription.FindSet() then
            exit(0);

        repeat
            //-NPR5.45 [321266]
            //IF NOT POSSalesWorkflowStep.GET(Code,EventSubscription."Subscriber Codeunit ID",EventSubscription."Subscriber Function") THEN BEGIN
            if not POSSalesWorkflowStep.Get('', Code, EventSubscription."Subscriber Codeunit ID", EventSubscription."Subscriber Function") then begin
                //+NPR5.45 [321266]
                StepsInitiated += 1;

                POSSalesWorkflowStep.Init();
                //-NPR5.45 [321266]
                POSSalesWorkflowStep."Set Code" := '';
                //+NPR5.45 [321266]
                POSSalesWorkflowStep."Workflow Code" := Code;
                POSSalesWorkflowStep."Subscriber Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                POSSalesWorkflowStep."Subscriber Function" := CopyStr(EventSubscription."Subscriber Function", 1, MaxStrLen(POSSalesWorkflowStep."Subscriber Function"));
                POSSalesWorkflowStep.Enabled := true;
                POSSalesWorkflowStep.Insert(true);
            end;
        until EventSubscription.Next() = 0;

        exit(StepsInitiated);
    end;

    internal procedure GetWorkflowStepSubscriberCodeunitsFilter(Include: Boolean) FilterExpression: Text
    var
        EventSubscription: Record "Event Subscription";
        NPRetalAppNameLbl: Label 'NP Retail', Locked = true;
    begin
        EventSubscription.Reset();
        EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
        EventSubscription.SetRange("Publisher Object ID", Rec."Publisher Codeunit ID");
        EventSubscription.SetRange("Published Function", Rec."Publisher Function");
        EventSubscription.SetRange("Originating App Name", NPRetalAppNameLbl);
        EventSubscription.SetCurrentKey("Subscriber Codeunit ID");

        EventSubscription.SetLoadFields("Publisher Object Type", "Publisher Object ID", "Published Function", "Originating App Name", "Subscriber Codeunit ID");
        if not EventSubscription.FindSet() then
            exit;

        repeat
            if Include then
                FilterExpression += '|'
            else
                FilterExpression += '&<>';

            FilterExpression += Format(EventSubscription."Subscriber Codeunit ID");

            EventSubscription.SetRange("Subscriber Codeunit ID", EventSubscription."Subscriber Codeunit ID");
            EventSubscription.FindLast();
            EventSubscription.SetRange("Subscriber Codeunit ID");
        until EventSubscription.Next() = 0;

        FilterExpression := CopyStr(FilterExpression, 2);
    end;

    local procedure FilterPOSScenarioStepsCount(var POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step")
    begin
        POSSalesWorkflowStep.Reset();
        POSSalesWorkflowStep.SetRange("Set Code", '');
        POSSalesWorkflowStep.SetRange("Workflow Code", Rec.Code);
        POSSalesWorkflowStep.SetFilter("Subscriber Codeunit ID", GetWorkflowStepSubscriberCodeunitsFilter(false));
    end;

    internal procedure GetPOSScenarioStepsCount() NoOfWorkflowSteps: Integer
    var
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
    begin
        FilterPOSScenarioStepsCount(POSSalesWorkflowStep);
        NoOfWorkflowSteps := POSSalesWorkflowStep.Count;
    end;

    internal procedure DrillDownPOSScenarioSteps()
    var
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
    begin
        FilterPOSScenarioStepsCount(POSSalesWorkflowStep);
        Page.Run(0, POSSalesWorkflowStep);
    end;
}

