page 6151450 "NPR Text Editor Dialog"
{
    Extensible = False;
    Caption = 'Text Editor Dialog';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
            }
            usercontrol(TextEditor; "NPR TextEditor")
            {
                ApplicationArea = NPRRetail;


                trigger OnControlReady();
                begin
                    SendOptionsToTextEditor();
                    SendDataToTextEditor();
                    CurrPage.TextEditor.InitTinyMce();
                end;

                trigger OnAfterInit();
                begin
                end;

                trigger OnContentChange(Content: Text)
                begin
                    EditorContent := Content;
                    CanClose := true;
                    CurrPage.Close();
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if (CanClose) then begin
            exit(true);
        end;

        if (CloseAction in [Action::LookupOK, Action::OK, Action::Yes]) then begin
            OKClicked := true;
            CurrPage.TextEditor.RequestContent();
        end;

        exit(CanClose);
    end;

    var
        TempOptionValueBuffer: Record "NPR Text Editor Dialog Option" temporary;
        EditorContent: Text;
        OKClicked: Boolean;
        CanClose: Boolean;

    local procedure SendOptionsToTextEditor()
    begin
        TempOptionValueBuffer.Reset();
        TempOptionValueBuffer.SetAutoCalcFields("Option Value");
        if TempOptionValueBuffer.FindSet() then begin
            repeat
                TempOptionValueBuffer.TestField("Option Key");
                SetOption(TempOptionValueBuffer."Option Key", TempOptionValueBuffer.GetOptionValue());
            until TempOptionValueBuffer.Next() = 0;
        end;
    end;

    local procedure SendDataToTextEditor()
    begin
        CurrPage.TextEditor.SetContent(EditorContent);
    end;

    procedure SetContent(ContentIn: Text)
    begin
        EditorContent := ContentIn;
    end;

    procedure GetContent(): Text
    begin
        exit(EditorContent);
    end;

    procedure SetOption(Option: Text; Value: Variant)
    begin
        CurrPage.TextEditor.PresetOption(Option, Value);
    end;

    procedure GetOKClicked(): Boolean
    begin
        exit(OKClicked);
    end;

    procedure EditText(var Content: Text): Boolean
    var
        TextEditorDialog: Page "NPR Text Editor Dialog";
    begin
        TextEditorDialog.SetContent(Content);
        TextEditorDialog.SetOptionValueBuffer(TempOptionValueBuffer);
        if TextEditorDialog.RunModal() = ACTION::OK then;
        if TextEditorDialog.GetOKClicked() then begin
            Content := TextEditorDialog.GetContent();
            exit(true);
        end;
    end;

    procedure InitTextEditorOptionKeyAndValueBuffer()
    begin
        TempOptionValueBuffer.Reset();
        TempOptionValueBuffer.DeleteAll();
    end;

    procedure AddTextEditorOptionKeyAndValue(OptionKey: Text; OptionValue: Variant)
    begin
        TempOptionValueBuffer.Init();
        TempOptionValueBuffer."Option Key" := OptionKey;
        TempOptionValueBuffer.SetOptionValue(OptionValue);
        TempOptionValueBuffer.Insert();
    end;

    procedure SetOptionValueBuffer(var OptionValueBufferInput: Record "NPR Text Editor Dialog Option" temporary)
    begin
        TempOptionValueBuffer.Copy(OptionValueBufferInput, true);
    end;
}
