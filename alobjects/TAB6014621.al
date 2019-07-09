table 6014621 "POS Web Font"
{
    // NPR4.12/VB/20150707 CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.14/VB/20150909 CASE 222602 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.14/VB/20150925 CASE 222938 Version increase for NaviPartner.POS.Web assembly reference(s), due to refactoring of QUANTITY_POS and QUANTITY_NEG functions.
    // NPR4.14/VB/20150930 CASE 224166 DataCaptionFields property set
    // NPR4.15/VB/20150930 CASE 224237 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR5.00/VB/20150104 CASE 225607 Changed references for compiling under NAV 2016
    // NPR5.00/VB/20160106 CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0
    // NPR5.28/VB/20160525 CASE 241047 Old function to get .NET font is obsoleted, new one created.

    Caption = 'POS Web Font';
    DataCaptionFields = "Code",Name;
    DataPerCompany = false;

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;"Company Name";Code[30])
        {
            Caption = 'Company Name';
            TableRelation = Company;
        }
        field(10;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(11;"Font Face";Text[80])
        {
            Caption = 'Font Face';
        }
        field(12;Prefix;Text[30])
        {
            Caption = 'Prefix';
        }
        field(20;Woff;BLOB)
        {
            Caption = 'Woff';
        }
        field(21;Css;BLOB)
        {
            Caption = 'Css';
        }
    }

    keys
    {
        key(Key1;"Code","Company Name")
        {
        }
    }

    fieldgroups
    {
    }

    procedure GetFontDotNet_Obsolete(var Font: DotNet npNetFont)
    var
        WoffStream: InStream;
        CssStream: InStream;
    begin
        CalcFields(Woff,Css);
        Woff.CreateInStream(WoffStream);
        Css.CreateInStream(CssStream);

        Font := Font.Font(Name,"Font Face",Prefix,CssStream,WoffStream);
        Font.Code := Code;
    end;

    procedure GetFontDotNet(var Font: DotNet npNetFont0)
    var
        WoffStream: InStream;
        CssStream: InStream;
    begin
        CalcFields(Woff,Css);
        Woff.CreateInStream(WoffStream);
        Css.CreateInStream(CssStream);

        Font := Font.Font(Name,"Font Face",Prefix,CssStream,WoffStream);
        Font.Code := Code;
    end;
}

