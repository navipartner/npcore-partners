tableextension 6014445 "NPR Warehouse Activity Line" extends "Warehouse Activity Line"
{
    // NPR5.33/TJ  /20170505 CASE 268412 New field Rem. Qty. to Pick (Base)
    fields
    {
        field(6014440; "NPR Rem. Qty. to Pick (Base)"; Decimal)
        {
            Caption = 'Rem. Qty. to Pick (Base)';
            DataClassification = CustomerContent;
            Description = 'NPR5.33';
        }
    }
}

