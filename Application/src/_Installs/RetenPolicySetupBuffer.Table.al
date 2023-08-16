table 6059993 "NPR Reten. Policy Setup Buffer"
{
    Access = Internal;
    Caption = 'Retention Policy Setup Buffer';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Table Id"; Integer)
        {
            BlankZero = true;
            DataClassification = SystemMetadata;
            MaxValue = 1999999999;
            MinValue = 0;
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(4; "Retention Period"; Code[20])
        {
            DataClassification = SystemMetadata;
            TableRelation = "Retention Period";
        }
        field(5; Enabled; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(6; "Apply to All Records"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PrimaryKey; "Table Id")
        {
            Clustered = true;
        }
    }
}
