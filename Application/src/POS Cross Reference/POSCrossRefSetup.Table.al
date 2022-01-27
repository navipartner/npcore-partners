table 6014661 "NPR POS Cross Ref. Setup"
{
    Access = Internal;
    Caption = 'POS Cross Reference Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Cross Ref. Setup";
    LookupPageID = "NPR POS Cross Ref. Setup";

    fields
    {
        field(1; "Table Name"; Text[250])
        {
            Caption = 'Table Name';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object Name" where("Object Type" = const(Table));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                ValidateTableName();
            end;

            trigger OnLookup()
            begin
                LookupTableName();
            end;
        }
        field(20; "Reference No. Pattern"; Code[50])
        {
            Caption = 'Reference No. Pattern';
            DataClassification = CustomerContent;
        }
        field(21; "Pattern Guide"; Text[250])
        {
            Caption = 'Pattern Guide';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table Name")
        {
        }
    }

    procedure InitSetup(TableName: Text[250])
    begin
        Rec."Table Name" := TableName;
        if Find() then
            exit;
        Rec.init();
        Rec.Validate("Table Name");
        Rec.Insert(true);
    end;


    [IntegrationEvent(false, false)]
    procedure OnDiscoverSetup(var Setup: Record "NPR POS Cross Ref. Setup")
    begin
    end;

    procedure ValidateTableName()
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if Rec."Table Name" = '' then
            exit;
        AllObjWithCaption.Setrange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.Setrange("Object NAme", Rec."Table Name");
        AllObjWithCaption.FindFirst();
    end;

    procedure LookupTableName(): Boolean
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if Rec.LookupTable(AllObjWithCaption) then begin
            Rec."Table Name" := AllObjWithCaption."Object Name";
            exit(true);
        end;
    end;

    procedure LookupTable(var AllObjWithCaption: Record AllObjWithCaption): Boolean
    var
        TableObjects: Page "Table Objects";
        Result: Boolean;
    begin
        AllObjWithCaption.FilterGroup(2);
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.FilterGroup(0);
        TableObjects.SetTableView(AllObjWithCaption);
        TableObjects.SetRecord(AllObjWithCaption);
        TableObjects.LookupMode := true;
        Result := TableObjects.RunModal() = ACTION::LookupOK;
        if Result then
            TableObjects.GetRecord(AllObjWithCaption)
        else
            Clear(AllObjWithCaption);

        exit(Result);
    end;
}

