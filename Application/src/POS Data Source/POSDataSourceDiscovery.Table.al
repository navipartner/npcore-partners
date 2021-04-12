table 6150708 "NPR POS Data Source Discovery"
{
    Caption = 'POS Data Source';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Name; Code[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Name)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        MakeSureRecIsTemporary();
    end;

    var
        Text001: Label 'Registering a data source is only allowed on a temporary table. If you see this error message, and you are not a developer, this is a serious issue that you should report to the support immediately.';
        Text002: Label 'Data Source %1 has already been registered. This may indicate that two data source codeunits are using the same name. This is a programming bug, not a user error.';

    local procedure MakeSureRecIsTemporary()
    begin
        if not Rec.IsTemporary then
            Error(Text001);
    end;

    procedure RegisterDataSource(Name: Code[50]; Description: Text)
    begin
        MakeSureRecIsTemporary();

        Rec.Name := CopyStr(Name, 1, MaxStrLen(Rec.Name));
        if Rec.Find() then
            Error(Text002, Rec.Name);

        Rec.Description := CopyStr(Description, 1, MaxStrLen(Rec.Description));
        Rec.Insert();
    end;

    procedure LookupDataSource(var DataSourceName: Code[50]): Boolean
    var
        DataSources: Page "NPR POS Data Sources";
    begin
        DataSources.SetCurrent(DataSourceName);
        DataSources.LookupMode := true;
        if DataSources.RunModal() = ACTION::LookupOK then begin
            DataSourceName := DataSources.GetCurrent();
            exit(true);
        end;
        exit(false);
    end;

    procedure DiscoverDataSources()
    begin
        OnDiscoverDataSource(Rec);
    end;

    [BusinessEvent(false)]
    local procedure OnDiscoverDataSource(var Rec: Record "NPR POS Data Source Discovery")
    begin
    end;
}

