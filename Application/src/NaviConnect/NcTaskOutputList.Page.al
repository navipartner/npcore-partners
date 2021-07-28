page 6151510 "NPR Nc Task Output List"
{
    Caption = 'Task Output List';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    PromotedActionCategories = 'New,Process,Report,Navigate,NaviPartner';
    SourceTable = "NPR Nc Task Output";
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Last Modified at"; Rec."Last Modified at")
                {

                    ToolTip = 'Specifies the value of the Last Modified at field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Process Count"; Rec."Process Count")
                {

                    ToolTip = 'Specifies the value of the Process Count field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRNaviConnect;
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

                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field(Control6151420; '')
                    {

                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field(Control6151419; '')
                    {

                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field(Control6151418; '')
                    {

                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field(Control6151417; '')
                    {

                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field(Control6151416; '')
                    {

                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field(Control6151415; '')
                    {

                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field(Control6151414; '')
                    {

                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field(Control6151413; '')
                    {

                        Caption = ' ';
                        Enabled = false;
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                        ApplicationArea = NPRNaviConnect;
                    }
                }
                group(Control6151410)
                {
                    ShowCaption = false;
                    field(Control6151409; '')
                    {

                        Caption = 'Response:                                                                                                                                                                                                                                                                                ';
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Response:                                                                                                                                                                                                                                                                                 field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field(ResponseText; ResponseText)
                    {

                        Editable = false;
                        MultiLine = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the ResponseText field';
                        ApplicationArea = NPRNaviConnect;
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

                ToolTip = 'Executes the Show Output action';
                ApplicationArea = NPRNaviConnect;

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
        NoOutputMsg: Label 'No Output';
        ResponseText: Text;

    local procedure ShowOutput()
    var
        FileMgt: Codeunit "File Management";
        InStr: InStream;
    begin
        Rec.CalcFields(Data);
        if not Rec.Data.HasValue() then begin
            Message(NoOutputMsg);
            exit;
        end;

        Rec.Data.CreateInStream(InStr, TEXTENCODING::UTF8);
        DownloadFromStream(InStr, 'Export', FileMgt.Magicpath(), '.' + FileMgt.GetExtension(Rec.Name), Rec.Name);
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

