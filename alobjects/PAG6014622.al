page 6014622 "POS Web Fonts"
{
    // NPR4.12/VB/20150707 CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.14/VB/20150909 CASE 222602 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.14/VB/20150925 CASE 222938 Version increase for NaviPartner.POS.Web assembly reference(s), due to refactoring of QUANTITY_POS and QUANTITY_NEG functions.
    // NPR4.14/VB/20150930 CASE 224166 Added the icon font preview feature
    // NPR4.15/VB/20150930 CASE 224237 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR5.00/VB/20150104 CASE 225607 Changed references for compiling under NAV 2016
    // NPR5.00/VB/20160106 CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0
    // NPR5.01/VB/20160222 CASE 234462 Export Manifest file to managed services
    // NPR5.32.10/MMV /20170308 CASE 265454 Changed export manifest action.
    // NPR5.32.10/MMV /20170609 CASE 280081 Added support for payload versions in manifest.

    Caption = 'POS Web Fonts';
    PageType = List;
    SourceTable = "POS Web Font";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field("Company Name";"Company Name")
                {
                }
                field(Name;Name)
                {
                }
                field("Font Face";"Font Face")
                {
                }
                field(Prefix;Prefix)
                {
                }
                field("FORMAT(WoffHasValue)";Format(WoffHasValue))
                {
                    Caption = 'Woff Exists';
                    Editable = false;
                }
                field("FORMAT(CssHasValue)";Format(CssHasValue))
                {
                    Caption = 'Css Exists';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Font (Woff)")
            {
                Caption = 'Font (Woff)';
                action("Import Font")
                {
                    Caption = 'Import Font';
                    Image = Attach;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        ImportFont();
                    end;
                }
                action("Export Font")
                {
                    Caption = 'Export Font';
                    Enabled = WoffHasValue;
                    Image = ExportAttachment;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        ExportFont();
                    end;
                }
                action("Remove Font")
                {
                    Caption = 'Remove Font';
                    Enabled = WoffHasValue;
                    Image = CancelAttachment;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        RemoveFont();
                    end;
                }
            }
            group("Stylesheet (Css)")
            {
                Caption = 'Stylesheet (Css)';
                action("Import Stylesheet")
                {
                    Caption = 'Import Stylesheet';
                    Image = XMLFile;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        ImportCss();
                    end;
                }
                action("Export Stylesheet")
                {
                    Caption = 'Export Stylesheet';
                    Enabled = CssHasValue;
                    Image = ExportElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        ExportCss();
                    end;
                }
                action("Remove Stylesheet")
                {
                    Caption = 'Remove Stylesheet';
                    Enabled = CssHasValue;
                    Image = DeleteXML;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        RemoveCss();
                    end;
                }
            }
            group(Configuration)
            {
                Caption = 'Configuration';
                action("Export Font Configuration")
                {
                    Caption = 'Export Font Configuration';
                    Image = Export;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        ExportConfiguration();
                    end;
                }
                action("Import Font Configuration")
                {
                    Caption = 'Import Font Configuration';
                    Image = Import;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        ImportConfiguration();
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
                        Rec2: Record "POS Web Font";
                        JArray: DotNet JArray;
                    begin
                        CurrPage.SetSelectionFilter(Rec2);
                        //-NPR5.32.10 [265454]
                        //ManagedDepMgt.ExportManifest(Rec2);
                        JArray := JArray.JArray();
                        ManagedDepMgt.RecordToJArray(Rec2, JArray);
                        ManagedDepMgt.ExportManifest(Rec2, JArray, 0);
                        //+NPR5.32.10 [265454]
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateWoffCss();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateWoffCss();
    end;

    var
        WoffHasValue: Boolean;
        CssHasValue: Boolean;
        Text001: Label '%1 already contains data. Do you want to overwrite it?';
        Text002: Label 'Import %1';
        Text003: Label 'Export %1';
        Text004: Label 'Web Open Font Files';
        Text005: Label 'Cascading Style Sheet Files';
        Text006: Label 'All Files';
        Text007: Label '%1 contains no data.';
        Text008: Label 'NaviPartner Font Definition File';
        Text009: Label 'What do you want to do:';
        Text010: Label 'Cancel,Create or update font (%1 %2),Update current font (%3 %4)';

    local procedure UpdateWoffCss()
    begin
        WoffHasValue := Woff.HasValue;
        CssHasValue := Css.HasValue;
    end;

    local procedure ImportFont()
    var
        TempBLOB: Record TempBlob;
    begin
        TempBLOB.Blob := Woff;
        if ImportWithDialog(TempBLOB,Woff.HasValue,FieldCaption(Woff),Text004,'woff') then begin
          Woff := TempBLOB.Blob;
          CurrPage.Update(true);
        end;
    end;

    local procedure ExportFont()
    var
        TempBLOB: Record TempBlob;
    begin
        TempBLOB.Blob := Woff;
        ExportWithDialog(TempBLOB,Woff.HasValue,FieldCaption(Woff),'woff');
    end;

    local procedure RemoveFont()
    begin
        Clear(Woff);
        CurrPage.Update(true);
    end;

    local procedure ImportCss()
    var
        TempBLOB: Record TempBlob;
    begin
        TempBLOB.Blob := Css;
        if ImportWithDialog(TempBLOB,Css.HasValue,FieldCaption(Css),Text005,'css') then begin
          Css := TempBLOB.Blob;
          CurrPage.Update(true);
        end;
    end;

    local procedure ExportCss()
    var
        TempBLOB: Record TempBlob;
    begin
        TempBLOB.Blob := Css;
        ExportWithDialog(TempBLOB,Css.HasValue,FieldCaption(Css),'css');
    end;

    local procedure RemoveCss()
    begin
        Clear(Css);
        CurrPage.Update(true);
    end;

    local procedure ExportConfiguration()
    var
        TempBlob: Record TempBlob;
        Font: DotNet npNetFont;
        JsonSerializer: DotNet npNetDataContractJsonSerializer;
        OutStr: OutStream;
    begin
        GetFontDotNet_Obsolete(Font);
        JsonSerializer := JsonSerializer.DataContractJsonSerializer(GetDotNetType(Font));

        TempBlob.Blob.CreateOutStream(OutStr);
        JsonSerializer.WriteObject(OutStr,Font);

        ExportWithDialog(TempBlob,true,Text008,'npfont');
    end;

    local procedure ImportConfiguration()
    var
        WebFont: Record "POS Web Font";
        TempBlob: Record TempBlob;
        Font: DotNet npNetFont;
        JsonSerializer: DotNet npNetDataContractJsonSerializer;
        InStr: InStream;
        Choice: Integer;
    begin
        if ImportWithDialog(TempBlob,Css.HasValue or Woff.HasValue,TableCaption,Text008,'npfont') then begin
          JsonSerializer := JsonSerializer.DataContractJsonSerializer(GetDotNetType(Font));

          TempBlob.Blob.CreateInStream(InStr);
          Font := JsonSerializer.ReadObject(InStr);

          case true of
            not Find():
              begin
                Init;
                Code := Font.Code;
                Insert(true);
              end;
            (Code = '') and (Font.Code = ''):
              FieldError(Code);
            (Code = '') and (Font.Code <> ''):
              Code := Font.Code;
            (Code <> '') and (Font.Code <> '') and (Font.Code <> Code):
              begin
                Choice := StrMenu(StrSubstNo(Text010,Font.Code,Font.Name,Code,Name),1,Text009);
                if Choice <= 1 then
                  exit;
                if Choice = 2 then begin
                  WebFont.Code := Font.Code;
                  WebFont.Insert(true);
                  SaveFontConfiguration(WebFont,Font);
                  CurrPage.Update(false);
                  exit;
                end;
              end;
          end;

          SaveFontConfiguration(Rec,Font);
          CurrPage.Update(false);
        end;
    end;

    local procedure SaveFontConfiguration(WebFont: Record "POS Web Font";Font: DotNet npNetFont)
    var
        OutStr: OutStream;
    begin
        with WebFont do begin
          Name := Font.Name;
          "Font Face" := Font.FontFace;
          Prefix := Font.Prefix;

          Woff.CreateOutStream(OutStr);
          Font.CopyWoffToStream(OutStr);
          Css.CreateOutStream(OutStr);
          Font.CopyCssToStream(OutStr);
          Modify(true);
        end;
    end;

    local procedure ImportWithDialog(var TempBLOB: Record TempBlob;HasValue: Boolean;"Field": Text;FileType: Text;FileExt: Text): Boolean
    var
        FileManagement: Codeunit "File Management";
        ResourceName: Text;
    begin
        if HasValue then
          if not Confirm(Text001,false,Field) then
            exit;

        ResourceName := FileManagement.BLOBImportWithFilter(
          TempBLOB,StrSubstNo(Text002,Field),'',
          FileType + ' (*.' + FileExt + ')|*.' + FileExt + '|' + Text006 + ' (*.*)|*.*','*.*');

        exit(ResourceName <> '');
    end;

    local procedure ExportWithDialog(var TempBLOB: Record TempBlob;HasValue: Boolean;"Field": Text;FileExt: Text)
    var
        FileManagement: Codeunit "File Management";
    begin
        if not HasValue then begin
          Message(Text007,Field);
          exit;
        end;

        FileManagement.BLOBExport(TempBLOB,Name + '.' + FileExt,true);
    end;
}

