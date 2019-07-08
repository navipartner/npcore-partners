table 6150705 "POS Parameter Value"
{
    // NPR5.40/VB  /20180213 CASE 306347 Table completely redesigned, and code largely dropped and replaced with new code.
    // NPR5.40/MMV /20180314 CASE 307453 Performance
    // NPR5.40/MMV /20180321 CASE 308050 Added event OnGetParameterInfo()
    // NPR5.43/THRO/20180607 CASE 318038 Added events OnLookupValue and OnValidateValue
    // NPR5.50/VB  /20190205 CASE 338666 Introduced functionality to keep track of parameter filter state, for the purpose of passing specific parameters for workflow 2.0

    Caption = 'POS Parameter Value';

    fields
    {
        field(1;"Table No.";Integer)
        {
            Caption = 'Table No.';
        }
        field(2;"Code";Code[20])
        {
            Caption = 'Code';
            TableRelation = "POS Menu";
        }
        field(3;ID;Integer)
        {
            Caption = 'ID';
            Editable = false;
        }
        field(4;"Record ID";RecordID)
        {
            Caption = 'Record ID';
        }
        field(5;Name;Text[30])
        {
            Caption = 'Name';
        }
        field(6;"Action Code";Code[20])
        {
            Caption = 'Action Code';
        }
        field(7;"Data Type";Option)
        {
            Caption = 'Data Type';
            OptionCaption = 'Text,Integer,Decimal,Date,Boolean,Option';
            OptionMembers = Text,"Integer",Decimal,Date,Boolean,Option;
        }
        field(8;Value;Text[250])
        {
            Caption = 'Value';

            trigger OnLookup()
            begin
                LookupValue();
            end;

            trigger OnValidate()
            begin
                ValidateValue();
            end;
        }
    }

    keys
    {
        key(Key1;"Table No.","Code",ID,"Record ID",Name)
        {
        }
    }

    fieldgroups
    {
    }

    var
        OptionStringCache: DotNet Dictionary_Of_T_U;
        ParamFilterIndicator: Boolean;

    procedure InitForMenuButton(MenuButton: Record "POS Menu Button")
    begin
        Init;
        "Table No." := DATABASE::"POS Menu Button";
        Code := MenuButton."Menu Code";
        ID := MenuButton.ID;
        "Record ID" := MenuButton.RecordId;
    end;

    procedure InitForField(RecordID: RecordID;FieldID: Integer)
    var
        RecRef: RecordRef;
    begin
        RecRef.Get(RecordID);

        Init;
        "Table No." := RecRef.Number;
        Code := '';
        ID := FieldID;
        "Record ID" := RecordID;
    end;

    procedure FilterParameters(RecordID: RecordID;FieldID: Integer): Boolean
    var
        RecRef: RecordRef;
    begin
        RecRef.Get(RecordID);

        Reset();
        SetRange("Table No.",RecRef.Number);
        SetRange("Record ID",RecordID);
        SetRange(ID,FieldID);
    end;

    procedure FindSetMenuButtonParameters(MenuCode: Code[20];ButtonID: Integer;ForModify: Boolean): Boolean
    begin
        Reset();
        SetRange("Table No.",DATABASE::"POS Menu Button");
        SetRange(Code,MenuCode);
        SetRange(ID,ButtonID);
        exit(FindSet(ForModify));
    end;

    [TryFunction]
    local procedure ValidateValue()
    var
        Param: Record "POS Action Parameter";
        OptionsCaption: Text;
        BaseOption: Text;
    begin
        //-NPR5.43 [318038]
        OnValidateValue(Rec);
        //+NPR5.43 [318038]
        Param."Data Type" := "Data Type";
        Param.Options := GetOptions();
        //-NPR5.40 [308050]
        OnGetParameterOptionStringCaption(Rec, OptionsCaption);
        if OptionsCaption <> '' then
          if TryGetBaseOptionStringValue(Param.Options, OptionsCaption, Value, BaseOption) then
            Value := BaseOption;
        //+NPR5.40 [308050]
        Param.Validate("Default Value",Value);
        Value := Param."Default Value";
    end;

    procedure AddParameterToAction(Target: DotNet Action)
    var
        Param: Record "POS Action Parameter";
        OptionsDict: DotNet Dictionary_Of_T_U;
        Date: Date;
        Decimal: Decimal;
        "Integer": Integer;
        Boolean: Boolean;
        CacheKey: Text;
    begin
        case "Data Type" of
          "Data Type"::Boolean:
            begin
              Evaluate(Boolean,Value,9);
              Target.Parameters.Add(Name,Boolean);
            end;
          "Data Type"::Date:
            begin
              Evaluate(Date,Value,9);
              Target.Parameters.Add(Name,Date);
            end;
          "Data Type"::Decimal:
            begin
              Evaluate(Decimal,Value,9);
              Target.Parameters.Add(Name,Decimal);
            end;
          "Data Type"::Integer:
            begin
              Evaluate(Integer,Value,9);
              Target.Parameters.Add(Name,Integer);
            end;
          "Data Type"::Text:
            Target.Parameters.Add(Name,Value);
          "Data Type"::Option:
            begin
              Param.Options := GetOptions();
              //-NPR5.40 [307453]
        //      Param.GetOptionsDictionary(OptionsDict);
        //      Target.Parameters.Add('_option_' + Name,OptionsDict);
              if IsNull(OptionStringCache) then
                OptionStringCache := OptionStringCache.Dictionary();
              CacheKey := StrSubstNo('Action_%1-Param_%2',"Action Code",Name);
              if OptionStringCache.ContainsKey(CacheKey) then begin
                Target.Parameters.Add('_option_' + Name, OptionStringCache.Item(CacheKey));
              end else begin
                Param.GetOptionsDictionary(OptionsDict);
                Target.Parameters.Add('_option_' + Name, OptionsDict);
                OptionStringCache.Add(CacheKey, OptionsDict);
              end;
              //+NPR5.40 [307453]
              Target.Parameters.Add(Name,Param.GetOptionInt(Value));
              Target.Content.Add('param_option_' + Name + 'originalValue',Value);
            end;
        end;
    end;

    procedure AddParameterToJObject(Target: DotNet JObject)
    var
        Param: Record "POS Action Parameter";
        JProperty: DotNet JProperty;
        Date: Date;
        Decimal: Decimal;
        "Integer": Integer;
        Boolean: Boolean;
    begin
        case "Data Type" of
          "Data Type"::Boolean:
            begin
              Evaluate(Boolean,Value,9);
              Target.Add(JProperty.JProperty(Name,Boolean));
            end;
          "Data Type"::Date:
            begin
              Evaluate(Date,Value,9);
              Target.Add(JProperty.JProperty(Name,Date));
            end;
          "Data Type"::Decimal:
            begin
              Evaluate(Decimal,Value,9);
              Target.Add(JProperty.JProperty(Name,Decimal));
            end;
          "Data Type"::Integer:
            begin
              Evaluate(Integer,Value,9);
              Target.Add(JProperty.JProperty(Name,Integer));
            end;
          "Data Type"::Text:
            Target.Add(JProperty.JProperty(Name,Value));
          "Data Type"::Option:
            begin
              Param.Options := GetOptions();
              Target.Add(JProperty.JProperty(Name,Param.GetOptionInt(Value)));
            end;
        end;
    end;

    local procedure GetOptions(): Text
    var
        Param: Record "POS Action Parameter";
    begin
        if Param.Get("Action Code",Name) then
          exit(Param.Options);
    end;

    procedure LookupValue()
    var
        TempRetailList: Record "Retail List" temporary;
        POSActionParamMgt: Codeunit "POS Action Parameter Mgt.";
        Parts: DotNet Array;
        Options: Text;
        "Part": Text;
        OptionsCaption: Text;
        Handled: Boolean;
    begin
        //-NPR5.43 [318038]
        OnLookupValue(Rec,Handled);
        if Handled then
          exit;
        //+NPR5.43 [318038]
        case "Data Type" of
          "Data Type"::Option :
            begin
              Options := GetOptions();
              //-NPR5.40 [308050]
              OnGetParameterOptionStringCaption(Rec, OptionsCaption);
              if OptionsCaption <> '' then
                POSActionParamMgt.SplitString(OptionsCaption,Parts)
              else
              //+NPR5.40 [308050]
                POSActionParamMgt.SplitString(Options,Parts);
              foreach Part in Parts do begin
                TempRetailList.Number += 1;
                TempRetailList.Choice := Part;
                TempRetailList.Insert;
              end;
            end;
          else
            exit;
        end;

        if TempRetailList.IsEmpty then
          exit;

        if PAGE.RunModal(PAGE::"Retail List", TempRetailList) = ACTION::LookupOK then
          Validate(Value, TempRetailList.Choice);
    end;

    procedure GetParameter(RecordID: RecordID;ID: Integer;Name: Text): Boolean
    var
        ParamValue: Record "POS Parameter Value";
        RecRef: RecordRef;
    begin
        RecRef.Get(RecordID);

        ParamValue.SetRange("Table No.",RecRef.Number);
        ParamValue.SetRange("Record ID",RecordID);
        ParamValue.SetRange(ID,ID);
        ParamValue.SetRange(Name,Name);
        if ParamValue.FindFirst then begin
          Rec := ParamValue;
          exit(true);
        end;
    end;

    procedure GetTableViewString(TableID: Integer;ViewString: Text): Text
    var
        RecRef: RecordRef;
        PageBuilder: FilterPageBuilder;
    begin
        //-NPR5.43 [318038]
        RecRef.Open(TableID);
        PageBuilder.AddTable(RecRef.Caption,RecRef.Number);
        if (ViewString <> '') and (TrySetView(RecRef,ViewString)) then
          PageBuilder.SetView(RecRef.Caption,ViewString);
        if PageBuilder.RunModal() then begin
          ViewString := PageBuilder.GetView(RecRef.Caption,false);
        end;
        exit(ViewString);
        //+NPR5.43 [318038]
    end;

    [TryFunction]
    local procedure TryGetBaseOptionStringValue(OptionString: Text;OptionStringCaption: Text;CaptionValue: Text;var BaseOption: Text)
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        //-NPR5.40 [308050]
        BaseOption := SelectStr(TypeHelper.GetOptionNo(CaptionValue,OptionStringCaption)+1,OptionString);
        //+NPR5.40 [308050]
    end;

    [TryFunction]
    local procedure TrySetView(RecRef: RecordRef;FilterString: Text)
    begin
        //-NPR5.43 [318038]
        RecRef.SetView(FilterString);
        //+NPR5.43 [318038]
    end;

    procedure SetParamFilterIndicator()
    begin
        //-NPR5.50 [338666]
        ParamFilterIndicator := true;
        //+NPR5.50 [338666]
    end;

    procedure GetParamFilterIndicator(): Boolean
    begin
        //-NPR5.50 [338666]
        exit(ParamFilterIndicator);
        //+NPR5.50 [338666]
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        //-NPR5.40 [308050]
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        //-NPR5.40 [308050]
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        //-NPR5.40 [308050]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    begin
        //-NPR5.43 [318038]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "POS Parameter Value")
    begin
        //-NPR5.43 [318038]
    end;
}

