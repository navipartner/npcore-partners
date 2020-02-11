tableextension 6014448 tableextension6014448 extends "Return Shipment Header" 
{
    // NPR5.53/MHA /20191211  CASE 380837 Added fields 6151300 "NpEc Store Code", 6151305 "NpEc Document No."
    fields
    {
        field(6151300;"NpEc Store Code";Code[20])
        {
            Caption = 'E-commerce Store Code';
            Description = 'NPR5.53';
            TableRelation = "NpEc Store";
        }
        field(6151305;"NpEc Document No.";Code[50])
        {
            Caption = 'E-commerce Document No.';
            Description = 'NPR5.53';
        }
    }
}

