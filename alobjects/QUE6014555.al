query 6014555 "NPR Attribute Keys"
{
    // NPR5.37/MHA /20171026  Object created - NPR Attribute Filter
    // NPR5.48/JDH /20181109 CASE 334163 Missing Object Caption Added

    Caption = 'NPR Attribute Keys';

    elements
    {
        dataitem(NPR_Attribute_Value_Set;"NPR Attribute Value Set")
        {
            filter(Table_ID;"Table ID")
            {
            }
            filter(Attribute_Set_ID;"Attribute Set ID")
            {
            }
            filter(Attribute_Code;"Attribute Code")
            {
            }
            filter(Text_Value;"Text Value")
            {
            }
            filter(Datetime_Value;"Datetime Value")
            {
            }
            filter(Numeric_Value;"Numeric Value")
            {
            }
            filter(Boolean_Value;"Boolean Value")
            {
            }
            column(MDR_Code_PK;"MDR Code PK")
            {
            }
            column(MDR_Line_PK;"MDR Line PK")
            {
            }
            column(MDR_Option_PK;"MDR Option PK")
            {
            }
            column(MDR_Code_2_PK;"MDR Code 2 PK")
            {
            }
            column(MDR_Line_2_PK;"MDR Line 2 PK")
            {
            }
            column("Count")
            {
                Method = Count;
            }
        }
    }
}

