table 6060048 "Reg. Item Wsht Variety Value"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created

    Caption = 'Reg. Item Wsht Variety Value';

    fields
    {
        field(1;"Registered Worksheet No.";Integer)
        {
            Caption = 'Registered Worksheet No.';
        }
        field(3;"Registered Worksheet Line No.";Integer)
        {
            Caption = 'Registered Worksheet Line No.';
        }
        field(4;Type;Code[10])
        {
            Caption = 'Type';
            NotBlank = true;
            TableRelation = Variety;
        }
        field(5;"Table";Code[20])
        {
            Caption = 'Table';
            NotBlank = true;
        }
        field(6;Value;Code[20])
        {
            Caption = 'Value';
            NotBlank = true;

            trigger OnValidate()
            begin
                if Description = '' then begin
                  if StrLen(Value) = 1 then
                    Description := Value
                  else
                    Description := CopyStr(Value, 1, 1) + LowerCase(CopyStr(Value, 2));
                end;
            end;
        }
        field(10;"Sort Order";Integer)
        {
            Caption = 'Sort Order';
        }
        field(20;Description;Text[30])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Registered Worksheet No.","Registered Worksheet Line No.",Type,"Table",Value)
        {
        }
        key(Key2;"Registered Worksheet Line No.",Type,"Sort Order")
        {
        }
        key(Key3;"Registered Worksheet No.","Registered Worksheet Line No.",Type,"Table","Sort Order")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        VRTCheck: Codeunit "Variety Check";
    begin
    end;

    procedure GetDecimalSeperator(): Text[1]
    var
        Dec: Decimal;
    begin
        Dec := 1.2;
        if StrPos(Format(Dec), '.') <> 0 then
          exit('.')
        else
          exit(',');
    end;
}

