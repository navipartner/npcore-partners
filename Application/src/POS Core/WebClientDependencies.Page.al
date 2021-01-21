page 6014659 "NPR Web Client Dependencies"
{
    Caption = 'Web Client Dependencies';
    PageType = List;
    SourceTable = "NPR Web Client Dependency";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("BLOB.HASVALUE"; Rec.BLOB.HasValue())
                {
                    ApplicationArea = All;
                    Caption = 'BLOB Imported';
                    ToolTip = 'Specifies the value of the BLOB Imported field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Import File...")
            {
                Caption = 'Import File...';
                Image = ImportDatabase;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Import File... action';

                trigger OnAction()
                begin
                    ImportFile();
                end;
            }
            action("Export Managed Dependency Manifest")
            {
                Caption = 'Export Managed Dependency Manifest';
                Image = ExportElectronicDocument;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Export Managed Dependency Manifest action';

                trigger OnAction()
                var
                    Rec2: Record "NPR Web Client Dependency";
                    ManagedDepMgt: Codeunit "NPR Managed Dependency Mgt.";
                    JArray: JsonArray;
                begin
                    CurrPage.SetSelectionFilter(Rec2);
                    ManagedDepMgt.RecordToJArray(Rec2, JArray);
                    ManagedDepMgt.ExportManifest(Rec2, JArray, 0);
                end;
            }
            action("Export File")
            {
                Caption = 'Export File';
                Image = ExportFile;
                ApplicationArea = All;
                ToolTip = 'Executes the Export File action';

                trigger OnAction()
                begin
                    ExportFile();
                end;
            }
        }
    }

    var
        TextUnsupportedFormat: Label 'You have specified a file in an unsupported format. Supported formats are JPG, PNG, and GIF.';

    procedure ImportFile()
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        InStr: InStream;
        OutStr: OutStream;
        AllFilesTxt: Label 'All Files';
        JavaScriptFilesTxt: Label 'JavaScript Files';
        StyleSheetFilesTxt: Label 'StyleSheet Files';
        HtmlFilesTxt: Label 'Html Documents';
        SvgFilesTxt: Label 'Scalable Vector Graphics Files';
        ImportTitleTxt: Label 'Import Web Client Dependency Files';
        ImportFilter: Text;
        FileName: Text;
    begin
        case Rec.Type of
            Rec.Type::JavaScript:
                ImportFilter := JavaScriptFilesTxt + ' (*.js)|*.js|';
            Rec.Type::CSS:
                ImportFilter := StyleSheetFilesTxt + ' (*.css)|*.css|';
            Rec.Type::HTML:
                ImportFilter := HtmlFilesTxt + ' (*.html)|*.html|';
            Rec.Type::SVG:
                ImportFilter := SvgFilesTxt + ' (*.svg)|*.svg|';
        end;

        FileName := FileManagement.BLOBImportWithFilter(
          TempBlob, ImportTitleTxt, '',
          ImportFilter + AllFilesTxt + ' (*.*)|*.*', '*.*');

        if FileName <> '' then begin
            TempBlob.CreateInStream(InStr);
            Rec.BLOB.CreateOutStream(OutStr);
            if Rec.Type = Rec.Type::DataUri then
                ConvertImgToDataUri(InStr, OutStr)
            else
                if Rec.Type = Rec.Type::SVG then begin
                    ConvertSVGToDataUri(InStr, OutStr);
                end else
                    CopyStream(OutStr, InStr);
            CurrPage.Update(true);
        end;
    end;

    procedure ExportFile()
    var
        FileBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        fPath: Text[1024];
    begin
        if Rec.BLOB.HasValue() then begin
            Rec.CalcFields(BLOB);

            case Rec.Type of
                Rec.Type::JavaScript:
                    fPath := Rec.Code + '.js';
                Rec.Type::CSS:
                    fPath := Rec.Code + '.css';
                Rec.Type::HTML:
                    fPath := Rec.Code + '.html';
                Rec.Type::SVG:
                    fPath := Rec.Code + '.svg';
            end;

            FileBlob.FromRecord(Rec, FieldNo(BLOB));
            FileManagement.BLOBExport(FileBlob, fPath, true);
        end;
    end;

    procedure ConvertImgToDataUri(InStr: InStream; var OutStr: OutStream)
    var
        Convert: DotNet NPRNetConvert;
        Image: DotNet NPRNetImage;
        ImageFormat: DotNet NPRNetImageFormat;
        MemStrIn: DotNet NPRNetMemoryStream;
        MemStrOut: DotNet NPRNetMemoryStream;
        Encoding: DotNet NPRNetEncoding;
        DataUri: Text;
    begin
        DataUri := 'data:image/';

        CalcFields(BLOB);
        MemStrIn := MemStrIn.MemoryStream();
        CopyStream(MemStrIn, InStr);
        Image := Image.FromStream(MemStrIn);
        ImageFormat := Image.RawFormat;
        case true of
            ImageFormat.Equals(ImageFormat.Gif):
                DataUri += 'gif';
            ImageFormat.Equals(ImageFormat.Jpeg):
                DataUri += 'jpg';
            ImageFormat.Equals(ImageFormat.Png):
                DataUri += 'png';
            else
                Error(TextUnsupportedFormat);
        end;
        DataUri += ';base64,' + Convert.ToBase64String(MemStrIn.ToArray());

        MemStrOut := MemStrOut.MemoryStream(Encoding.UTF8.GetBytes(DataUri));
        CopyStream(OutStr, MemStrOut);
    end;

    procedure ConvertSVGToDataUri(InStr: InStream; var OutStr: OutStream)
    var
        Convert: DotNet NPRNetConvert;
        MemStrIn: DotNet NPRNetMemoryStream;
        MemStrOut: DotNet NPRNetMemoryStream;
        Encoding: DotNet NPRNetEncoding;
        DataUri: Text;
        SVGText: Text;
    begin
        DataUri := 'data:image/svg+xml;base64,';

        CalcFields(BLOB);
        MemStrIn := MemStrIn.MemoryStream();
        CopyStream(MemStrIn, InStr);
        SVGText := CheckNamespaces(Encoding.UTF8.GetString(MemStrIn.ToArray()));
        DataUri += Convert.ToBase64String(Encoding.UTF8.GetBytes(SVGText));
        MemStrOut := MemStrOut.MemoryStream(Encoding.UTF8.GetBytes(DataUri));
        CopyStream(OutStr, MemStrOut);
    end;

    local procedure CheckNamespaces(SVGText: Text): Text
    begin
        if StrPos(SVGText, 'xmlns=') = 0 then
            SVGText := InsStr(SVGText, 'xmlns="http://www.w3.org/2000/svg" ', StrPos(SVGText, '<svg') + 5);
        if StrPos(SVGText, 'xlink') <> 0 then
            SVGText := InsStr(SVGText, 'xmlns:xlink="http://www.w3.org/1999/xlink" ', StrPos(SVGText, '<svg') + 5);
        exit(SVGText);
    end;
}

