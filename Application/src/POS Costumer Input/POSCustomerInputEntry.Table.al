table 6151193 "NPR POS Customer Input Entry"
{
    Access = Internal;
    Caption = 'Customer Input Entry';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR POS Customer Input Entries";
    LookupPageId = "NPR POS Customer Input Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(5; "POS Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry";
        }
        field(10; "Date & Time"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(20; Signature; Blob)
        {
            DataClassification = CustomerContent;
        }
        field(30; Context; Enum "NPR POS Costumer Input Context")
        {
            DataClassification = CustomerContent;
        }
        field(40; "Information Collected"; Enum "NPR Information Collected")
        {
            DataClassification = CustomerContent;
        }
        field(50; "Information Value"; Text[80])
        {
            DataClassification = CustomerContent;
        }
        field(60; "Information Context"; Text[250])
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    internal procedure ReadSignatureData() SignatureText: Text
    var
        InStr: InStream;
    begin
        Rec.CalcFields(Signature);
        Rec.Signature.CreateInStream(InStr);
        InStr.ReadText(SignatureText);
    end;

    internal procedure WriteSignatureData(SignatureText: Text)
    var
        OutStr: OutStream;
    begin
        Rec.Signature.CreateOutStream(OutStr);
        OutStr.WriteText(SignatureText);
    end;
}
