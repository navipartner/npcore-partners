// Ordinals are parity-locked with the "NPR Nc Task".Type option (minus Rename).
enum 6014625 "NPR Spfy Task Op"
{
    Access = Internal;
    Extensible = false;

    value(0; Insert)
    {
        Caption = 'Insert';
    }
    value(1; Modify)
    {
        Caption = 'Modify';
    }
    value(2; Delete)
    {
        Caption = 'Delete';
    }
}
