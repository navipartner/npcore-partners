page 6014659 "Web Client Dependencies"
{
    // NPR5.00/VB/20151130 CASE 226832 Object created to support dynamic Web client objects (scripts, stylesheets, HTML, and image data uris)
    // NPR5.01/VB/20160222 CASE 234462 Export Manifest file to managed services
    // NPR5.25/TTH/20160718 CASE 238859 Added Special handling for vector graphics.
    // NPR5.32.10/MMV /20170308 CASE 265454 Changed export manifest action.
    // NPR5.32.10/MMV /20170609 CASE 280081 Added support for payload versions in manifest.
    // NPR5.38/CLVA/20170628 CASE 271423 Added Export functionality

    Caption = 'Web Client Dependencies';
    PageType = List;
    SourceTable = "Web Client Dependency";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("BLOB.HASVALUE"; BLOB.HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'BLOB Imported';
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
                PromotedCategory = Process;
                PromotedIsBig = true;

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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ManagedDepMgt: Codeunit "Managed Dependency Mgt.";
                    Rec2: Record "Web Client Dependency";
                    JArray: DotNet JArray;
                begin
                    CurrPage.SetSelectionFilter(Rec2);
                    //-NPR5.32.10 [265454]
                    JArray := JArray.JArray();
                    ManagedDepMgt.RecordToJArray(Rec2, JArray);
                    ManagedDepMgt.ExportManifest(Rec2, JArray, 0);
                    //ManagedDepMgt.ExportManifest(Rec2);
                    //+NPR5.32.10 [265454]
                end;
            }
            action("Export File")
            {
                Caption = 'Export File';
                Image = ExportFile;

                trigger OnAction()
                begin
                    //-NPR5.38
                    ExportFile;
                    //+NPR5.38
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
        Asm: DotNet npNetAssembly;
        InStr: InStream;
        OutStr: OutStream;
        FileName: Text;
        AllFilesTxt: Label 'All Files';
        JavaScriptFilesTxt: Label 'JavaScript Files';
        StyleSheetFilesTxt: Label 'StyleSheet Files';
        HtmlFilesTxt: Label 'Html Documents';
        SvgFilesTxt: Label 'Scalable Vector Graphics Files';
        ImportTitleTxt: Label 'Import Web Client Dependency Files';
        ImportFilter: Text;
    begin
        case Type of
            Type::JavaScript:
                ImportFilter := JavaScriptFilesTxt + ' (*.js)|*.js|';
            Type::CSS:
                ImportFilter := StyleSheetFilesTxt + ' (*.css)|*.css|';
            Type::HTML:
                ImportFilter := HtmlFilesTxt + ' (*.html)|*.html|';
            Type::SVG:
                ImportFilter := SvgFilesTxt + ' (*.svg)|*.svg|';
        end;

        FileName := FileManagement.BLOBImportWithFilter(
          TempBlob, ImportTitleTxt, '',
          ImportFilter + AllFilesTxt + ' (*.*)|*.*', '*.*');

        if FileName <> '' then begin
            TempBlob.CreateInStream(InStr);
            BLOB.CreateOutStream(OutStr);
            if Type = Type::DataUri then
                ConvertImgToDataUri(InStr, OutStr)
            //-NPR5.25
            else
                if Type = Type::SVG then begin
                    ConvertSVGToDataUri(InStr, OutStr);
                end
                //+NPR5.25
                else
                    CopyStream(OutStr, InStr);
            CurrPage.Update(true);
        end;
    end;

    procedure ExportFile()
    var
        FileManagement: Codeunit "File Management";
        fPath: Text[1024];
        FileBlob: Codeunit "Temp Blob";
    begin
        //-NPR5.38
        if BLOB.HasValue then begin
            CalcFields(BLOB);

            case Type of
                Type::JavaScript:
                    fPath := Code + '.js';
                Type::CSS:
                    fPath := Code + '.css';
                Type::HTML:
                    fPath := Code + '.html';
                Type::SVG:
                    fPath := Code + '.svg';
            end;

            FileBlob.FromRecord(Rec, FieldNo(BLOB));
            FileManagement.BLOBExport(FileBlob, fPath, true);
        end;
        //+NPR5.38
    end;

    procedure ConvertImgToDataUri(InStr: InStream; var OutStr: OutStream)
    var
        Convert: DotNet npNetConvert;
        Image: DotNet npNetImage;
        ImageFormat: DotNet npNetImageFormat;
        MemStrIn: DotNet npNetMemoryStream;
        MemStrOut: DotNet npNetMemoryStream;
        Encoding: DotNet npNetEncoding;
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
        Convert: DotNet npNetConvert;
        Image: DotNet npNetImage;
        ImageFormat: DotNet npNetImageFormat;
        MemStrIn: DotNet npNetMemoryStream;
        MemStrOut: DotNet npNetMemoryStream;
        Encoding: DotNet npNetEncoding;
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

