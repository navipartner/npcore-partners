page 6151450 "Magento Text Editor Dialog"
{
    // MAG1.14/MH/20150508  CASE 208941 Updated TextEditor Addin to JavaScript version
    // MAG1.19/HSK/20150720 CASE 217576 TextEditor 1.01 update
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object

    Caption = 'Magento Text Editor Dialog';
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

        //-MAG1.19
        //SetOption('statusbar',FALSE);
        //SetOption('save_delay',10);
        //+MAG1.19
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::Cancel then
            exit(true);

        OKClicked := true;

        CloseAllowed := true;
        //CurrPage.TextEditor.RequestContent();
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
        //-MAG1.19
        SetOption('statusbar', false);
        SetOption('save_delay', 10);
        //+MAG1.19
    end;

    local procedure SendDataToTextEditor()
    var
        Stream: InStream;
        StreamReader: DotNet npNetStreamReader;
        Data: Text;
    begin
        if not TextEditorInitialized then
            exit;

        //CurrPage.TextEditor.SetContent(EditorContent);
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
        TextEditor: Page "Magento Text Editor Dialog";
    begin
        TextEditor.SetContent(Content);
        if TextEditor.RunModal() = ACTION::OK then;
        if TextEditor.GetOKClicked() then begin
            Content := TextEditor.GetContent();
            exit(true);
        end;
    end;
}

