page 6014420 "NPR Master No. Input Dialog"
{
    // NPR5.23/LS  /20160616 CASE 226819 Input Master No.

    Caption = 'Master No. Input Dialog';
    PageType = StandardDialog;
    UsageCategory = Administration;
    ApplicationArea = All;

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

    actions
    {
    }

    var
        "InputNo.": Text;
        Vars: array[10] of Variant;
        Captions: Text;

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

    local procedure InputNo()
    begin
    end;
}

