tableextension 50044 tableextension50044 extends "Transfer Line" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields  6014400..6014403
    // NPR4.04/JDH/20150427  CASE 212229  Removed references to old Variant solution "Color Size"
    // NPR5.23/TS/20151021  CASE 214173 Added Field Cross Reference No.(6014410)
    // NPR5.23/TJ/20160512 CASE 241286 Removed code that was commented out regarding case 214173
    // NPR5.23/TS/20160602  CASE 242315  Added  Publisher Codeunit to trigger on CrossReference Lookup
    // VRT1.20/JDH /20170105 CASE 260516 Added Fields for Variety
    // NPR5.29/TJ  /20170118 CASE 262797 Removed unused function CrossReferenceNoLookUp
    // NPR5.29/TJ  /20170119 CASE 263919 Removed code from Cross-Reference No. - OnLookup trigger and created TableRelation
    // NPR5.31/TJ  /20170320 CASE 269200 Fixed TableRelation property of field Cross-Reference No. so other types can be used when validating
    // NPR5.38.01/JKL/20180206/ Case 289017 added field 6151051
    // NPR5.41/JDH /20180418 CASE 309641 Deleted Fields Color, Size and Label. Changed Vendor Item No. to flowfield
    fields
    {
        field(6014403;"Vendor Item No.";Text[20])
        {
            CalcFormula = Lookup(Item."Vendor Item No." WHERE ("No."=FIELD("Item No.")));
            Caption = 'Vendor Item No.';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014410;"Cross-Reference No.";Code[20])
        {
            Caption = 'Cross-Reference No.';
            Description = 'NPR5.23';
            TableRelation = "Item Cross Reference"."Cross-Reference No.";
        }
        field(6059970;"Is Master";Boolean)
        {
            Caption = 'Is Master';
            Description = 'VRT';
        }
        field(6059971;"Master Line No.";Integer)
        {
            Caption = 'Master Line No.';
            Description = 'VRT';
        }
        field(6151051;"Retail Replenisment No.";Integer)
        {
            Caption = 'Retail Replenisment No.';
            Description = 'NPR5.38.01';
        }
    }
}

