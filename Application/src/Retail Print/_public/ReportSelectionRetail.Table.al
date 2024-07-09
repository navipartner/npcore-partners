table 6014404 "NPR Report Selection Retail"
{
    Caption = 'Report Selection - Retail';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Report Type"; Enum "NPR Report Selection Type")
        {
            Caption = 'Report Type';
            DataClassification = CustomerContent;
        }
        field(2; Sequence; Code[10])
        {
            Caption = 'Sequence';
            DataClassification = CustomerContent;
            Numeric = true;
        }
        field(3; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Report));

            trigger OnValidate()
            begin
                CalcFields("Report Name");
            end;
        }
        field(4; "Report Name"; Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Report ID")));
            Caption = 'Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "XML Port ID"; Integer)
        {
            Caption = 'XML Port ID';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(XMLport));
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'No longer supported';
        }
        field(6; "XML Port Name"; Text[249])
        {
            Caption = 'XML Port Name';
            Editable = false;
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'No longer supported';
        }
        field(7; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(9; "Codeunit ID"; Integer)
        {
            Caption = 'Codeunit ID';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));

            trigger OnValidate()
            begin
                CalcFields("Codeunit Name");
            end;
        }
        field(10; "Codeunit Name"; Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Codeunit),
                                                                           "Object ID" = FIELD("Codeunit ID")));
            Caption = 'Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Print Template"; Code[20])
        {
            Caption = 'Print Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header".Code;
        }
        field(12; "Filter Object ID"; Integer)
        {
            Caption = 'Filter Object ID';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Use print template filters instead.';
        }
        field(13; "Record Filter"; TableFilter)
        {
            Caption = 'Record Filter';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Use print template filters instead.';
        }
        field(15; Optional; Boolean)
        {
            Caption = 'Optional';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Report Type", Sequence)
        {
        }
        key(Key2; "Report Type", "Report ID", "Register No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ReportSelectionRetail2: Record "NPR Report Selection Retail";

    internal procedure NewRecord()
    begin
        ReportSelectionRetail2.SetRange("Report Type", "Report Type");
        if ReportSelectionRetail2.FindLast() and (ReportSelectionRetail2.Sequence <> '') then
            Sequence := IncStr(ReportSelectionRetail2.Sequence)
        else
            Sequence := '1';
    end;
}

