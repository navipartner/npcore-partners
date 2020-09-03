tableextension 6014435 "NPR Purchase Line" extends "Purchase Line"
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
        field(6014400; "NPR Gift Voucher"; Code[20])
        {
            Caption = 'Gift Voucher';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014401; "NPR Credit Note"; Code[20])
        {
            Caption = 'Credit Note';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014402; "NPR Sendt"; Boolean)
        {
            Caption = 'Sendt';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014405; "NPR Compaign Order"; Boolean)
        {
            Caption = 'Campaign Order';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014410; "NPR Procure Quantity"; Decimal)
        {
            Caption = 'Procure Quantity';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014411; "NPR Gift Voucher no."; Code[20])
        {
            Caption = 'Gift Voucher no.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014412; "NPR Credit Note No."; Code[20])
        {
            Caption = 'Credit Note No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014413; "NPR Former Order No."; Code[20])
        {
            Caption = 'Former Order No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014414; "NPR Accessory"; Boolean)
        {
            Caption = 'Accessory';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014415; "NPR Belongs to Item"; Code[20])
        {
            Caption = 'Belongs to Item';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014416; "NPR Belongs to Line No."; Integer)
        {
            Caption = 'Belongs to Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014420; "NPR Exchange Label"; Code[13])
        {
            Caption = 'Exchange Label';
            DataClassification = CustomerContent;
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
        field(6014602; "NPR Color"; Code[20])
        {
            Caption = 'Color';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014603; "NPR Size"; Code[20])
        {
            Caption = 'Size';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014606; "NPR Create"; Code[20])
        {
            Caption = 'Create';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014607; "NPR Label"; Boolean)
        {
            Caption = 'Label';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014608; "NPR Hide Line"; Boolean)
        {
            Caption = 'Hide Line';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014609; "NPR Main Line"; Boolean)
        {
            Caption = 'Main Line';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6059970; "NPR Is Master"; Boolean)
        {
            Caption = 'Is Master';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059971; "NPR Master Line No."; Integer)
        {
            Caption = 'Master Line No.';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6151051; "NPR Retail Replenishment No."; Integer)
        {
            Caption = 'Retail Replenisment No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.38.01';
        }
    }
}

