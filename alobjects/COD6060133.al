codeunit 6060133 "Record Field Management"
{

    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'No table relation has been setup';

    procedure TranslateCaptionClass(Ref: Text): Text
    var
        RecordFieldSetup: Record "Record Field Setup";
        RecordFieldType: Record "Record Field Type";
        TableNo: Integer;
        GlobalFieldNo: Integer;
    begin
        // definition of ref: [TableNo],[Global position]
        if StrPos(Ref,',')>0 then begin
          Evaluate(TableNo,CopyStr(Ref,1,StrPos(Ref,',')-1));
          Evaluate(GlobalFieldNo,CopyStr(Ref,StrPos(Ref,',')+1));
          if RecordFieldSetup.Get(TableNo) then begin
            case GlobalFieldNo of
              1 : begin
                    if RecordFieldType.Get(RecordFieldSetup."Custom Field No. 1") then
                      exit(RecordFieldType."Field Caption");
                  end;
              2 : begin
                    if RecordFieldType.Get(RecordFieldSetup."Custom Field No. 2") then
                      exit(RecordFieldType."Field Caption");
                  end;
              3 : begin
                    if RecordFieldType.Get(RecordFieldSetup."Custom Field No. 3") then
                      exit(RecordFieldType."Field Caption");
                  end;
              4 : begin
                    if RecordFieldType.Get(RecordFieldSetup."Custom Field No. 4") then
                      exit(RecordFieldType."Field Caption");
                  end;
              5 : begin
                    if RecordFieldType.Get(RecordFieldSetup."Custom Field No. 5") then
                      exit(RecordFieldType."Field Caption");
                  end;
              6 : begin
                    if RecordFieldType.Get(RecordFieldSetup."Custom Field No. 6") then
                      exit(RecordFieldType."Field Caption");
                  end;
              7 : begin
                    if RecordFieldType.Get(RecordFieldSetup."Custom Field No. 7") then
                      exit(RecordFieldType."Field Caption");
                  end;
              8 : begin
                    if RecordFieldType.Get(RecordFieldSetup."Custom Field No. 8") then
                      exit(RecordFieldType."Field Caption");
                  end;
              9 : begin
                    if RecordFieldType.Get(RecordFieldSetup."Custom Field No. 9") then
                      exit(RecordFieldType."Field Caption");
                  end;
              10: begin
                    if RecordFieldType.Get(RecordFieldSetup."Custom Field No. 10") then
                      exit(RecordFieldType."Field Caption");
                  end;

              20: exit(RecordFieldSetup."Text Field 1 Caption");
              21: exit(RecordFieldSetup."Text Field 2 Caption");
              30: exit(RecordFieldSetup."Decimal Field 1 Caption");
              31: exit(RecordFieldSetup."Decimal Field 2 Caption");
              40: exit(RecordFieldSetup."Code Field 1 Caption");
              41: exit(RecordFieldSetup."Code Field 2 Caption");
            end;
          end;
        end;
    end;

    procedure DoGlobalLookup(TableNo: Integer;FieldNo: Integer;CurrentValue: Code[20];var NewValue: Code[20]): Boolean
    var
        RecordFieldSetup: Record "Record Field Setup";
        RecordFieldType: Record "Record Field Type";
        RecRef: RecordRef;
        LookupTableNo: Integer;
    begin
        RecordFieldSetup.Get(TableNo);
        case FieldNo of
          1 : begin
                RecordFieldType.Get(RecordFieldSetup."Custom Field No. 1");
                LookupTableNo := RecordFieldType."Table No.";
              end;
          40: LookupTableNo := RecordFieldSetup."Code Field 1 Table No.";
          41: LookupTableNo := RecordFieldSetup."Code Field 2 Table No.";
        end;

        exit(DoLookup(LookupTableNo,CurrentValue,NewValue));
    end;

    procedure DoShortcutLookup(RecordFieldTypeCode: Code[20];CurrentValue: Code[20];var NewValue: Code[20]): Boolean
    var
        RecordFieldType: Record "Record Field Type";
    begin
        if RecordFieldType.Get(RecordFieldTypeCode) then
          exit(DoLookup(RecordFieldType."Table No.",CurrentValue,NewValue));
    end;

    procedure DoLookup(LookupTableNo: Integer;CurrentValue: Code[20];var NewValue: Code[20]): Boolean
    var
        Currency: Record Currency;
        Language: Record Language;
        Country: Record "Country/Region";
        Salesperson: Record "Salesperson/Purchaser";
    begin
        case LookupTableNo of
          0: Error(Text001);
          4: begin
               if Currency.Get(CurrentValue) then;
               if PAGE.RunModal(0,Currency)=ACTION::LookupOK then begin
                 NewValue := Currency.Code;
                 exit(true);
               end else begin
                 exit(false);
               end;
             end;
          8: begin
               if Language.Get(CurrentValue) then;
               if PAGE.RunModal(0,Language)=ACTION::LookupOK then begin
                 NewValue := Language.Code;
                 exit(true);
               end else begin
                 exit(false);
               end;
             end;
          9: begin
               if Country.Get(CurrentValue) then;
               if PAGE.RunModal(0,Country)=ACTION::LookupOK then begin
                 NewValue := Country.Code;
                 exit(true);
               end else begin
                 exit(false);
               end;
             end;
        end;
    end;

    procedure GetShortcutValues(var RecordField: array [20] of Text)
    begin
    end;
}

