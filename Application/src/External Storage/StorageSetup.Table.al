table 6184892 "NPR Storage Setup"
{
    // NPR5.54/ALST/20200311 CASE 394895 Object created

    Caption = 'External Storage Setup';
    DataClassification = CustomerContent;
    LookupPageID = "NPR Storage Setup";

    fields
    {
        field(1; "Storage ID"; Text[24])
        {
            Caption = 'Storage ID';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                ExternalStorageInterface: Codeunit "NPR External Storage Interface";
            begin
                ExternalStorageInterface.OnConfigureSetup(Rec);
            end;
        }
        field(10; "Storage Type"; Code[20])
        {
            Caption = 'Storage Type';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                TempStorageType: Record "NPR Storage Type" temporary;
            begin
                if PAGE.RunModal(0, TempStorageType) <> ACTION::LookupOK then
                    exit;

                if "Storage Type" <> TempStorageType."Storage Type" then
                    Clear("Storage ID");

                "Storage Type" := TempStorageType."Storage Type";
            end;
        }
        field(20; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Storage ID", "Storage Type")
        {
        }
    }

    fieldgroups
    {
    }
}

