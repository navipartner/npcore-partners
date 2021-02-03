page 6014420 "NPR Master No. Input Dialog"
{
    Caption = 'Master No. Input Dialog';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field("InputNo."; "InputNo.")
            {
                ApplicationArea = All;
                CaptionClass = Captions;
                Caption = 'Input No.';
                ToolTip = 'Specifies the value of the Input No. field';

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

    local procedure StoreInput(var Value: Text)
    var
        CodeVar: Code[20];
    begin
        Evaluate(CodeVar, Value);
    end;
}

