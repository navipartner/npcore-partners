table 6014642 "NPR Tax Free Handler Param."
{
    // NPR5.30/NPKNAV/20170310  CASE 261964 Transport NPR5.30 - 26 January 2017
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free Handler Parameters';

    fields
    {
        field(1; Parameter; Text[30])
        {
            Caption = 'Parameter';
        }
        field(2; "Data Type"; Option)
        {
            Caption = 'Data Type';
            OptionCaption = 'Text,Integer,Decimal,Date,Boolean,Option';
            OptionMembers = Text,"Integer",Decimal,Date,Boolean,Option;
        }
        field(3; Value; Text[250])
        {
            Caption = 'Value';

            trigger OnLookup()
            begin
                if "Data Type" = "Data Type"::Option then
                    LookupOption;
            end;

            trigger OnValidate()
            begin
                ValidateValue();
            end;
        }
    }

    keys
    {
        key(Key1; Parameter)
        {
        }
    }

    fieldgroups
    {
    }

    procedure SerializeParameterBLOB(var TaxFreeUnit: Record "NPR Tax Free POS Unit")
    var
        OutStream: OutStream;
        JSON: Text;
        JObject: DotNet JObject;
        JProperty: DotNet NPRNetJProperty;
    begin
        if not FindSet then
            exit;

        JObject := JObject.JObject();

        repeat
            JProperty := JProperty.JProperty(Parameter, Value);
            JObject.Add(JProperty);
        until Next = 0;

        JSON := JObject.ToString();

        Clear(TaxFreeUnit."Handler Parameters");
        TaxFreeUnit."Handler Parameters".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(JSON);
    end;

    procedure DeserializeParameterBLOB(var TaxFreeUnit: Record "NPR Tax Free POS Unit")
    var
        Buffer: Text;
        JSON: Text;
        JObject: DotNet JObject;
        JProperty: DotNet NPRNetJProperty;
        InStream: InStream;
        i: Integer;
    begin
        TaxFreeUnit.CalcFields("Handler Parameters");
        TaxFreeUnit."Handler Parameters".CreateInStream(InStream, TEXTENCODING::UTF8);
        while (not InStream.EOS) do begin
            InStream.ReadText(Buffer);
            JSON += Buffer;
        end;

        JObject := JObject.Parse(JSON);
        if JObject.Count() = 0 then
            exit;

        for i := 0 to JObject.Count - 1 do begin
            if i = 0 then
                JProperty := JObject.First
            else
                JProperty := JProperty.Next;

            if Get(JProperty.Name) then begin
                Value := Format(JProperty.Value);
                Modify;
            end;
        end;
    end;

    [TryFunction]
    procedure TryGetParameterValue(Param: Text; var Value: Variant)
    begin
        GetParameterValue(Param, Value);
    end;

    procedure GetParameterValue(Param: Text; var pValue: Variant)
    var
        Boolean: Boolean;
        Date: Date;
        Decimal: Decimal;
        "Integer": Integer;
        Text: Text;
    begin
        Get(Param);

        case "Data Type" of
            "Data Type"::Boolean:
                begin
                    Evaluate(Boolean, Value, 9);
                    pValue := Boolean;
                end;
            "Data Type"::Date:
                begin
                    Evaluate(Date, Value, 9);
                    pValue := Date;
                end;
            "Data Type"::Decimal:
                begin
                    Evaluate(Decimal, Value, 9);
                    pValue := Decimal;
                end;
            "Data Type"::Integer:
                begin
                    Evaluate(Integer, Value, 9);
                    pValue := Integer;
                end;
            "Data Type"::Text:
                begin
                    Evaluate(Text, Value, 9);
                    pValue := Text;
                end;
            "Data Type"::Option:
                Error('Not implemented');
        end;
    end;

    local procedure ValidateValue()
    var
        Boolean: Boolean;
        Date: Date;
        Decimal: Decimal;
        "Integer": Integer;
        Text: Text;
    begin
        case "Data Type" of
            "Data Type"::Boolean:
                begin
                    Evaluate(Boolean, Value);
                    Value := Format(Boolean, 0, 9);
                end;
            "Data Type"::Date:
                begin
                    Evaluate(Date, Value);
                    Value := Format(Date, 0, 9);
                end;
            "Data Type"::Decimal:
                begin
                    Evaluate(Decimal, Value);
                    Value := Format(Decimal, 0, 9);
                end;
            "Data Type"::Integer:
                begin
                    Evaluate(Integer, Value);
                    Value := Format(Integer, 0, 9);
                end;
            "Data Type"::Text:
                begin
                    Evaluate(Text, Value);
                    Value := Format(Text, 0, 9);
                end;
            "Data Type"::Option:
                Error('Not implemented');
        end;
    end;

    local procedure LookupOption()
    begin
        Error('Not implemented');
    end;

    procedure AddParameter(ParamName: Text; DataType: Integer)
    begin
        Init;
        Parameter := ParamName;
        "Data Type" := DataType;
        Insert;
    end;
}

