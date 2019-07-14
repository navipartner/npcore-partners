tableextension 50045 tableextension50045 extends "Warehouse Activity Line" 
{
    // NPR5.33/TJ  /20170505 CASE 268412 New field Rem. Qty. to Pick (Base)
    fields
    {
        field(6014440;"Rem. Qty. to Pick (Base)";Decimal)
        {
            Caption = 'Rem. Qty. to Pick (Base)';
            Description = 'NPR5.33';
        }
    }
}

