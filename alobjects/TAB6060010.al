table 6060010 "GIM - Data Format"
{
    Caption = 'GIM - Data Format';
    LookupPageID = "GIM - Data Format List";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(5;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(10;"CSV Field Delimiter";Text[10])
        {
            Caption = 'CSV Field Delimiter';
        }
        field(20;"CSV Field Separator";Text[10])
        {
            Caption = 'CSV Field Separator';
        }
        field(30;"CSV First Data Row";Integer)
        {
            Caption = 'CSV First Data Row';
        }
        field(40;"Excel First Data Row";Integer)
        {
            Caption = 'Excel First Data Row';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    procedure GetCSVSetup(DocNo: Code[20];var FieldDelimiter: Text[30];var FieldSeparator: Text[30];var FirstDataRow: Integer)
    begin
        Get(DocNo);
        if "CSV Field Delimiter" in ['','<None>'] then
          FieldDelimiter := ''
        else
          FieldDelimiter := "CSV Field Delimiter";
        FieldSeparator := "CSV Field Separator";
        if "CSV First Data Row" = 0 then
          FirstDataRow := 1
        else
          FirstDataRow := "CSV First Data Row";
    end;
}

