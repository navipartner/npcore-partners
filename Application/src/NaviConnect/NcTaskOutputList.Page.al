page 6151510 "NPR Nc Task Output List"
{
    Caption = 'Task Output List';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    PromotedActionCategories = 'New,Process,Report,Navigate,NaviPartner';
    SourceTable = "NPR Nc Task Output";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Last Modified at"; Rec."Last Modified at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Modified at field';
                }
                field("Process Count"; Rec."Process Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Process Count field';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
            }
            grid(Control6151411)
            {
                ShowCaption = false;
                group(Control6151412)
                {
                    ShowCaption = false;
                    field(" "; '')
                    {
                        ApplicationArea = All;
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                    }
                    field(Control6151420; '')
                    {
                        ApplicationArea = All;
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                    }
                    field(Control6151419; '')
                    {
                        ApplicationArea = All;
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                    }
                    field(Control6151418; '')
                    {
                        ApplicationArea = All;
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                    }
                    field(Control6151417; '')
                    {
                        ApplicationArea = All;
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                    }
                    field(Control6151416; '')
                    {
                        ApplicationArea = All;
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                    }
                    field(Control6151415; '')
                    {
                        ApplicationArea = All;
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                    }
                    field(Control6151414; '')
                    {
                        ApplicationArea = All;
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                    }
                    field(Control6151413; '')
                    {
                        ApplicationArea = All;
                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                    }
                }
                group(Control6151410)
                {
                    ShowCaption = false;
                    field(Control6151409; '')
                    {
                        ApplicationArea = All;
                        Caption = 'Response:                                                                                                                                                                                                                                                                                ';
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Response:                                                                                                                                                                                                                                                                                 field';
                    }
                    field(ResponseText; ResponseText)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        MultiLine = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the ResponseText field';
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
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Show Output action';

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
        FileMgt: Codeunit "File Management";
        InStr: InStream;
        Path: Text;
    begin
        Rec.CalcFields(Data);
        if not Rec.Data.HasValue() then begin
            Message(Text000);
            exit;
        end;

        Rec.Data.CreateInStream(InStr, TEXTENCODING::UTF8);
        Path := TemporaryPath + Rec.Name;
        DownloadFromStream(InStr, 'Export', FileMgt.Magicpath(), '.' + FileMgt.GetExtension(Rec.Name), Path);
        HyperLink(Path);
    end;

    local procedure UpdateResponseText()
    var
        InStr: InStream;
        BufferText: Text;
    begin
        ResponseText := '';
        if not Rec.Response.HasValue() then
            exit;
        Rec.CalcFields(Response);
        Rec.Response.CreateInStream(InStr, TextEncoding::UTF8);
        BufferText := '';
        while not InStr.EOS do begin
            InStr.ReadText(BufferText);
            ResponseText += BufferText;
        end;
    end;
}

