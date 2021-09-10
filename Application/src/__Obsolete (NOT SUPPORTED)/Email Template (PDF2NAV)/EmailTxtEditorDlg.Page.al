page 6059804 "NPR E-mail Txt Editor Dlg"
{
    Caption = 'NaviConnect Text Editor Dialog';
    PageType = StandardDialog;
    UsageCategory = None;
    ObsoleteState = Pending;
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


    procedure SetContent(ContentIn: Text)
    begin
        EditorContent := ContentIn;
    end;

    procedure GetContent(): Text
    begin
        exit(EditorContent);
    end;

    procedure GetOKClicked(): Boolean
    begin
        exit(OKClicked);
    end;

    procedure EditText(var Content: Text): Boolean
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

