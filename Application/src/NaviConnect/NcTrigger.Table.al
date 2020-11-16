table 6151520 "NPR Nc Trigger"
{
    // NC2.01 /BR  /20160809  CASE 247479 NaviConnect: Object created
    // NC2.01 /BR  /20161219  CASE 261431 Added Subscriber Codeunit ID and -Name
    // NC2.03 /BR  /20170103  CASE 271242 Added field Error on Empty Output
    // NC2.04 /MHA /20170524  CASE 277893 NPR5.31 removed from Version List
    // NC2.16/BHR /20180824  CASE 322752 Replace record Object to Allobj - fields 70,80
    // NC2.17/JDH /20181112 CASE 334163 Added Caption to fields 60, 70, 80 and 90

    Caption = 'Nc Trigger';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "Split Trigger and Endpoint"; Boolean)
        {
            Caption = 'Split Trigger and Endpoint';
            DataClassification = CustomerContent;
        }
        field(40; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(50; "Linked Endpoints"; Integer)
        {
            CalcFormula = Count ("NPR Nc Endpoint Trigger Link" WHERE("Trigger Code" = FIELD(Code)));
            Caption = 'Linked Endpoints';
            Editable = false;
            FieldClass = FlowField;
        }
        field(60; "Task Processor"; Code[20])
        {
            Caption = 'Task Processor';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Task Processor";
        }
        field(70; "Subscriber Codeunit ID"; Integer)
        {
            Caption = 'Subscriber Codeunit ID';
            DataClassification = CustomerContent;
            Description = 'NC2.01';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));
        }
        field(80; "Subscriber Codeunit Name"; Text[50])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Subscriber Codeunit ID")));
            Caption = 'Subscriber Codeunit Name';
            Description = 'NC2.01';
            Editable = false;
            FieldClass = FlowField;
        }
        field(90; "Error on Empty Output"; Boolean)
        {
            Caption = 'Error on Empty Output';
            DataClassification = CustomerContent;
            Description = 'NC2.03 [271242]';
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

    var
        EventSubscription: Record "Event Subscription";
}

