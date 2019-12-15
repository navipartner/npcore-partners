table 6014560 "RP Device Settings"
{
    // NPR5.32/MMV /20170411 CASE 241995 Retail Print 2.0

    Caption = 'Device Settings';

    fields
    {
        field(1;Template;Code[20])
        {
            Caption = 'Template';
            TableRelation = "RP Template Header".Code;
        }
        field(2;Name;Text[50])
        {
            Caption = 'Name';

            trigger OnLookup()
            var
                TemplateHeader: Record "RP Template Header";
                LinePrinterInterface: Codeunit "RP Line Printer Interface";
                MatrixPrinterInterface: Codeunit "RP Matrix Printer Interface";
                LookupOK: Boolean;
                tmpDeviceSetting: Record "RP Device Settings" temporary;
            begin
                TemplateHeader.Get(GetFilter(Template));
                TemplateHeader.TestField("Printer Device");
                case TemplateHeader."Printer Type" of
                  TemplateHeader."Printer Type"::Line:
                    begin
                      LinePrinterInterface.Construct(TemplateHeader."Printer Device");
                      LinePrinterInterface.OnLookupDeviceSetting(LookupOK, tmpDeviceSetting);
                    end;
                  TemplateHeader."Printer Type"::Matrix:
                    begin
                      MatrixPrinterInterface.Construct(TemplateHeader."Printer Device");
                      MatrixPrinterInterface.OnLookupDeviceSetting(LookupOK, tmpDeviceSetting);
                    end;
                end;

                if LookupOK then begin
                  Rec.Name := tmpDeviceSetting.Name;
                  Rec."Data Type" := tmpDeviceSetting."Data Type";
                  Rec.Options := tmpDeviceSetting.Options;
                end;
            end;
        }
        field(4;"Data Type";Option)
        {
            Caption = 'Data Type';
            OptionCaption = 'Text,Integer,Decimal,Date,Boolean,Option';
            OptionMembers = Text,"Integer",Decimal,Date,Boolean,Option;
        }
        field(5;Value;Text[250])
        {
            Caption = 'Value';

            trigger OnLookup()
            var
                StringLibrary: Codeunit "String Library";
                i: Integer;
                OptionCount: Integer;
                Option: Text;
                tmpRetailList: Record "Retail List" temporary;
            begin
                if "Data Type" <> "Data Type"::Option then
                  exit;

                StringLibrary.Construct(Options);
                OptionCount := StringLibrary.CountOccurences(',');
                if OptionCount < 1 then
                  exit;

                for i := 1 to OptionCount+1 do begin
                  tmpRetailList.Number += 1;
                  tmpRetailList.Choice := StringLibrary.SelectStringSep(i, ',');
                  tmpRetailList.Insert;
                end;

                if tmpRetailList.IsEmpty then
                  exit;

                if PAGE.RunModal(PAGE::"Retail List", tmpRetailList) = ACTION::LookupOK then
                  Value := tmpRetailList.Choice;
            end;
        }
        field(6;Options;Text[250])
        {
            Caption = 'Options';
        }
    }

    keys
    {
        key(Key1;Template,Name)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        ModifiedRec;
    end;

    trigger OnInsert()
    begin
        ModifiedRec;
    end;

    trigger OnModify()
    begin
        ModifiedRec;
    end;

    trigger OnRename()
    begin
        ModifiedRec;
    end;

    local procedure ModifiedRec()
    var
        TemplateHeader: Record "RP Template Header";
    begin
        if IsTemporary then
          exit;
        if TemplateHeader.Get(Template) then
          TemplateHeader.Modify(true);
    end;
}

