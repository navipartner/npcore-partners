table 6014621 "NPR POS Web Font"
{
    Caption = 'POS Web Font';
    DataCaptionFields = "Code", Name;
    DataPerCompany = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; "Company Name"; Code[30])
        {
            Caption = 'Company Name';
            TableRelation = Company;
            DataClassification = CustomerContent;
        }
        field(10; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(11; "Font Face"; Text[80])
        {
            Caption = 'Font Face';
            DataClassification = CustomerContent;
        }
        field(12; Prefix; Text[30])
        {
            Caption = 'Prefix';
            DataClassification = CustomerContent;
        }
        field(20; Woff; BLOB)
        {
            Caption = 'Woff';
            DataClassification = CustomerContent;
        }
        field(21; Css; BLOB)
        {
            Caption = 'Css';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code", "Company Name")
        {
        }
    }

    procedure GetWebFont(Font: Interface "NPR Font Definition")
    var
        WoffStream: InStream;
        CssStream: InStream;
    begin
        CalcFields(Woff, Css);
        Woff.CreateInStream(WoffStream);
        Css.CreateInStream(CssStream);

        Font.Initialize(Code, Name, "Font Face", Prefix, CssStream, WoffStream);
    end;
}
