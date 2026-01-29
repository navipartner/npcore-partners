enum 6014568 "NPR NationalIdentifierType" implements "NPR NationalIdentifierIface"
{
    Extensible = true;
    AssignmentCompatibility = false;

    // Core only provides a "no validation" option. This is to ensure not polluting all customers with
    // national identifier implementations that they do not need. The PTEs can implement the national identifier
    // handling as needed for their local requirements.
    //
    // Core provides reference implementations for DK and SE that the PTEs can use as is or as a reference.
    // The PTEs need to extend this enum to add the needed national identifier types and link to the appropriate implementation codeunits.

    value(0; NONE)
    {
        Caption = 'No validation';
        Implementation = "NPR NationalIdentifierIface" = "NPR NationalIdentifier_None";
    }

    // 
    // Sweden
    // 
    // This is commented out in core and is intened for the PTE to implement.
    // The PTE can then implement the SE national identifier handling as needed.
    // Codeunit "NPR MMNationalIdentifier_SE_xxx" are provided as is and is public - it can be used as is or as a reference implementation.
    //
    // value(50010; SE_PNR)
    // {
    //     Caption = 'SE Person number';
    //     Implementation = "NPR NationalIdentifierIface" = "NPR NationalIdentifier_SE_PNR";
    // }
    // value(50011; SE_CNR)
    // {
    //     Caption = 'SE Coordination number';
    //     Implementation = "NPR NationalIdentifierIface" = "NPR NationalIdentifier_SE_CNR";
    // }
    // value(50012; SE_ONR)
    // {
    //     Caption = 'SE Organisation Number';
    //     Implementation = "NPR NationalIdentifierIface" = "NPR NationalIdentifier_SE_ONR";
    // }
    // value(50013; SE_VAT)
    // {
    //     Caption = 'SE VAT number';
    //     Implementation = "NPR NationalIdentifierIface" = "NPR NationalIdentifier_SE_VAT";
    // }

    //
    // Denmark
    //
    // This is commented out in core and is intened for the PTE to implement. 
    // The PTE can then implement the DK national identifier handling as needed.
    // Codeunit "NPR MMNationalIdentifier_DK_xxx" are provided as is and is public - it can be used as is or as a reference implementation.
    // 
    // value(50020; DK_CPR)
    // {
    //     Caption = 'DK CPR number';
    //     Implementation = "NPR NationalIdentifierIface" = "NPR NationalIdentifier_DK_CPR";
    // }
    // value(50021; DK_CVR)
    // {
    //     Caption = 'DK CVR number';
    //     Implementation = "NPR NationalIdentifierIface" = "NPR NationalIdentifier_DK_CVR";
    // }
    // value(50022; DK_VAT)
    // {
    //     Caption = 'DK VAT number';
    //     Implementation = "NPR NationalIdentifierIface" = "NPR NationalIdentifier_DK_VAT";
    // }
}
