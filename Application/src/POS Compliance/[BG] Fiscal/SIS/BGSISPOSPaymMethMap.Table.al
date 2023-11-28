table 6060088 "NPR BG SIS POS Paym. Meth. Map"
{
    Access = Internal;
    Caption = 'BG SIS POS Payment Method Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR BG SIS POS Paym. Meth. Map";
    LookupPageId = "NPR BG SIS POS Paym. Meth. Map";

    fields
    {
        field(1; "POS Payment Method Code"; Code[10])
        {
            Caption = 'POS Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(20; "BG SIS Payment Method"; Enum "NPR BG SIS Payment Method")
        {
            Caption = 'BG SIS Payment Method';
            DataClassification = CustomerContent;
            InitValue = " ";
        }
    }

    keys
    {
        key(Key1; "POS Payment Method Code")
        {
            Clustered = true;
        }
    }

    internal procedure CheckIsBGSISPaymentMethodPopulated()
    var
        NotPopulatedErr: Label '%1 must be populated for %2 %3.', Comment = '%1 - BG SIS Payment Method field caption, %2 - POS Payment Method Code field caption, %3 - POS Payment Method Code field value';
    begin
        if "BG SIS Payment Method" = "BG SIS Payment Method"::" " then
            Error(NotPopulatedErr, FieldCaption("BG SIS Payment Method"), FieldCaption("POS Payment Method Code"), "POS Payment Method Code");
    end;
}