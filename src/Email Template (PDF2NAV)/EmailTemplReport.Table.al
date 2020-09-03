table 6014461 "NPR E-mail Templ. Report"
{
    // PN1.01/MH/20140731  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Table contains a additional Reports to be saved and attached as PDF in connection to sending E-mail Template.
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)

    Caption = 'Report Selections - E-mail';

    fields
    {
        field(1; "E-mail Template Code"; Code[20])
        {
            Caption = 'E-mail Template Code';
            TableRelation = "NPR E-mail Template Header";
        }
        field(2; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));

            trigger OnValidate()
            begin
                CalcFields("Report Name");
            end;
        }
        field(40; Filename; Text[250])
        {
            Caption = 'Filename';
        }
        field(100; "Report Name"; Text[80])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Report ID")));
            Caption = 'Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "E-mail Template Code", "Report ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        TestField(Filename);
    end;

    trigger OnModify()
    begin
        TestField(Filename);
    end;

    var
        ReportSelection2: Record "Report Selections";
}

