#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
table 6151287 "NPR Retention Policy"
{
    Caption = 'NPR Retention Policy';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Retention Policy";
    LookupPageID = "NPR Retention Policy";
    Extensible = false;

    fields
    {
        field(1; "Table Id"; Integer)
        {
            Caption = 'Table Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Table Name"; Text[30])
        {
            Caption = 'Table Name';
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = field("Table Id")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(3; "Table Caption"; Text[249])
        {
            Caption = 'Table Caption';
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table Id")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(5; Implementation; Enum "NPR Retention Policy")
        {
            Caption = 'Implementation (obsolete)';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Pending;
            ObsoleteTag = '2026-05-15';
            ObsoleteReason = 'Please use newer "Implementation V2" field.';
        }
        field(6; "Implementation V2"; Enum "NPR Retention Policy V2")
        {
            Caption = 'Implementation';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Table Id")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        RetentionPolicyPeriod: Record "NPR Retention Policy Period";
    begin
        RetentionPolicyPeriod.SetRange("Table Id", Rec."Table Id");
        if not RetentionPolicyPeriod.IsEmpty() then
            RetentionPolicyPeriod.DeleteAll();
    end;

    internal procedure DiscoverRetentionPolicyTables()
    var
        RetentionPolicy: Codeunit "NPR Retention Policy";
    begin
        RetentionPolicy.OnDiscoverRetentionPolicyTables();
    end;

    /// <summary>
    /// Returns default retention policy for the table, if the setup doesn't specify one explicitly.
    /// </summary>
    /// <returns></returns>
    internal procedure GetActiveRetentionPeriod(PeriodType: enum "NPR Retention Period Type") RetentionPeriod: DateFormula
    var
        EmptyDateFormula: DateFormula;
    begin
        RetentionPeriod := Rec.GetRetentionPeriod(PeriodType);
        if RetentionPeriod = EmptyDateFormula then
            RetentionPeriod := Rec.GetDefaultRetentionPeriod(PeriodType);
    end;

    internal procedure GetRetentionPeriod(PeriodType: Enum "NPR Retention Period Type"): DateFormula
    var
        RetentionPolicyPeriod: Record "NPR Retention Policy Period";
    begin
        if RetentionPolicyPeriod.Get(Rec."Table Id", PeriodType) then
            exit(RetentionPolicyPeriod."Retention Period");
    end;

    internal procedure GetDefaultRetentionPeriod(PeriodType: enum "NPR Retention Period Type"): DateFormula
    var
        IRetentionPolicy: Interface "NPR IRetention Policy V2";
    begin
        IRetentionPolicy := Rec."Implementation V2";
        exit(IRetentionPolicy.GetDefaultRetentionPeriod(PeriodType));
    end;
}
#endif