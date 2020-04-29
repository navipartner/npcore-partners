page 6150640 "POS Info Card"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action
    // NPR5.51/ALPO/20190826 CASE 364558 Define inheritable pos info codes (will be copied from Sales POS header to new lines)
    // NPR5.51/ALPO/20190912 CASE 368351 Apply red color to POS sale lines only for selected POS info codes

    Caption = 'POS Info Card';
    PageType = Card;
    SourceTable = "POS Info";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field(Message;Message)
                {
                }
                field("Once per Transaction";"Once per Transaction")
                {
                }
                field("Copy from Header";"Copy from Header")
                {
                }
                field("Available in Front-End";"Available in Front-End")
                {
                }
                field("Set POS Sale Line Color to Red";"Set POS Sale Line Color to Red")
                {
                }
                field(Type;Type)
                {
                }
                field("Input Mandatory";"Input Mandatory")
                {
                }
                field("Input Type";"Input Type")
                {
                }
                field("Table No.";"Table No.")
                {
                }
            }
            part("POS Info Subform";"POS Info Subform")
            {
                Caption = 'POS Info Subform';
                SubPageLink = Code=FIELD(Code);
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

                trigger OnAction()
                var
                    POSInfoLookupFieldSetup: Page "POS Info Lookup Field Setup";
                begin
                    if ("Input Type" <> "Input Type"::Table) or ("Table No." = 0) then
                      Error(ErrorText001,Format("Input Type"::Table),FieldCaption("Table No."));

                    POSInfoLookupFieldSetup.SetPOSInfo(Rec);
                    POSInfoLookupFieldSetup.RunModal;
                end;
            }
        }
    }

    var
        ErrorText001: Label 'You can only setup fieldmapping if input type is %1 and %2 is not empty.';
}

