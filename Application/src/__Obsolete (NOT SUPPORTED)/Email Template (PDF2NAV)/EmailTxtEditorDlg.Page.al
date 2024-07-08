page 6059804 "NPR E-mail Txt Editor Dlg"
{
    Extensible = False;
    Caption = 'NaviConnect Text Editor Dialog';
    PageType = StandardDialog;
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Not used and not working';


    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::Cancel then
            exit(true);

        OKClicked := true;

        exit(false);
    end;

    var
        EditorContent: Text;
        OKClicked: Boolean;


    internal procedure SetContent(ContentIn: Text)
    begin
        EditorContent := ContentIn;
    end;

    internal procedure GetContent(): Text
    begin
        exit(EditorContent);
    end;

    internal procedure GetOKClicked(): Boolean
    begin
        exit(OKClicked);
    end;

    internal procedure EditText(var Content: Text): Boolean
    var
        TextEditor: Page "NPR E-mail Txt Editor Dlg";
    begin
        TextEditor.SetContent(Content);
        if TextEditor.RunModal() = ACTION::OK then;
        if TextEditor.GetOKClicked() then begin
            Content := TextEditor.GetContent();
            exit(true);
        end;
    end;
}

