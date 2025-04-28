table 6151115 "NPR HU L POS Unit Mapping"
{
    Access = Internal;
    Caption = 'HU Laurel Unit Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR HU L POS Unit Mapping";
    LookupPageId = "NPR HU L POS Unit Mapping";

    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(2; "POS Unit Name"; Text[50])
        {
            CalcFormula = lookup("NPR POS Unit".Name where("No." = field("POS Unit No.")));
            Caption = 'POS Unit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(3; "Laurel License"; Text[30])
        {
            Caption = 'Laurel License';
            DataClassification = CustomerContent;
        }
        field(4; "POS FCU Day Status"; Option)
        {
            Caption = 'POS FCU Day Status';
            DataClassification = CustomerContent;
            Editable = false;
            OptionMembers = OPEN,CLOSED;
            InitValue = CLOSED;
        }
        field(10; "POS FCU Daily Totals"; Media)
        {
            Caption = 'POS FCU Daily Totals';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Unit No.")
        {
            Clustered = true;
        }
    }

    internal procedure GetDailyTotalsText() DailyTotals: Text;
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        DailyTotalsTextLine: Text;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        "POS FCU Daily Totals".ExportStream(OutStream);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        while not InStream.EOS do begin
            InStream.ReadText(DailyTotalsTextLine);
            DailyTotals += DailyTotalsTextLine;
        end;
    end;

    internal procedure SetDailyTotalsText(DailyTotals: Text)
    var
        TenantMedia: Record "Tenant Media";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        if "POS FCU Daily Totals".HasValue() then
            if TenantMedia.Get("POS FCU Daily Totals".MediaId) then
                TenantMedia.Delete(true);

        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(DailyTotals);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        "POS FCU Daily Totals".ImportStream(InStream, FieldCaption("POS FCU Daily Totals"));
        Modify();
    end;
}