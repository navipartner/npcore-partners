table 6060005 "GIM - Mapping Table"
{
    // GIM1.00/MH/20150814 CASE 210725 Added field 45 Level and 50 "Parent Entry No."
    //                                 Added Parameters to InsertLine(): ColumName, Level, ParentEntryNo
    // NPR5.38/MHA /20180104  CASE 301054 Removed unused Automation variable in GetAttribute()
    // NPR5.51/MHA /20190819  CASE 365377 Generic Import Module is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'GIM - Mapping Table';
    LookupPageID = "GIM - Mapping";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

