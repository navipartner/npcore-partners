page 6150640 "NPR POS Info Card"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action
    // NPR5.51/ALPO/20190826 CASE 364558 Define inheritable pos info codes (will be copied from Sales POS header to new lines)
    // NPR5.51/ALPO/20190912 CASE 368351 Apply red color to POS sale lines only for selected POS info codes

    Caption = 'POS Info Card';
    PageType = Card;
    SourceTable = "NPR POS Info";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Message"; Message)
                {
                    ApplicationArea = All;
                }
                field("Once per Transaction"; "Once per Transaction")
                {
                    ApplicationArea = All;
                }
                field("Copy from Header"; "Copy from Header")
                {
                    ApplicationArea = All;
                }
                field("Available in Front-End"; "Available in Front-End")
                {
                    ApplicationArea = All;
                }
                field("Set POS Sale Line Color to Red"; "Set POS Sale Line Color to Red")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Input Mandatory"; "Input Mandatory")
                {
                    ApplicationArea = All;
                }
                field("Input Type"; "Input Type")
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
            }
            part("POS Info Subform"; "NPR POS Info Subform")
            {
                Caption = 'POS Info Subform';
                SubPageLink = Code = FIELD(Code);
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Field Mapping")
            {
                Caption = 'Field Mapping';
                Image = "Action";
                ApplicationArea = All;

                trigger OnAction()
                var
                    POSInfoLookupFieldSetup: Page "NPR POS Info Look. Field Setup";
                begin
                    if ("Input Type" <> "Input Type"::Table) or ("Table No." = 0) then
                        Error(ErrorText001, Format("Input Type"::Table), FieldCaption("Table No."));

                    POSInfoLookupFieldSetup.SetPOSInfo(Rec);
                    POSInfoLookupFieldSetup.RunModal;
                end;
            }
        }
    }

    var
        ErrorText001: Label 'You can only setup fieldmapping if input type is %1 and %2 is not empty.';
}

