report 6060041 "NPR Delete Reg. Item Works."
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    Caption = 'Delete Reg. Item Worksheets';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    ApplicationArea = NPRRetail;
    dataset
    {
        dataitem("Registered Item Worksheet"; "NPR Registered Item Works.")
        {
            DataItemTableView = SORTING("No.") ORDER(Ascending);
            RequestFilterFields = "No.", "Item Worksheet Template", "Registered Date Time";
            RequestFilterHeading = 'Registered Item Worksheet';

            trigger OnAfterGetRecord()
            begin
                Window.Update(1, "No.");

                Delete(true);
            end;

            trigger OnPreDataItem()
            begin
                Window.Open(
                  ProcessingDocLbl +
                  NoLbl);
            end;
        }
    }

    var
        Window: Dialog;
        NoLbl: Label 'No.              #1##########';
        ProcessingDocLbl: Label 'Processing registered documents...\\';
}

