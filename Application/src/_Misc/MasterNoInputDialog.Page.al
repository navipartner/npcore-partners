page 6014420 "NPR Master No. Input Dialog"
{
    Extensible = False;
    Caption = 'Master No. Input Dialog';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field("InputNo."; "InputNo.")
            {

                CaptionClass = Captions;
                Caption = 'Input No.';
                ToolTip = 'Specifies the value of the Input No. field';
                ApplicationArea = NPRRetail;

                trigger OnValidate()
                begin
                    StoreInput("InputNo.");
                end;

            }
        }
    }

    var
        Captions: Text;
        "InputNo.": Text;

    procedure SetInput(Variable: Variant; Description: Text[250])
    begin
        "InputNo." := Format(Variable);
        Captions := Description;
    end;

    procedure InputCode(var OutVar: Code[20]): Code[20]
    begin
        Evaluate(OutVar, "InputNo.");
    end;

    local procedure StoreInput(Value: Text)
    var
        CodeVar: Code[20];
    begin
        Evaluate(CodeVar, Value);
        Clear(CodeVar);
    end;
}

