tableextension 50035 tableextension50035 extends "Purchase Line" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields : 6014400..6014609
    // 
    // VRT1.00/JDH/20150304 CASE 201022 Added Variety Fields for grouping
    // NPR4.04/JDH/20150427  CASE 212229  Removed references to old Variant solution "Color Size"
    // NPR4.14/RMT/20150730 CASE 219456 Added code to resolve item information from "Vendor Item No."
    // NPR4.15/JDH/20150929 CASE 223643 only validate vendors item no, if its actually entered from that field
    // NPR5.22/TJ/20160407 CASE 238601 Commenting and cleaning up unused code
    //                                 Removed code from Vendor Item No. - OnLookup
    // NPR5.31/JLK /20170313  CASE 268274 Changed ENU Caption
    // NPR5.38.01/JKL/20180206/ Case 289017 added field 6151051
    // NPR5.49/LS  /20190329  CASE 347542 Added field 6014420 + Global Variable ExchangeLabel
    // NPR5.50/LS  /20190506  CASE 347542 Removed codes for field 6014420 + Global Variable ExchangeLabel
    fields
    {
        field(6014400;"Gift Voucher";Code[20])
        {
            Caption = 'Gift Voucher';
            Description = 'NPR7.100.000';
        }
        field(6014401;"Credit Note";Code[20])
        {
            Caption = 'Credit Note';
            Description = 'NPR7.100.000';
        }
        field(6014402;Sendt;Boolean)
        {
            Caption = 'Sendt';
            Description = 'NPR7.100.000';
        }
        field(6014405;"Compaign Order";Boolean)
        {
            Caption = 'Campaign Order';
            Description = 'NPR7.100.000';
        }
        field(6014410;"Procure Quantity";Decimal)
        {
            Caption = 'Procure Quantity';
            Description = 'NPR7.100.000';
        }
        field(6014411;"Gift Voucher no.";Code[20])
        {
            Caption = 'Gift Voucher no.';
            Description = 'NPR7.100.000';
        }
        field(6014412;"Credit Note No.";Code[20])
        {
            Caption = 'Credit Note No.';
            Description = 'NPR7.100.000';
        }
        field(6014413;"Former Order No.";Code[20])
        {
            Caption = 'Former Order No.';
            Description = 'NPR7.100.000';
        }
        field(6014414;Accessory;Boolean)
        {
            Caption = 'Accessory';
            Description = 'NPR7.100.000';
        }
        field(6014415;"Belongs to Item";Code[20])
        {
            Caption = 'Belongs to Item';
            Description = 'NPR7.100.000';
        }
        field(6014416;"Belongs to Line No.";Integer)
        {
            Caption = 'Belongs to Line No.';
            Description = 'NPR7.100.000';
        }
        field(6014420;"Exchange Label";Code[13])
        {
            Caption = 'Exchange Label';
            DataClassification = ToBeClassified;
            Description = 'NPR5.49';

            trigger OnValidate()
            var
                ItemCheck: Record Item;
            begin
                //-NPR5.50 [347542]
                // //-NPR5.49 [347542]
                // ExchangeLabel.RESET;
                // ExchangeLabel.SETRANGE(Barcode,"Exchange Label");
                // IF ExchangeLabel.FINDFIRST THEN BEGIN
                //  VALIDATE(Type,Type::Item);
                //  VALIDATE("No.",ExchangeLabel."Item No.");
                //  VALIDATE("Variant Code",ExchangeLabel."Variant Code");
                //  "Exchange Label" := ExchangeLabel.Barcode;
                //  //-NPR5.50 [347542] added new codes after Release 5.49
                //  Quantity := ExchangeLabel.Quantity; //added this one
                //  ItemCheck.RESET;
                //  IF ItemCheck.GET("No.") THEN
                //    VALIDATE("Direct Unit Cost",ItemCheck."Unit Cost");
                //  //+NPR5.50 [347542]
                // END;
                // //+NPR5.49 [347542]
                //+NPR5.50 [347542]
            end;
        }
        field(6014602;Color;Code[20])
        {
            Caption = 'Color';
            Description = 'NPR7.100.000';
        }
        field(6014603;Size;Code[20])
        {
            Caption = 'Size';
            Description = 'NPR7.100.000';
        }
        field(6014606;Create;Code[20])
        {
            Caption = 'Create';
            Description = 'NPR7.100.000';
        }
        field(6014607;Label;Boolean)
        {
            Caption = 'Label';
            Description = 'NPR7.100.000';
        }
        field(6014608;"Hide Line";Boolean)
        {
            Caption = 'Hide Line';
            Description = 'NPR7.100.000';
        }
        field(6014609;"Main Line";Boolean)
        {
            Caption = 'Main Line';
            Description = 'NPR7.100.000';
        }
        field(6059970;"Is Master";Boolean)
        {
            Caption = 'Is Master';
            Description = 'VRT1.00';
        }
        field(6059971;"Master Line No.";Integer)
        {
            Caption = 'Master Line No.';
            Description = 'VRT1.00';
        }
        field(6151051;"Retail Replenisment No.";Integer)
        {
            Caption = 'Retail Replenisment No.';
            Description = 'NPR5.38.01';
        }
    }
}

