page 6014449 "NPR Input Dialog"
{
    // NPR4.01/JDH/20150319  CASE 202681 changed function setVariable - parameters made "nonVariable"
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // NPR5.29/VB/20161127 CASE 259086 Removing last remnants of the .NET Control Add-in
    // NPR5.34/BR  /20170704 CASE 282922 Added AutoCloseOnValidate functionalit
    // NPR5.41/TS  /20180105 CASE 300893 Removed SourceTableTemporary as Page is not bound to Table
    //                                   Caption on ActionContainer Removed

    Caption = 'Input Dialog';
    PageType = StandardDialog;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            field(InputField1; TextInputs[1])
            {
                ApplicationArea = All;
                CaptionClass = Captions[1];
                Visible = ControlCount >= 1;
                ToolTip = 'Specifies the value of the TextInputs[1] field';

                trigger OnValidate()
                begin
                    StoreInput(1, TextInputs[1], Vars[1]);
                end;
            }
            field(InputField2; TextInputs[2])
            {
                ApplicationArea = All;
                CaptionClass = Captions[2];
                Visible = ControlCount >= 2;
                ToolTip = 'Specifies the value of the TextInputs[2] field';

                trigger OnValidate()
                begin
                    StoreInput(2, TextInputs[2], Vars[2]);
                end;
            }
            field(InputField3; TextInputs[3])
            {
                ApplicationArea = All;
                CaptionClass = Captions[3];
                Visible = ControlCount >= 3;
                ToolTip = 'Specifies the value of the TextInputs[3] field';

                trigger OnValidate()
                begin
                    StoreInput(3, TextInputs[3], Vars[3]);
                end;
            }
            field(InputField4; TextInputs[4])
            {
                ApplicationArea = All;
                CaptionClass = Captions[4];
                Visible = ControlCount >= 4;
                ToolTip = 'Specifies the value of the TextInputs[4] field';

                trigger OnValidate()
                begin
                    StoreInput(4, TextInputs[4], Vars[4]);
                end;
            }
            field(InputField5; TextInputs[5])
            {
                ApplicationArea = All;
                CaptionClass = Captions[5];
                Visible = ControlCount >= 5;
                ToolTip = 'Specifies the value of the TextInputs[5] field';

                trigger OnValidate()
                begin
                    StoreInput(5, TextInputs[5], Vars[5]);
                end;
            }
            field(InputField6; TextInputs[6])
            {
                ApplicationArea = All;
                CaptionClass = Captions[6];
                Visible = ControlCount >= 6;
                ToolTip = 'Specifies the value of the TextInputs[6] field';

                trigger OnValidate()
                begin
                    StoreInput(6, TextInputs[6], Vars[6]);
                end;
            }
            field(InputField7; TextInputs[7])
            {
                ApplicationArea = All;
                CaptionClass = Captions[7];
                Visible = ControlCount >= 7;
                ToolTip = 'Specifies the value of the TextInputs[7] field';

                trigger OnValidate()
                begin
                    StoreInput(7, TextInputs[7], Vars[7]);
                end;
            }
            field(InputField8; TextInputs[8])
            {
                ApplicationArea = All;
                CaptionClass = Captions[8];
                Visible = ControlCount >= 8;
                ToolTip = 'Specifies the value of the TextInputs[8] field';

                trigger OnValidate()
                begin
                    StoreInput(8, TextInputs[8], Vars[8]);
                end;
            }
            field(InputField9; TextInputs[9])
            {
                ApplicationArea = All;
                CaptionClass = Captions[9];
                Visible = ControlCount >= 9;
                ToolTip = 'Specifies the value of the TextInputs[9] field';

                trigger OnValidate()
                begin
                    StoreInput(9, TextInputs[9], Vars[9]);
                end;
            }
            field(InputField10; TextInputs[10])
            {
                ApplicationArea = All;
                CaptionClass = Captions[10];
                Visible = ControlCount >= 10;
                ToolTip = 'Specifies the value of the TextInputs[10] field';

                trigger OnValidate()
                begin
                    StoreInput(10, TextInputs[10], Vars[10]);
                end;
            }
        }
    }

    actions
    {
    }

    var
        Text: Text[100];
        TextInputs: array[10] of Text;
        Vars: array[10] of Variant;
        Captions: array[10] of Text;
        ControlCount: Integer;
        IsVisible: array[10] of Boolean;
        AutoCloseOnValidate: Boolean;

    procedure SetInput(ControlID: Integer; Variable: Variant; Description: Text[250])
    begin
        Vars[ControlID] := Variable;
        TextInputs[ControlID] := Format(Variable);
        Captions[ControlID] := Description;
        IsVisible[ControlID] := true;
        ControlCount += 1;
    end;

    procedure Input(ControlID: Integer; var OutVar: Variant)
    begin
        // This function does not work as intended.
        // Only works if OutVar is declared a variant. Waiting for MS
        // to fix their shit. For know use the strongly type functions
        // listed below.
        OutVar := 'Test';
    end;

    procedure InputBoolean(ControlID: Integer; var OutVar: Boolean): Integer
    begin
        if Evaluate(OutVar, Format(Vars[ControlID])) then exit(ControlID);
    end;

    procedure InputInteger(ControlID: Integer; var OutVar: Integer): Integer
    begin
        if Evaluate(OutVar, Format(Vars[ControlID])) then exit(ControlID);
    end;

    procedure InputDecimal(ControlID: Integer; var OutVar: Decimal): Integer
    begin
        if Evaluate(OutVar, Format(Vars[ControlID])) then exit(ControlID);
    end;

    procedure InputText(ControlID: Integer; var OutVar: Text): Integer
    var
        Text2: Text;
    begin
        if Evaluate(OutVar, Format(Vars[ControlID])) then exit(ControlID);
    end;

    procedure InputCode(ControlID: Integer; var OutVar: Code[20]): Integer
    begin
        if Evaluate(OutVar, Format(Vars[ControlID])) then exit(ControlID);
    end;

    procedure InputDate(ControlID: Integer; var OutVar: Date): Integer
    begin
        if Evaluate(OutVar, Format(Vars[ControlID])) then exit(ControlID);
    end;

    procedure InputTime(ControlID: Integer; var OutVar: Time): Integer
    begin
        if Evaluate(OutVar, Format(Vars[ControlID])) then exit(ControlID);
    end;

    local procedure StoreInput(ControlID: Integer; var Value: Text; var Variable: Variant)
    var
        BoolVar: Boolean;
        IntegerVar: Integer;
        DecimalVar: Decimal;
        TextVar: Text;
        CodeVar: Code[20];
        DateVar: Date;
        TimeVar: Time;
    begin
        case true of
            Variable.IsBoolean:
                begin
                    Evaluate(BoolVar, Value);
                    Variable := BoolVar;
                end;
            Variable.IsInteger:
                begin
                    Evaluate(IntegerVar, Value);
                    Variable := IntegerVar;
                end;
            Variable.IsDecimal:
                begin
                    Evaluate(DecimalVar, Value);
                    Variable := DecimalVar;
                end;
            Variable.IsText:
                begin
                    Evaluate(TextVar, Value);
                    Variable := TextVar;
                end;
            Variable.IsCode:
                begin
                    Evaluate(CodeVar, Value);
                    Variable := CodeVar;
                end;
            Variable.IsDate:
                begin
                    Evaluate(DateVar, Value);
                    Variable := DateVar;
                end;
            Variable.IsTime:
                begin
                    Evaluate(TimeVar, Value);
                    Variable := TimeVar;
                end;
            else
                Error('Unsupported input type.')
        end;

        Value := Format(Vars[ControlID]);

        //-NPR5.34 [282922]
        if (ControlID = ControlCount) and AutoCloseOnValidate then
            CurrPage.Close;
        //+NPR5.34 [282922]
    end;

    procedure SetAutoCloseOnValidate(ParAutoCloseOnValidate: Boolean)
    begin
        AutoCloseOnValidate := ParAutoCloseOnValidate;
    end;
}

