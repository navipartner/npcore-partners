﻿page 6014622 "NPR POS Web Fonts"
{
    Extensible = False;
    Caption = 'POS Web Fonts';
    PageType = List;
    SourceTable = "NPR POS Web Font";
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR31.0';
    ObsoleteReason = 'New POS frontend+editor will no longer support customer specific injected web scripts/styling/html/fonts';


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Company Name"; Rec."Company Name")
                {

                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Font Face"; Rec."Font Face")
                {

                    ToolTip = 'Specifies the value of the Font Face field';
                    ApplicationArea = NPRRetail;
                }
                field(Prefix; Rec.Prefix)
                {

                    ToolTip = 'Specifies the value of the Prefix field';
                    ApplicationArea = NPRRetail;
                }
                field("Woff Exists"; Format(WoffHasValue))
                {

                    Caption = 'Woff Exists';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Woff Exists field';
                    ApplicationArea = NPRRetail;
                }
                field("Css Exists"; Format(CssHasValue))
                {

                    Caption = 'Css Exists';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Css Exists field';
                    ApplicationArea = NPRRetail;
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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Import Font action';
                    ApplicationArea = NPRRetail;

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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Export Font action';
                    ApplicationArea = NPRRetail;

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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Remove Font action';
                    ApplicationArea = NPRRetail;

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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Import Stylesheet action';
                    ApplicationArea = NPRRetail;

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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Export Stylesheet action';
                    ApplicationArea = NPRRetail;

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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Remove Stylesheet action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Export Font Configuration action';
                    PromotedCategory = Process;
                    Promoted = true;
                    PromotedOnly = true;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ExportConfiguration();
                    end;
                }
                action("Import Font Configuration")
                {
                    Caption = 'Import Font Configuration';
                    Image = Import;

                    ToolTip = 'Executes the Import Font Configuration action';
                    PromotedCategory = Process;
                    Promoted = true;
                    PromotedOnly = true;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ImportConfiguration();
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
        Text004: Label 'Web Open Font Files';
        Text005: Label 'Cascading Style Sheet Files';
        Text006: Label 'All Files';
        Text007: Label '%1 contains no data.';
        Text008: Label 'NaviPartner Font Definition File';
        Text009: Label 'What do you want to do:';
        Text010: Label 'Cancel,Create or update font (%1 %2),Update current font (%3 %4)';

    local procedure UpdateWoffCss()
    begin
        WoffHasValue := Rec.Woff.HasValue;
        CssHasValue := Rec.Css.HasValue;
    end;

    local procedure ImportFont()
    var
        TempBLOB: Codeunit "Temp Blob";
        RecRef: RecordRef;
    begin
        TempBLOB.FromRecord(Rec, Rec.FieldNo(Woff));
        if ImportWithDialog(TempBLOB, Rec.Woff.HasValue, Rec.FieldCaption(Woff), Text004, 'woff') then begin
            RecRef.GetTable(Rec);
            TempBlob.ToRecordRef(RecRef, Rec.FieldNo(Woff));
            RecRef.SetTable(Rec);
            CurrPage.Update(true);
        end;
    end;

    local procedure ExportFont()
    var
        TempBLOB: Codeunit "Temp Blob";
    begin
        TempBLOB.FromRecord(Rec, Rec.FieldNo(Woff));
        ExportWithDialog(TempBLOB, Rec.Woff.HasValue, Rec.FieldCaption(Woff), 'woff');
    end;

    local procedure RemoveFont()
    begin
        Clear(Rec.Woff);
        CurrPage.Update(true);
    end;

    local procedure ImportCss()
    var
        TempBLOB: Codeunit "Temp Blob";
        RecRef: RecordRef;
    begin
        TempBLOB.FromRecord(Rec, Rec.FieldNo(Css));
        if ImportWithDialog(TempBLOB, Rec.Css.HasValue, Rec.FieldCaption(Css), Text005, 'css') then begin
            RecRef.GetTable(Rec);
            TempBlob.ToRecordRef(RecRef, Rec.FieldNo(Css));
            RecRef.SetTable(Rec);
            CurrPage.Update(true);
        end;
    end;

    local procedure ExportCss()
    var
        TempBLOB: Codeunit "Temp Blob";
    begin
        TempBLOB.FromRecord(Rec, Rec.FieldNo(Css));
        ExportWithDialog(TempBLOB, Rec.Css.HasValue, Rec.FieldCaption(Css), 'css');
    end;

    local procedure RemoveCss()
    begin
        Clear(Rec.Css);
        CurrPage.Update(true);
    end;

    local procedure ExportConfiguration()
    var
        TempBlob: Codeunit "Temp Blob";
        Font: Codeunit "NPR Web Font";
        OutStr: OutStream;
    begin
        Rec.GetWebFont(Font);
        TempBlob.CreateOutStream(OutStr);
        Font.GetJson().WriteTo(OutStr);

        ExportWithDialog(TempBlob, true, Text008, 'npfont');
    end;

    local procedure ImportConfiguration()
    var
        WebFont: Record "NPR POS Web Font";
        TempBlob: Codeunit "Temp Blob";
        Font: Codeunit "NPR Web Font";
        InStr: InStream;
        Choice: Integer;
    begin
        if ImportWithDialog(TempBlob, Rec.Css.HasValue() or Rec.Woff.HasValue(), Rec.TableCaption, Text008, 'npfont') then begin
            TempBlob.CreateInStream(InStr);
            Font.Initialize(InStr);

            case true of
                not Rec.Find():
                    begin
                        Rec.Init();
                        Rec.Code := CopyStr(Font.Code(), 1, MaxStrLen(Rec.Code));
                        Rec.Insert(true);
                    end;
                (Rec.Code = '') and (Font.Code() = ''):
                    Rec.FieldError(Code);
                (Rec.Code = '') and (Font.Code() <> ''):
                    Rec.Code := CopyStr(Font.Code(), 1, MaxStrLen(Rec.Code));
                (Rec.Code <> '') and (Font.Code() <> '') and (Font.Code() <> Rec.Code):
                    begin
                        Choice := StrMenu(StrSubstNo(Text010, Font.Code(), Font.Name(), Rec.Code, Rec.Name), 1, Text009);
                        if Choice <= 1 then
                            exit;
                        if Choice = 2 then begin
                            WebFont.Code := CopyStr(Font.Code(), 1, MaxStrLen(WebFont.Code));
                            WebFont.Insert(true);
                            SaveFontConfiguration(WebFont, Font);
                            CurrPage.Update(false);
                            exit;
                        end;
                    end;
            end;

            SaveFontConfiguration(Rec, Font);
            CurrPage.Update(false);
        end;
    end;

    local procedure SaveFontConfiguration(WebFont: Record "NPR POS Web Font"; Font: Interface "NPR Font Definition")
    var
        OutStr: OutStream;
    begin
        WebFont.Name := CopyStr(Font.Name(), 1, MaxStrLen(WebFont.Name));
        WebFont."Font Face" := CopyStr(Font.FontFace(), 1, MaxStrLen(WebFont."Font Face"));
        WebFont.Prefix := CopyStr(Font.Prefix(), 1, MaxStrLen(WebFont.Prefix));

        WebFont.Woff.CreateOutStream(OutStr);
        Font.GetWoffStream(OutStr);

        Clear(OutStr);
        WebFont.Css.CreateOutStream(OutStr);
        Font.GetCssStream(OutStr);
        WebFont.Modify(true);
    end;

    local procedure ImportWithDialog(var TempBLOB: Codeunit "Temp Blob"; HasValue: Boolean; "Field": Text; FileType: Text; FileExt: Text): Boolean
    var
        FileManagement: Codeunit "File Management";
        ResourceName: Text;
    begin
        if HasValue then
            if not Confirm(Text001, false, Field) then
                exit;

        ResourceName := FileManagement.BLOBImportWithFilter(
          TempBLOB, StrSubstNo(Text002, Field), '',
          FileType + ' (*.' + FileExt + ')|*.' + FileExt + '|' + Text006 + ' (*.*)|*.*', '*.*');

        exit(ResourceName <> '');
    end;

    local procedure ExportWithDialog(var TempBLOB: Codeunit "Temp Blob"; HasValue: Boolean; "Field": Text; FileExt: Text)
    var
        FileManagement: Codeunit "File Management";
    begin
        if not HasValue then begin
            Message(Text007, Field);
            exit;
        end;

        FileManagement.BLOBExport(TempBLOB, Rec.Name + '.' + FileExt, true);
    end;
}
