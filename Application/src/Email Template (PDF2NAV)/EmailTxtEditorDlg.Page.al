page 6059804 "NPR E-mail Txt Editor Dlg"
{
    Caption = 'NaviConnect Text Editor Dialog';
    PageType = StandardDialog;
    UsageCategory = Administration;

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
        Options: DotNet NPRNetDictionary_Of_T_U;
        EditorContent: Text;
        TextEditorInitialized: Boolean;
        CloseAllowed: Boolean;
        OKClicked: Boolean;

    local procedure InitOptions()
    var
        Type: DotNet NPRNetType;
        Types: DotNet NPRNetArray;
        "Object": DotNet NPRNetObject;
        Activator: DotNet NPRNetActivator;
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
        StreamReader: DotNet NPRNetStreamReader;
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

