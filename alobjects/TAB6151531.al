table 6151531 "Nc Endpoint Type"
{
    // NC2.01\BR\20160921  CASE 248630 Object created

    Caption = 'Nc Endpoint Type';
    DataClassification = CustomerContent;
    DrillDownPageID = "Nc Endpoint Types";
    LookupPageID = "Nc Endpoint Types";

    fields
    {
        field(10; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            TableRelation = "Nc Endpoint FTP";
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

    procedure SetupEndpointTypes()
    begin
        OnSetupEndpointTypes;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupEndpointTypes()
    begin
    end;
}

