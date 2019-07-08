page 6150640 "POS Info Card"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

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

