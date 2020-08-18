page 6151366 "CS Select Entries"
{
    // NPR5.55/ALST/20200727 CASE 415521 created for manually selecting item number or variant code

    Caption = 'Update Unknown Entries';
    PageType = ConfirmationDialog;
    SourceTable = "CS Stock-Takes Data";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field("Item No.";"Item No.")
            {
            }
            field("Variant Code";"Variant Code")
            {
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Insert;
    end;

    var
        ConfirmUpdateMsg: Label 'Please confirm you wish to update changes for %1 line(s) with "%2" : "%3" and "%4": "%5"';
        NoItemNumberErr: Label 'You must select a valid %1 before associating them with %2';
        NoSelectionErr: Label 'Please select at least one entry before proceeding';
}

