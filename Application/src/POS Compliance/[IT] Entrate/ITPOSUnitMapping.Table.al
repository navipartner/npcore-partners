table 6150739 "NPR IT POS Unit Mapping"
{
    Access = Internal;
    Caption = 'IT POS Unit Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR IT POS Unit Mapping";
    LookupPageId = "NPR IT POS Unit Mapping";

    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(2; "POS Unit Name"; Text[50])
        {
            CalcFormula = lookup("NPR POS Unit".Name where("No." = field("POS Unit No.")));
            Caption = 'POS Unit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; "Fiscal Printer IP Address"; Text[30])
        {
            Caption = 'Fiscal Printer IP Address';
            DataClassification = CustomerContent;
            CharAllowed = '09::..';

            trigger OnValidate()
            begin
                if "Fiscal Printer IP Address" = xRec."Fiscal Printer IP Address" then
                    exit;
                Clear("Fiscal Printer Serial No.");
                Clear("Fiscal Printer RT Type");
                Clear("Fiscal Printer Password");
            end;
        }
        field(11; "Fiscal Printer Serial No."; Text[10])
        {
            Caption = 'Fiscal Printer Serial No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Fiscal Printer RT Type"; Text[1])
        {
            Caption = 'Fiscal Printer RT Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "Fiscal Printer Password"; Text[40])
        {
            Caption = 'Fiscal Printer Password';
            DataClassification = CustomerContent;
            CharAllowed = '09';
            ExtendedDatatype = Masked;
        }
        field(15; "Fiscal Printer Logo"; Media)
        {
            Caption = 'Fiscal Printer Logo';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Unit No.")
        {
            Clustered = true;
        }
    }
#if not (BC17 or BC18 or BC19)
    internal procedure ConvertLogoToBase64(): Text
    var
        TempBlob: Codeunit "Temp Blob";
        Image: Codeunit Image;
        OStream: OutStream;
        IStream: InStream;
        POSLogoNotUploadedInSetupErr: Label '%1 has not been uploaded to %2.';
    begin
        if not "Fiscal Printer Logo".HasValue() then
            Error(POSLogoNotUploadedInSetupErr, FieldCaption("Fiscal Printer Logo"), TableCaption);

        TempBlob.CreateOutStream(OStream);
        "Fiscal Printer Logo".ExportStream(OStream);
        TempBlob.CreateInStream(IStream);
        Image.FromStream(IStream);
        Image.SetFormat(Enum::"Image Format"::Bmp);
        Image.Save(OStream);
        exit(Image.ToBase64());
    end;
#endif
    internal procedure ImportFPLogo()
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        LogoUploadCap: Label 'Fiscal Printer Logo Image';
        MaxFileSizeErr: Label 'Maximum supported image size is 20KB.';
        SuccessfullLogoUploadMsg: Label 'Fiscal Printer Logo has successfully been uploaded.';
        OverwriteLogoCap: Label 'Are you sure you want to overwrite the existing Fiscal Printer Logo?';
        IStream: InStream;
    begin
        if "Fiscal Printer Logo".HasValue() then
            if not Confirm(OverwriteLogoCap) then
                exit;
        TempBlob.CreateInStream(IStream);
        FileMgt.BLOBImportWithFilter(TempBlob, LogoUploadCap, '', 'Image Files (*.BMP)|*.BMP', 'bmp');
        if not TempBlob.HasValue() then
            exit;
        if TempBlob.Length() > 20000 then
            Error(MaxFileSizeErr);
        "Fiscal Printer Logo".ImportStream(IStream, FieldName("Fiscal Printer Logo"));
        Modify();
        Message(SuccessfullLogoUploadMsg);
    end;

    internal procedure ExportFPLogo()
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        LogoFieldEmptyErr: Label 'Fiscal Printer Logo Field is empty.';
    begin
        if not "Fiscal Printer Logo".HasValue() then
            Error(LogoFieldEmptyErr);
        TempBlob.CreateOutStream(OutStr);
        "Fiscal Printer Logo".ExportStream(OutStr);
        FileManagement.BLOBExport(TempBlob, "POS Unit Name" + '.bmp', true);
    end;
}