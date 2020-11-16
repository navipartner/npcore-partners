table 6060160 "NPR Event Plan. Line Buffer"
{
    // NPR5.55/TJ  /20200331 CASE 397741 New object

    Caption = 'Event Planning Line Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Job No."; Code[20])
        {
            Caption = 'Job No.';
            DataClassification = CustomerContent;
        }
        field(2; "Job Task No."; Code[20])
        {
            Caption = 'Job Task No.';
            DataClassification = CustomerContent;
        }
        field(3; "Job Planning Line No."; Integer)
        {
            Caption = 'Job Planning Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Planning Date"; Date)
        {
            Caption = 'Planning Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateFields();
            end;
        }
        field(20; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateFields();
                EventPlanLineGroupingMgt.CalcTimeQty("Starting Time", "Ending Time", Quantity);
            end;
        }
        field(30; "Ending Time"; Time)
        {
            Caption = 'Ending Time';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateFields();
                EventPlanLineGroupingMgt.CalcTimeQty("Starting Time", "Ending Time", Quantity);
            end;
        }
        field(40; "Status Checked"; Boolean)
        {
            Caption = 'Status Checked';
            DataClassification = CustomerContent;
        }
        field(50; "Status Text"; Text[250])
        {
            Caption = 'Status Text';
            DataClassification = CustomerContent;
        }
        field(60; "Status Type"; Option)
        {
            Caption = 'Status Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Warning,Error';
            OptionMembers = " ",Warning,Error;
        }
        field(70; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateFields();
            end;
        }
        field(80; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
        }
        field(90; "Action Type"; Option)
        {
            Caption = 'Action Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Create,Skip';
            OptionMembers = " ",Create,Skip;

            trigger OnValidate()
            begin
                if ("Action Type" <> xRec."Action Type") and ("Status Type" = "Status Type"::Error) then
                    TestField("Action Type", "Action Type"::Skip);
            end;
        }
        field(100; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Resource,Item';
            OptionMembers = Resource,Item;
        }
        field(110; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Resource)) Resource;
        }
    }

    keys
    {
        key(Key1; "Job No.", "Job Task No.", "Job Planning Line No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if ("Unit of Measure Code" = '') and JobPlanningLine.Get("Job No.", "Job Task No.", "Job Planning Line No.") then
            "Unit of Measure Code" := JobPlanningLine."Unit of Measure Code";
    end;

    var
        JobPlanningLine: Record "Job Planning Line";
        EventPlanLineGroupingMgt: Codeunit "NPR Event Plan.Line Group. Mgt";

    local procedure UpdateFields()
    begin
        "Status Checked" := StatusChecked();
        if not "Status Checked" then begin
            "Status Type" := "Status Type"::" ";
            "Status Text" := '';
            "Action Type" := "Action Type"::" ";
        end;
    end;

    local procedure StatusChecked(): Boolean
    begin
        exit(("Planning Date" = xRec."Planning Date") and
             ("Starting Time" = xRec."Starting Time") and
             ("Ending Time" = xRec."Ending Time") and
             (Quantity = xRec.Quantity));
    end;
}

