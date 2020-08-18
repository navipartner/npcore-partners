table 6060160 "Event Planning Line Buffer"
{
    // NPR5.55/TJ  /20200331 CASE 397741 New object

    Caption = 'Event Planning Line Buffer';

    fields
    {
        field(1;"Job No.";Code[20])
        {
            Caption = 'Job No.';
        }
        field(2;"Job Task No.";Code[20])
        {
            Caption = 'Job Task No.';
        }
        field(3;"Job Planning Line No.";Integer)
        {
            Caption = 'Job Planning Line No.';
        }
        field(4;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;"Planning Date";Date)
        {
            Caption = 'Planning Date';

            trigger OnValidate()
            begin
                UpdateFields();
            end;
        }
        field(20;"Starting Time";Time)
        {
            Caption = 'Starting Time';

            trigger OnValidate()
            begin
                UpdateFields();
                EventPlanLineGroupingMgt.CalcTimeQty("Starting Time","Ending Time",Quantity);
            end;
        }
        field(30;"Ending Time";Time)
        {
            Caption = 'Ending Time';

            trigger OnValidate()
            begin
                UpdateFields();
                EventPlanLineGroupingMgt.CalcTimeQty("Starting Time","Ending Time",Quantity);
            end;
        }
        field(40;"Status Checked";Boolean)
        {
            Caption = 'Status Checked';
        }
        field(50;"Status Text";Text[250])
        {
            Caption = 'Status Text';
        }
        field(60;"Status Type";Option)
        {
            Caption = 'Status Type';
            OptionCaption = ' ,Warning,Error';
            OptionMembers = " ",Warning,Error;
        }
        field(70;Quantity;Decimal)
        {
            Caption = 'Quantity';

            trigger OnValidate()
            begin
                UpdateFields();
            end;
        }
        field(80;"Unit of Measure Code";Code[10])
        {
            Caption = 'Unit of Measure Code';
        }
        field(90;"Action Type";Option)
        {
            Caption = 'Action Type';
            OptionCaption = ' ,Create,Skip';
            OptionMembers = " ",Create,Skip;

            trigger OnValidate()
            begin
                if ("Action Type" <> xRec."Action Type") and ("Status Type" = "Status Type"::Error) then
                  TestField("Action Type","Action Type"::Skip);
            end;
        }
        field(100;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Resource,Item';
            OptionMembers = Resource,Item;
        }
        field(110;"No.";Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type=CONST(Resource)) Resource;
        }
    }

    keys
    {
        key(Key1;"Job No.","Job Task No.","Job Planning Line No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if ("Unit of Measure Code" = '') and JobPlanningLine.Get("Job No.","Job Task No.","Job Planning Line No.") then
          "Unit of Measure Code" := JobPlanningLine."Unit of Measure Code";
    end;

    var
        JobPlanningLine: Record "Job Planning Line";
        EventPlanLineGroupingMgt: Codeunit "Event Plan. Line Grouping Mgt.";

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

