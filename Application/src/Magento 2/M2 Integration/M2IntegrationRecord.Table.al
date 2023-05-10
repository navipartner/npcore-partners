table 6059854 "NPR M2 Integration Record"
{
    Access = Internal;
    Extensible = false;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = SystemMetadata;
            TableRelation = "Table Metadata".ID;
        }
        field(4; "Integration Area"; Enum "NPR M2 Integration Area")
        {
            Caption = 'Integration Area';
            DataClassification = SystemMetadata;
        }
        field(3; "Table Name"; Text[80])
        {
            Caption = 'Table Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Table Metadata".Caption where(ID = field("Table No.")));
            Editable = false;
        }
        field(2; "Last SystemRowVersionNo"; BigInteger)
        {
            Caption = 'Last SystemRowVersionNo';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key("Primary Key"; "Table No.", "Integration Area")
        {
            Clustered = true;
        }
    }

    internal procedure AddTable(TableNo: Integer; IntegrationArea: Enum "NPR M2 Integration Area")
    begin
        if (Rec.Get(TableNo, IntegrationArea)) then
            exit;

        Rec.Init();
        Rec.Validate("Table No.", TableNo);
        Rec.Validate("Integration Area", IntegrationArea);
        Rec.Insert(true);
    end;
}