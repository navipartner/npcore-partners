page 6059804 "E-mail Text Editor Dialog"
{
    // NC1.14/MH/20150508  CASE 208941 Updated TextEditor Addin to JavaScript version
    // NC1.19/HSK/20150720 CASE 217576 TextEditor 1.01 update
    // NPR5.23.03/MHA/20160726  CASE 242557 Object renamed and re-versioned from NC1.19 to PN1.10.01

    Caption = 'NaviConnect Text Editor Dialog';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        InitOptions();

        //-NC1.19
        //SetOption('statusbar',FALSE);
        //SetOption('save_delay',10);
        //+NC1.19
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::Cancel then
            exit(true);

        OKClicked := true;

        CloseAllowed := true;
        exit(false);
    end;

    var
        Options: DotNet npNetDictionary_Of_T_U;
        EditorContent: Text;
        TextEditorInitialized: Boolean;
        CloseAllowed: Boolean;
        OKClicked: Boolean;

    local procedure InitOptions()
    var
        Type: DotNet npNetType;
        Types: DotNet npNetArray;
        "Object": DotNet npNetObject;
        Activator: DotNet npNetActivator;
    begin
        Types := Types.CreateInstance(GetDotNetType(Type), 2);
        Types.SetValue(GetDotNetType(''), 0);
        Types.SetValue(GetDotNetType(Object), 1);

        Type := GetDotNetType(Options);
        Options := Activator.CreateInstance(Type.MakeGenericType(Types));
        //-NC1.19
        SetOption('statusbar', false);
        SetOption('save_delay', 10);
        //+NC1.19
    end;

    local procedure SendDataToTextEditor()
    var
        Stream: InStream;
        StreamReader: DotNet npNetStreamReader;
        Data: Text;
    begin
        if not TextEditorInitialized then
            exit;

    end;

    procedure SetContent(ContentIn: Text)
    begin
        EditorContent := ContentIn;
        SendDataToTextEditor();
    end;

    procedure GetContent(): Text
    begin
        exit(EditorContent);
    end;

    procedure SetOption(Option: Text; Value: Variant)
    begin
        if Options.ContainsKey(Option) then
            Options.Remove(Option);

        Options.Add(Option, Value);
    end;

    procedure GetOKClicked(): Boolean
    begin
        exit(OKClicked);
    end;

    procedure EditText(var Content: Text): Boolean
    var
        TextEditor: Page "E-mail Text Editor Dialog";
    begin
        TextEditor.SetContent(Content);
        if TextEditor.RunModal() = ACTION::OK then;
        if TextEditor.GetOKClicked() then begin
            Content := TextEditor.GetContent();
            exit(true);
        end;
    end;
}

