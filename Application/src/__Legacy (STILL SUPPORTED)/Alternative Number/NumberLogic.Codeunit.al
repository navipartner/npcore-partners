codeunit 6014420 "NPR Number Logic"
{
    // NPK, RR, 310708, Added function "RetailKladdelinie"
    // 
    // NPR4.000.001, NPK, MH - Tilf¢jet funktion, Salgslinie:
    //                         Slår op i alternative varenumre for "Sales Line".
    // NPR4.000.002, NPK, 01-05-09, MH - Tilf¢jet funktion, RetailDokumentLinie:
    //                         Slår op i alternative varenumre for "Retail Document Line".
    // NPR4.04/JDH/20150427  CASE 212229  Removed references to old Variant solution "Color Size"
    // NPR5.36/TJ /20170920  CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                   Removed unused variables
    // NPR5.40/JDH /20180320 CASE 308647 Removed unused functions


    trigger OnRun()
    begin
    end;

    procedure FindAlternativeNo(Text: Text[260]; var AlternativeNo: Record "NPR Alternative No."): Boolean
    begin
        AlternativeNo.SetCurrentKey("Alt. No.");
        AlternativeNo.SetRange("Alt. No.", Text);
        exit(AlternativeNo.Find('-'))
    end;

    procedure ForRetailDocumentLine(Text: Text[260]; var RetailDocumentLines: Record "NPR Retail Document Lines"): Boolean
    var
        AlternativeNo: Record "NPR Alternative No.";
    begin
        if FindAlternativeNo(Text, AlternativeNo) then begin
            RetailDocumentLines."No." := AlternativeNo.Code;
            RetailDocumentLines."Variant Code" := AlternativeNo."Variant Code";
            exit(true);
        end;
    end;
}

