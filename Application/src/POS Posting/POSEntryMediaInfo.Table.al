table 6014680 "NPR POS Entry Media Info"
{
    Caption = 'POS Entry Media Info';
    DataClassification = ToBeClassified;
    Extensible = False;
    Access = Internal;
    LookupPageId = "NPR POS Entry Media Info List";
    DrillDownPageId = "NPR POS Entry Media Info List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Pos Entry No."; Integer)
        {
            Caption = 'Pos Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "NPR POS Entry"."Entry No.";
            NotBlank = true;
        }
        field(10; Image; Media)
        {
            Caption = 'Image';
            DataClassification = CustomerContent;
        }
        field(20; Comment; Text[100])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(POSEntry; "Pos Entry No.")
        {

        }
    }

    local procedure InitNewEntry(var POSEntryMediaInfo: Record "NPR POS Entry Media Info"; POSEntry: Record "NPR POS Entry")
    begin
        POSEntry.TestField("Entry No.");
        POSEntryMediaInfo.Init();
        POSEntryMediaInfo."Entry No." := 0;
        POSEntryMediaInfo."Pos Entry No." := POSEntry."Entry No.";
    end;

    local procedure CheckOverrideImage(POSEntryMediaInfo: Record "NPR POS Entry Media Info")
    var
        OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?';
    begin
        if POSEntryMediaInfo.Image.HasValue then
            if not Confirm(OverrideImageQst, false) then
                Error('');
    end;

    procedure ImportImage(var POSEntryMediaInfo: Record "NPR POS Entry Media Info")
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        InStr: Instream;

    begin
        CheckOverrideImage(POSEntryMediaInfo);

        FileManagement.BLOBImport(TempBlob, '');
        if not TempBlob.Hasvalue() then
            Error('');

        TempBlob.CreateInStream(InStr);
        Clear(POSEntryMediaInfo.Image);
        POSEntryMediaInfo.Image.ImportStream(InStr, POSEntryMediaInfo.FieldCaption(Image));
    end;

    procedure SetImageFromCamera(var POSEntryMediaInfo: Record "NPR POS Entry Media Info")
    var
        Camera: Page "NPR NPCamera";
        inStr: InStream;
    begin
        CheckOverrideImage(POSEntryMediaInfo);
        if (Camera.TakePicture(inStr)) then
            POSEntryMediaInfo.Image.ImportStream(inStr, POSEntryMediaInfo.FieldName(Image))
        else
            Error('');

    end;

    procedure CreateNewEntry(POSEntry: Record "NPR POS Entry"; GetImageFrom: Option Import,Camera; OpenList: Boolean)
    var
        POSEntryMediaInfo: Record "NPR POS Entry Media Info";
    begin
        InitNewEntry(POSEntryMediaInfo, POSEntry);

        case GetImageFrom of
            GetImageFrom::Import:
                ImportImage(POSEntryMediaInfo);
            GetImageFrom::Camera:
                SetImageFromCamera(POSEntryMediaInfo);
        end;

        POSEntryMediaInfo.Insert(true);

        if OpenList then begin
            POSEntryMediaInfo.Reset();
            POSEntryMediaInfo.SetRange("Pos Entry No.", POSEntry."Entry No.");
            Page.Run(0, POSEntryMediaInfo);
        end;
    end;

    procedure CreateNewEntry2(POSEntryNo: Integer; GetImageFrom: Option Import,Camera; OpenList: Boolean)
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.Get(POSEntryNo);
        CreateNewEntry(POSEntry, GetImageFrom, OpenList);
    end;
}
