report 6060041 "Delete Reg. Item Worksheets"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to object

    Caption = 'Delete Reg. Item Worksheets';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Registered Item Worksheet";"Registered Item Worksheet")
        {
            DataItemTableView = SORTING("No.") ORDER(Ascending);
            RequestFilterFields = "No.","Item Worksheet Template","Registered Date Time";
            RequestFilterHeading = 'Registered Item Worksheet';

            trigger OnAfterGetRecord()
            begin
                Window.Update(1,"No.");

                Delete(true);
            end;

            trigger OnPreDataItem()
            begin
                Window.Open(
                  Text000 +
                  Text001 );
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        Text000: Label 'Processing registered documents...\\';
        Text001: Label 'No.              #1##########';
        Window: Dialog;
}

