table 6014560 "NPR RP Device Settings"
{
    Access = Internal;
    // NPR5.32/MMV /20170411 CASE 241995 Retail Print 2.0

    Caption = 'Device Settings';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Template; Code[20])
        {
            Caption = 'Template';
            TableRelation = "NPR RP Template Header".Code;
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                RPTemplateHeader: Record "NPR RP Template Header";
                LinePrinterInterface: Codeunit "NPR RP Line Printer Interf.";
                MatrixPrinterInterface: Codeunit "NPR RP Matrix Printer Interf.";
                LookupOK: Boolean;
                TempDeviceSetting: Record "NPR RP Device Settings" temporary;
            begin
                RPTemplateHeader.Get(GetFilter(Template));
                RPTemplateHeader.TestField("Printer Device");
                case RPTemplateHeader."Printer Type" of
                    RPTemplateHeader."Printer Type"::Line:
                        begin
                            LinePrinterInterface.Construct(RPTemplateHeader."Printer Device");
                            LinePrinterInterface.OnLookupDeviceSetting(LookupOK, TempDeviceSetting);
                        end;
                    RPTemplateHeader."Printer Type"::Matrix:
                        begin
                            MatrixPrinterInterface.Construct(RPTemplateHeader."Printer Device");
                            MatrixPrinterInterface.OnLookupDeviceSetting(LookupOK, TempDeviceSetting);
                        end;
                end;

                if LookupOK then begin
                    Rec.Name := TempDeviceSetting.Name;
                    Rec."Data Type" := TempDeviceSetting."Data Type";
                    Rec.Options := TempDeviceSetting.Options;
                end;
            end;
        }
        field(4; "Data Type"; Option)
        {
            Caption = 'Data Type';
            OptionCaption = 'Text,Integer,Decimal,Date,Boolean,Option';
            OptionMembers = Text,"Integer",Decimal,Date,Boolean,Option;
            DataClassification = CustomerContent;
        }
        field(5; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                StringLibrary: Codeunit "NPR String Library";
                i: Integer;
                OptionCount: Integer;
                TempRetailList: Record "NPR Retail List" temporary;
            begin
                if "Data Type" <> "Data Type"::Option then
                    exit;

                StringLibrary.Construct(Options);
                OptionCount := StringLibrary.CountOccurences(',');
                if OptionCount < 1 then
                    exit;

                for i := 1 to OptionCount + 1 do begin
                    TempRetailList.Number += 1;
                    TempRetailList.Choice := StringLibrary.SelectStringSep(i, ',');
                    TempRetailList.Insert();
                end;

                if TempRetailList.IsEmpty then
                    exit;

                if PAGE.RunModal(PAGE::"NPR Retail List", TempRetailList) = ACTION::LookupOK then
                    Value := TempRetailList.Choice;
            end;
        }
        field(6; Options; Text[250])
        {
            Caption = 'Options';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Template, Name)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        ModifiedRec();
    end;

    trigger OnInsert()
    begin
        ModifiedRec();
    end;

    trigger OnModify()
    begin
        ModifiedRec();
    end;

    trigger OnRename()
    begin
        ModifiedRec();
    end;

    local procedure ModifiedRec()
    var
        RPTemplateHeader: Record "NPR RP Template Header";
    begin
        if IsTemporary then
            exit;
        if RPTemplateHeader.Get(Template) then
            RPTemplateHeader.Modify(true);
    end;
}

