table 6060017 "GIM - Mapping Table Field Spec"
{
    // GIM8.00.10.1.02/TJ/20150819 CASE 210725 Changed code in AddLine()
    // GIM8.00.10.1.02/TJ/20150819 CASE 210725 Added fields 30 Doc. Type Code, 40 Sender IDCode, 50 Version No. and 60 Mapping Table Line No.
    //                                         Changed primary key
    //                                           from: Document No.,Column No.,Table ID,Field ID,Entry No.
    //                                             to: Document No.,Doc. Type Code,Sender ID,Version No.,Mapping Table Line No.,Field ID,Entry No.
    // NPR5.51/MHA /20190819  CASE 365377 Generic Import Module is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'GIM - Mapping Table Field Spec';
    LookupPageID = "GIM - Mapping Table Field Spec";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

