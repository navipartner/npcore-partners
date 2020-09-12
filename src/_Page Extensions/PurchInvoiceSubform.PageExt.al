pageextension 6014459 "NPR Purch. Invoice Subform" extends "Purch. Invoice Subform"
{
    // NPR7.100.000/LS/220114  : Retail Merge
    // NPR4.13/MMV /20150724 CASE 214173 Changed "No." to variable to handle barcode scanning OnValidate trigger.
    // NPR4.15/JLK /20151009 CASE 224522 Added "Vendor Item No." Field
    // NPR4.15.01/TS  /20151021 CASE 214173 Removed Code related to release 4.13
    // NPR4.18/MMV /20160105 CASE 229221 Unify how label printing of lines are handled.
    // NPR5.22/TJ  /20160411 CASE 238601 Setting standard captions on all of the actions and action groups
    //                                   Setting control ID of field No. back to standard value
    //                                   Setting back Image property of action ItemChargeAssignment
    //                                   Reworked how to check for license read permission
    // NPR5.22/MMV /20160428 CASE 237743 Updated references to label library CU.
    // NPR5.24/JDH/20160720 CASE 241848 Moved code OnAfterGetRecord and OnDeleteRecord, so Powershell didnt triggered a mergeConflicts + Deleted unused code
    // NPR5.29/MMV /20161122 CASE 259110 Removed CurrPage.UPDATE() on Print Validate
    // NPR5.29/TJ  /20170118 CASE 263761 Removed code from Vendor Item No. - OnLookup and unused variable/separators
    // NPR5.30/TJ  /20170202 CASE 262533 Removed code, control, variables and functions used for label printing and moved to a subscriber
    // NPR5.49/LS  /20190329  CASE 347542 Added field 6014420 Exchange Label
    layout
    {
        addafter("No.")
        {
            field("NPR Vendor Item No."; "Vendor Item No.")
            {
                ApplicationArea = All;
            }
        }
        addafter("Line No.")
        {
            field("NPR Exchange Label"; "NPR Exchange Label")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }
    actions
    {
        addafter("Related Information")
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';
                ApplicationArea = All;
            }
        }
    }
}

