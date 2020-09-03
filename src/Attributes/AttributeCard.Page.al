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
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Code Caption"; "Code Caption")
                {
                    ApplicationArea = All;
                }
                field("Filter Caption"; "Filter Caption")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field(Global; Global)
                {
                    ApplicationArea = All;
                }
                field("Value Datatype"; "Value Datatype")
                {
                    ApplicationArea = All;
                }
                field("On Validate"; "On Validate")
                {
                    ApplicationArea = All;
                }
                field("On Format"; "On Format")
                {
                    ApplicationArea = All;
                }
                field("LookUp Table"; "LookUp Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'LookUp Table overide manual set lookup value.';
                }
                field("LookUp Table Id"; "LookUp Table Id")
                {
                    ApplicationArea = All;
                }
                field("LookUp Table Name"; "LookUp Table Name")
                {
                    ApplicationArea = All;
                }
                field("LookUp Value Field Id"; "LookUp Value Field Id")
                {
                    ApplicationArea = All;
                }
                field("LookUp Value Field Name"; "LookUp Value Field Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("LookUp Description Field Id"; "LookUp Description Field Id")
                {
                    ApplicationArea = All;
                }
                field("LookUp Description Field Name"; "LookUp Description Field Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Import File Column No."; "Import File Column No.")
                {
                    ApplicationArea = All;
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
                RunPageLink = "Attribute Code" = FIELD(Code);
                RunPageView = SORTING("Attribute Code")
                              ORDER(Ascending);
            }
            action(Translations)
            {
                Caption = 'Translations';
                Image = Translation;
                RunObject = Page "NPR Attribute Translations";
                RunPageLink = "Attribute Code" = FIELD(Code);
                RunPageView = SORTING("Attribute Code", "Language ID");
            }
            action(Values)
            {
                Caption = 'Values';
                Image = List;
                RunObject = Page "NPR Attribute Value Lookup";
                RunPageLink = "Attribute Code" = FIELD(Code);
                RunPageView = SORTING("Attribute Code");
            }
        }
    }
}

