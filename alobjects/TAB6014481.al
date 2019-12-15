table 6014481 "Report Usage Setup"
{
    // NPR5.48/TJ  /20181108 CASE 324444 New object

    Caption = 'Report Usage Setup';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10;Enabled;Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            begin
                ReportUsageMgt.EnableDisableSetup(Enabled);
            end;
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ReportUsageMgt: Codeunit "Report Usage Mgt.";
}

