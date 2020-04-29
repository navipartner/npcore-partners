codeunit 6151455 "Magento NpXml Firstname"
{
    // MAG1.16/TS/20150507  CASE 213379 Object created - Custom Values for NpXml
    // MAG1.22/MHA/20160217 CASE 234806 Added exception for name ending with #Space#
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.09/MHA /20180105  CASE 301053 Removed redundant CASE 'boolean' in SetRecRefCalcFieldFilter()

    TableNo = "NpXml Custom Value Buffer";

    trigger OnRun()
    var
        NpXmlElement: Record "NpXml Element";
        RecRef: RecordRef;
        RecRef2: RecordRef;
        CustomValue: Text;
        OutStr: OutStream;
    begin
        if not NpXmlElement.Get("Xml Template Code","Xml Element Line No.") then
          exit;
        Clear(RecRef);
        RecRef.Open("Table No.");
        RecRef.SetPosition("Record Position");
        if not RecRef.Find then
          exit;

        SetRecRefCalcFieldFilter(NpXmlElement,RecRef,RecRef2);
        CustomValue := Format(GetFirstname(RecRef,NpXmlElement."Field No."),0,9);
        RecRef.Close;

        Clear(RecRef);

        Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Modify;
    end;

    procedure GetFirstname(RecRef: RecordRef;FieldNo: Integer) Firstname: Text
    var
        FieldRef: FieldRef;
        Name: Text;
        Position: Integer;
    begin
        FieldRef := RecRef.Field(FieldNo);
        Name := Format(FieldRef.Value,0,9);

        Position := StrPos(Name,' ');
        if Position = 0 then
          exit(Name);

        Firstname := '';
        //-MAG1.22
        //WHILE (Position > 0) AND (Position < STRLEN(Name)) DO BEGIN
        while (Position > 0) and (Position <= StrLen(Name)) do begin
        //+MAG1.22
          if Position = 1 then
            Name := DelStr(Name,1,1)
          else begin
            if Firstname <> '' then
              Firstname += ' ';
            Firstname += CopyStr(Name,1,Position - 1);
            Name := DelStr(Name,1,Position);
          end;

          Position := StrPos(Name,' ');
        end;

        exit(Firstname);
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
                    //-NX1.11
                    case LowerCase(Format(FieldRef2.Type)) of
                      'boolean': FieldRef2.SetFilter('=%1',LowerCase(NpXmlFilter."Filter Value") in ['1','yes','ja','true']);
                      //-MAG2.09 [301053]
                      //'integer','option','boolean' :
                      'integer','option':
                      //+MAG2.09 [301053]
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
                    //+NX1.11
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
}

