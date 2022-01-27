page 6014659 "NPR Web Client Dependencies"
{
    Extensible = False;
    Caption = 'Web Client Dependencies';
    PageType = List;
    SourceTable = "NPR Web Client Dependency";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("BLOB Imported"; Rec.BLOB.HasValue())
                {

                    Caption = 'BLOB Imported';
                    ToolTip = 'Specifies the value of the BLOB Imported field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Import File... action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Export Managed Dependency Manifest action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Export File action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    ExportFile();
                end;
            }
        }
    }

    local procedure ImportFile()
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

            case Rec.Type of
                Rec.Type::DataUri:
                    ConvertImgToDataUri(InStr, OutStr);
                Rec.Type::SVG:
                    ConvertSVGToDataUri(InStr, OutStr);
                else
                    CopyStream(OutStr, InStr);
            end;

            CurrPage.Update(true);
        end;
    end;

    local procedure ExportFile()
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

            FileBlob.FromRecord(Rec, Rec.FieldNo(BLOB));
            FileManagement.BLOBExport(FileBlob, fPath, true);
        end;
    end;

    local procedure ConvertImgToDataUri(InStr: InStream; var OutStr: OutStream)
    var
        Ext: Text;
        DataUri: Text;
        ImageFormat: Codeunit "NPR Image Format";
        Base64: Codeunit "Base64 Convert";
        UnsupportedFormatErr: Label 'You have specified a file in an unsupported image format.';
        DataUriLabel: Label 'data:image/%1;base64,%2', Locked = true;
    begin
        Ext := ImageFormat.GetImageExtensionFromHeader(InStr);
        if Ext = '' then
            Error(UnsupportedFormatErr);

        DataUri := StrSubstNo(DataUriLabel, Ext, Base64.ToBase64(InStr));
        OutStr.WriteText(DataUri);
    end;

    local procedure ConvertSVGToDataUri(InStm: InStream; var OutStm: OutStream)
    var
        DataUri: Text;
        SVGText: Text;
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
    begin
        DataUri := 'data:image/svg+xml;base64,';
        Rec.CalcFields(BLOB);
        InStm.ReadText(SVGText);
        SVGText := CheckNamespaces(SVGText);
        DataUri := DataUri + Base64Convert.ToBase64(SVGText);
        TempBlob.CreateOutStream(OutStm);
        OutStm.WriteText(DataUri);
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

