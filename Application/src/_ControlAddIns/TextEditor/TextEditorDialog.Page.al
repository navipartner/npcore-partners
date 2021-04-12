page 6151450 "NPR Text Editor Dialog"
{
    Caption = 'Text Editor Dialog';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;

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
                ApplicationArea = All;

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
        OptionValueBuffer: Record "NPR Text Editor Dialog Option" temporary;
        EditorContent: Text;
        OKClicked: Boolean;
        CanClose: Boolean;

    local procedure SendOptionsToTextEditor()
    begin
        OptionValueBuffer.Reset();
        OptionValueBuffer.SetAutoCalcFields("Option Value");
        if OptionValueBuffer.FindSet() then begin
            repeat
                OptionValueBuffer.TestField("Option Key");
                SetOption(OptionValueBuffer."Option Key", OptionValueBuffer.GetOptionValue());
            until OptionValueBuffer.Next() = 0;
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
        TextEditor: Page "NPR Text Editor Dialog";
    begin
        TextEditor.SetContent(Content);
        TextEditor.SetOptionValueBuffer(OptionValueBuffer);
        if TextEditor.RunModal() = ACTION::OK then;
        if TextEditor.GetOKClicked() then begin
            Content := TextEditor.GetContent();
            exit(true);
        end;
    end;

    procedure InitTextEditorOptionKeyAndValueBuffer()
    begin
        OptionValueBuffer.Reset();
        OptionValueBuffer.DeleteAll();
    end;

    procedure AddTextEditorOptionKeyAndValue(OptionKey: Text; OptionValue: Variant)
    begin
        OptionValueBuffer.Init();
        OptionValueBuffer."Option Key" := OptionKey;
        OptionValueBuffer.SetOptionValue(OptionValue);
        OptionValueBuffer.Insert();
    end;

    procedure SetOptionValueBuffer(var OptionValueBufferInput: Record "NPR Text Editor Dialog Option" temporary)
    begin
        OptionValueBuffer.Copy(OptionValueBufferInput, true);
    end;
}
