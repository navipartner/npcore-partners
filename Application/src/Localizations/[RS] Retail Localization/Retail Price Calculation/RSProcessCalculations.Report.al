report 6014469 "NPR RS Process Calculations"
{
#if not BC17
    Extensible = false;
#endif
    Caption = 'RS Retail Process Calculations';
    UsageCategory = Tasks;
    ApplicationArea = NPRRSRLocal;
    ProcessingOnly = true;

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Filters)
                {
                    field("Retail Calculation Doc Type"; RSRetailCalcDocType)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'Document Type';
                        ToolTip = 'Specifies the value of the Document Type field.';
                    }
                    field("Document No."; DocumentNoFilter)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the value of the Document No. field.';
                    }
                    field("Start Date"; StartDateFilter)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'Start Date';
                        ToolTip = 'Specifies the value of the Start Date field.';
                        ShowMandatory = true;
                    }
                    field("End Date"; EndDateFilter)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'End Date';
                        ToolTip = 'Specifies the value of the Posting Date End field.';
                        ShowMandatory = true;
                    }
                }
            }
        }
    }

#if not (BC17 or BC18 or BC19)
    trigger OnPostReport()
    var
        RSProcessCalculations: Codeunit "NPR RS Process Calculations";
        RetailCalcDocTypeMustBeChosenErr: Label 'You must choose a valid Document Type. It must not be empty';
        EntriesNotFoundNotPostedErr: Label 'There were not entires found with the selected filters therefore no calculations have been posted.';
    begin
        if RSRetailCalcDocType in [RSRetailCalcDocType::" "] then
            Error(RetailCalcDocTypeMustBeChosenErr);

        if not RSProcessCalculations.ProcessCalculationDocuments(RSRetailCalcDocType, DocumentNoFilter, StartDateFilter, EndDateFilter) then
            Error(EntriesNotFoundNotPostedErr);
    end;
#endif
    var
        RSRetailCalcDocType: Enum "NPR RS Retail Calc. Doc. Type";
        DocumentNoFilter: Text;
        StartDateFilter: Date;
        EndDateFilter: Date;
}