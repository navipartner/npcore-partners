codeunit 6151555 "NpXml Value Mgt."
{
    // NC1.13/MHA /20150414  CASE 211360 Object Created - Restructured NpXml Codeunits. Independent functions moved to new codeunits
    // NC1.16/TS  /20150507  CASE 213379 Moved hardcoded value functions to custom codeunits
    // NC1.20/TTH /20151005  CASE 218023 Adding Preffix to the XML Tags and attributes
    // NC2.00/MHA /20160525  CASE 240005 NaviConnect
    // NC2.01/MHA /20161018  CASE 2425550 Added function OnGetXml() for enabling Value generation by Subscription
    // NC2.08/MHA /20180105  CASE 301053 Removed redundant CASE 'boolean' in SetRecRefCalcFieldFilter()
    // NC2.13/JDH /20180604 CASE 317971 Changed caption to ENU


    trigger OnRun()
    begin
    end;

    var
        Error001: Label 'NpXml Template: %1\API Error:\%2';
        Error002: Label 'Record in %1 within the filters does not exist';
        Text001: Label 'Checking images:     @1@@@@@@@@@@@@@@@@@@\Estimated time left: #2##################';
        Text002: Label 'Exporting %1 to XML\Exporting:           @2@@@@@@@@@@@@@@@@@@@\Estimated Time Left: #3###################\Record:       #4###########################';
        Text100: Label 'Choose XML Document';
        Text200: Label 'Finding first record in %1 within the filters: @2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\Estimated Time Left:                           #3##############################\Record:  #4####################################################################';

    procedure GetXmlValue(RecRef: RecordRef;NpXmlElement: Record "NpXml Element";FieldNo: Integer) XmlValue: Text
    var
        TempBlob: Record TempBlob temporary;
        FieldRef: FieldRef;
        InStr: InStream;
        DateBuffer: Date;
        DecBuffer: Decimal;
        IntBuffer: Integer;
        OptionString: Text;
        TextBuffer: Text;
        Handled: Boolean;
    begin
        //-NC2.01 [255641]
        if NpXmlElement."Xml Value Codeunit ID" > 0 then begin
          OnGetXmlValue(RecRef,NpXmlElement,FieldNo,XmlValue,Handled);
          if Handled then
            exit(XmlValue);
        end;
        //+NC2.01 [255641]
        if NpXmlElement."Custom Codeunit ID" > 0 then
          exit(GetCustomFieldValue(RecRef,NpXmlElement));

        if FieldNo <= 0 then
          exit('');

        XmlValue := '';
        FieldRef := RecRef.Field(FieldNo);
        if LowerCase(Format(FieldRef.Class)) = 'flowfield' then
          FieldRef.CalcField;

        if NpXmlElement."Field Type" <> NpXmlElement."Field Type"::" " then
          XmlValue := GetSpecialFieldValue(RecRef,NpXmlElement,FieldNo)
        else
          case LowerCase(Format(FieldRef.Type)) of
            'integer':
              begin
                Evaluate(IntBuffer,Format(FieldRef.Value,0,9),9);
                if (NpXmlElement."Blank Zero" and (IntBuffer = 0)) then
                  exit('');

                if NpXmlElement."Reverse Sign" then
                  IntBuffer := -1 * IntBuffer;
                XmlValue := Format(IntBuffer,0,9);
              end;
            'decimal':
              begin
                Evaluate(DecBuffer,Format(FieldRef.Value,0,9),9);
                if (NpXmlElement."Blank Zero" and (DecBuffer = 0)) then
                  exit('');
                if NpXmlElement."Reverse Sign" then
                  DecBuffer := -1 * DecBuffer;
                XmlValue := Format(DecBuffer,0,9);
              end;
            'option':
              begin
                OptionString := Format(FieldRef.OptionString);
                if Evaluate(IntBuffer,Format(FieldRef.Value,0,9)) and (OptionString <> '') then begin
                  XmlValue := GetEnumOption(IntBuffer,OptionString);
                end;
              end;
            else if LowerCase(Format(FieldRef.Type)) = 'blob' then begin
              XmlValue := '';

              FieldRef.CalcField;
              TempBlob.Blob := FieldRef.Value;
              TempBlob.Blob.CreateInStream(InStr);
              while not InStr.EOS do begin
                InStr.ReadText(TextBuffer);
                XmlValue += TextBuffer;
              end;
            end else
              XmlValue := Format(FieldRef.Value,0,9);
          end;

        if NpXmlElement."Lower Case" then
          XmlValue := LowerCase(XmlValue);

        //-NC1.20
        if (NpXmlElement.Prefix <> '') then
          XmlValue := NpXmlElement.Prefix + XmlValue;
        //+NC1.20

        exit(XmlValue);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetXmlValue(RecRef: RecordRef;NpXmlElement: Record "NpXml Element";FieldNo: Integer;var XmlValue: Text;var Handled: Boolean)
    begin
        //-NC2.01 [255641]
        //+NC2.01 [255641]
    end;

    local procedure "--- Filter"()
    begin
    end;

    local procedure SetRecRefCalcFieldFilter(NpXmlElement: Record "NpXml Element";RecRef: RecordRef;var RecRef2: RecordRef)
    var
        NpXmlFilter: Record "NpXml Filter";
        FieldRef: FieldRef;
        FieldRef2: FieldRef;
        BufferDecimal: Decimal;
        BufferInteger: Integer;
    begin
        Clear(RecRef2);
        RecRef2.Open(RecRef.Number);
        RecRef2 := RecRef.Duplicate;

        NpXmlFilter.SetRange("Xml Template Code",NpXmlElement."Xml Template Code");
        NpXmlFilter.SetRange("Xml Element Line No.",NpXmlElement."Line No.");
        if NpXmlFilter.FindSet then
          repeat
            FieldRef2 := RecRef2.Field(NpXmlFilter."Field No.");
            case NpXmlFilter."Filter Type" of
              NpXmlFilter."Filter Type"::Constant :
                begin
                  if NpXmlFilter."Filter Value" <> '' then begin
                    //-NC1.11
                    case LowerCase(Format(FieldRef2.Type)) of
                      'boolean': FieldRef2.SetFilter('=%1',LowerCase(NpXmlFilter."Filter Value") in ['1','yes','ja','true']);
                      //-NC2.08 [301053]
                      //'integer','option','boolean' :
                      'integer','option':
                      //+NC2.08 [301053]
                        begin
                          if Evaluate(BufferDecimal,NpXmlFilter."Filter Value") then
                            FieldRef2.SetFilter('=%1',BufferDecimal);
                        end;
                      'decimal':
                        begin
                          if Evaluate(BufferInteger,NpXmlFilter."Filter Value") then
                            FieldRef2.SetFilter('=%1',BufferInteger);
                        end;
                      else
                        FieldRef2.SetFilter('=%1',NpXmlFilter."Filter Value");
                    end;
                    //+NC1.11
                  end;
                end;
              NpXmlFilter."Filter Type"::Filter :
                begin
                  FieldRef2.SetFilter(NpXmlFilter."Filter Value");
                end;
            end;
          until NpXmlFilter.Next = 0;

        case NpXmlElement."Iteration Type" of
          NpXmlElement."Iteration Type"::First :
            begin
              if RecRef2.FindFirst then
                RecRef2.SetRecFilter;
            end;
          NpXmlElement."Iteration Type"::Last :
            begin
              if RecRef2.FindLast then
                RecRef2.SetRecFilter;
            end;
        end;
    end;

    local procedure "--- Xml Value"()
    begin
    end;

    procedure FillCustomValueBuffer(RecRef: RecordRef;NPXmlElement: Record "NpXml Element";var TempNpXmlCustomValueBuffer: Record "NpXml Custom Value Buffer" temporary)
    begin
        TempNpXmlCustomValueBuffer.DeleteAll;
        TempNpXmlCustomValueBuffer.Init;
        TempNpXmlCustomValueBuffer."Table No." := RecRef.Number;
        TempNpXmlCustomValueBuffer."Record Position" := RecRef.GetPosition(false);
        TempNpXmlCustomValueBuffer."Xml Template Code" := NPXmlElement."Xml Template Code";
        TempNpXmlCustomValueBuffer."Xml Element Line No." := NPXmlElement."Line No.";
        TempNpXmlCustomValueBuffer.Insert;
    end;

    procedure GetCustomFieldValue(RecRef: RecordRef;NPXmlElement: Record "NpXml Element") Value: Text
    var
        TempNpXmlCustomValueBuffer: Record "NpXml Custom Value Buffer" temporary;
        InStr: InStream;
        Line: Text;
    begin
        if NPXmlElement."Custom Codeunit ID" <= 0 then
          exit('');

        FillCustomValueBuffer(RecRef,NPXmlElement,TempNpXmlCustomValueBuffer);
        CODEUNIT.Run(NPXmlElement."Custom Codeunit ID",TempNpXmlCustomValueBuffer);
        Value := '';
        TempNpXmlCustomValueBuffer.CalcFields(Value);
        TempNpXmlCustomValueBuffer.Value.CreateInStream(InStr);
        while not InStr.EOS do begin
          InStr.ReadText(Line);
          Value += Line;
        end;
        exit(Value);
    end;

    local procedure GetEnum(RecRef: RecordRef;NPXmlElement: Record "NpXml Element";FieldNo: Integer) EnumOption: Text
    var
        FieldRef: FieldRef;
        Option: Integer;
    begin
        FieldRef := RecRef.Field(FieldNo);
        if LowerCase(Format(FieldRef.Type)) in ['boolean','option','integer'] then begin
          if NPXmlElement."Enum List (,)" = '' then
            exit('');
          Evaluate(Option,Format(FieldRef.Value,0,2));
          EnumOption := GetEnumOption(Option,NPXmlElement."Enum List (,)");
          exit(EnumOption);
        end;

        exit(Format(FieldRef.Value,0,9));
    end;

    procedure GetEnumOption(Option: Integer;EnumString: Text) EnumOption: Text
    var
        Position: Integer;
        i: Integer;
    begin
        EnumOption := EnumString;
        for i := 0 to Option do begin
          if EnumOption = '' then
            exit('');
          if i < Option then begin
            Position := StrPos(EnumOption,',');
            if Position = 0 then
              exit('');
            EnumOption := DelStr(EnumOption,1,Position);
          end;
        end;
        Position := StrPos(EnumOption,',');
        if Position > 0 then
          EnumOption := CopyStr(EnumOption,1,Position - 1);
        exit(EnumOption);
    end;

    procedure GetPrimaryKeyValue(var RecRef: RecordRef) PrimaryKeyValue: Text
    var
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        i: Integer;
    begin
        KeyRef := RecRef.KeyIndex(1);
        for i := 1 to KeyRef.FieldCount do begin
          FieldRef := KeyRef.FieldIndex(i);
          if PrimaryKeyValue <> '' then
            PrimaryKeyValue += '_';
          PrimaryKeyValue += Format(FieldRef.Value,0,9);
        end;
        exit(PrimaryKeyValue);
    end;

    local procedure GetSpecialFieldValue(RecRef: RecordRef;NPXmlElement: Record "NpXml Element";FieldNo: Integer) Value: Text
    var
        FieldRef: FieldRef;
        RecRef2: RecordRef;
    begin
        SetRecRefCalcFieldFilter(NPXmlElement,RecRef,RecRef2);
        Value := '';
        case NPXmlElement."Field Type" of
          //-NC1.16
          //NPXmlElement."Field Type"::SKU: Value := GetSKU(RecRef);
          //NPXmlElement."Field Type"::StockQty: Value := FORMAT(GetStockQty(RecRef2),0,9);
          //NPXmlElement."Field Type"::StockStatus: Value := FORMAT(GetStockStatus(RecRef2),0,9);
          //NPXmlElement."Field Type"::Base64: Value := GetBase64(RecRef,FieldNo);
          //NPXmlElement."Field Type"::Enum: Value := GetEnum(RecRef,NPXmlElement,FieldNo);
          //NPXmlElement."Field Type"::FIK: Value := GetFIK('71',RecRef);
          //NPXmlElement."Field Type"::PrimaryKey: Value := GetPrimaryKeyValue(RecRef);
          //NPXmlElement."Field Type"::ExclVat: Value := GetExclVat(RecRef2,FieldNo);
          //NPXmlElement."Field Type"::Firstname: Value := GetFirstname(RecRef2,FieldNo);
          //NPXmlElement."Field Type"::Lastname: Value := GetLastname(RecRef2,FieldNo);
          NPXmlElement."Field Type"::Enum: Value := GetEnum(RecRef,NPXmlElement,FieldNo);
          NPXmlElement."Field Type"::PrimaryKey: Value := GetPrimaryKeyValue(RecRef);
          //+NC1.16
        end;
        RecRef2.Close;
        exit(Value);
    end;
}

