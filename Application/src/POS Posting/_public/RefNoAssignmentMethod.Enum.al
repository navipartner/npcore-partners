enum 6014628 "NPR Ref.No. Assignment Method" implements "NPR Reference No. Assignment"
{
    Extensible = true;
    DefaultImplementation = "NPR Reference No. Assignment" = "NPR Ref.No. Assignment-Default";

    value(0; Auto)
    {
        Caption = 'Auto';
        Implementation = "NPR Reference No. Assignment" = "NPR Ref.No. Assignment-Auto";
    }
    value(1; Manual)
    {
        Caption = 'Manual';
    }
    value(2; NoSeries)
    {
        Caption = 'Number Series';
        Implementation = "NPR Reference No. Assignment" = "NPR Ref.No. Assignment-NSeries";
    }
}