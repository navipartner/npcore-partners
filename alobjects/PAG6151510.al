page 6151510 "Nc Task Output List"
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - Multi Output per Nc Task

    Caption = 'Task Output List';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Navigate,NaviPartner';
    SourceTable = "Nc Task Output";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                }
                field("Last Modified at";"Last Modified at")
                {
                }
                field("Process Count";"Process Count")
                {
                }
                field("Entry No.";"Entry No.")
                {
                }
            }
            grid(Control6151411)
            {
                ShowCaption = false;
                group(Control6151412)
                {
                    ShowCaption = false;
                    field(" ";'')
                    {
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                    }
                    field(Control6151420;'')
                    {
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                    }
                    field(Control6151419;'')
                    {
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                    }
                    field(Control6151418;'')
                    {
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                    }
                    field(Control6151417;'')
                    {
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                    }
                    field(Control6151416;'')
                    {
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                    }
                    field(Control6151415;'')
                    {
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                    }
                    field(Control6151414;'')
                    {
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                    }
                    field(Control6151413;'')
                    {
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                    }
                }
                group(Control6151410)
                {
                    ShowCaption = false;
                    field(Control6151409;'')
                    {
                        Caption = 'Response:                                                                                                                                                                                                                                                                                ';
                        HideValue = true;
                        ShowCaption = false;
                    }
                    field(ResponseText;ResponseText)
                    {
                        Editable = false;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Show Output")
            {
                Caption = 'Show Output';
                Image = XMLFile;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ShowOutput();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateResponseText();
    end;

    var
        Text000: Label 'No Output';
        ResponseText: Text;

    local procedure ShowOutput()
    var
        TempBlob: Record TempBlob temporary;
        FileMgt: Codeunit "File Management";
        InStr: InStream;
        Path: Text;
        Content: Text;
    begin
        CalcFields(Data);
        if not Data.HasValue then begin
          Message(Text000);
          exit;
        end;

        Data.CreateInStream(InStr,TEXTENCODING::UTF8);
        Path := TemporaryPath + Name;
        DownloadFromStream(InStr,'Export',FileMgt.Magicpath,'.' + FileMgt.GetExtension(Name),Path);
        HyperLink(Path);
    end;

    local procedure UpdateResponseText()
    var
        InStream: InStream;
        Line: Text;
        LF: Char;
        CR: Char;
        StreamReader: DotNet npNetStreamReader;
    begin
        ResponseText := '';
        if not Response.HasValue then
          exit;
        CalcFields(Response);
        Response.CreateInStream(InStream,TEXTENCODING::UTF8);
        StreamReader := StreamReader.StreamReader(InStream);
        ResponseText := StreamReader.ReadToEnd();
    end;
}

