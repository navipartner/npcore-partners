table 6059793 "NPR POS Layout"
{
    Access = Internal;
    Caption = 'POS Layout';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Layouts";
    LookupPageID = "NPR POS Layouts";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Frontend Properties"; Blob)
        {
            Caption = 'Frontend Properties';
            DataClassification = CustomerContent;
        }
        field(4; "Template Name"; Text[100])
        {
            Caption = 'Template Name';
            DataClassification = CustomerContent;
        }
        field(200; "No. of Archived Versions"; Integer)
        {
            Caption = 'No. of Archived Versions';
            FieldClass = FlowField;
            CalcFormula = Max("NPR POS Layout Archive"."Version No." WHERE("Code" = FIELD("Code")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        POSUnit: Record "NPR POS Unit";
        LayoutIsInUseErr: Label 'You cannot delete %1 "%2" because it is currently assigned to one or more POS units.', Comment = '%1 = POS Layout tablecation, %2 = table "POS Layout" field "Code" caption, %3 = "NPR POS View Profiles" page caption';
    begin
        POSUnit.SetRange("POS Layout Code", Code);
        if not POSUnit.IsEmpty() then
            Error(LayoutIsInUseErr, TableCaption, Code);
    end;

    procedure GetLayot(ReadFromDB: Boolean) Text: Text
    var
        InStream: InStream;
    begin
        if not "Frontend Properties".HasValue() then
            exit;

        if ReadFromDB then
            CalcFields("Frontend Properties");
        "Frontend Properties".CreateInStream(InStream, TExtEncoding::UTF8);
        InStream.Read(Text);
    end;

    procedure SetLayout(Text: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Frontend Properties");
        "Frontend Properties".CreateOutStream(OutStream, Textencoding::UTF8);
        OutStream.Write(Text);
    end;

    procedure AssignedToPOSUnitsFilter(): Text
    var
        POSUnit: Record "NPR POS Unit";
        POSUnitList: Page "NPR POS Unit List";
    begin
        POSUnit.SetRange("POS Layout Code", Code);
        if POSUnit.IsEmpty() then
            exit('');
        exit(POSUnitList.GetSelectionFilter(POSUnit));
    end;

    procedure AssignedToPOSUnits() JArray: JsonArray
    var
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.SetRange("POS Layout Code", Code);
        if POSUnit.IsEmpty() then
            exit;

        if POSUnit.FindSet() then
            repeat
                JArray.Add(POSUnit."No.");
            until POSUnit.Next() = 0;
    end;
}
