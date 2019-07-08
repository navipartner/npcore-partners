page 6014604 "NPR Attribute Card"
{
    // NPR4.11/TSA/20150422  CASE 209946 - Entity and Shortcut Attributes
    // NPR5.35/ANEN/20170608 CASE 276486 Support for lookup from table
    // NPR5.39/BR  /20180215 CASE 295322 Added field Import File Column No.
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Client Attribute Card';
    PageType = Card;
    SourceTable = "NPR Attribute";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field(Name;Name)
                {
                }
                field("Code Caption";"Code Caption")
                {
                }
                field("Filter Caption";"Filter Caption")
                {
                }
                field(Blocked;Blocked)
                {
                }
                field(Global;Global)
                {
                }
                field("Value Datatype";"Value Datatype")
                {
                }
                field("On Validate";"On Validate")
                {
                }
                field("On Format";"On Format")
                {
                }
                field("LookUp Table";"LookUp Table")
                {
                    ToolTip = 'LookUp Table overide manual set lookup value.';
                }
                field("LookUp Table Id";"LookUp Table Id")
                {
                }
                field("LookUp Table Name";"LookUp Table Name")
                {
                }
                field("LookUp Value Field Id";"LookUp Value Field Id")
                {
                }
                field("LookUp Value Field Name";"LookUp Value Field Name")
                {
                    Editable = false;
                }
                field("LookUp Description Field Id";"LookUp Description Field Id")
                {
                }
                field("LookUp Description Field Name";"LookUp Description Field Name")
                {
                    Editable = false;
                }
                field("Import File Column No.";"Import File Column No.")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Attribute ID")
            {
                Caption = 'Attribute ID';
                Image = LinkWithExisting;
                RunObject = Page "NPR Attribute IDs";
                RunPageLink = "Attribute Code"=FIELD(Code);
                RunPageView = SORTING("Attribute Code")
                              ORDER(Ascending);
            }
            action(Translations)
            {
                Caption = 'Translations';
                Image = Translation;
                RunObject = Page "NPR Attribute Translations";
                RunPageLink = "Attribute Code"=FIELD(Code);
                RunPageView = SORTING("Attribute Code","Language ID");
            }
            action(Values)
            {
                Caption = 'Values';
                Image = List;
                RunObject = Page "NPR Attribute Value Lookup";
                RunPageLink = "Attribute Code"=FIELD(Code);
                RunPageView = SORTING("Attribute Code");
            }
        }
    }
}

